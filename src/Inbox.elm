module Inbox exposing (Inbox, Message, debug, message, messageCount, sender)

import Username exposing (Username)


type alias Inbox =
    List Message


type Message
    = Message Username String



-- Info on Inbox


messageCount : Inbox -> Int
messageCount =
    List.foldl (\_ count -> count + 1) 0



-- Info on Messages


sender : Message -> Username
sender (Message uname _) =
    uname


message : Message -> String
message (Message _ mess) =
    mess



-- Debugging an Inbox


debug : Inbox
debug =
    [ Message Username.debug "Test message 1"
    , Message Username.debug "Test message 2"
    , Message Username.debug "Test message 3"
    ]
