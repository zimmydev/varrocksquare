module Author exposing (Author(..), FollowedUser, UnfollowedUser, decoder, profile, user, username)

import Json.Decode as Decode exposing (Decoder, nullable)
import Json.Decode.Pipeline exposing (custom, optional, required)
import LoggedInUser exposing (LoggedInUser)
import Profile exposing (Profile)
import Session exposing (Session)
import User exposing (User)
import Username exposing (Username)


type Author
    = Following FollowedUser
    | NotFollowing UnfollowedUser
    | CantFollow UnfollowableUser


type FollowedUser
    = Followed User


type UnfollowedUser
    = Unfollowed User


type UnfollowableUser
    = Unfollowable User



-- Obtaining an Author


decoder : Session -> Decoder Author
decoder session =
    let
        authorDecoder ( isFollowing, usr ) =
            Session.withLoggedInUser session
                { guest = Decode.succeed <| CantFollow (Unfollowable usr)
                , loggedIn =
                    \loggedInUser ->
                        case isFollowing of
                            Just True ->
                                Decode.succeed <| Following (Followed usr)

                            Just False ->
                                Decode.succeed <| NotFollowing (Unfollowed usr)

                            Nothing ->
                                if User.username usr == LoggedInUser.username loggedInUser then
                                    Decode.succeed <| CantFollow (Unfollowable usr)

                                else
                                    Decode.fail "Author is definitely someone else but I encountered a missing or null `following` field."
                }
    in
    Decode.succeed Tuple.pair
        |> optional "following" (nullable Decode.bool) Nothing
        |> custom User.decoder
        |> Decode.andThen authorDecoder



-- Info on Author


user : Author -> User
user author =
    case author of
        Following (Followed usr) ->
            usr

        NotFollowing (Unfollowed usr) ->
            usr

        CantFollow (Unfollowable usr) ->
            usr


username : Author -> Username
username author =
    user author
        |> User.username


profile : Author -> Profile
profile author =
    user author
        |> User.profile



-- Following


follow : UnfollowedUser -> FollowedUser
follow (Unfollowed usr) =
    Followed usr


unfollow : FollowedUser -> UnfollowedUser
unfollow (Followed usr) =
    Unfollowed usr
