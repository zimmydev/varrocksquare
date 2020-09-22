module Config.App exposing (logEffect, logMsg, messagePreviewLength)


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
    log "Received a message"


logEffect : List a -> a -> a
logEffect =
    log "Performing an effect"


log : String -> List a -> a -> a
log label ignored item =
    if verbose && not (List.member item ignored) then
        item
            |> Debug.log ("[VERBOSE MODE] " ++ label)

    else
        identity item
