module View exposing (..)

import Components.Backdrop exposing (backdrop)
import Html exposing (..)
import Html.Attributes exposing (class)
import Html.Events exposing (onMouseUp)
import Model exposing (..)
import Views.Board exposing (renderBoard)


view : Model -> Html Msg
view model =
    let
        debugMove =
            model.currentMove
                |> Maybe.map (List.map Tuple.first)
                |> toString
    in
        div [ onMouseUp StopMove ]
            [ renderBoard model
            , p [ class "tc relative z-5" ] [ text debugMove ]
            , backdrop model
            ]
