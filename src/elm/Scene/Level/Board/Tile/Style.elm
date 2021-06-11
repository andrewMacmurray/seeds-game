module Scene.Level.Board.Tile.Style exposing
    ( coordStyles
    , height
    , lighterStrokeColor
    , position
    , releasingStyles
    , size
    , strokeColors
    , width
    , widthHeightStyles
    )

import Board.Block as Block exposing (Block(..))
import Board.Coord as Coord exposing (Coord)
import Board.Move as Move exposing (Move)
import Board.Tile as Tile exposing (State(..), Tile(..))
import Css.Color as Color
import Css.Style as Style exposing (..)
import Css.Transform exposing (..)
import Css.Transition exposing (transitionAll)
import Scene.Level.Board.Tile.Scale as Scale
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
    [ Style.width <| toFloat (width window)
    , Style.height <| toFloat (height window)
    ]


width : Window -> Int
width =
    Scale.width


height : Window -> Int
height =
    Scale.height



-- Block Styles


releasingStyles : Move -> List Style
releasingStyles move =
    case Move.tileState move of
        Releasing _ order ->
            [ transitionAll (200 + (30 * order)) [] ]

        _ ->
            []



-- Tile Type Styles


size : Block -> Float
size =
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
            22

        Tile.Burst _ ->
            36
