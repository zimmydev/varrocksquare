module Utils.String exposing (abridge, surround)


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


surround : String -> String -> String
surround left string =
    let
        right =
            case left of
                "(" ->
                    ")"

                "[" ->
                    "]"

                "{" ->
                    "}"

                "<" ->
                    ">"

                other ->
                    other
    in
    left ++ string ++ right
