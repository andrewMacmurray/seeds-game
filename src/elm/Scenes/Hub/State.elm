module Scenes.Hub.State exposing (init, scrollHubToLevel, subscriptions, update)

import Data.InfoWindow as InfoWindow
import Data.Window as Window
import Delay exposing (after)
import Helpers.Delay exposing (sequenceMs)
import Ports exposing (receiveHubLevelOffset, scrollToHubLevel)
import Scenes.Hub.Types as Hub exposing (..)
import Task exposing (Task)


init : Int -> HubModel model -> ( HubModel model, Cmd HubMsg )
init levelNumber model =
    ( model
    , after 1000 Delay.Millisecond <| ScrollHubToLevel levelNumber
    )



-- Update


update : HubMsg -> HubModel model -> ( HubModel model, Cmd HubMsg )
update msg model =
    case msg of
        SetInfoState infoWindow ->
            ( { model | hubInfoWindow = infoWindow }
            , Cmd.none
            )

        ShowLevelInfo levelProgress ->
            ( { model | hubInfoWindow = InfoWindow.show levelProgress }
            , Cmd.none
            )

        HideLevelInfo ->
            ( model
            , sequenceMs
                [ ( 0, SetInfoState <| InfoWindow.leave model.hubInfoWindow )
                , ( 1000, SetInfoState InfoWindow.hidden )
                ]
            )

        ScrollHubToLevel level ->
            ( model
            , scrollToHubLevel level
            )

        ReceiveHubLevelOffset offset ->
            ( model
            , scrollHubToLevel offset model.window
            )

        DomNoOp _ ->
            ( model
            , Cmd.none
            )



-- Update Helpers


scrollHubToLevel : Float -> Window.Size -> Cmd HubMsg
scrollHubToLevel offset window =
    let
        targetDistance =
            offset - toFloat (window.height // 2) + 20
    in
    -- Dom.Scroll.toY "hub" targetDistance |> Task.attempt DomNoOp
    -- FIXME
    Cmd.none



-- Subscriptions


subscriptions : HubModel model -> Sub HubMsg
subscriptions _ =
    receiveHubLevelOffset ReceiveHubLevelOffset
