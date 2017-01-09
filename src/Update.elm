module Update exposing (..)

import Types exposing (..)
import Random exposing (..)


mapProbabilities : Int -> Int
mapProbabilities x =
    if x > 80 then
        4
    else if x > 20 then
        3
    else if x > 10 then
        2
    else
        1


numberGenerator : Generator Int
numberGenerator =
    map mapProbabilities (int 1 100)


generateRawTiles : Cmd Msg
generateRawTiles =
    generate RandomTiles (list 8 (list 8 numberGenerator))


makeTile : Int -> Int -> Int -> Tile
makeTile i j x =
    { value = x
    , y = i
    , x = j
    }


makeTileRow : Int -> List Int -> List Tile
makeTileRow i row =
    List.indexedMap (makeTile i) row


makeBoard : List (List Int) -> List (List Tile)
makeBoard board =
    List.indexedMap makeTileRow board


init : ( Model, Cmd Msg )
init =
    ( Model [ [] ], generateRawTiles )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        RandomTiles tiles ->
            ( { model | tiles = makeBoard tiles }, Cmd.none )

        ShuffleTiles ->
            ( model, generateRawTiles )
