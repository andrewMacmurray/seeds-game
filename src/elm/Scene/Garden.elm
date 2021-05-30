module Scene.Garden exposing
    ( Model
    , Msg
    , getContext
    , init
    , menuOptions
    , update
    , updateContext
    , view
    )

import Config.Level as Level
import Config.World as Worlds
import Context exposing (Context)
import Element exposing (..)
import Element.Animations as Animations
import Element.Background as Background
import Element.Button as Button
import Element.Layout as Layout
import Element.Palette as Palette
import Element.Scale as Scale
import Element.Seed as Seed
import Element.Text as Text
import Exit exposing (continue, exit)
import Html exposing (Html)
import Level.Progress as Progress exposing (Progress)
import Ports.Scroll as Scroll
import Scene.Garden.Chrysanthemum as Chrysanthemum
import Scene.Garden.Cornflower as Cornflower
import Scene.Garden.Hills as Hills
import Scene.Garden.Sunflower as Sunflower
import Seed exposing (Seed(..))
import Simple.Animation as Animation exposing (Animation)
import Utils.Animated as Animated
import Utils.Delay exposing (after)
import Utils.Element as Element
import View.Menu as Menu



-- Model


type alias Model =
    { context : Context
    }


type Msg
    = ScrollToCurrentCompletedWorld
    | ExitToHub



-- Context


getContext : Model -> Context
getContext model =
    model.context


updateContext : (Context -> Context) -> Model -> Model
updateContext f model =
    { model | context = f model.context }


menuOptions : List (Menu.Option Msg)
menuOptions =
    [ Menu.option ExitToHub "Levels"
    ]



-- Init


init : Context -> ( Model, Cmd Msg )
init context =
    ( initialState context
    , after 500 ScrollToCurrentCompletedWorld
    )


initialState : Context -> Model
initialState context =
    { context = context
    }



-- Update


update : Msg -> Model -> Exit.Status ( Model, Cmd Msg )
update msg model =
    case msg of
        ScrollToCurrentCompletedWorld ->
            continue model [ scrollToCurrentCompletedWorld model.context.progress ]

        ExitToHub ->
            exit model


scrollToCurrentCompletedWorld : Progress -> Cmd msg
scrollToCurrentCompletedWorld =
    Progress.currentCompletedSeed
        >> Seed.name
        >> Scroll.toCenter



-- View


view : Model -> Html Msg
view model =
    Layout.view
        [ inFront backToLevelsButton

        --, inFront initialOverlay
        ]
        (el
            [ width fill
            , height fill
            , centerX
            ]
            (allFlowers model.context)
        )


initialOverlay : Element msg
initialOverlay =
    Animated.el fadeOut
        [ width fill
        , height fill
        , Background.color Palette.background1_
        , Element.disableTouch
        ]
        (el
            [ centerX
            , centerY
            ]
            (Animated.el fadeIn [] gardenText)
        )


gardenText : Element msg
gardenText =
    Text.text [ Text.wideSpaced, Text.large ] "GARDEN"


fadeOut : Animation
fadeOut =
    Animations.fadeOut 1500
        [ Animation.delay 3000
        , Animation.linear
        ]


fadeIn : Animation
fadeIn =
    Animations.fadeIn 1500
        [ Animation.linear
        ]


backToLevelsButton : Element Msg
backToLevelsButton =
    el
        [ alignBottom
        , centerX
        , paddingXY 0 Scale.extraLarge
        ]
        (Button.button
            [ Button.white
            , Button.small
            ]
            { onClick = ExitToHub
            , label = "BACK TO LEVELS"
            }
        )


allFlowers : Context -> Element Msg
allFlowers context =
    column
        [ centerX
        , alignBottom
        , width fill
        , height fill
        , behindContent (html (Hills.view context))
        ]
        (Worlds.list
            |> List.map (worldFlowers context)
            |> List.reverse
        )


worldFlowers : Context -> Level.WorldWithLevels -> Element Msg
worldFlowers context { world, levels } =
    if Progress.worldComplete levels context.progress then
        el [ width fill, height (px context.window.height) ]
            (column
                [ centerX
                , centerY
                , spacing Scale.medium
                , seedId world.seed
                ]
                [ flowers world.seed
                , seeds world.seed
                , flowerName world.seed
                ]
            )

    else
        el [ width fill, height (px context.window.height) ]
            (column
                [ seedId world.seed
                , spacing Scale.medium
                , centerX
                , centerY
                ]
                [ unfinishedWorldSeeds
                , Text.text [ centerX ] "These seeds need saving..."
                ]
            )


seedId : Seed -> Attribute msg
seedId seed =
    Element.id (Seed.name seed)


unfinishedWorldSeeds : Element msg
unfinishedWorldSeeds =
    row [ spacing Scale.small, centerX ]
        [ el [ alignBottom ] (Seed.grey (Seed.size 20))
        , el [ moveDown 2 ] (Seed.grey (Seed.size 30))
        , el [ alignBottom ] (Seed.grey (Seed.size 20))
        ]


flowerName : Seed -> Element msg
flowerName seed =
    Text.text
        [ Text.color (textColor seed)
        , Text.wideSpaced
        , Text.bold
        , centerX
        ]
        (String.toUpper (Seed.name seed))


seeds : Seed -> Element msg
seeds seed =
    row [ centerX, moveUp 20, spacing Scale.small ]
        [ el [ alignBottom ] (Seed.view (Seed.size 12) seed)
        , el [ moveDown 2 ] (Seed.view (Seed.size 20) seed)
        , el [ alignBottom ] (Seed.view (Seed.size 12) seed)
        ]


flowers : Seed -> Element msg
flowers seed =
    case seed of
        Sunflower ->
            Sunflower.flowers

        Chrysanthemum ->
            Chrysanthemum.flowers

        Cornflower ->
            Cornflower.flowers

        _ ->
            Sunflower.flowers


textColor : Seed -> Color
textColor seed =
    case seed of
        Sunflower ->
            Palette.white

        Chrysanthemum ->
            Palette.purple9

        Cornflower ->
            Palette.yellow1

        _ ->
            Palette.white
