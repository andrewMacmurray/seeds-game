module Views.Board.Styles exposing (..)

import Data.Color exposing (blockYellow)
import Data.Level.Board.Block exposing (getTileState)
import Data.Level.Board.Tile exposing (..)
import Helpers.Scale exposing (tileScaleFactor)
import Data.Level.Score exposing (scoreTileTypes)
import Dict exposing (Dict)
import Helpers.Style exposing (..)
import Scenes.Level.Types as Level exposing (..)
import Window


boardMarginTop : Level.Model -> Style
boardMarginTop model =
    marginTop <| boardOffsetTop model


boardOffsetTop : TileConfig model -> Int
boardOffsetTop model =
    (model.window.height - boardHeight model) // 2 + model.topBarHeight // 2


boardHeight : TileConfig model -> Int
boardHeight model =
    round (model.tileSize.y * tileScaleFactor model.window) * model.boardScale


boardWidth : TileConfig model -> Int
boardWidth model =
    round (model.tileSize.x * tileScaleFactor model.window) * model.boardScale


tileCoordsStyles : TileConfig model -> Coord -> List Style
tileCoordsStyles model coord =
    let
        ( y, x ) =
            tilePosition model coord
    in
        [ transformStyle <| translate x y ]


tilePosition : TileConfig model -> Coord -> ( Float, Float )
tilePosition { window, tileSize } ( y, x ) =
    let
        tileScale =
            tileScaleFactor window
    in
        ( (toFloat y) * tileSize.y * tileScale
        , (toFloat x) * tileSize.x * tileScale
        )


wallStyles : Window.Size -> Move -> List Style
wallStyles window ( _, block ) =
    let
        wallSize =
            tileScaleFactor window * 45
    in
        case block of
            Wall ->
                [ backgroundColor blockYellow
                , widthStyle wallSize
                , heightStyle wallSize
                ]

            _ ->
                []


enteringStyles : Move -> List Style
enteringStyles ( _, block ) =
    case getTileState block of
        Entering tile ->
            [ animationStyle "bounce-down 1s linear"
            ]

        _ ->
            []


growingStyles : Move -> List Style
growingStyles ( coord, block ) =
    case getTileState block of
        Growing SeedPod _ ->
            [ transformStyle <| scale 4
            , transitionStyle "0.4s ease"
            , opacityStyle 0
            , transitionDelayStyle <| growingOrder block % 5 * 70
            , ( "pointer-events", "none" )
            ]

        Growing Seed _ ->
            [ animationStyle "bulge 0.5s ease"
            ]

        _ ->
            []


fallingStyles : Move -> List Style
fallingStyles ( _, block ) =
    case getTileState block of
        Falling tile distance ->
            [ animationStyle <| "bounce-down-" ++ (toString distance) ++ " 0.9s linear"
            , fillModeStyle "forwards"
            ]

        _ ->
            []


leavingStyles : Level.Model -> Move -> List Style
leavingStyles model (( _, tile ) as move) =
    if isLeaving tile then
        [ transitionStyle "0.8s ease"
        , opacityStyle 0.2
        , transitionDelayStyle <| ((leavingOrder tile) % 5) * 80
        , handleExitDirection move model
        ]
    else
        []


releasingStyles : Move -> List Style
releasingStyles ( _, tile ) =
    if isReleasing tile then
        [ transitionStyle "0.3s"
        , transformStyle <| scale 1
        ]
    else
        []


handleExitDirection : Move -> Level.Model -> Style
handleExitDirection ( coord, block ) model =
    case getTileState block of
        Leaving Rain _ ->
            getLeavingStyle Rain model

        Leaving Sun _ ->
            getLeavingStyle Sun model

        Leaving Seed _ ->
            getLeavingStyle Seed model

        _ ->
            emptyStyle


getLeavingStyle : TileType -> Level.Model -> Style
getLeavingStyle tileType model =
    newLeavingStyles model
        |> Dict.get (toString tileType)
        |> Maybe.withDefault ""
        |> transformStyle


newLeavingStyles : Level.Model -> Dict String String
newLeavingStyles model =
    model.tileSettings
        |> scoreTileTypes
        |> List.indexedMap (prepareLeavingStyle model)
        |> Dict.fromList


prepareLeavingStyle : Level.Model -> Int -> TileType -> ( String, String )
prepareLeavingStyle model i tileType =
    ( toString tileType
    , translateScale (exitXDistance i model) -(exitYdistance model) 0.5
    )


exitXDistance : Int -> Level.Model -> Float
exitXDistance n model =
    let
        scoreWidth =
            model.scoreIconSize * 2

        scoreBarWidth =
            (List.length model.tileSettings) * scoreWidth

        baseOffset =
            (boardWidth model - scoreBarWidth) // 2

        offset =
            exitOffsetFunction model.tileSize <| tileScaleFactor model.window
    in
        toFloat (baseOffset + (n * scoreWidth) + model.scoreIconSize) + offset


exitOffsetFunction : TileSize -> Float -> Float
exitOffsetFunction tileSize x =
    25 * (x ^ 2) - (75 * x) + tileSize.x


exitYdistance : Level.Model -> Int
exitYdistance model =
    (boardOffsetTop model) - 9


moveTracerStyles : Move -> List Style
moveTracerStyles (( coord, tile ) as move) =
    if isDragging tile then
        [ animationStyle "bulge-fade 0.8s ease"
        , fillModeStyle "forwards"
        ]
    else
        [ displayStyle "none"
        ]


draggingStyles : Maybe MoveShape -> Move -> List Style
draggingStyles moveShape ( _, tileState ) =
    if moveShape == Just Square then
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


tileWidthHeightStyles : TileConfig model -> List Style
tileWidthHeightStyles { tileSize, window } =
    let
        tileScale =
            tileScaleFactor window
    in
        [ widthStyle <| tileSize.x * tileScale
        , heightStyle <| tileSize.y * tileScale
        ]


baseTileClasses : List String
baseTileClasses =
    [ "br-100"
    , centerBlock
    ]


centerBlock : String
centerBlock =
    "ma absolute top-0 left-0 right-0 bottom-0"
