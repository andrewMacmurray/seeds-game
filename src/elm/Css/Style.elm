module Css.Style exposing
    ( Style
    , compose
    , opacity
    , property
    , style
    , svg
    , transform
    , transformOrigin
    , width
    )

import Css.Transform as Transform exposing (Transform)
import Html
import Html.Attributes
import Svg
import Svg.Attributes
import Utils.Unit as Unit


type Style
    = Property String String
    | Raw String


property : String -> String -> Style
property =
    Property


compose : List Style -> Style
compose =
    Raw << renderStyles_



-- Html


style : List Style -> Html.Attribute msg
style =
    Html.Attributes.attribute "style" << renderStyles_



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
    property "transform" (Transform.render transforms)


transformOrigin : String -> Style
transformOrigin =
    property "transform-origin"


width : Float -> Style
width n =
    property "width" (Unit.px (round n))


opacity : Float -> Style
opacity o =
    property "opacity" (String.fromFloat o)



-- Class Helpers
