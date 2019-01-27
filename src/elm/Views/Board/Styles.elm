module Views.Board.Styles exposing
    ( TileViewModel
    , baseTileClasses
    , boardFullWidth
    , boardHeight
    , boardMarginTop
    , boardOffsetLeft
    , boardOffsetTop
    , boardWidth
    , burstStyles
    , burstTracerStyles
    , centerBlock
    , draggingStyles
    , enteringStyles
    , fallingStyles
    , growingStyles
    , lighterStrokeColor
    , moveTracerStyles
    , scoreIconSize
    , seedStrokeColors
    , strokeColors
    , tileBackground
    , tileCoordsStyles
    , tilePosition
    , tileSize
    , tileWidth
    , tileWidthheights
    , topBarHeight
    , wallStyles
    )

import Css.Animation as Animation
import Css.Color as Color
import Css.Style as Style exposing (..)
import Css.Transform exposing (..)
import Css.Transition exposing (delay, transitionAll)
import Data.Board.Block as Block exposing (..)
import Data.Board.Move as Move
import Data.Board.Score exposing (collectable, scoreTileTypes)
import Data.Board.Tile as Tile
import Data.Board.Types exposing (..)
import Data.Window exposing (Window)
import Dict exposing (Dict)



-- Score Bar


scoreIconSize : number
scoreIconSize =
    32


topBarHeight : number
topBarHeight =
    80



-- Board


type alias TileViewModel =
    ( Window, BoardDimensions )


boardMarginTop : TileViewModel -> Style
boardMarginTop model =
    marginTop <| toFloat <| boardOffsetTop model


boardOffsetTop : TileViewModel -> Int
boardOffsetTop (( window, _ ) as model) =
    (window.height - boardHeight model) // 2 + (topBarHeight // 2) - 10


boardOffsetLeft : TileViewModel -> Int
boardOffsetLeft (( window, _ ) as model) =
    (window.width - boardWidth model) // 2


boardHeight : TileViewModel -> Int
boardHeight ( window, dimensions ) =
    round (Tile.baseSizeY * Tile.scale window) * dimensions.y


boardWidth : TileViewModel -> Int
boardWidth (( window, dimensions ) as model) =
    tileWidth window * dimensions.x


boardFullWidth : Window -> Int
boardFullWidth window =
    tileWidth window * 8



-- Tile Position


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
            Tile.scale window
    in
    ( toFloat y * Tile.baseSizeY * tileScale
    , toFloat x * Tile.baseSizeX * tileScale
    )


tileWidthheights : Window -> List Style
tileWidthheights window =
    [ width <| toFloat <| tileWidth window
    , height <| toFloat <| tileHeight window
    ]


baseTileClasses : List String
baseTileClasses =
    [ "br-100"
    , centerBlock
    ]


centerBlock : String
centerBlock =
    "ma absolute top-0 left-0 right-0 bottom-0"


tileWidth : Window -> Int
tileWidth window =
    round <| Tile.baseSizeX * Tile.scale window


tileHeight : Window -> Int
tileHeight window =
    round <| Tile.baseSizeY * Tile.scale window



-- Block Styles


wallStyles : Window -> Move -> List Style
wallStyles window move =
    let
        wallSize =
            Tile.scale window * 45
    in
    case Move.block move of
        Wall color ->
            [ backgroundColor color
            , width wallSize
            , height wallSize
            ]

        _ ->
            []


enteringStyles : Move -> List Style
enteringStyles move =
    case getTileState <| Move.block move of
        Entering tile ->
            [ Animation.animation "bounce-down" 1000 [ Animation.ease ] ]

        _ ->
            []


fallingStyles : Move -> List Style
fallingStyles move =
    case getTileState <| Move.block move of
        Falling tile distance ->
            [ Animation.animation ("bounce-down-" ++ String.fromInt distance) 900 [ Animation.linear ] ]

        _ ->
            []


releasingStyles : Move -> List Style
releasingStyles move =
    case getTileState <| Move.block move of
        Releasing _ ->
            [ transitionAll 200 []
            , transform [ scale 1 ]
            ]

        _ ->
            []


moveTracerStyles : Move -> List Style
moveTracerStyles move =
    if isDragging (Move.block move) then
        [ Animation.animation "bulge-fade" 800 [ Animation.ease ]
        ]

    else
        [ displayStyle "none"
        ]


draggingStyles : Bool -> Move -> List Style
draggingStyles externalDragTriggered move =
    let
        block =
            Move.block move
    in
    if isLeaving block then
        [ transitionAll 100 []
        ]

    else if externalDragTriggered then
        [ transitionAll 500 []
        ]

    else if Block.isDragging block && not (Block.isBurst block) then
        [ transform [ scale 0.8 ]
        , transitionAll 300 []
        ]

    else
        []



-- SeedPod


growingStyles : Move -> List Style
growingStyles move =
    case getTileState <| Move.block move of
        Growing SeedPod _ ->
            [ transform [ scale 4 ]
            , transitionAll 400 [ delay <| modBy 5 (Block.growingOrder <| Move.block move) * 70 ]
            , opacity 0
            , property "pointer-events" "none"
            ]

        Growing (Seed _) _ ->
            [ Animation.animation "bulge" 500 [ Animation.ease ] ]

        _ ->
            []



-- Burst


burstStyles : Int -> Block -> List Style
burstStyles burstMagnitude block =
    if Block.isLeaving block && Block.isBurst block then
        [ Animation.animation "bulge-fade-10" 800 [ Animation.cubicBezier 0 0 0 0.8 ]
        ]

    else if Block.isDragging block && Block.isBurst block then
        [ transform [ scale 1.3 ]
        , transitionAll 300 []
        ]

    else
        []


burstTracerStyles : Int -> Move -> List Style
burstTracerStyles burstMagnitude move =
    let
        block =
            Move.block move

        pulseSpeed =
            clamp 500 1000 <| 2000 - burstMagnitude * 200
    in
    if Block.isDragging block && Block.isBurst block then
        [ Animation.animation "bulge-fade" pulseSpeed [ Animation.infinite, Animation.cubicBezier 0 0 0 1 ] ]

    else
        []



-- Tile Type Styles


tileBackground : Block -> List Style
tileBackground =
    fromBlock tileBackground_ []


tileSize : Block -> Float
tileSize =
    fromBlock tileSize_ 0


fromBlock : (TileType -> a) -> a -> Block -> a
fromBlock f default =
    Block.fold (Tile.map default f) default


strokeColors : TileType -> Color.Color
strokeColors tile =
    case tile of
        Rain ->
            Color.lightBlue

        Sun ->
            Color.gold

        SeedPod ->
            Color.green

        Seed seedType ->
            seedStrokeColors seedType

        Burst tile_ ->
            burstColor tile_


lighterStrokeColor : TileType -> Color.Color
lighterStrokeColor tile =
    case tile of
        Rain ->
            Color.rgb 171 238 237

        Sun ->
            Color.rgb 249 221 79

        SeedPod ->
            Color.rgb 157 229 106

        Seed seedType ->
            lighterSeedStrokeColor seedType

        Burst tile_ ->
            lighterBurstColor tile_


burstColor : Maybe TileType -> Color.Color
burstColor =
    Maybe.map strokeColors >> Maybe.withDefault Color.greyYellow


lighterBurstColor : Maybe TileType -> Color.Color
lighterBurstColor =
    Maybe.map lighterStrokeColor >> Maybe.withDefault Color.transparent


seedStrokeColors : SeedType -> Color.Color
seedStrokeColors seedType =
    case seedType of
        Sunflower ->
            Color.darkBrown

        Chrysanthemum ->
            Color.purple

        Cornflower ->
            Color.darkBlue

        Lupin ->
            Color.crimson

        _ ->
            Color.darkBrown


lighterSeedStrokeColor seedType =
    case seedType of
        Sunflower ->
            Color.lightBrown

        Chrysanthemum ->
            Color.orange

        Cornflower ->
            Color.lightBlue

        Lupin ->
            Color.brown

        _ ->
            Color.lightBrown


tileBackground_ : TileType -> List Style
tileBackground_ tile =
    case tile of
        Rain ->
            [ backgroundColor Color.lightBlue ]

        Sun ->
            [ backgroundColor Color.gold ]

        SeedPod ->
            [ background Color.seedPodGradient ]

        Seed _ ->
            []

        Burst _ ->
            []


tileSize_ : TileType -> Float
tileSize_ tile =
    case tile of
        Rain ->
            18

        Sun ->
            18

        SeedPod ->
            26

        Seed _ ->
            35

        Burst _ ->
            35
