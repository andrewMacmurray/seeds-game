module Utils.Color exposing (toString)

import Element



-- To RGB String


toString : Element.Color -> String
toString color =
    let
        c =
            Element.toRgb color
    in
    String.concat
        [ "rgb("
        , String.fromInt (to255RgbValue c.red)
        , ", "
        , String.fromInt (to255RgbValue c.green)
        , ", "
        , String.fromInt (to255RgbValue c.blue)
        , ")"
        ]


to255RgbValue : Float -> Int
to255RgbValue value =
    if value <= 1 then
        round (value * 255)

    else
        round value
