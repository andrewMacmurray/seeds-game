module Helpers.Css.Keyframes exposing
    ( Frames
    , KeyframeProp
    , KeyframesAnimation
    , backgroundColor
    , color
    , embed
    , map
    , map2
    , map3
    , opacity
    , render
    , rotateZ
    , scale
    , translateX
    , translateY
    )

import Helpers.Css.Format exposing (pc)
import Helpers.Css.Transform as Transform exposing (Transform, fromTransform)
import Html exposing (Html, node)
import Html.Attributes exposing (property)
import Json.Encode



{-
    -- example usage

    bugleSpinFade : Html msg
    bulgeSpinFade =
        embed
            [ { name = "bulge-spin-fade"
              , frames =
                    map3 ( scale, rotateZ, opacity )
                        [ ( 0, ( 1, 0, 1 ) )
                        , ( 100, ( 2.5, 90, 0 ) )
                        ]
              }
            ]

   -- <style>
   --     @keyframes bulge-spin-fade {
   --       0% { transform: scale(1) rotateZ(0deg); opacity: 1 }
   --       100% { transform: scale(2.5) rotateZ(90deg); opacity: 0 }
   --     }
   -- </style>
-}


type alias KeyframesAnimation =
    { name : String
    , frames : Frames
    }


type Frames
    = Frames (List ( Float, List KeyframeProp ))


type KeyframeProp
    = OpacityKey Float
    | ColorKey String
    | BackgroundColorKey String
    | TransformKey Transform



-- embeds animations in a `style` html node


embed : List KeyframesAnimation -> Html msg
embed animations =
    let
        r =
            animations
                |> List.map render
                |> String.join " "
                |> Json.Encode.string
    in
    node "style" [ property "textContent" r ] []



-- Functions for embedding plain values into KeyframeProps
-- Used in conjunction with map, map2, map3


backgroundColor : String -> KeyframeProp
backgroundColor =
    BackgroundColorKey


color : String -> KeyframeProp
color =
    ColorKey


translateX : Float -> KeyframeProp
translateX =
    TransformKey << Transform.translateX


translateY : Float -> KeyframeProp
translateY =
    TransformKey << Transform.translateY


rotateZ : Float -> KeyframeProp
rotateZ =
    TransformKey << Transform.rotateZ


scale : Float -> KeyframeProp
scale =
    TransformKey << Transform.scale


opacity : Float -> KeyframeProp
opacity =
    OpacityKey



-- Used to generate Opaque Frames to be rendered
-- Each maps a corresponding keyframe props to plain values


map3 :
    ( a -> KeyframeProp, b -> KeyframeProp, c -> KeyframeProp )
    -> List ( Float, ( a, b, c ) )
    -> Frames
map3 ( fa, fb, fc ) =
    Frames << List.map (\( step, ( a, b, c ) ) -> ( step, [ fa a, fb b, fc c ] ))


map2 :
    ( a -> KeyframeProp, b -> KeyframeProp )
    -> List ( Float, ( a, b ) )
    -> Frames
map2 ( fa, fb ) =
    Frames << List.map (\( step, ( a, b ) ) -> ( step, [ fa a, fb b ] ))


map : (a -> KeyframeProp) -> List ( Float, a ) -> Frames
map f =
    Frames << List.map (\( step, a ) -> ( step, [ f a ] ))



-- Function to render KeyframeAnimation with a name and a collection of steps


render : KeyframesAnimation -> String
render { name, frames } =
    String.join " "
        [ "@keyframes", name, "{", renderSteps frames, "}" ]


renderSteps : Frames -> String
renderSteps (Frames frames) =
    frames
        |> List.map renderStep
        |> String.join " "


renderStep : ( Float, List KeyframeProp ) -> String
renderStep ( step, props ) =
    String.join " "
        [ pc step, "{", renderProps props, "}" ]


renderProps : List KeyframeProp -> String
renderProps props =
    props
        |> List.partition isTransform
        |> combineProps
        |> String.join "; "


combineProps : ( List KeyframeProp, List KeyframeProp ) -> List String
combineProps ( transforms, props ) =
    let
        renderedProps =
            List.map renderProp props
    in
    transforms
        |> combineTransforms
        |> Maybe.map (\transform -> transform :: renderedProps)
        |> Maybe.withDefault renderedProps


combineTransforms : List KeyframeProp -> Maybe String
combineTransforms transforms =
    if List.isEmpty transforms then
        Nothing

    else
        transforms
            |> List.map renderTransform
            |> String.join " "
            |> (++) "transform: "
            |> Just


renderProp : KeyframeProp -> String
renderProp prop =
    case prop of
        OpacityKey n ->
            "opacity: " ++ Debug.toString n

        ColorKey c ->
            "color: " ++ c

        BackgroundColorKey c ->
            "background-color: " ++ c

        _ ->
            ""


renderTransform : KeyframeProp -> String
renderTransform prop =
    case prop of
        TransformKey t ->
            fromTransform t

        _ ->
            ""


isTransform : KeyframeProp -> Bool
isTransform prop =
    case prop of
        TransformKey _ ->
            True

        _ ->
            False
