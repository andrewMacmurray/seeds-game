module Game.Board.Mechanic.Burst exposing
    ( burst
    , drag
    , isBursting
    , isValidNextMove
    , reset
    , shouldBurst
    )

import Game.Board as Board exposing (Board)
import Game.Board.Block as Block
import Game.Board.Coord as Coord exposing (Coord)
import Game.Board.Move as Move exposing (Move)
import Game.Board.Tile exposing (State(..))



-- Valid Next Move


isValidNextMove : Move -> Board -> Bool
isValidNextMove move board =
    let
        last =
            Board.lastMove board

        burstTypeNotSet =
            Board.activeMoveType board == Nothing

        isValidMoveAfterBurst =
            isBurst last && Board.activeMoveType board == Move.tile move
    in
    isBurst move || isValidMoveAfterBurst || burstTypeNotSet


isBurst : Move -> Bool
isBurst =
    Move.block >> Block.isBurst



-- Drag


drag : Board.Size -> Board -> Board
drag boardSize =
    handleAddBurstType >> addActiveTiles boardSize


handleAddBurstType : Board -> Board
handleAddBurstType board =
    case Board.activeMoveType board of
        Just moveType ->
            Board.updateBlocks (Block.setDraggingBurstType moveType) board

        Nothing ->
            Board.updateBlocks Block.clearBurstType board


addActiveTiles : Board.Size -> Board -> Board
addActiveTiles boardSize board =
    let
        radius =
            burstRadius board

        burstCoords =
            coordinates board

        burstAreaCoordinates =
            burstCoords
                |> List.map (Coord.surrounding boardSize radius)
                |> List.concat

        withinBurstArea move =
            List.member (Move.coord move) burstAreaCoordinates

        activeMoveType =
            Board.activeMoveType board

        nonBurstingMove move =
            not (withinBurstArea move) || activeMoveType /= Move.tile move

        nonBurstCoords =
            Board.moves board
                |> List.filter nonBurstingMove
                |> List.map Move.coord

        updateBlockToActive block =
            if activeMoveType == Block.tile block then
                Block.setToActive block

            else
                block

        updateToActive coord =
            Board.updateAt coord updateBlockToActive

        updateToStatic coord =
            Board.updateAt coord Block.setActiveToStatic
    in
    List.foldl updateToActive board burstAreaCoordinates
        |> (\updatedBoard -> List.foldl updateToStatic updatedBoard nonBurstCoords)



-- Burst


shouldBurst : Board -> Bool
shouldBurst =
    Board.activeMoves >> List.any (Move.block >> Block.isBurst)


isBursting : Board -> Bool
isBursting =
    Board.blocks >> List.any (\block -> Block.isBurst block && Block.isLeaving block)


burst : Board -> Board
burst board =
    let
        burstCoords =
            coordinates board

        withMoveOrder coord =
            Coord.x coord + (Coord.y coord * 8)

        updateActiveBlockToDragging coord block =
            case Block.tileState block of
                Active _ ->
                    Block.setToDragging (withMoveOrder coord) block

                _ ->
                    block

        updateBurstsToLeaving coord =
            Board.updateAt coord Block.setDraggingToLeaving

        updatedDraggingBoard =
            Board.update updateActiveBlockToDragging board
    in
    burstCoords
        |> List.foldl updateBurstsToLeaving updatedDraggingBoard
        |> Board.updateBlocks Block.clearBearing


burstRadius : Board -> Int
burstRadius board =
    let
        activeMoves =
            Board.activeMoves board

        numberOfBurstTiles =
            activeMoves
                |> List.filter (Move.block >> Block.isBurst)
                |> List.length
    in
    List.length activeMoves // 2 + numberOfBurstTiles


coordinates : Board -> List Coord
coordinates =
    Board.activeMoves
        >> List.filter (Move.block >> Block.isBurst)
        >> List.map Move.coord



-- Reset


reset : Board -> Board
reset =
    Board.updateBlocks Block.clearBurstType
