module Inbox exposing (Inbox, Message, debug, message, messageCount, sender)

import Config.Links exposing (Href)
import Username exposing (Username)



-- INBOX


type alias Inbox =
    List Message


messageCount : Inbox -> Int
messageCount =
    List.foldl (\_ count -> count + 1) 0



-- MESSAGE


type Message
    = Message Username String


sender : Message -> Username
sender (Message uname _) =
    uname


message : Message -> String
message (Message _ mess) =
    mess



-- DEBUG


debug : Inbox
debug =
    [ Message (Username.debug "MessageSender1") "Test message 1"
    , Message (Username.debug "MessageSender2") "Test message 2"
    , Message (Username.debug "MessageSender3") "Test message 3"
    ]
