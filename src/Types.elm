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
    = RandomTiles (List (List Int))
    | ShuffleTiles
    | StopDrag
    | CheckTile Tile
    | StartMove Tile
