module Css.Animation exposing
    ( Frame
    , Keyframes
    , Property
    , animation
    , embed
    , frame
    , keyframes
    , opacity
    )

import Css.Style as Style exposing (Style)
import Html exposing (Html)
import Html.Attributes
import Json.Encode
import Utils.Unit as Unit



-- Animation Style
-- animatedDiv =
--     div
--         [ style [ animation "fade-in" 500 [ delay 500, infinite ] ] ]
--         []


animation : String -> Int -> Style
animation name duration =
    Style.compose
        [ animationName name
        , animationDuration duration
        , fillForwards
        ]



-- Styles


animationName : String -> Style
animationName =
    Style.property "animation-name"


animationDuration : Int -> Style
animationDuration n =
    Style.property "animation-duration" (Unit.ms (toFloat n))


fillForwards : Style
fillForwards =
    Style.property "animation-fill-mode" "forwards"



-- Keyframes
-- myAnimation =
--     keyframes "fade-out-slide-down"
--         [ frame 0
--             [ opacity 1, transform [ Transform.translateY 0 ] ]
--         , frame 100
--             [ opacity 0, transform [ Transform.translateY 300 ] ]
--         ]


type Keyframes
    = Keyframes String (List Frame)


type Frame
    = Frame Float (List Property)


type Property
    = Property Style



-- Construct Keyframes


keyframes : String -> List Frame -> Keyframes
keyframes =
    Keyframes


frame : Float -> List Property -> Frame
frame =
    Frame


opacity : Float -> Property
opacity =
    Property << Style.opacity



-- Embed Keyframes


embed : List Keyframes -> Html msg
embed frames =
    let
        renderedKeyframes =
            frames
                |> List.map render
                |> join
                |> Json.Encode.string
    in
    Html.node "style" [ Html.Attributes.property "textContent" renderedKeyframes ] []


render : Keyframes -> String
render (Keyframes name frames) =
    join [ "@keyframes", name, "{", renderFrames frames, "}" ]


renderFrames : List Frame -> String
renderFrames =
    List.map renderFrame >> join


renderFrame : Frame -> String
renderFrame (Frame n props) =
    join [ Unit.pc n, "{", renderProperties props, "}" ]


renderProperties : List Property -> String
renderProperties =
    List.map getStyle >> Style.renderStyles_


getStyle : Property -> Style
getStyle (Property s) =
    s


join : List String -> String
join =
    String.join " "
