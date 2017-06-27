module Styles.Board exposing (..)

import Data.Moves.Check exposing (isInCurrentMove)
import Data.Tiles exposing (getTileType, growingOrder, isLeaving, leavingOrder, tileColorMap)
import Model exposing (..)
import Styles.Utils exposing (classes, emptyStyle, ms, px, translate)


boardOffsetTop : Model -> ( String, String )
boardOffsetTop model =
    let
        offset =
            (toFloat model.window.height - boardHeight model) / 2
    in
        ( "margin-top", px offset )


boardHeight : Model -> Float
boardHeight model =
    model.tileSettings.sizeY * toFloat model.boardSettings.sizeY


tileCoordsStyles : Model -> Coord -> List ( String, String )
tileCoordsStyles model coord =
    let
        ( y, x ) =
            tilePosition model coord
    in
        [ ( "transform", translate x y ) ]


tilePosition : Model -> Coord -> ( Float, Float )
tilePosition model ( y, x ) =
    ( (toFloat y) * model.tileSettings.sizeY
    , (toFloat x) * model.tileSettings.sizeX
    )


enteringStyles : Model -> Move -> List ( String, String )
enteringStyles model ( _, tile ) =
    case tile of
        Entering tile ->
            [ ( "animation", "bounce 0.4s ease" )
            ]

        _ ->
            []


growingStyles : Model -> Move -> List ( String, String )
growingStyles model ( coord, tile ) =
    let
        transitionDelay =
            ms <| ((growingOrder tile) % 5) * 70
    in
        case tile of
            Growing SeedPod _ ->
                [ ( "transform", "scale(4)" )
                , ( "opacity", "0" )
                , ( "transition", "0.4s ease" )
                , ( "transition-delay", transitionDelay )
                , ( "pointer-events", "none" )
                ]

            Growing Seed _ ->
                [ ( "animation", "bulge 0.5s ease" )
                ]

            _ ->
                []


fallingStyles : Model -> Move -> List ( String, String )
fallingStyles model ( _, tile ) =
    case tile of
        Falling tile distance ->
            [ ( "animation", "fall-" ++ (toString (distance - 1)) ++ " 0.5s ease" )
            , ( "animation-fill-mode", "forwards" )
            ]

        _ ->
            []


leavingStyles : Model -> Move -> List ( String, String )
leavingStyles model (( _, tile ) as move) =
    if isLeaving tile then
        [ ( "transition", "0.8s ease" )
        , ( "transition-delay", ms <| ((leavingOrder tile) % 5) * 80 )
        , ( "opacity", "0" )
        , handleExitDirection move model
        ]
    else
        []


handleExitDirection : Move -> Model -> ( String, String )
handleExitDirection ( coord, tile ) model =
    case tile of
        Leaving Rain _ ->
            ( "transform", exitLeft )

        Leaving Sun _ ->
            ( "transform", exitRight model )

        Leaving Seed _ ->
            ( "transform", exitTop model )

        _ ->
            emptyStyle


exitRight : Model -> String
exitRight model =
    let
        x =
            model.tileSettings.sizeX * (toFloat (model.boardSettings.sizeX - 1))
    in
        (translate x -80) ++ " scale(0.6)"


exitTop : Model -> String
exitTop model =
    let
        x =
            model.tileSettings.sizeX * ((toFloat model.boardSettings.sizeX) / 2) - (model.tileSettings.sizeX / 2)
    in
        (translate x -80) ++ " scale(0.6)"


exitLeft : String
exitLeft =
    (translate 0 -80) ++ " scale(0.6)"


moveTracerStyles : Model -> Move -> List ( String, String )
moveTracerStyles model (( coord, tile ) as move) =
    if isInCurrentMove move model.currentMove then
        [ ( "animation", "bulge-fade 0.8s ease" )
        , ( "animation-fill-mode", "forwards" )
        ]
    else if isLeaving tile && getTileType tile /= Just Seed then
        [ ( "display", "none" )
        ]
    else
        []


draggingStyles : Model -> Move -> List ( String, String )
draggingStyles model (( _, tile ) as move) =
    if isInCurrentMove move model.currentMove && model.moveType /= Just Square then
        [ ( "transform", "scale(0.5)" )
        , ( "transition", "0.5s ease" )
        ]
    else if model.moveType == Just Square then
        [ ( "transition", "0.5s ease" )
        ]
    else if isLeaving tile then
        [ ( "transform", "scale(0.7)" )
        , ( "transition", "0.5s ease" )
        ]
    else
        []


tileWidthHeightStyles : Model -> List ( String, String )
tileWidthHeightStyles { tileSettings } =
    [ ( "width", px tileSettings.sizeX )
    , ( "height", px tileSettings.sizeY )
    ]
