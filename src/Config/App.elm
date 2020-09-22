module Config.App exposing (log, logEffect, logMsg, messagePreviewLength)


messagePreviewLength : Int
messagePreviewLength =
    -- The max length of message alert previews
    50



-- DEBUGGING


verbose : Bool
verbose =
    True


logMsg : List a -> a -> a
logMsg =
    logIgnoring "Received a message"


logEffect : List a -> a -> a
logEffect =
    logIgnoring "Performing an effect"


logIgnoring : String -> List a -> a -> a
logIgnoring label ignored item =
    if verbose && not (List.member item ignored) then
        item
            |> Debug.log ("[VERBOSE] " ++ label)

    else
        identity item


log : String -> a -> a
log label =
    Debug.log ("[DEBUG] " ++ label)
