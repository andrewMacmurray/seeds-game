module Scenes.Level.Board.Tile.Style exposing
    ( baseClasses
    , burstStyles
    , centerBlock
    , coordStyles
    , draggingStyles
    , enteringStyles
    , fallingStyles
    , growingStyles
    , height
    , lighterStrokeColor
    , moveTracerStyles
    , position
    , seedStrokeColors
    , strokeColors
    , tileBackground
    , tileSize
    , wallStyles
    , width
    , widthHeightStyles
    )

import Board.Block as Block exposing (Block(..))
import Board.Coord as Coord exposing (Coord)
import Board.Move as Move exposing (Move)
import Board.Tile as Tile exposing (Tile)
import Css.Animation as Animation
import Css.Color as Color
import Css.Style as Style exposing (..)
import Css.Transform exposing (..)
import Css.Transition exposing (delay, transitionAll)
import Seed
import Window exposing (Window)


type alias Position =
    { x : Float
    , y : Float
    }



-- Tile Position


coordStyles : Window -> Coord -> List Style
coordStyles window coord =
    let
        { x, y } =
            position window coord
    in
    [ transform
        [ translate x y
        , translateZ 0
        ]
    ]


position : Window -> Coord -> Position
position window coord =
    { x = toFloat <| Coord.x coord * width window
    , y = toFloat <| Coord.y coord * height window
    }


widthHeightStyles : Window -> List Style
widthHeightStyles window =
    [ Style.width <| toFloat <| width window
    , Style.height <| toFloat <| height window
    ]


baseClasses : List String
baseClasses =
    [ "br-100"
    , centerBlock
    ]


centerBlock : String
centerBlock =
    "ma absolute top-0 left-0 right-0 bottom-0"


width : Window -> Int
width window =
    round <| Tile.baseSizeX * Tile.scale window


height : Window -> Int
height window =
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
            , Style.width wallSize
            , Style.height wallSize
            ]

        _ ->
            []


enteringStyles : Move -> List Style
enteringStyles move =
    case Move.tileState move of
        Tile.Entering _ ->
            [ Animation.animation "bounce-down" 1000 [ Animation.ease ] ]

        _ ->
            []


fallingStyles : Move -> List Style
fallingStyles move =
    case Move.tileState move of
        Tile.Falling _ distance ->
            [ Animation.animation ("bounce-down-" ++ String.fromInt distance) 900 [ Animation.linear ] ]

        _ ->
            []


moveTracerStyles : Move -> List Style
moveTracerStyles move =
    case Move.tileState move of
        Tile.Dragging (Tile.Burst _) _ _ ->
            [ Animation.animation "bulge-fade-2" 800 [ Animation.ease, Animation.infinite ] ]

        Tile.Dragging _ _ _ ->
            [ Animation.animation "bulge-fade-2" 800 [ Animation.ease ]
            ]

        Tile.Active _ ->
            [ Animation.animation "bulge-fade" 800 [ Animation.ease, Animation.infinite ]
            ]

        _ ->
            [ display "none"
            ]


draggingStyles : Bool -> Move -> List Style
draggingStyles isBursting move =
    let
        block =
            Move.block move
    in
    if Block.isLeaving block then
        [ transitionAll 100 []
        ]

    else if isBursting then
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
    case Move.tileState move of
        Tile.Growing Tile.SeedPod _ ->
            [ transform [ scale 4 ]
            , transitionAll 400 [ delay <| modBy 5 (Block.growingOrder <| Move.block move) * 70 ]
            , opacity 0
            , disablePointer
            ]

        Tile.Growing (Tile.Seed _) _ ->
            [ Animation.animation "bulge" 500 [ Animation.ease ] ]

        _ ->
            []



-- Burst


burstStyles : Block -> List Style
burstStyles block =
    if Block.isLeaving block && Block.isBurst block then
        [ Animation.animation "bulge-fade-10" 800 [ Animation.cubicBezier 0 0 0 0.8 ]
        ]

    else if Block.isDragging block && Block.isBurst block then
        [ transform [ scale 1.3 ]
        , transitionAll 300 []
        ]

    else
        [ transitionAll 300 []
        , transform [ scale 1 ]
        ]



-- Tile Type Styles


tileBackground : Block -> List Style
tileBackground =
    fromBlock tileBackground_ []


tileSize : Block -> Float
tileSize =
    fromBlock tileSize_ 0


fromBlock : (Tile -> a) -> a -> Block -> a
fromBlock f default =
    Block.fold (Tile.map default f) default


strokeColors : Tile -> Color.Color
strokeColors tile =
    case tile of
        Tile.Rain ->
            Color.lightBlue

        Tile.Sun ->
            Color.gold

        Tile.SeedPod ->
            Color.green

        Tile.Seed seed ->
            seedStrokeColors seed

        Tile.Burst tile_ ->
            burstColor tile_


lighterStrokeColor : Tile -> Color.Color
lighterStrokeColor tile =
    case tile of
        Tile.Rain ->
            Color.rgb 171 238 237

        Tile.Sun ->
            Color.rgb 249 221 79

        Tile.SeedPod ->
            Color.rgb 157 229 106

        Tile.Seed seed ->
            lighterSeedStrokeColor seed

        Tile.Burst tile_ ->
            lighterBurstColor tile_


burstColor : Maybe Tile -> Color.Color
burstColor =
    Maybe.map strokeColors >> Maybe.withDefault Color.greyYellow


lighterBurstColor : Maybe Tile -> Color.Color
lighterBurstColor =
    Maybe.map lighterStrokeColor >> Maybe.withDefault Color.transparent


seedStrokeColors : Seed.Seed -> Color.Color
seedStrokeColors seed =
    case seed of
        Seed.Sunflower ->
            Color.darkBrown

        Seed.Chrysanthemum ->
            Color.purple

        Seed.Cornflower ->
            Color.darkBlue

        Seed.Lupin ->
            Color.crimson

        _ ->
            Color.darkBrown


lighterSeedStrokeColor : Seed.Seed -> Color.Color
lighterSeedStrokeColor seed =
    case seed of
        Seed.Sunflower ->
            Color.lightBrown

        Seed.Chrysanthemum ->
            Color.orange

        Seed.Cornflower ->
            Color.blueGrey

        Seed.Lupin ->
            Color.brown

        _ ->
            Color.lightBrown


tileBackground_ : Tile -> List Style
tileBackground_ tile =
    case tile of
        Tile.Rain ->
            [ backgroundColor Color.lightBlue ]

        Tile.Sun ->
            [ backgroundColor Color.gold ]

        Tile.SeedPod ->
            [ background Color.seedPodGradient ]

        Tile.Seed _ ->
            []

        Tile.Burst _ ->
            []


tileSize_ : Tile -> Float
tileSize_ tile =
    case tile of
        Tile.Rain ->
            18

        Tile.Sun ->
            18

        Tile.SeedPod ->
            26

        Tile.Seed _ ->
            35

        Tile.Burst _ ->
            35
