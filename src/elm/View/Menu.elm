module View.Menu exposing
    ( Option
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
import Element.Icon.Cog as Cog
import Element.Palette as Palette
import Element.Scale as Scale
import Utils.Animated as Animated
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


hidden : Element msg
hidden =
    Animated.el (fadeOut 1000)
        [ alignTop
        , alignRight
        , padding Scale.medium
        ]
        (Cog.icon Palette.darkYellow)


fadeOut duration =
    Animations.fadeOut duration []


view : Options msg -> Model model -> (sceneMsg -> msg) -> List (Option sceneMsg) -> Element msg
view options model sceneMsg sceneSpecificOptions =
    --Debug.todo ""
    none



--    div []
--        [ div
--            [ class "fixed pointer right-1 top-1 z-9"
--            , withDisable model.menu
--            , style [ animation "fade-in" 500 ]
--            ]
--            [ menuDrawerButton options model ]
--        , div [ class "fixed z-8 top-0", enableWhenOpen model.menu ]
--            [ overlay options model
--            , drawer options model sceneMsg sceneSpecificOptions
--            ]
--        ]
--
--
--overlay : Options msg -> Model model -> Html msg
--overlay msg model =
--    let
--        visibility =
--            case model.menu of
--                Open ->
--                    opacity 0.6
--
--                _ ->
--                    opacity 0
--    in
--    div
--        [ style
--            [ height (toFloat model.window.height)
--            , width (toFloat model.window.width)
--            , backgroundColor Color.black
--            , visibility
--            , transitionAll 300 []
--            ]
--        , enableWhenOpen model.menu
--        , onClick msg.onClose
--        ]
--        []
--
--
--drawer : Options msg -> Model model -> (sceneMsg -> msg) -> List (Option sceneMsg) -> Html msg
--drawer options model sceneMsg sceneMenuOptions =
--    let
--        drawerWidth =
--            240
--
--        renderSceneButton =
--            renderOption >> Html.map sceneMsg
--
--        drawerOffset =
--            case model.menu of
--                Open ->
--                    transform [ translateX 0 ]
--
--                _ ->
--                    transform [ translateX drawerWidth ]
--
--        resetButtonMargin =
--            if List.length sceneMenuOptions == 0 then
--                0
--
--            else
--                75
--    in
--    div
--        [ style
--            [ Style.background Color.seedPodGradient
--            , height (toFloat model.window.height)
--            , color Color.white
--            , width drawerWidth
--            , drawerOffset
--            , transitionAll 300 []
--            ]
--        , attribute "touch-action" "none"
--        , class "absolute right-0 top-0 flex flex-column items-center justify-center"
--        ]
--        (List.concat
--            [ List.map renderSceneButton sceneMenuOptions
--            , [ div [ style [ marginTop resetButtonMargin ] ] [ menuButtonBorder options.onReset "Reset Data" ]
--              , attributionLink
--              , closeMenuCaptureArea options
--              ]
--            ]
--        )
--
--
--closeMenuCaptureArea : Options msg -> Html msg
--closeMenuCaptureArea msg =
--    div
--        [ class "w-100 h-100 z-6 absolute top-0 left-0"
--        , Touch.onRelease_ msg.onClose
--        ]
--        []
--
--
--attributionLink : Html msg
--attributionLink =
--    a
--        [ style [ color Color.white ]
--        , class "absolute db bottom-1 z-9 left-1 f7 ma0 no-underline"
--        , href "https://github.com/andrewMacmurray/seeds-game"
--        , target "_blank"
--        ]
--        [ text "A game by Andrew MacMurray" ]
--
--
--withDisable : State -> Attribute msg
--withDisable menu =
--    case menu of
--        Disabled ->
--            class "touch-disabled"
--
--        _ ->
--            Attribute.empty
--
--
--renderOption : Option msg -> Html msg
--renderOption (Option { msg, text }) =
--    menuButtonSolid msg Color.white Color.lightGold text
--
--
--enableWhenOpen : State -> Attribute msg
--enableWhenOpen menu =
--    case menu of
--        Open ->
--            Attribute.empty
--
--        _ ->
--            class "touch-disabled"
--
--
--menuButtonSolid : msg -> Color.Color -> Color.Color -> String -> Html msg
--menuButtonSolid msg textColor bgColor content =
--    button
--        [ style
--            [ borderNone
--            , backgroundColor bgColor
--            , width 150
--            , color textColor
--            ]
--        , class "outline-0 relative z-9 br4 f6 pv2 ph3 mv2 ttu pointer sans-serif tracked-mega"
--        , onClick msg
--        ]
--        [ text content ]
--
--
--menuButtonBorder : msg -> String -> Html msg
--menuButtonBorder msg content =
--    button
--        [ style
--            [ border 2 Color.white
--            , width 150
--            , backgroundColor Color.transparent
--            , color Color.white
--            ]
--        , class "outline-0 relative z-9 br4 pv2 ph3 mv2 ttu pointer sans-serif tracked-mega"
--        , onClick msg
--        ]
--        [ text content ]
--
--
--menuDrawerButton : Options msg -> Model model -> Html msg
--menuDrawerButton { onOpen, onClose } model =
--    case model.menu of
--        Open ->
--            div
--                [ onClick onClose
--                , style
--                    [ transform [ Transform.rotate 0 ]
--                    , width 20
--                    , height 20
--                    , transitionAll 300 []
--                    ]
--                ]
--                [ Cog.icon Color.white ]
--
--        _ ->
--            div
--                [ onClick onOpen
--                , style
--                    [ transform [ Transform.rotate 180 ]
--                    , width 20
--                    , height 20
--                    , transitionAll 300 []
--                    ]
--                ]
--                [ Cog.icon Color.darkYellow ]
