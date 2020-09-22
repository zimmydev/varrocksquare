module Config.App exposing (logEffect, logMsg, messagePreviewLength, problem, verbose)


messagePreviewLength : Int
messagePreviewLength =
    -- The max length of message alert previews
    50



-- DEBUGGING


verboseIsActive : Bool
verboseIsActive =
    True


logMsg : List a -> a -> a
logMsg =
    verbose "Received a message"


logEffect : List a -> a -> a
logEffect =
    verbose "Performing an effect"


verbose : String -> List a -> a -> a
verbose label ignored item =
    if verboseIsActive && not (List.member item ignored) then
        Debug.log ("[VERBOSE] " ++ label) item

    else
        identity item


problem : String -> b -> a -> b
problem label replacement item =
    item
        |> Debug.log ("[PROBLEM] " ++ label)
        |> always replacement
