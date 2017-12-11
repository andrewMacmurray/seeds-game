module Views.Hub.Info exposing (..)

import Data.Color exposing (gold, purple, seedPodGradient, white)
import Data.Hub.Progress exposing (getLevelConfig, getLevelNumber)
import Helpers.Html exposing (emptyProperty)
import Helpers.Style exposing (animationStyle, background, backgroundColor, classes, color, fillModeStyle, marginTop, transformStyle, transitionStyle, translateY, widthStyle)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Config.Level exposing (allLevels)
import Scenes.Hub.Types as Hub exposing (..)
import Views.Seed.All exposing (renderSeed)


info : Hub.Model -> Html Hub.Msg
info model =
    case model.infoWindow of
        Hidden ->
            span [] []

        Visible ( world, level ) ->
            let
                config =
                    getLevelConfig ( world, level ) model
            in
                infoContainer model.infoWindow
                    [ div
                        [ class "pa3 br3 tc relative"
                        , style
                            [ background seedPodGradient
                            , color white
                            , animationStyle "elastic-bounce-in 2s linear"
                            , widthStyle 380
                            ]
                        , onClick <| StartLevel ( world, level )
                        ]
                        (infoContent ( world, level ) config model)
                    ]

        Leaving ( world, level ) ->
            let
                config =
                    getLevelConfig ( world, level ) model
            in
                infoContainer model.infoWindow
                    [ div
                        [ class "pa3 br3 tc relative"
                        , style
                            [ background seedPodGradient
                            , color white
                            , widthStyle 380
                            , animationStyle "exit-down 0.7s cubic-bezier(0.93, -0.36, 0.57, 0.96)"
                            , fillModeStyle "forwards"
                            ]
                        ]
                        (infoContent ( world, level ) config model)
                    ]


infoContent : LevelProgress -> ( WorldData, LevelData ) -> Hub.Model -> List (Html Hub.Msg)
infoContent ( world, level ) ( worldData, levelData ) model =
    [ p [] [ text <| toString <| getLevelNumber ( world, level ) allLevels ]
    , div [ style [ widthStyle 35 ], class "center" ] [ renderSeed worldData.seedType ]
    , p [] [ text "collect the seeds" ]
    , p [ class "tracked-mega", style [ marginTop 50 ] ] [ text "PLAY" ]
    ]


handleHideInfo : Hub.Model -> Attribute Hub.Msg
handleHideInfo model =
    case model.infoWindow of
        Hidden ->
            emptyProperty

        _ ->
            onClick HideInfo


infoContainer : InfoWindow -> List (Html Hub.Msg) -> Html Hub.Msg
infoContainer infoWindow =
    case infoWindow of
        Leaving _ ->
            div [ classes [ "touch-disabled", infoContainerBaseClasses ] ]

        _ ->
            div [ class infoContainerBaseClasses ]


infoContainerBaseClasses : String
infoContainerBaseClasses =
    "pointer fixed top-0 bottom-0 left-0 right-0 flex items-center justify-center z-3 ph3"
