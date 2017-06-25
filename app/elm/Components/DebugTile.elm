module Components.DebugTile exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Model exposing (..)


debugTile : Coord -> Html Msg
debugTile coord =
    p [ class debugClasses ] [ text <| toString coord ]


debugTileState : TileState -> Html Msg
debugTileState tileState =
    p [ class debugClasses ] [ text <| toString tileState ]


debugClasses : String
debugClasses =
    "absolute left-0 right-0 f6 no-select mid-gray"
