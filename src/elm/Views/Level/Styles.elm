module Views.Level.Styles exposing (..)

import Config.Color exposing (..)
import Config.Scale as ScaleConfig
import Data.Board.Block exposing (..)
import Data.Board.Score exposing (collectable, scoreTileTypes)
import Data.Board.Tile as TileState
import Data.Board.Types exposing (..)
import Dict exposing (Dict)
import Helpers.Css.Animation exposing (..)
import Helpers.Css.Style exposing (..)
import Helpers.Css.Timing exposing (..)
import Helpers.Css.Transform exposing (..)
import Helpers.Css.Transition exposing (easeAll, transitionStyle)
import Scenes.Level.Types as Level exposing (..)
import Window


boardMarginTop : Level.Model -> Style
boardMarginTop model =
    marginTop <| boardOffsetTop model


boardOffsetTop : TileConfig model -> Int
boardOffsetTop model =
    (model.window.height - boardHeight model) // 2 + ScaleConfig.topBarHeight // 2


boardHeight : TileConfig model -> Int
boardHeight model =
    round (ScaleConfig.baseTileSizeY * ScaleConfig.tileScaleFactor model.window) * model.boardDimensions.y


boardWidth : TileConfig model -> Int
boardWidth model =
    tileWidth model * model.boardDimensions.x


boardFullWidth : TileConfig model -> Int
boardFullWidth model =
    tileWidth model * 8


tileWidth : TileConfig model -> Int
tileWidth model =
    round <| ScaleConfig.baseTileSizeX * ScaleConfig.tileScaleFactor model.window


tileCoordsStyles : TileConfig model -> Coord -> List Style
tileCoordsStyles model coord =
    let
        ( y, x ) =
            tilePosition model coord
    in
        [ transformStyle [ translate x y ] ]


tilePosition : TileConfig model -> Coord -> ( Float, Float )
tilePosition { window } ( y, x ) =
    let
        tileScale =
            ScaleConfig.tileScaleFactor window
    in
        ( (toFloat y) * ScaleConfig.baseTileSizeY * tileScale
        , (toFloat x) * ScaleConfig.baseTileSizeX * tileScale
        )


wallStyles : Window.Size -> Move -> List Style
wallStyles window ( _, block ) =
    let
        wallSize =
            ScaleConfig.tileScaleFactor window * 45
    in
        case block of
            Wall color ->
                [ backgroundColor color
                , widthStyle wallSize
                , heightStyle wallSize
                ]

            _ ->
                []


enteringStyles : Move -> List Style
enteringStyles ( _, block ) =
    case getTileState block of
        Entering tile ->
            [ animateEase "bounce-down" 1000 ]

        _ ->
            []


growingStyles : Move -> List Style
growingStyles ( coord, block ) =
    case getTileState block of
        Growing SeedPod _ ->
            [ transformStyle [ scale 4 ]
            , transitionStyle
                { property = "all"
                , duration = 400
                , timing = Ease
                , delay = Just <| toFloat <| growingOrder block % 5 * 70
                }
            , opacityStyle 0
            , ( "pointer-events", "none" )
            ]

        Growing (Seed _) _ ->
            [ animateEase "bulge" 500 ]

        _ ->
            []


fallingStyles : Move -> List Style
fallingStyles ( _, block ) =
    case getTileState block of
        Falling tile distance ->
            [ animationStyle
                { name = "bounce-down-" ++ toString distance
                , duration = 900
                , timing = Linear
                }
            ]

        _ ->
            []


leavingStyles : Level.Model -> Move -> List Style
leavingStyles model (( _, tile ) as move) =
    if isLeaving tile then
        [ transitionStyle
            { property = "all"
            , duration = 800
            , timing = Ease
            , delay = Just <| toFloat <| ((leavingOrder tile) % 5) * 80
            }
        , opacityStyle 0.2
        , handleExitDirection move model
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

        Leaving (Seed seedType) _ ->
            getLeavingStyle (Seed seedType) model

        _ ->
            emptyStyle


getLeavingStyle : TileType -> Level.Model -> Style
getLeavingStyle tileType model =
    newLeavingStyles model
        |> Dict.get (toString tileType)
        |> Maybe.withDefault emptyStyle


newLeavingStyles : Level.Model -> Dict String Style
newLeavingStyles model =
    model.tileSettings
        |> scoreTileTypes
        |> List.indexedMap (prepareLeavingStyle model)
        |> Dict.fromList


prepareLeavingStyle : Level.Model -> Int -> TileType -> ( String, Style )
prepareLeavingStyle model i tileType =
    ( toString tileType
    , transformStyle
        [ translate (exitXDistance i model) -(exitYdistance model)
        , scale 0.5
        ]
    )


exitXDistance : Int -> Level.Model -> Float
exitXDistance n model =
    let
        scoreWidth =
            ScaleConfig.scoreIconSize * 2

        scoreBarWidth =
            model.tileSettings
                |> List.filter collectable
                |> List.length
                |> (*) scoreWidth

        baseOffset =
            (boardWidth model - scoreBarWidth) // 2

        offset =
            exitOffsetFunction <| ScaleConfig.tileScaleFactor model.window
    in
        toFloat (baseOffset + n * scoreWidth) + offset


exitOffsetFunction : Float -> Float
exitOffsetFunction x =
    25 * (x ^ 2) - (75 * x) + ScaleConfig.baseTileSizeX


exitYdistance : Level.Model -> Float
exitYdistance model =
    toFloat (boardOffsetTop model) - 9


moveTracerStyles : Move -> List Style
moveTracerStyles (( coord, tile ) as move) =
    if isDragging tile then
        [ animateEase "bulge-fade" 800 ]
    else
        [ displayStyle "none"
        ]


draggingStyles : Maybe MoveShape -> Move -> List Style
draggingStyles moveShape ( _, tileState ) =
    if moveShape == Just Square then
        [ easeAll 500
        ]
    else if isLeaving tileState then
        [ easeAll 100
        ]
    else if isDragging tileState then
        [ transformStyle [ scale 0.8 ]
        , easeAll 300
        ]
    else
        []


tileWidthHeightStyles : TileConfig model -> List Style
tileWidthHeightStyles { window } =
    let
        tileScale =
            ScaleConfig.tileScaleFactor window
    in
        [ widthStyle <| ScaleConfig.baseTileSizeX * tileScale
        , heightStyle <| ScaleConfig.baseTileSizeY * tileScale
        ]


baseTileClasses : List String
baseTileClasses =
    [ "br-100"
    , centerBlock
    ]


centerBlock : String
centerBlock =
    "ma absolute top-0 left-0 right-0 bottom-0"


tileColorMap : Block -> List Style
tileColorMap =
    foldBlock (tileStyleMap tileColors) []


tileSizeMap : Block -> Float
tileSizeMap =
    foldBlock (tileTypeMap 0 tileSize) 0


strokeColors : TileType -> String
strokeColors tile =
    case tile of
        Rain ->
            lightBlue

        Sun ->
            gold

        SeedPod ->
            green

        Seed seedType ->
            seedStrokeColors seedType


seedStrokeColors : SeedType -> String
seedStrokeColors seedType =
    case seedType of
        Sunflower ->
            darkBrown

        Foxglove ->
            purple

        Lupin ->
            crimson

        _ ->
            darkBrown


tileColors : TileType -> List Style
tileColors tile =
    case tile of
        Rain ->
            [ backgroundColor lightBlue ]

        Sun ->
            [ backgroundColor gold ]

        SeedPod ->
            [ background seedPodGradient ]

        Seed seedType ->
            [ backgroundImage <| seedBackgrounds seedType ] ++ frameBackgroundImage


seedBackgrounds : SeedType -> String
seedBackgrounds seedType =
    case seedType of
        Sunflower ->
            "img/sunflower.svg"

        Foxglove ->
            "img/foxglove.svg"

        Lupin ->
            "img/lupin.svg"

        Rose ->
            "img/rose.svg"

        _ ->
            ""


tileSize : TileType -> Float
tileSize tile =
    case tile of
        Rain ->
            18

        Sun ->
            18

        SeedPod ->
            26

        Seed _ ->
            35


tileClassMap : (TileType -> String) -> TileState -> String
tileClassMap =
    tileTypeMap ""


tileStyleMap : (TileType -> List Style) -> TileState -> List Style
tileStyleMap =
    tileTypeMap []


tileTypeMap : a -> (TileType -> a) -> TileState -> a
tileTypeMap default fn tileState =
    tileState
        |> TileState.getTileType
        |> Maybe.map fn
        |> Maybe.withDefault default
