module View exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onMouseDown, onMouseUp, onMouseEnter)
import Types exposing (..)
import StyleLinks


-- VIEW


view : Model -> Html Msg
view model =
    div [ onMouseUp StopMove ]
        [ StyleLinks.tachyons
        , StyleLinks.mainStyle
        , div [ class "tc ma6" ]
            [ p [] [ text (toString model.currentTile) ]
            , p [] [ text (toString (List.map .coord model.currentMove)) ]
            , button [ onClick ShuffleTiles, class "mb5 br1 bn pv2 ph3 bg-light-blue dark-blue" ] [ text "shuffle" ]
            , (renderBoard model.currentMove model.tiles)
            ]
        ]


renderBoard : List Tile -> List (List Tile) -> Html Msg
renderBoard currentMove tiles =
    div [] (List.map (renderRow currentMove) tiles)


renderRow : List Tile -> List Tile -> Html Msg
renderRow currentMove row =
    div [] (List.map (renderTile currentMove) row)


renderTile : List Tile -> Tile -> Html Msg
renderTile currentMove tile =
    div
        [ class "pv1 ph2 dib pointer"
        , onMouseDown (StartMove tile)
        , onMouseEnter (CheckTile tile)
        , onMouseUp StopMove
        ]
        [ div
            [ class
                ("br-100 w2 h2 dib full-scale transition-300 "
                    ++ (tileBackground tile.value)
                    ++ " "
                    ++ (renderDragging tile currentMove)
                )
            ]
            []
        ]


tileBackground : Int -> String
tileBackground tile =
    case tile of
        1 ->
            "bg-light-blue"

        2 ->
            "bg-light-orange"

        3 ->
            "bg-seed-pod"

        4 ->
            "bg-seed"

        _ ->
            ""


renderDragging : Tile -> List Tile -> String
renderDragging tile currentMove =
    if (List.member tile currentMove) then
        "half-scale"
    else
        ""
