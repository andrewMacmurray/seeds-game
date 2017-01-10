module Update exposing (..)

import Types exposing (..)
import Random exposing (..)
import Directions exposing (validMove)


-- INIT


init : ( Model, Cmd Msg )
init =
    ( Model [ [] ] Nothing [] False, generateRawTiles )


generateRawTiles : Cmd Msg
generateRawTiles =
    generate RawTiles (list 8 (list 8 numberGenerator))


numberGenerator : Generator Int
numberGenerator =
    map probabilityToTileValue (int 1 100)


probabilityToTileValue : Int -> Int
probabilityToTileValue x =
    if x > 80 then
        4
    else if x > 20 then
        3
    else if x > 10 then
        2
    else
        1



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        RawTiles tileValues ->
            ( { model | tiles = makeBoard tileValues }, Cmd.none )

        ShuffleTiles ->
            ( model, generateRawTiles )

        StopMove ->
            ( { model
                | isDragging = False
                , currentTile = Nothing
                , currentMove = []
              }
            , Cmd.none
            )

        StartMove tile ->
            ( { model
                | isDragging = True
                , currentTile = Just tile
                , currentMove = [ tile ]
              }
            , Cmd.none
            )

        CheckTile tile ->
            ( { model
                | currentTile = (handleNextTile model tile)
                , currentMove = (addToCurrentMove model tile)
              }
            , Cmd.none
            )


makeBoard : List (List Int) -> List (List Tile)
makeBoard board =
    List.indexedMap makeRow board


makeRow : Int -> List Int -> List Tile
makeRow i row =
    List.indexedMap (makeTile i) row


makeTile : Int -> Int -> Int -> Tile
makeTile i j x =
    { value = x
    , coord = ( j, i )
    }


addToCurrentMove : Model -> Tile -> List Tile
addToCurrentMove model tile =
    case (handleNextTile model tile) of
        Just next ->
            model.currentMove ++ [ next ]

        Nothing ->
            model.currentMove


handleNextTile : Model -> Tile -> Maybe Tile
handleNextTile model next =
    case model.currentTile of
        Just current ->
            let
                nextTile =
                    if (validMove next current) then
                        next
                    else
                        current
            in
                if model.isDragging then
                    Just nextTile
                else
                    Nothing

        Nothing ->
            if model.isDragging then
                Just next
            else
                Nothing
