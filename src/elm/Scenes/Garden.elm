module Scenes.Garden exposing
    ( Model
    , Msg
    , getContext
    , init
    , update
    , updateContext
    , view
    )

import Context exposing (Context)
import Css.Animation as Animation
import Css.Color as Color
import Css.Style as Style exposing (..)
import Data.Board.Tile exposing (seedName)
import Data.Board.Types exposing (SeedType(..))
import Data.Window exposing (Window)
import Exit exposing (exit)
import Html exposing (Html, div, p, text)
import Html.Attributes exposing (class)
import Views.Flowers.All exposing (renderFlower)
import Views.Seed.All exposing (renderSeed)
import Worlds



-- Model


type alias Model =
    { context : Context }


type Msg
    = ExitToHub



-- Context


getContext : Model -> Context
getContext model =
    model.context


updateContext : (Context -> Context) -> Model -> Model
updateContext f model =
    { model | context = f model.context }



-- Init


init : Context -> ( Model, Cmd Msg )
init context =
    ( initialState context, Cmd.none )


initialState : Context -> Model
initialState context =
    { context = context }



-- Update


update : Msg -> Model -> Exit.Status ( Model, Cmd Msg )
update msg model =
    case msg of
        ExitToHub ->
            exit model



-- View


view : Model -> Html Msg
view model =
    div [ class "w-100 z-1" ]
        [ initialOverlay model.context.window
        , div [ class "w-100 absolute overflow-y-scroll momentum-scroll z-2" ]
            [ div [ style [ marginTop 50, marginBottom 50 ], class "flex flex-column items-center" ] allFlowers ]
        ]


initialOverlay : Window -> Html msg
initialOverlay window =
    div
        [ style
            [ background Color.lightYellow
            , height <| toFloat window.height
            , Animation.animation "fade-out" 1000 [ Animation.linear, Animation.delay 2500 ]
            ]
        , class "w-100 ttu tracked-mega f3 z-3 fixed flex items-center justify-center"
        ]
        [ p
            [ style
                [ color Color.darkYellow
                , opacity 0
                , Animation.animation "fade-in" 1000 [ Animation.linear, Animation.delay 500 ]
                ]
            ]
            [ text "Garden" ]
        ]


allFlowers =
    Worlds.list
        |> List.map (Tuple.first >> .seedType)
        |> List.reverse
        |> List.map worldFlowers


worldFlowers seedType =
    div
        [ style
            [ marginTop 50
            , marginBottom 50
            ]
        ]
        [ flowers seedType
        , seeds seedType
        , flowerName seedType
        ]


flowerName seedType =
    p [ style [ color Color.darkYellow ], class "tc ttu tracked-ultra" ]
        [ text <| seedName seedType ]


seeds seedType =
    div [ style [ marginTop -20, marginBottom 30 ], class "flex items-end justify-center" ]
        [ seed 20 seedType
        , seed 30 seedType
        , seed 20 seedType
        ]


seed size seedType =
    sized size <| renderSeed seedType


flowers seedType =
    let
        spacing =
            flowerSpacing seedType
    in
    div [ class "flex items-end justify-center" ]
        [ div [ style [ marginRight spacing.offsetX ] ] [ flower spacing.small seedType ]
        , div [ style [ marginBottom spacing.offsetY ] ] [ flower spacing.large seedType ]
        , div [ style [ marginLeft spacing.offsetX ] ] [ flower spacing.small seedType ]
        ]


flower size seedType =
    sized size <| renderFlower seedType


sized size element =
    div [ style [ width size, height size ] ] [ element ]


flowerSpacing seedType =
    case seedType of
        Sunflower ->
            { large = 150
            , small = 80
            , offsetX = -30
            , offsetY = 20
            }

        Chrysanthemum ->
            { large = 120
            , small = 80
            , offsetX = 0
            , offsetY = 30
            }

        Cornflower ->
            { large = 170
            , small = 100
            , offsetX = -45
            , offsetY = 20
            }

        _ ->
            { large = 150
            , small = 80
            , offsetX = 30
            , offsetY = 20
            }
