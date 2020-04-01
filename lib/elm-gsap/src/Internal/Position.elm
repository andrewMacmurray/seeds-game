module Internal.Position exposing
    ( Position
    , attribute
    , encode
    , shiftBy
    , time
    )

import Html exposing (Attribute)
import Html.Attributes as Attribute
import Json.Encode as Encode



-- Position


type Position
    = Time Float
    | ShiftForwards Float
    | ShiftBackwards Float



-- Construct


time : Float -> Position
time =
    Time


shiftBy : Float -> Position
shiftBy n =
    if n == 0 then
        Time 0

    else if n > 0 then
        ShiftForwards n

    else
        ShiftBackwards (abs n)



-- Attribute


encode : Position -> Encode.Value
encode =
    positionToString >> Encode.string


attribute : Position -> Attribute msg
attribute =
    positionToString >> Attribute.attribute "position"


positionToString : Position -> String
positionToString position_ =
    case position_ of
        Time time_ ->
            String.fromFloat time_

        ShiftForwards by ->
            "+=" ++ String.fromFloat by

        ShiftBackwards by ->
            "-=" ++ String.fromFloat by
