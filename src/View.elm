module View exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onMouseDown, onMouseUp, onMouseEnter)
import Types exposing (..)
import StyleLinks


-- VIEW


view : Model -> Html Msg
view model =
    div [ onMouseUp StopDrag ]
        [ StyleLinks.tachyons
        , StyleLinks.mainStyle
        , div [ class "tc ma6" ]
            [ p [] [ text (toString model.currentTile) ]
            , button [ onClick ShuffleTiles, class "mb5 br1 bn pv2 ph3 bg-light-blue dark-blue" ] [ text "shuffle" ]
            , (renderBoard model.tiles)
            ]
        ]


renderBoard : List (List Tile) -> Html Msg
renderBoard tiles =
    div [] (List.map renderRow tiles)


renderRow : List Tile -> Html Msg
renderRow row =
    div [] (List.map renderTile row)


renderTile : Tile -> Html Msg
renderTile tile =
    div
        [ class ("br-100 w2 h2 dib mv1 mh2 " ++ (tileBackground tile.value))
        , onMouseDown (StartMove tile)
        , onMouseEnter (CheckTile tile)
        , onMouseUp StopDrag
        ]
        []


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
            "bg-light-brown"

        _ ->
            ""
