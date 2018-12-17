module Views.Lives exposing (renderLivesLeft)

import Css.Animation exposing (animation, ease, infinite)
import Css.Style as Style exposing (..)
import Css.Transform exposing (scale)
import Data.Transit as Transit exposing (Transit)
import Html exposing (..)
import Html.Attributes exposing (class)
import Views.Icons.Heart as Heart


type alias Life =
    { active : Bool
    , currentLife : Bool
    , breaking : Bool
    , lifeState : Transit Int
    }


renderLivesLeft : Transit Int -> List (Html msg)
renderLivesLeft lifeState =
    let
        lives =
            Transit.val lifeState
    in
    List.range 1 5
        |> List.map (\n -> Life (n <= lives) (n == lives) (n == lives + 1) lifeState)
        |> List.map life


life : Life -> Html msg
life { active, currentLife, breaking, lifeState } =
    let
        visibleHeart =
            if active then
                Heart.alive

            else if breaking && Transit.isTransitioning lifeState then
                Heart.breaking

            else
                Heart.broken
    in
    div
        [ style
            [ width 35
            , height 35
            , marginLeft 10
            , marginRight 10
            , Style.applyIf (not active) <| transform [ scale 1.11 ]
            , Style.applyIf currentLife Heart.beatingAnimation
            ]
        , class "dib"
        ]
        [ visibleHeart ]
