module View.Menu exposing
    ( Model
    , Option
    , Options
    , State
    , closed
    , disabled
    , hidden
    , open
    , option
    , view
    )

import Element exposing (..)
import Element.Animations as Animations
import Element.Background as Background
import Element.Events exposing (onClick)
import Element.Icon.Cog as Cog
import Element.Layout as Layout
import Element.Palette as Palette
import Element.Scale as Scale
import Element.Text as Text
import Element.Transition as Transition
import Simple.Animation as Animation exposing (Animation)
import Utils.Animated as Animated
import Utils.Element as Element
import Window exposing (Window)



-- Menu


type alias Options msg =
    { onOpen : msg
    , onClose : msg
    , onReset : msg
    }


type alias Model model =
    { model
        | window : Window
        , menu : State
    }


type State
    = Open
    | Closed
    | Disabled


type Option msg
    = Option (Option_ msg)


type alias Option_ msg =
    { msg : msg
    , text : String
    }



-- State


open : State
open =
    Open


closed : State
closed =
    Closed


disabled : State
disabled =
    Disabled



-- Option


option : msg -> String -> Option msg
option msg text =
    Option
        { msg = msg
        , text = text
        }



-- View


hidden : Layout.Overlay msg
hidden =
    Layout.overlay [ Element.disableTouch ]
        (Animated.el (fadeOut 1000)
            [ alignTop
            , alignRight
            , padding Scale.medium
            ]
            Cog.inactive
        )


fadeOut : Animation.Millis -> Animation
fadeOut duration =
    Animations.fadeOut duration []


view :
    Options msg
    -> (sceneMsg -> msg)
    -> List (Option sceneMsg)
    -> Model model
    -> Layout.Overlay msg
view options msg sceneOptions model =
    Layout.overlay
        [ width fill
        , height fill
        , behindContent (overlay options model)
        , disableWhenHidden model
        ]
        (el
            [ alignTop
            , alignRight
            , height fill
            , inFront (cog options model)
            ]
            (drawer options msg sceneOptions model)
        )


disableWhenHidden : Model model -> Attribute msg
disableWhenHidden model =
    case model.menu of
        Open ->
            Element.empty

        _ ->
            Element.disableTouch


overlay : Options msg -> Model model -> Element msg
overlay options model =
    el
        [ width fill
        , height fill
        , Background.color Palette.black
        , Transition.alpha 300
        , handleOverlayClick options model
        , overlayAlpha model
        ]
        none


handleOverlayClick : Options msg -> Model model -> Attribute msg
handleOverlayClick options model =
    case model.menu of
        Open ->
            onClick options.onClose

        _ ->
            Element.disableTouch


overlayAlpha : Model model -> Attribute msg
overlayAlpha model =
    case model.menu of
        Open ->
            alpha 0.6

        _ ->
            alpha 0


cog : Options msg -> Model model -> Element msg
cog options model =
    el
        [ alignRight
        , pointer
        , handleCogClick options model
        , cogRotation model
        , Transition.transform 300
        , padding Scale.medium
        ]
        (cog_ model)


cogRotation : Model model -> Attribute msg
cogRotation model =
    case model.menu of
        Open ->
            rotate (degrees 180)

        _ ->
            rotate 0


cog_ : Model model -> Element msg
cog_ model =
    case model.menu of
        Open ->
            Cog.active

        _ ->
            Cog.inactive


handleCogClick : Options msg -> Model model -> Attribute msg
handleCogClick options model =
    case model.menu of
        Open ->
            onClick options.onClose

        Closed ->
            onClick options.onOpen

        Disabled ->
            Element.disableTouch


drawer : Options msg -> (sceneMsg -> msg) -> List (Option sceneMsg) -> Model model -> Element msg
drawer options msg sceneOptions model =
    column
        [ width (px drawerWidth)
        , drawerOffset model
        , onClick options.onOpen
        , Transition.transform 300
        , height fill
        , alignRight
        , Palette.seedPodBackground
        ]
        [ attribution
        ]


drawerOffset : Model model -> Attribute msg
drawerOffset model =
    case model.menu of
        Open ->
            moveRight 0

        _ ->
            moveRight drawerWidth


drawerWidth : number
drawerWidth =
    240



-- Attribution


attribution : Element msg
attribution =
    newTabLink
        [ centerY
        , alignRight
        ]
        { url = "https://github.com/andrewMacmurray/seeds-game"
        , label = attribution_
        }


attribution_ : Element msg
attribution_ =
    Text.text
        [ Text.white
        , padding Scale.medium
        , Text.f6
        ]
        "A game by Andrew MacMurray"
