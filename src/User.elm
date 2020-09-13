module User exposing (FollowedUser, UnfollowedUser, User(..), profile, username)

import Credentials exposing (Credentials)
import Profile exposing (Profile)
import Username exposing (Username)



-- TYPES


type User
    = IsFollowing FollowedUser
    | IsNotFollowing UnfollowedUser
    | IsSelf Credentials Profile


type FollowedUser
    = FollowedUser Username Profile


type UnfollowedUser
    = UnfollowedUser Username Profile



-- INFO


username : User -> Username
username user =
    case user of
        IsFollowing (FollowedUser name _) ->
            name

        IsNotFollowing (UnfollowedUser name _) ->
            name

        IsSelf cred _ ->
            Credentials.username cred


profile : User -> Profile
profile user =
    case user of
        IsFollowing (FollowedUser _ prof) ->
            prof

        IsNotFollowing (UnfollowedUser _ prof) ->
            prof

        IsSelf _ prof ->
            prof
