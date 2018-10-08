module Scenes.Hub.State exposing (init, update)

import Browser.Dom as Dom
import Data.InfoWindow as InfoWindow
import Data.Level.Types exposing (Progress)
import Data.Window as Window
import Exit exposing (continue, exitWithPayload)
import Helpers.Delay exposing (delay, sequence)
import Scenes.Hub.Types as Hub exposing (..)
import Shared
import Task exposing (Task)


init : Int -> Shared.Data -> ( HubModel, Cmd HubMsg )
init levelNumber shared =
    ( initialState shared
    , delay 1000 <| ScrollHubToLevel levelNumber
    )


initialState : Shared.Data -> HubModel
initialState shared =
    { shared = shared
    , infoWindow = InfoWindow.hidden
    }



-- Update


update : HubMsg -> HubModel -> Exit.WithPayload Progress ( HubModel, Cmd HubMsg )
update msg model =
    case msg of
        SetInfoState infoWindow ->
            continue { model | infoWindow = infoWindow } []

        ShowLevelInfo levelProgress ->
            continue { model | infoWindow = InfoWindow.show levelProgress } []

        HideLevelInfo ->
            continue model
                [ sequence
                    [ ( 0, SetInfoState <| InfoWindow.leave model.infoWindow )
                    , ( 1000, SetInfoState InfoWindow.hidden )
                    ]
                ]

        ScrollHubToLevel level ->
            continue model [ scrollHubToLevel level ]

        DomNoOp _ ->
            continue model []

        StartLevel level ->
            exitWithPayload level model []



-- Update Helpers


scrollHubToLevel : Int -> Cmd HubMsg
scrollHubToLevel levelNumber =
    getLevelId levelNumber
        |> Dom.getElement
        |> Task.andThen scrollLevelToView
        |> Task.attempt DomNoOp


scrollLevelToView : Dom.Element -> Task Dom.Error ()
scrollLevelToView { element, viewport } =
    Dom.setViewportOf "hub" 0 <| element.y - viewport.height / 2


getLevelId : Int -> String
getLevelId levelNumber =
    "level-" ++ String.fromInt levelNumber
