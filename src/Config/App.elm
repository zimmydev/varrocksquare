module Config.App exposing (logEffect, logInfo, logMsg, logProblem, messagePreviewLength, startUser)

{-| Configurations that affect the entire app.
-}

import LoggedInUser exposing (LoggedInUser)


{-| The max length of message alert previews.
-}
messagePreviewLength : Int
messagePreviewLength =
    50



-- Debugging


startUser : Maybe LoggedInUser
startUser =
    Just LoggedInUser.debug



-- Debug Logging


allowedLogs : { verbose : Bool, logic : Bool }
allowedLogs =
    -- Debug message type flags
    { verbose = True
    , logic = True
    }


logInfo : List a -> String -> a -> a
logInfo =
    log allowedLogs.verbose "info"


logMsg : List a -> a -> a
logMsg ignored =
    logLogic ignored "Received a message"


logEffect : List a -> a -> a
logEffect ignored =
    logLogic ignored "Performing an effect"


logProblem : String -> b -> a -> b
logProblem output replacement item =
    log True "problem" [] output item
        |> always replacement



-- Debug Logging (Helpers)


tagString : String -> String -> String
tagString tag string =
    "[" ++ String.toUpper tag ++ "] " ++ string


log : Bool -> String -> List a -> String -> a -> a
log enabled tag ignored output item =
    if enabled && not (List.member item ignored) then
        item |> Debug.log (tagString tag output)

    else
        item


logLogic : List a -> String -> a -> a
logLogic =
    log allowedLogs.logic "logic"
