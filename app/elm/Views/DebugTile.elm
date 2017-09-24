module Views.DebugTile exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Data.Level.Types exposing (..)


debugCoord : Coord -> Html msg
debugCoord coord =
    p [ class debugClasses ] [ text <| toString coord ]


debugTileState : TileState -> Html msg
debugTileState tileState =
    p [ class debugClasses ] [ text <| toString tileState ]


debugClasses : String
debugClasses =
    "absolute left-0 right-0 f6 no-select mid-gray"
