module Css.Style exposing
    ( Style
    , concat
    , opacity
    , property
    , svg
    , transform
    , transformOrigin
    )

import Svg
import Svg.Attributes
import Utils.Transform as Transform exposing (Transform)


type Style
    = Property String String
    | Raw String


property : String -> String -> Style
property =
    Property


concat : List Style -> Style
concat =
    Raw << renderStyles_



-- Svg


svg : List Style -> Svg.Attribute msg
svg =
    Svg.Attributes.style << renderStyles_



-- Render Styles to Raw String


renderStyles_ : List Style -> String
renderStyles_ =
    List.filter isNonEmpty
        >> List.map styleToString_
        >> String.join ";"


styleToString_ : Style -> String
styleToString_ s =
    case s of
        Property prop val ->
            prop ++ ":" ++ val

        Raw val ->
            val


isNonEmpty : Style -> Bool
isNonEmpty s =
    case s of
        Property prop val ->
            nonEmpty prop && nonEmpty val

        Raw _ ->
            True


nonEmpty : String -> Bool
nonEmpty =
    String.trim >> String.isEmpty >> not



-- Properties


transform : List Transform -> Style
transform transforms =
    property "transform" (Transform.toString transforms)


transformOrigin : String -> Style
transformOrigin =
    property "transform-origin"


opacity : Float -> Style
opacity o =
    property "opacity" (String.fromFloat o)
