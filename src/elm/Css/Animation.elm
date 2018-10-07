module Css.Animation exposing
    ( AnimationOption
    , Frame
    , KeyframeProperty
    , KeyframesAnimation
    , animation
    , cubicBezier
    , delay
    , ease
    , easeOut
    , embed
    , frame
    , infinite
    , keyframes
    , linear
    , opacity
    , transform
    )

import Css.Style as Style exposing (Style)
import Css.Transform exposing (Transform)
import Css.Unit exposing (cubicBezier_, ms, pc)
import Html exposing (Html)
import Html.Attributes
import Json.Encode



-- Animation Style
-- animatedDiv =
--     div
--         [ style [ animation "fade-in" 500 [ delay 500, infinite ] ] ]
--         []


type AnimationOption
    = AnimationOption Style


animation : String -> Int -> List AnimationOption -> Style
animation name duration options =
    [ [ animationName name
      , animationDuration duration
      , fillForwards
      ]
    , toStyles options
    ]
        |> List.concat
        |> Style.compose


delay : Int -> AnimationOption
delay duration =
    animationOption <| animationDelay duration


ease : AnimationOption
ease =
    animationOption <| animationTimingFunction "ease"


easeOut : AnimationOption
easeOut =
    animationOption <| animationTimingFunction "ease-out"


linear : AnimationOption
linear =
    animationOption <| animationTimingFunction "linear"


cubicBezier : Float -> Float -> Float -> Float -> AnimationOption
cubicBezier a b c d =
    animationOption <| animationTimingFunction (cubicBezier_ a b c d)


infinite : AnimationOption
infinite =
    animationOption <| animationIterationCount "infinite"



-- Styles


animationName : String -> Style
animationName =
    Style.property "animation-name"


animationDuration : Int -> Style
animationDuration n =
    Style.property "animation-duration" <| ms <| toFloat n


animationDelay : Int -> Style
animationDelay n =
    Style.property "animation-delay" <| ms <| toFloat n


animationTimingFunction : String -> Style
animationTimingFunction =
    Style.property "animation-timing-function"


animationIterationCount : String -> Style
animationIterationCount =
    Style.property "animation-iteration-count"


fillForwards : Style
fillForwards =
    Style.property "animation-fill-mode" "forwards"


animationOption : Style -> AnimationOption
animationOption =
    AnimationOption


toStyles : List AnimationOption -> List Style
toStyles =
    List.map (\(AnimationOption s) -> s)



-- Keyframes
-- myAnimation =
--     keyframes "fade-out-slide-down"
--         [ frame 0
--             [ opacity 1, transform [ Transform.translateY 0 ] ]
--         , frame 100
--             [ opacity 0, transform [ Transform.translateY 300 ] ]
--         ]


type KeyframesAnimation
    = KeyframesAnimation String (List Frame)


type Frame
    = Frame Float (List KeyframeProperty)


type KeyframeProperty
    = KeyframeProperty Style



-- Construct Keyframes


keyframes : String -> List Frame -> KeyframesAnimation
keyframes =
    KeyframesAnimation


frame : Float -> List KeyframeProperty -> Frame
frame =
    Frame


transform : List Transform -> KeyframeProperty
transform =
    KeyframeProperty << Style.transform


opacity : Float -> KeyframeProperty
opacity =
    KeyframeProperty << Style.opacity



-- Embed Keyframes


embed : List KeyframesAnimation -> Html msg
embed frames =
    let
        renderedKeyframes =
            frames
                |> List.map render
                |> join
                |> Json.Encode.string
    in
    Html.node "style" [ Html.Attributes.property "textContent" renderedKeyframes ] []


render : KeyframesAnimation -> String
render (KeyframesAnimation name frames) =
    join [ "@keyframes", name, "{", renderFrames frames, "}" ]


renderFrames : List Frame -> String
renderFrames =
    List.map renderFrame >> join


renderFrame : Frame -> String
renderFrame (Frame n props) =
    join [ pc n, "{", renderProps props, "}" ]


renderProps : List KeyframeProperty -> String
renderProps =
    List.map getStyle >> Style.renderStyles_


getStyle : KeyframeProperty -> Style
getStyle (KeyframeProperty s) =
    s


join : List String -> String
join =
    String.join " "
