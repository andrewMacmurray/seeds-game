module Internal.Ease exposing
    ( Amplitude
    , Config(..)
    , Direction(..)
    , Ease(..)
    , ElasticConfig
    , Overshoot
    , Period
    , encode
    )

import Json.Encode as Encode



-- Ease


type Ease
    = Elastic (Config ElasticConfig) Direction
    | Back (Config Overshoot) Direction
    | Bounce Direction
    | Power1 Direction
    | Power2 Direction
    | Power3 Direction
    | Power4 Direction
    | Circ Direction
    | Quad Direction
    | Quart Direction
    | Quint Direction
    | Sine Direction
    | Expo Direction
    | Linear


type Direction
    = In
    | Out
    | InOut


type Config custom
    = Default
    | Custom custom


type alias ElasticConfig =
    { amplitude : Amplitude
    , period : Period
    }


type alias Overshoot =
    Float


type alias Period =
    Float


type alias Amplitude =
    Float



-- Encode


encode : Ease -> Encode.Value
encode =
    easeToString >> Encode.string


easeToString : Ease -> String
easeToString ease =
    case ease of
        Elastic direction config ->
            elasticToString direction config

        Back direction config ->
            backToString direction config

        Bounce direction ->
            toDirection "bounce" direction

        Power1 direction ->
            toDirection "power1" direction

        Power2 direction ->
            toDirection "power2" direction

        Power3 direction ->
            toDirection "power3" direction

        Power4 direction ->
            toDirection "power4" direction

        Circ direction ->
            toDirection "circ" direction

        Quad direction ->
            toDirection "quad" direction

        Quart direction ->
            toDirection "quart" direction

        Quint direction ->
            toDirection "quint" direction

        Sine direction ->
            toDirection "sine" direction

        Expo direction ->
            toDirection "expo" direction

        Linear ->
            "none"


elasticToString : Config ElasticConfig -> Direction -> String
elasticToString config direction =
    case config of
        Default ->
            toDirection "elastic" direction

        Custom c ->
            toDirection "elastic" direction ++ toConfig [ c.amplitude, c.period ]


backToString : Config Overshoot -> Direction -> String
backToString config direction =
    case config of
        Default ->
            toDirection "back" direction

        Custom overshoot ->
            toDirection "back" direction ++ toConfig [ overshoot ]


toDirection : String -> Direction -> String
toDirection ease direction =
    ease ++ directionToString direction


directionToString : Direction -> String
directionToString direction =
    case direction of
        In ->
            ".in"

        Out ->
            ".out"

        InOut ->
            ".inOut"


toConfig : List Float -> String
toConfig xs =
    "(" ++ (xs |> List.map String.fromFloat |> String.join ", ") ++ ")"
