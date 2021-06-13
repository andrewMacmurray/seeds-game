module Game.Board.Move.Check exposing
    ( isNewNeighbour
    , sameActiveTileType
    )

import Game.Board as Board exposing (Board)
import Game.Board.Move as Move exposing (Move)


isNewNeighbour : Move -> Board -> Bool
isNewNeighbour move board =
    Move.areNeighbours move (Board.lastMove board) && not (Board.isActiveMove move board)


sameActiveTileType : Move -> Board -> Bool
sameActiveTileType move board =
    Move.sameTileType move (Board.lastMove board)
