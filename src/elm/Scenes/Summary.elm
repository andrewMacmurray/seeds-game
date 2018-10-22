module Scenes.Summary exposing
    ( Model
    , Msg
    , getShared
    , init
    , update
    , updateShared
    , view
    )

import Css.Animation exposing (animation, delay, linear)
import Css.Color exposing (gold, rainBlue, washedYellow)
import Css.Style as Style exposing (..)
import Css.Transform exposing (translateX, translateY)
import Data.Board.Types exposing (..)
import Data.Exit as Exit exposing (continue, exitWith)
import Data.Level.Summary exposing (..)
import Data.Levels as Levels
import Data.Wave exposing (wave)
import Helpers.Delay exposing (after, trigger)
import Html exposing (..)
import Html.Attributes exposing (class)
import Ports exposing (cacheProgress)
import Shared
import Views.Icons.RainBank exposing (..)
import Views.Icons.SeedBank exposing (seedBank)
import Views.Icons.SunBank exposing (sunBank, sunBankFull)
import Views.Seed.All exposing (renderSeed)
import Worlds



-- Model


type alias Model =
    { shared : Shared.Data
    , resources : Resources
    }


type Msg
    = IncrementProgress
    | CacheProgress
    | BackToHub


type Resources
    = Waiting
    | Filling



-- Shared


getShared : Model -> Shared.Data
getShared model =
    model.shared


updateShared : (Shared.Data -> Shared.Data) -> Model -> Model
updateShared f model =
    { model | shared = f model.shared }



-- Init


init : Shared.Data -> ( Model, Cmd Msg )
init shared =
    ( initialState shared
    , after 1500 IncrementProgress
    )


initialState : Shared.Data -> Model
initialState shared =
    { shared = shared
    , resources = Waiting
    }



-- Update


update : Msg -> Model -> Exit.With Levels.Key ( Model, Cmd Msg )
update msg model =
    case msg of
        IncrementProgress ->
            continue (incrementProgress model)
                [ trigger CacheProgress
                , after 2500 BackToHub
                ]

        CacheProgress ->
            continue model [ cacheProgress <| Levels.toCache model.shared.progress ]

        BackToHub ->
            exitWith model.shared.progress model []


incrementProgress : Model -> Model
incrementProgress model =
    { model
        | resources = Filling
        , shared =
            model.shared
                |> Shared.incrementProgress Worlds.all
                |> Shared.incrementMessageIndex
    }



-- View


view : Model -> Html Msg
view { shared } =
    let
        primarySeed =
            Worlds.seedType shared.progress |> Maybe.withDefault Sunflower

        resources =
            secondaryResourceTypes shared.progress |> Maybe.withDefault []
    in
    div
        [ style
            [ height <| toFloat shared.window.height
            , background washedYellow
            , animation "fade-in" 1000 [ linear ]
            ]
        , class "fixed z-5 flex justify-center items-center w-100 top-0 left-0"
        ]
        [ div [ style [ marginTop -100 ] ]
            [ div
                [ style
                    [ width 65
                    , marginBottom 30
                    ]
                , class "center"
                ]
                [ seedBank primarySeed <| percentComplete (Seed primarySeed) shared.progress ]
            , div [ style [ height 50 ] ] <| List.map (renderResourceBank shared.progress shared.currentLevel) resources
            ]
        ]


renderResourceBank : Levels.Key -> Maybe Levels.Key -> TileType -> Html msg
renderResourceBank progress currentLevel tileType =
    let
        fillLevel =
            percentComplete tileType progress
    in
    case tileType of
        Rain ->
            div [ style [ width 40 ], class "dib ph1 mh4" ]
                [ renderResourceFill tileType
                , rainBank fillLevel
                ]

        Sun ->
            div [ style [ width 40 ], class "dib mh4" ]
                [ renderResourceFill tileType
                , sunBank fillLevel
                ]

        Seed seedType ->
            div [ style [ width 40 ], class "dib ph1 mh4" ]
                [ renderResourceFill tileType
                , seedBank seedType fillLevel
                ]

        _ ->
            span [] []


renderResourceFill : TileType -> Html msg
renderResourceFill tileType =
    case tileType of
        Rain ->
            div [ style [ height 50 ] ]
                [ div [ style [ width 13 ], class "center" ] [ rainBankFull ]
                , div [ class "relative" ] <| List.map (drop rainBlue) <| List.range 1 50
                ]

        Sun ->
            div [ style [ height 50 ] ]
                [ div [ style [ width 18 ], class "center" ] [ sunBankFull ]
                , div [ class "relative" ] <| List.map (drop gold) <| List.range 4 54
                ]

        Seed seedType ->
            div [ style [ height 50 ] ]
                [ div [ style [ width 15 ], class "center" ] [ renderSeed seedType ]
                , div [ class "relative", style [ transform [ translateY -10 ] ] ] <| List.map (seedDrop seedType) <| List.range 7 57
                ]

        _ ->
            span [] []


seedDrop : SeedType -> Int -> Html msg
seedDrop seedType n =
    div
        [ style [ transform [ translateX <| wave { left = -5, center = 0, right = 5 } (n - 1) ] ] ]
        [ div
            [ style
                [ width 5
                , height 8
                , opacity 0
                , animation "fade-slide-down" 150 [ delay <| n * dropDelay n, linear ]
                ]
            , class "absolute top-0 left-0 right-0 center"
            ]
            [ renderSeed seedType ]
        ]


drop : String -> Int -> Html msg
drop bgColor n =
    div
        [ style [ transform [ translateX <| wave { left = -5, center = 0, right = 5 } (n - 1) ] ] ]
        [ div
            [ style
                [ width 6
                , height 6
                , background bgColor
                , opacity 0
                , animation "fade-slide-down" 150 [ delay (n * dropDelay n), linear ]
                ]
            , class "br-100 absolute left-0 right-0 center"
            ]
            []
        ]


dropDelay : Int -> Int
dropDelay n =
    if modBy 3 n == 0 then
        30

    else if modBy 3 n == 1 then
        60

    else
        90
