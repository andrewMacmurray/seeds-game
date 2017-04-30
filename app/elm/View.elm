module View exposing (..)

import Model exposing (..)
import Html exposing (..)
import Html.Attributes exposing (class)
import Html.Events exposing (onMouseUp)
import Views.Board exposing (renderBoard)
import Components.Backdrop exposing (backdrop)


view : Model -> Html Msg
view model =
    let
        debugMove =
            model.currentMove
                |> List.map Tuple.first
                |> toString
    in
        div [ onMouseUp StopMove ]
            [ renderBoard model
            , p [ class "tc relative z-5" ] [ text debugMove ]
            , backdrop model
            ]
