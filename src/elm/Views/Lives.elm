module Views.Lives exposing (life, renderLivesLeft)

import Css.Animation exposing (animation, ease, infinite)
import Css.Style as Style exposing (..)
import Css.Transform exposing (scale)
import Data.Transit as Transit exposing (Transit)
import Html exposing (..)
import Html.Attributes exposing (class)
import Views.Icons.Heart exposing (..)


type alias Heart =
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
        |> List.map (\n -> Heart (n <= lives) (n == lives) (n == lives + 1) lifeState)
        |> List.map life


life : Heart -> Html msg
life { active, currentLife, breaking, lifeState } =
    let
        animationStyles =
            if currentLife then
                animation "heartbeat" 1000 [ ease, infinite ]

            else
                Style.empty

        visibleHeart =
            if active then
                heart

            else if breaking && Transit.isTransitioning lifeState then
                breakingHeart

            else
                brokenHeart

        adjustScale =
            if active then
                empty

            else
                transform [ scale 1.11 ]
    in
    div
        [ style
            [ width 35
            , height 35
            , marginLeft 10
            , marginRight 10
            , adjustScale
            , animationStyles
            ]
        , class "dib"
        ]
        [ visibleHeart ]
