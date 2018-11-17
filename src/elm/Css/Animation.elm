module Css.Animation exposing
    ( Frame
    , Keyframes
    , Option
    , Property
    , animation
    , count
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


type Option
    = Option Style


animation : String -> Int -> List Option -> Style
animation name duration options =
    [ [ animationName name
      , animationDuration duration
      , fillForwards
      ]
    , toStyles options
    ]
        |> List.concat
        |> Style.compose


delay : Int -> Option
delay duration =
    option <| animationDelay duration


ease : Option
ease =
    option <| animationTimingFunction "ease"


easeOut : Option
easeOut =
    option <| animationTimingFunction "ease-out"


linear : Option
linear =
    option <| animationTimingFunction "linear"


cubicBezier : Float -> Float -> Float -> Float -> Option
cubicBezier a b c d =
    option <| animationTimingFunction (cubicBezier_ a b c d)


infinite : Option
infinite =
    option <| animationIterationCount "infinite"


count : Int -> Option
count n =
    option <| animationIterationCount <| String.fromInt n



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


option : Style -> Option
option =
    Option


toStyles : List Option -> List Style
toStyles =
    List.map (\(Option s) -> s)



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


transform : List Transform -> Property
transform =
    Property << Style.transform


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
    join [ pc n, "{", renderProperties props, "}" ]


renderProperties : List Property -> String
renderProperties =
    List.map getStyle >> Style.renderStyles_


getStyle : Property -> Style
getStyle (Property s) =
    s


join : List String -> String
join =
    String.join " "
