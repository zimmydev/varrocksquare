module Author exposing (Author(..), FollowedUser, UnfollowedUser)

import LoggedInUser exposing (LoggedInUser)
import Profile exposing (Profile)
import User exposing (User)
import Username exposing (Username)


type Author
    = Following FollowedUser
    | NotFollowing UnfollowedUser
    | Me LoggedInUser


type FollowedUser
    = Followed User


type UnfollowedUser
    = Unfollowed User



-- Info on Author


username : Author -> Username
username author =
    case author of
        Following (Followed user) ->
            User.username user

        NotFollowing (Unfollowed user) ->
            User.username user

        Me loggedInUser ->
            LoggedInUser.username loggedInUser


profile : Author -> Profile
profile author =
    case author of
        Following (Followed user) ->
            User.profile user

        NotFollowing (Unfollowed user) ->
            User.profile user

        Me loggedInUser ->
            LoggedInUser.profile loggedInUser



-- Following


follow : UnfollowedUser -> FollowedUser
follow (Unfollowed user) =
    Followed user


unfollow : FollowedUser -> UnfollowedUser
unfollow (Followed user) =
    Unfollowed user
