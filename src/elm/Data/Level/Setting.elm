module Data.Level.Setting exposing
    ( Probability(..)
    , StartTile
    , TargetScore(..)
    , TileSetting
    , bst_
    , burst
    , move
    , rain
    , rain_
    , rnd_
    , sedp_
    , seed
    , seedPod
    , snf_
    , startTiles
    , sun
    , sun_
    )

import Data.Board.Block as Block
import Data.Board.Coord as Coord
import Data.Board.Move as Move
import Data.Board.Types exposing (Coord, Move, SeedType(..), TileType(..))


type alias TileSetting =
    { tileType : TileType
    , probability : Probability
    , targetScore : Maybe TargetScore
    }


type TargetScore
    = TargetScore Int


type Probability
    = Probability Int


type StartTile
    = StartTile Coord TileType


type DefaultTile
    = Constant TileType
    | Random



-- Settings


rain : Probability -> TargetScore -> TileSetting
rain prob targetScore =
    TileSetting Rain prob <| Just targetScore


sun : Probability -> TargetScore -> TileSetting
sun prob targetScore =
    TileSetting Sun prob <| Just targetScore


seed : SeedType -> Probability -> TargetScore -> TileSetting
seed seedType prob targetScore =
    TileSetting (Seed seedType) prob <| Just targetScore


seedPod : Probability -> TileSetting
seedPod prob =
    TileSetting SeedPod prob Nothing


burst : Probability -> TileSetting
burst prob =
    TileSetting (Burst Nothing) prob Nothing



-- Start Tiles


move : StartTile -> Move
move (StartTile coord tileType) =
    Move.move coord <| Block.static tileType


startTiles : List (List DefaultTile) -> List StartTile
startTiles tiles =
    tiles
        |> List.indexedMap (\i t -> List.indexedMap (toStartTile i) t)
        |> List.concat
        |> List.concat


toStartTile : Int -> Int -> DefaultTile -> List StartTile
toStartTile y x defaultTile =
    case defaultTile of
        Constant t ->
            [ StartTile (Coord.fromXY x y) t ]

        Random ->
            []


rain_ : DefaultTile
rain_ =
    Constant Rain


sun_ : DefaultTile
sun_ =
    Constant Sun


bst_ : DefaultTile
bst_ =
    Constant <| Burst Nothing


rnd_ : DefaultTile
rnd_ =
    Random


sedp_ : DefaultTile
sedp_ =
    Constant SeedPod


snf_ : DefaultTile
snf_ =
    Constant (Seed Sunflower)
