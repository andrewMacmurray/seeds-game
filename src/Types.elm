module Types exposing (..)


type alias Coord =
    ( Int, Int )


type alias Tile =
    { value : Int
    , coord : Coord
    }


type alias Model =
    { tiles : List (List Tile)
    , currentTile : Maybe Tile
    , currentMove : List Tile
    , isDragging : Bool
    }


type Msg
    = RawTiles (List (List Int))
    | ShuffleTiles
    | StopMove
    | CheckTile Tile
    | StartMove Tile
