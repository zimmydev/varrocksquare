module Config.App exposing (logEffect, logInfo, logMsg, logProblem, messagePreviewLength)

{-| Configurations that affect the entire app.
-}


{-| The max length of message alert previews.
-}
messagePreviewLength : Int
messagePreviewLength =
    50



-- Debug Logging


allowedLogs =
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
