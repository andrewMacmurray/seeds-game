module Update exposing (..)

import Types exposing (..)
import Random exposing (..)
import Directions exposing (validMove)
import List.Extra exposing (getAt)


-- INIT


init : ( Model, Cmd Msg )
init =
    ( Model [ [] ] Nothing Empty False, generateRawTiles )


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
                , currentMove = Empty
              }
            , Cmd.none
            )

        StartMove tile ->
            ( { model
                | isDragging = True
                , currentTile = Just tile
                , currentMove = OneTile tile
              }
            , Cmd.none
            )

        CheckTile tile ->
            let
                ( currentTile, currentMove ) =
                    handleMove model tile
            in
                ( { model
                    | currentTile = currentTile
                    , currentMove = currentMove
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


handleMove : Model -> Tile -> ( Maybe Tile, Move )
handleMove model tile =
    if model.isDragging then
        ( (handleNextTile model tile), (addToCurrentMove model tile) )
    else
        ( model.currentTile, model.currentMove )


addToCurrentMove : Model -> Tile -> Move
addToCurrentMove model tile =
    let
        valid =
            validMove model tile
    in
        case model.currentMove of
            Empty ->
                OneTile tile

            OneTile prevTile ->
                if (valid) then
                    Pair ( prevTile, tile )
                else
                    model.currentMove

            _ ->
                if (valid) then
                    handleRemove model tile
                else
                    model.currentMove


handleRemove : Model -> Tile -> Move
handleRemove model tile =
    case model.currentMove of
        Pair ( t1, t2 ) ->
            if tile == t1 then
                OneTile t1
            else
                Full [ t1, t2, tile ]

        Full tiles ->
            handleFullRemove tile tiles model

        _ ->
            model.currentMove


handleFullRemove : Tile -> List Tile -> Model -> Move
handleFullRemove tile moveTiles model =
    let
        moveLength =
            List.length moveTiles

        lastButTwo =
            getAt (moveLength - 2) moveTiles
    in
        case lastButTwo of
            Just t2 ->
                if tile == t2 then
                    Full (List.take (moveLength - 1) moveTiles)
                else
                    Full (moveTiles ++ [ tile ])

            Nothing ->
                model.currentMove


handleNextTile : Model -> Tile -> Maybe Tile
handleNextTile model next =
    case model.currentTile of
        Just current ->
            if (validMove model next) then
                Just next
            else
                Just current

        Nothing ->
            Just next
