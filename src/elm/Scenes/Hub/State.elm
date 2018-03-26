module Scenes.Hub.State exposing (..)

import Data.InfoWindow as InfoWindow exposing (InfoWindow(..))
import Dom.Scroll
import Helpers.Delay exposing (sequenceMs)
import Ports exposing (receiveHubLevelOffset, scrollToHubLevel)
import Scenes.Hub.Types as Hub exposing (..)
import Task exposing (Task)
import Window


-- Update


update : HubMsg -> HubModel model -> ( HubModel model, Cmd HubMsg )
update msg model =
    case msg of
        SetInfoState infoWindow ->
            { model | hubInfoWindow = infoWindow } ! []

        ShowLevelInfo levelProgress ->
            { model | hubInfoWindow = Visible levelProgress } ! []

        HideLevelInfo ->
            model
                ! [ sequenceMs
                        [ ( 0, SetInfoState <| InfoWindow.toHiding model.hubInfoWindow )
                        , ( 1000, SetInfoState Hidden )
                        ]
                  ]

        ScrollHubToLevel level ->
            model ! [ scrollToHubLevel level ]

        ReceiveHubLevelOffset offset ->
            model ! [ scrollHubToLevel offset model.window ]

        DomNoOp _ ->
            model ! []



-- Update Helpers


scrollHubToLevel : Float -> Window.Size -> Cmd HubMsg
scrollHubToLevel offset window =
    let
        targetDistance =
            offset - toFloat (window.height // 2) + 60
    in
        Dom.Scroll.toY "hub" targetDistance |> Task.attempt DomNoOp



-- Subscriptions


subscriptions : HubModel model -> Sub HubMsg
subscriptions _ =
    receiveHubLevelOffset ReceiveHubLevelOffset
