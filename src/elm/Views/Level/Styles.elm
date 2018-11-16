module Views.Level.Styles exposing
    ( TileViewModel
    , baseTileClasses
    , boardFullWidth
    , boardHeight
    , boardMarginTop
    , boardOffsetLeft
    , boardOffsetTop
    , boardWidth
    , centerBlock
    , draggingStyles
    , enteringStyles
    , fallingStyles
    , growingStyles
    , moveTracerStyles
    , seedBackgrounds
    , seedStrokeColors
    , strokeColors
    , tileBackground
    , tileBackgroundMap
    , tileClassMap
    , tileCoordsStyles
    , tilePosition
    , tileSize
    , tileSizeMap
    , tileStyleMap
    , tileWidth
    , tileWidthheights
    , wallStyles
    )

import Config.Scale as ScaleConfig
import Css.Animation exposing (animation, ease, linear)
import Css.Color exposing (..)
import Css.Style as Style exposing (..)
import Css.Transform exposing (..)
import Css.Transition exposing (delay, transitionAll)
import Data.Board.Block as Block exposing (..)
import Data.Board.Score exposing (collectable, scoreTileTypes)
import Data.Board.Tile as Tile
import Data.Board.Types exposing (..)
import Data.Window exposing (Window)
import Dict exposing (Dict)


type alias TileViewModel =
    ( Window, BoardDimensions )


boardMarginTop : TileViewModel -> Style
boardMarginTop model =
    marginTop <| toFloat <| boardOffsetTop model


boardOffsetTop : TileViewModel -> Int
boardOffsetTop (( window, _ ) as model) =
    (window.height - boardHeight model) // 2 + (ScaleConfig.topBarHeight // 2) - 10


boardOffsetLeft : TileViewModel -> Int
boardOffsetLeft (( window, _ ) as model) =
    (window.width - boardWidth model) // 2


boardHeight : TileViewModel -> Int
boardHeight ( window, dimensions ) =
    round (ScaleConfig.baseTileSizeY * ScaleConfig.tileScaleFactor window) * dimensions.y


boardWidth : TileViewModel -> Int
boardWidth (( window, dimensions ) as model) =
    tileWidth window * dimensions.x


boardFullWidth : Window -> Int
boardFullWidth window =
    tileWidth window * 8


tileWidth : Window -> Int
tileWidth window =
    round <| ScaleConfig.baseTileSizeX * ScaleConfig.tileScaleFactor window


tileCoordsStyles : Window -> Coord -> List Style
tileCoordsStyles window coord =
    let
        ( y, x ) =
            tilePosition window coord
    in
    [ transform
        [ translate x y
        , translateZ 0
        ]
    ]


tilePosition : Window -> Coord -> ( Float, Float )
tilePosition window ( y, x ) =
    let
        tileScale =
            ScaleConfig.tileScaleFactor window
    in
    ( toFloat y * ScaleConfig.baseTileSizeY * tileScale
    , toFloat x * ScaleConfig.baseTileSizeX * tileScale
    )


wallStyles : Window -> Move -> List Style
wallStyles window ( _, block ) =
    let
        wallSize =
            ScaleConfig.tileScaleFactor window * 45
    in
    case block of
        Wall color ->
            [ backgroundColor color
            , width wallSize
            , height wallSize
            ]

        _ ->
            []


enteringStyles : Move -> List Style
enteringStyles ( _, block ) =
    case getTileState block of
        Entering tile ->
            [ animation "bounce-down" 1000 [ ease ] ]

        _ ->
            []


growingStyles : Move -> List Style
growingStyles ( coord, block ) =
    case getTileState block of
        Growing SeedPod _ ->
            [ transform [ scale 4 ]
            , transitionAll 400 [ delay <| modBy 5 (growingOrder block) * 70 ]
            , opacity 0
            , property "pointer-events" "none"
            ]

        Growing (Seed _) _ ->
            [ animation "bulge" 500 [ ease ] ]

        _ ->
            []


fallingStyles : Move -> List Style
fallingStyles ( _, block ) =
    case getTileState block of
        Falling tile distance ->
            [ animation ("bounce-down-" ++ String.fromInt distance) 900 [ linear ] ]

        _ ->
            []


moveTracerStyles : Move -> List Style
moveTracerStyles (( coord, tile ) as move) =
    if isDragging tile then
        [ animation "bulge-fade" 800 [ ease ] ]

    else
        [ displayStyle "none" ]


draggingStyles : Maybe MoveShape -> Move -> List Style
draggingStyles moveShape ( _, tileState ) =
    if moveShape == Just Square then
        [ transitionAll 500 []
        ]

    else if isLeaving tileState then
        [ transitionAll 100 []
        ]

    else if isDragging tileState then
        [ transform [ scale 0.8 ]
        , transitionAll 300 []
        ]

    else
        []


tileWidthheights : Window -> List Style
tileWidthheights window =
    let
        tileScale =
            ScaleConfig.tileScaleFactor window
    in
    [ width <| ScaleConfig.baseTileSizeX * tileScale
    , height <| ScaleConfig.baseTileSizeY * tileScale
    ]


baseTileClasses : List String
baseTileClasses =
    [ "br-100"
    , centerBlock
    ]


centerBlock : String
centerBlock =
    "ma absolute top-0 left-0 right-0 bottom-0"


tileBackgroundMap : Block -> List Style
tileBackgroundMap =
    Block.fold (tileStyleMap tileBackground) []


tileSizeMap : Block -> Float
tileSizeMap =
    Block.fold (Tile.map 0 tileSize) 0


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


tileBackground : TileType -> List Style
tileBackground tile =
    case tile of
        Rain ->
            [ backgroundColor lightBlue ]

        Sun ->
            [ backgroundColor gold ]

        SeedPod ->
            [ background seedPodGradient ]

        Seed _ ->
            []


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
    Tile.map ""


tileStyleMap : (TileType -> List Style) -> TileState -> List Style
tileStyleMap =
    Tile.map []
