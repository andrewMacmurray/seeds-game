module Views.Level.Styles exposing (..)

import Data.Moves.Check exposing (isInCurrentMove)
import Data.Tiles exposing (getTileType, growingOrder, isLeaving, leavingOrder, tileColorMap)
import Helpers.Style exposing (classes, emptyStyle, ms, px, scale, translate, translateScale)
import Model exposing (..)


boardMarginTop : Model -> Style
boardMarginTop model =
    ( "margin-top", px <| boardOffsetTop model )


boardOffsetTop : Model -> Int
boardOffsetTop model =
    (model.window.height - boardHeight model) // 2 + model.topBarHeight // 2


boardHeight : Model -> Int
boardHeight model =
    round model.tileSettings.sizeY * model.boardSettings.sizeY


boardWidth : Model -> Int
boardWidth { tileSettings, boardSettings } =
    round tileSettings.sizeX * boardSettings.sizeX


tileCoordsStyles : Model -> Coord -> List Style
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


enteringStyles : Model -> Move -> List Style
enteringStyles model ( _, tile ) =
    case tile of
        Entering tile ->
            [ ( "animation", "bounce 0.4s ease" )
            ]

        _ ->
            []


growingStyles : Model -> Move -> List Style
growingStyles model ( coord, tile ) =
    let
        transitionDelay =
            ms <| ((growingOrder tile) % 5) * 70
    in
        case tile of
            Growing SeedPod _ ->
                [ ( "transform", scale 4 )
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


fallingStyles : Model -> Move -> List Style
fallingStyles model ( _, tile ) =
    case tile of
        Falling tile distance ->
            [ ( "animation", "fall-" ++ (toString (distance - 1)) ++ " 0.5s ease" )
            , ( "animation-fill-mode", "forwards" )
            ]

        _ ->
            []


leavingStyles : Model -> Move -> List Style
leavingStyles model (( _, tile ) as move) =
    if isLeaving tile then
        [ ( "transition", "0.8s ease" )
        , ( "transition-delay", ms <| ((leavingOrder tile) % 5) * 80 )
        , ( "opacity", "0.2" )
        , handleExitDirection move model
        ]
    else
        []


handleExitDirection : Move -> Model -> Style
handleExitDirection ( coord, tile ) model =
    case tile of
        Leaving Rain _ ->
            ( "transform", exitLeft model )

        Leaving Sun _ ->
            ( "transform", exitRight model )

        Leaving Seed _ ->
            ( "transform", exitTop model )

        _ ->
            emptyStyle


exitRight : Model -> String
exitRight model =
    translateScale (exitRightXdistance model) -(exitYdistance model) 0.5


exitTop : Model -> String
exitTop model =
    translateScale (exitTopXdistance model) -(exitYdistance model) 0.6


exitLeft : Model -> String
exitLeft model =
    translateScale 0 -(exitYdistance model) 0.5


exitRightXdistance : Model -> Int
exitRightXdistance model =
    round model.tileSettings.sizeX * (model.boardSettings.sizeX - 1)


exitTopXdistance : Model -> Int
exitTopXdistance { tileSettings, boardSettings } =
    round tileSettings.sizeX * (boardSettings.sizeX // 2) - (round tileSettings.sizeX // 2)


exitYdistance : Model -> Int
exitYdistance model =
    (boardOffsetTop model) - 9


moveTracerStyles : Model -> Move -> List Style
moveTracerStyles model (( coord, tile ) as move) =
    if isInCurrentMove move model.currentMove then
        [ ( "animation", "bulge-fade 0.8s ease" )
        , ( "animation-fill-mode", "forwards" )
        ]
    else if isLeaving tile then
        [ ( "display", "none" )
        ]
    else
        []


draggingStyles : Model -> Move -> List Style
draggingStyles model (( _, tile ) as move) =
    if isInCurrentMove move model.currentMove && model.moveType /= Just Square then
        [ ( "transform", "scale(0.5)" )
        , ( "transition", "0.5s ease" )
        ]
    else if model.moveType == Just Square then
        [ ( "transition", "0.5s ease" ) ]
    else if isLeaving tile then
        [ ( "transition", "0.1s ease" )
        ]
    else
        []


tileWidthHeightStyles : Model -> List Style
tileWidthHeightStyles { tileSettings } =
    [ ( "width", px tileSettings.sizeX )
    , ( "height", px tileSettings.sizeY )
    ]
