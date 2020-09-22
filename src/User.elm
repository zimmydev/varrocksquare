module User exposing (FollowedUser, UnfollowedUser, User(..), profile, username)

import LoggedInUser exposing (LoggedInUser)
import Profile exposing (Profile)
import Username exposing (Username)


type User
    = IsFollowing FollowedUser
    | IsNotFollowing UnfollowedUser
    | IsSelf LoggedInUser


type FollowedUser
    = FollowedUser Username Profile


type UnfollowedUser
    = UnfollowedUser Username Profile



-- Info on User


username : User -> Username
username user =
    case user of
        IsFollowing (FollowedUser name _) ->
            name

        IsNotFollowing (UnfollowedUser name _) ->
            name

        IsSelf loggedInUser ->
            LoggedInUser.username loggedInUser


profile : User -> Profile
profile user =
    case user of
        IsFollowing (FollowedUser _ prof) ->
            prof

        IsNotFollowing (UnfollowedUser _ prof) ->
            prof

        IsSelf loggedInUser ->
            LoggedInUser.profile loggedInUser
