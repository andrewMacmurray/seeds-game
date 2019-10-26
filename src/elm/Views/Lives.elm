module Views.Lives exposing (view)

import Css.Style as Style exposing (..)
import Css.Transform exposing (scale)
import Html exposing (..)
import Html.Attributes exposing (class)
import Lives
import Views.Icons.Heart as Heart



-- Config


type alias Life =
    { active : Bool
    , currentLife : Bool
    , breaking : Bool
    }



-- View


view : Lives.Lives -> List (Html msg)
view lives =
    let
        remaining =
            Lives.remaining lives
    in
    List.range 1 Lives.max
        |> List.map (\n -> Life (n <= remaining) (n == remaining) (n == remaining + 1))
        |> List.map toLife


toLife : Life -> Html msg
toLife { active, currentLife, breaking } =
    let
        visibleHeart =
            if active then
                Heart.alive

            else if breaking then
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
