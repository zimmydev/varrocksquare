module Author exposing (Author(..), FollowedUser, UnfollowedUser, decoder, profile, user, username)

import Json.Decode as Decode exposing (Decoder, nullable)
import Json.Decode.Pipeline exposing (custom, optional, required)
import LoggedInUser exposing (LoggedInUser)
import Profile exposing (Profile)
import Session exposing (Session(..))
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
        decodeAuthor ( isFollowing, author ) =
            case session of
                Guest ->
                    Decode.succeed <| CantFollow (Unfollowable author)

                LoggedIn loggedInUser ->
                    if LoggedInUser.username loggedInUser == User.username author then
                        Decode.succeed <| CantFollow (Unfollowable author)

                    else if isFollowing then
                        Decode.succeed <| Following (Followed author)

                    else
                        Decode.succeed <| NotFollowing (Unfollowed author)
    in
    Decode.succeed Tuple.pair
        |> optional "following" Decode.bool False
        |> custom User.decoder
        |> Decode.andThen decodeAuthor



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
