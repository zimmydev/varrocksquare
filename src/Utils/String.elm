module Utils.String exposing (abridge)


abridge : Int -> String -> String
abridge maxLength string =
    let
        optionalEllipses s =
            if String.length string > maxLength then
                s ++ "…"

            else
                s
    in
    string
        |> String.left maxLength
        |> String.trimRight
        |> optionalEllipses
