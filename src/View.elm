module View exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Types exposing (..)


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


renderTile : Tile -> Html Msg
renderTile { value } =
    div [ class ("br-100 w2 h2 dib mv1 mh2 " ++ (tileBackground value)) ] []


renderRow : List Tile -> Html Msg
renderRow row =
    div [] (List.map renderTile row)


styleSheetNode : String -> Html Msg
styleSheetNode url =
    node "link" [ rel "stylesheet", href url ] []


view : Model -> Html Msg
view model =
    let
        board =
            List.map renderRow model.tiles

        tachyons =
            styleSheetNode "https://unpkg.com/tachyons@4.6.1/css/tachyons.min.css"

        mainStyle =
            styleSheetNode "/style.css"
    in
        div []
            [ tachyons
            , mainStyle
            , div [ class "tc ma6" ]
                [ button [ onClick ShuffleTiles, class "mb5 br1 bn pv2 ph3 bg-light-blue dark-blue" ] [ text "shuffle" ]
                , div [] board
                ]
            ]
