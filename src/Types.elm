module Types exposing (..)


type alias Tile =
    { value : Int
    , x : Int
    , y : Int
    }


type alias Model =
    { tiles : List (List Tile)
    }


type Msg
    = RandomTiles (List (List Int))
    | ShuffleTiles
