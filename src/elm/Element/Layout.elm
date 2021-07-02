module Element.Layout exposing
    ( Overlay
    , Scene
    , fadeIn
    , map
    , overlay
    , scene
    , scrollable
    , view
    )

import Element exposing (..)
import Element.Animations as Animations
import Element.Palette as Palette
import Element.Text as Text
import Html exposing (Html, div)
import Html.Keyed as Keyed
import Simple.Animation as Animation exposing (Animation)
import Simple.Animation.Animated as Animated
import Utils.Element as Element
import Utils.Style as Style



-- Layout


type alias Layout msg =
    { menu : Overlay msg
    , loading : Overlay msg
    , scene : ( String, Scene msg )
    , backdrop : Maybe ( String, Scene msg )
    }


type Scene msg
    = Scene (Scene_ msg)


type alias Scene_ msg =
    { el : Element msg
    , attributes : List (Attribute msg)
    , fadeIn : Bool
    , scrollable : Bool
    }


type Overlay msg
    = Overlay (Overlay_ msg)


type alias Overlay_ msg =
    { el : Element msg
    , attributes : List (Attribute msg)
    }



-- Construct


scene : List (Attribute msg) -> Element msg -> Scene msg
scene attrs el =
    Scene
        { el = el
        , attributes = attrs
        , fadeIn = False
        , scrollable = False
        }


scrollable : List (Attribute msg) -> Element msg -> Scene msg
scrollable attrs el =
    Scene
        { el = el
        , attributes = attrs
        , fadeIn = False
        , scrollable = True
        }


fadeIn : List (Attribute msg) -> Element msg -> Scene msg
fadeIn attrs el =
    Scene
        { el = el
        , attributes = attrs
        , fadeIn = True
        , scrollable = False
        }


overlay : List (Attribute msg) -> Element msg -> Overlay msg
overlay attrs el =
    Overlay
        { el = el
        , attributes = attrs
        }



-- Update


map : (a -> b) -> Scene a -> Scene b
map msg (Scene scene_) =
    Scene
        { el = Element.map msg scene_.el
        , attributes = List.map (Element.mapAttribute msg) scene_.attributes
        , fadeIn = scene_.fadeIn
        , scrollable = scene_.scrollable
        }



-- View


view : Layout msg -> Html msg
view layout =
    div []
        [ loadingScreen layout.loading
        , menu layout.menu
        , stage
            [ viewBackdrop layout.backdrop
            , viewScene layout.scene
            ]
        ]



-- Loading Screen


loadingScreen : Overlay msg -> Html msg
loadingScreen =
    viewOverlay { index = 5 }



-- Menu


menu : Overlay msg -> Html msg
menu =
    viewOverlay { index = 4 }



-- Scene


stage : List (List ( String, Html msg )) -> Html msg
stage =
    Keyed.node "div" [] << List.concat


viewScene : ( a, Scene msg ) -> List ( a, Html msg )
viewScene =
    Tuple.mapSecond viewScene_ >> List.singleton


viewBackdrop : Maybe ( a, Scene msg ) -> List ( a, Html msg )
viewBackdrop =
    Maybe.map viewScene >> Maybe.withDefault []


viewScene_ : Scene msg -> Html msg
viewScene_ (Scene scene_) =
    if scene_.fadeIn then
        fadeIn_ scene_

    else
        view_ scene_


view_ : Scene_ msg -> Html msg
view_ scene_ =
    Element.layoutWith secondary
        (List.append
            [ width fill
            , height fill
            , Element.style "position" "fixed"
            , Element.style "z-index" "2"
            , handleScroll scene_
            , Text.fonts
            , Palette.background1
            ]
            scene_.attributes
        )
        scene_.el


handleScroll : Scene_ msg -> Attribute msg
handleScroll scene_ =
    if scene_.scrollable then
        Element.class "scrollable"

    else
        Element.preventScroll


viewOverlay : { index : Int } -> Overlay msg -> Html msg
viewOverlay { index } (Overlay o) =
    Element.layoutWith primary
        (List.append
            [ width fill
            , height fill
            , Element.style "position" "fixed"
            , Element.style "z-index" (String.fromInt index)
            , Element.preventScroll
            , Text.fonts
            ]
            o.attributes
        )
        o.el


fadeIn_ : Scene_ msg -> Html msg
fadeIn_ scene_ =
    Animated.div fade_
        (Style.center
            [ Style.absolute
            , Style.zIndex 2
            ]
        )
        [ view_ scene_ ]


fade_ : Animation
fade_ =
    Animations.fadeIn 1000
        [ Animation.linear
        , Animation.delay 200
        ]



-- Layout Options


primary : { options : List Option }
primary =
    { options =
        [ focusStyle
        ]
    }


secondary : { options : List Option }
secondary =
    { options =
        [ focusStyle
        , Element.noStaticStyleSheet
        ]
    }


focusStyle : Option
focusStyle =
    Element.focusStyle
        { borderColor = Nothing
        , backgroundColor = Nothing
        , shadow = Nothing
        }
