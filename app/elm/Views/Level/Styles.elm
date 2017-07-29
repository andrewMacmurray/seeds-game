module Views.Level.Styles exposing (..)

import Data.Block exposing (getTileState)
import Data.Tile exposing (getTileType, growingOrder, isDragging, isLeaving, leavingOrder, tileColorMap)
import Helpers.Style exposing (animationStyle, classes, displayStyle, emptyStyle, fillModeStyle, heightStyle, ms, opacityStyle, px, scale, size, transformStyle, transitionDelayStyle, transitionStyle, translate, translateScale, widthStyle)
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
        [ transformStyle <| translate x y ]


tilePosition : Model -> Coord -> ( Float, Float )
tilePosition model ( y, x ) =
    ( (toFloat y) * model.tileSettings.sizeY
    , (toFloat x) * model.tileSettings.sizeX
    )


wallStyles : Move -> List Style
wallStyles ( _, block ) =
    case block of
        Wall ->
            [ ( "background-color", "#f6e06f" )
            , widthStyle 45
            , heightStyle 45
            ]

        _ ->
            []


enteringStyles : Move -> List Style
enteringStyles ( _, block ) =
    let
        tile =
            getTileState block
    in
        case tile of
            Entering tile ->
                [ animationStyle "bounce 0.4s ease"
                ]

            _ ->
                []


growingStyles : Move -> List Style
growingStyles ( coord, block ) =
    let
        tile =
            getTileState block

        transitionDelay =
            ((growingOrder block) % 5) * 70
    in
        case tile of
            Growing SeedPod _ ->
                [ transformStyle <| scale 4
                , transitionStyle "0.4s ease"
                , opacityStyle 0
                , transitionDelayStyle transitionDelay
                , ( "pointer-events", "none" )
                ]

            Growing Seed _ ->
                [ animationStyle "bulge 0.5s ease"
                ]

            _ ->
                []


fallingStyles : Move -> List Style
fallingStyles ( _, block ) =
    let
        tile =
            getTileState block
    in
        case tile of
            Falling tile distance ->
                [ animationStyle <| "fall-" ++ (toString (distance - 1)) ++ " 0.5s ease"
                , fillModeStyle "forwards"
                ]

            _ ->
                []


leavingStyles : Model -> Move -> List Style
leavingStyles model (( _, tile ) as move) =
    if isLeaving tile then
        [ transitionStyle "0.8s ease"
        , opacityStyle 0.2
        , transitionDelayStyle <| ((leavingOrder tile) % 5) * 80
        , handleExitDirection move model
        ]
    else
        []


handleExitDirection : Move -> Model -> Style
handleExitDirection ( coord, block ) model =
    let
        tile =
            getTileState block
    in
        case tile of
            Leaving Rain _ ->
                transformStyle <| exitLeft model

            Leaving Sun _ ->
                transformStyle <| exitRight model

            Leaving Seed _ ->
                transformStyle <| exitTop model

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
    if isDragging tile then
        [ animationStyle "bulge-fade 0.8s ease"
        , fillModeStyle "forwards"
        ]
    else if isLeaving tile then
        [ displayStyle "none"
        ]
    else
        []


draggingStyles : Model -> Move -> List Style
draggingStyles model ( _, tileState ) =
    if model.moveShape == Just Square then
        [ transitionStyle "0.5s ease"
        ]
    else if isLeaving tileState then
        [ transitionStyle "0.1s ease"
        ]
    else if isDragging tileState then
        [ transformStyle <| scale 0.8
        , transitionStyle "0.3s ease"
        ]
    else
        []


tileWidthHeightStyles : Model -> List Style
tileWidthHeightStyles { tileSettings } =
    [ widthStyle tileSettings.sizeX
    , heightStyle tileSettings.sizeY
    ]


centerBlock : String
centerBlock =
    "ma absolute top-0 left-0 right-0 bottom-0"
