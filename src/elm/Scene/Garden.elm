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

import Browser.Dom as Dom
import Config.Level as Level exposing (WorldConfig)
import Config.World as Worlds
import Context exposing (Context)
import Element exposing (..)
import Element.Animations as Animations
import Element.Background as Background
import Element.Border as Border
import Element.Input as Input
import Element.Palette as Palette
import Element.Scale as Scale
import Element.Text as Text
import Exit exposing (continue, exit)
import Html exposing (Html)
import Html.Attributes
import Level.Progress as Progress exposing (Progress)
import Scene.Garden.Chrysanthemum as Chrysanthemum
import Scene.Garden.Hills as Hills
import Scene.Garden.Sunflower as Sunflower
import Seed exposing (Seed(..))
import Simple.Animation as Animation exposing (Animation)
import Task exposing (Task)
import Utils.Animated as Animated
import Utils.Delay exposing (after)
import Utils.Element as Element
import View.Flower as Flower
import View.Menu as Menu
import View.Seed as Seed
import View.Seed.Mono exposing (greyedOutSeed)
import Window exposing (Window)



-- Model


type alias Model =
    { context : Context
    }


type Msg
    = ScrollToCurrentCompletedWorld
    | WorldScrolledToView
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

        WorldScrolledToView ->
            continue model []

        ExitToHub ->
            exit model


scrollToCurrentCompletedWorld : Progress -> Cmd Msg
scrollToCurrentCompletedWorld =
    Progress.currentCompletedSeed
        >> Seed.name
        >> Dom.getElement
        >> Task.andThen scrollWorldToView
        >> Task.attempt (always WorldScrolledToView)


scrollWorldToView : Dom.Element -> Task Dom.Error ()
scrollWorldToView el =
    Dom.setViewportOf "flowers" 0 (worldYOffset el)


worldYOffset : Dom.Element -> Float
worldYOffset { element, viewport } =
    element.y - viewport.height / 2 + element.height / 2



-- View


view : Model -> Html Msg
view model =
    layout
        [ inFront backToLevelsButton
        ]
        (el
            [ width fill
            , height fill
            , centerX
            ]
            (allFlowers model.context)
        )


layout : List (Attribute msg) -> Element msg -> Html msg
layout attrs =
    Element.layoutWith layoutOptions
        ([ width fill
         , height fill
         , Element.style "position" "absolute"
         , Element.style "z-index" "1"
         , Text.fonts
         ]
            ++ attrs
        )


layoutOptions : { options : List Option }
layoutOptions =
    { options =
        [ Element.focusStyle
            { borderColor = Nothing
            , backgroundColor = Nothing
            , shadow = Nothing
            }
        ]
    }


initialOverlay : Element msg
initialOverlay =
    Animated.el fadeOut
        [ width fill
        , height fill
        , Background.color Palette.lightYellow
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
        (Input.button []
            { onPress = Just ExitToHub
            , label = buttonLabel "BACK TO LEVELS"
            }
        )


buttonLabel : String -> Element msg
buttonLabel text =
    el
        [ Background.color Palette.white
        , paddingXY Scale.medium Scale.small
        , Border.rounded 20
        ]
        (Text.text
            [ Text.color Palette.black
            , Text.bold
            , Text.spaced
            , Text.small
            ]
            text
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
                [ seedId world.seed
                , centerX
                , centerY
                , spacing Scale.medium
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
    htmlAttribute (Html.Attributes.id (Seed.name seed))


unfinishedWorldSeeds : Element msg
unfinishedWorldSeeds =
    row [ spacing 5, centerX ]
        [ sized 20 (html greyedOutSeed)
        , sized 30 (html greyedOutSeed)
        , sized 20 (html greyedOutSeed)
        ]


flowerName : Seed -> Element msg
flowerName seed =
    Text.text
        [ Text.color Palette.white
        , Text.wideSpaced
        , Text.bold
        , centerX
        ]
        (String.toUpper (Seed.name seed))


seeds : Seed -> Element msg
seeds seed =
    row [ centerX, moveUp 20 ]
        [ el [ alignBottom ] (renderSeed 20 seed)
        , renderSeed 30 seed
        , el [ alignBottom ] (renderSeed 20 seed)
        ]


renderSeed : Int -> Seed -> Element msg
renderSeed size =
    sized size << html << Seed.view


flowers : Seed -> Element msg
flowers seed =
    case seed of
        Sunflower ->
            Sunflower.flowers

        Chrysanthemum ->
            Chrysanthemum.flowers

        _ ->
            let
                config =
                    flowerConfig seed
            in
            row [ moveDown config.seedOffset ]
                [ el [ alignBottom, moveRight config.offsetX ] (flower config.small seed)
                , el [ alignBottom, moveUp config.offsetY ] (flower config.large seed)
                , el [ alignBottom, moveLeft config.offsetX ] (flower config.small seed)
                ]


flower : Int -> Seed -> Element msg
flower size =
    el [ width (px size) ] << html << Flower.view


sized : Int -> Element msg -> Element msg
sized size =
    el [ width (px size), height (px size) ]



-- Config


type alias FlowerConfig number =
    { large : number
    , small : number
    , offsetX : number
    , offsetY : number
    , seedOffset : number
    }


flowerConfig : Seed -> FlowerConfig number
flowerConfig seed =
    case seed of
        Sunflower ->
            { large = 180
            , small = 100
            , offsetX = 45
            , offsetY = 25
            , seedOffset = 20
            }

        Chrysanthemum ->
            { large = 120
            , small = 80
            , offsetX = 10
            , offsetY = 50
            , seedOffset = 0
            }

        Cornflower ->
            { large = 170
            , small = 100
            , offsetX = 45
            , offsetY = 20
            , seedOffset = 20
            }

        _ ->
            { large = 150
            , small = 80
            , offsetX = Scale.small
            , offsetY = 20
            , seedOffset = 0
            }
