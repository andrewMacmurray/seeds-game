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
import Element.Events exposing (onClick)
import Element.Input as Input
import Element.Palette as Palette
import Element.Scale as Scale
import Element.Text as Text
import Exit exposing (continue, exit)
import Html exposing (Html)
import Html.Attributes
import Level.Progress as Progress exposing (Progress)
import Scene.Garden.Chrysanthemum as Chrysanthemum
import Scene.Garden.Flower as GardenFlower
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



-- Model


type alias Model =
    { context : Context
    , flower : SelectedFlower
    }


type Msg
    = ScrollToCurrentCompletedWorld
    | WorldScrolledToView
    | ViewFlowerClicked Seed
    | HideFlowerClicked Seed
    | ClearFlower
    | ExitToHub


type SelectedFlower
    = Hidden
    | Leaving Seed
    | Visible Seed



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
    , flower = Hidden
    }



-- Update


update : Msg -> Model -> Exit.Status ( Model, Cmd Msg )
update msg model =
    case msg of
        ScrollToCurrentCompletedWorld ->
            continue model [ scrollToCurrentCompletedWorld model.context.progress ]

        WorldScrolledToView ->
            continue model []

        ViewFlowerClicked seed ->
            continue { model | flower = Visible seed } []

        HideFlowerClicked seed ->
            continue { model | flower = Leaving seed } [ after 1000 ClearFlower ]

        ClearFlower ->
            continue { model | flower = Hidden } []

        ExitToHub ->
            exit model


scrollToCurrentCompletedWorld : Progress -> Cmd Msg
scrollToCurrentCompletedWorld progress =
    progress
        |> (currentCompletedWorldSeedType >> Seed.name)
        |> Dom.getElement
        |> Task.andThen scrollWorldToView
        |> Task.attempt (always WorldScrolledToView)


scrollWorldToView : Dom.Element -> Task Dom.Error ()
scrollWorldToView el =
    Dom.setViewportOf "flowers" 0 (worldYOffset el)


worldYOffset : Dom.Element -> Float
worldYOffset { element, viewport } =
    element.y - viewport.height / 2 + element.height / 2


currentCompletedWorldSeedType : Progress -> Seed
currentCompletedWorldSeedType progress =
    Worlds.list
        |> List.filter (\( _, keys ) -> worldComplete progress keys)
        |> List.reverse
        |> List.head
        |> Maybe.map (Tuple.first >> .seed)
        |> Maybe.withDefault Sunflower


worldComplete : Progress -> List Level.Id -> Bool
worldComplete progress levelKeys =
    levelKeys
        |> List.reverse
        |> List.head
        |> Maybe.map (\l -> Level.completed (Progress.reachedLevel progress) l)
        |> Maybe.withDefault False



-- View


view : Model -> Html Msg
view model =
    layout
        [ inFront backToLevelsButton
        , inFront initialOverlay
        , inFront (viewSelectedFlower model)
        ]
        (el
            [ width fill
            , height fill
            , centerX
            ]
            (allFlowers model.context.progress)
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
    el [ alignBottom, centerX, paddingXY 0 Scale.extraLarge ]
        (Input.button []
            { onPress = Just ExitToHub
            , label = buttonLabel "BACK TO LEVELS"
            }
        )


buttonLabel : String -> Element msg
buttonLabel text =
    el
        [ Background.color Palette.darkBrown
        , paddingXY Scale.medium Scale.small
        , Border.rounded 20
        ]
        (Text.text
            [ Text.color Palette.white
            , Text.spaced
            , Text.small
            ]
            text
        )


allFlowers : Progress -> Element Msg
allFlowers progress =
    column
        [ paddingXY Scale.medium (Scale.extraLarge * 2)
        , spacing (Scale.extraLarge * 2)
        , centerX
        , alignBottom
        ]
        (Worlds.list
            |> List.reverse
            |> List.map (worldFlowers progress)
        )


worldFlowers : Progress -> ( WorldConfig, List Level.Id ) -> Element Msg
worldFlowers progress ( { seed }, levelKeys ) =
    if worldComplete progress levelKeys then
        column
            [ seedId seed
            , centerX
            , onClick (ViewFlowerClicked seed)
            , pointer
            , spacing Scale.medium
            ]
            [ flowers seed
            , seeds seed
            , flowerName seed
            ]

    else
        column
            [ seedId seed
            , centerX
            ]
            [ unfinishedWorldSeeds
            , Text.text [ centerX ] "..."
            ]


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
    Text.text [ Text.wideSpaced, centerX ] (String.toUpper (Seed.name seed))


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



-- Selected Flower


viewSelectedFlower : Model -> Element Msg
viewSelectedFlower model =
    case model.flower of
        Hidden ->
            none

        Leaving seed ->
            viewFlower seed (hiddenConfig model seed)

        Visible seed ->
            viewFlower seed (visibleConfig model seed)


viewFlower : Seed -> GardenFlower.Config msg -> Element msg
viewFlower seed =
    case seed of
        Sunflower ->
            Sunflower.view

        Chrysanthemum ->
            Chrysanthemum.view

        _ ->
            Sunflower.view


visibleConfig : Model -> Seed -> GardenFlower.Config Msg
visibleConfig model seed =
    { window = model.context.window
    , isVisible = True
    , onHide = HideFlowerClicked seed
    }


hiddenConfig : Model -> Seed -> GardenFlower.Config Msg
hiddenConfig model seed =
    { window = model.context.window
    , isVisible = False
    , onHide = HideFlowerClicked seed
    }



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


flowerDescription : Seed -> String
flowerDescription seed =
    case seed of
        Sunflower ->
            "Sunflowers are native to North America but bloom across the world. During growth their bright yellow flowers turn to face the sun. Their seeds are an important food source for both humans and animals."

        Chrysanthemum ->
            "Chrysanthemums are native to Asia and Northeastern Europe, with the largest variety in China. They bloom early in Autumn, in many different colours and shapes. The Ancient Chinese used Chrysanthemum roots in pain relief medicine."

        Cornflower ->
            "Cornflowers are a wildflower native to Europe. In the past their bright blue heads could be seen amongst fields of corn. They are now endangered in their natural habitat from Agricultural intensification."

        _ ->
            ""
