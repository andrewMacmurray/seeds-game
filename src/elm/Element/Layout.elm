module Element.Layout exposing
    ( Model
    , Scene
    , fadeIn
    , map
    , scene
    , view
    )

import Element exposing (..)
import Element.Animations as Animations
import Element.Loading as Loading
import Element.Palette as Palette
import Element.Text as Text
import Game.Level.Progress exposing (Progress)
import Html exposing (Html, div)
import Html.Keyed as Keyed
import Simple.Animation as Animation exposing (Animation)
import Simple.Animation.Animated as Animated
import Utils.Element as Element
import Utils.Html.Style as Style



-- Layout


type alias Layout msg =
    { model : Model
    , menu : Element msg
    , scene : ( String, Scene msg )
    , backdrop : Maybe ( String, Scene msg )
    }


type alias Model =
    { loading : Loading.Screen
    , progress : Progress
    }


type Scene msg
    = Scene (Scene_ msg)


type alias Scene_ msg =
    { el : Element msg
    , attributes : List (Attribute msg)
    , fadeIn : Bool
    }



-- Construct


scene : List (Attribute msg) -> Element msg -> Scene msg
scene attrs el =
    Scene
        { el = el
        , attributes = attrs
        , fadeIn = False
        }


fadeIn : List (Attribute msg) -> Element msg -> Scene msg
fadeIn attrs el =
    Scene
        { el = el
        , attributes = attrs
        , fadeIn = True
        }



-- Update


map : (a -> b) -> Scene a -> Scene b
map msg (Scene scene_) =
    Scene
        { el = Element.map msg scene_.el
        , attributes = List.map (Element.mapAttribute msg) scene_.attributes
        , fadeIn = scene_.fadeIn
        }



-- View


view : Layout msg -> Html msg
view layout =
    div []
        [ loadingScreen layout.model
        , stage
            [ viewBackdrop layout.backdrop
            , viewScene layout.scene
            ]
        ]


viewScene : ( a, Scene msg ) -> List ( a, Html msg )
viewScene =
    Tuple.mapSecond viewScene_ >> List.singleton


viewBackdrop : Maybe ( a, Scene msg ) -> List ( a, Html msg )
viewBackdrop =
    Maybe.map viewScene >> Maybe.withDefault []


viewScene_ : Scene msg -> Html msg
viewScene_ (Scene scene_) =
    if scene_.fadeIn then
        fadeIn_ scene_.attributes scene_.el

    else
        view_ scene_.attributes scene_.el


stage : List (List ( String, Html msg )) -> Html msg
stage =
    Keyed.node "div" [] << List.concat


view_ : List (Attribute msg) -> Element msg -> Html msg
view_ attrs =
    Element.layoutWith secondary
        (List.append
            [ width fill
            , height fill
            , Element.style "position" "absolute"
            , Element.style "z-index" "2"
            , Element.class "overflow-y-scroll momentum-scroll"
            , Text.fonts
            , Palette.background1
            ]
            attrs
        )


extra_ : Int -> Element msg -> Html msg
extra_ order =
    Element.layoutWith primary
        [ width fill
        , height fill
        , Element.style "position" "absolute"
        , Element.style "z-index" (String.fromInt order)
        , Element.class "overflow-y-scroll momentum-scroll"
        , Element.disableTouch
        , Text.fonts
        ]


fadeIn_ : List (Attribute msg) -> Element msg -> Html msg
fadeIn_ attributes el =
    Animated.div fade_
        (Style.center
            [ Style.absolute
            , Style.zIndex 2
            ]
        )
        [ view_ attributes el ]


loadingScreen : Model -> Html msg
loadingScreen model =
    extra_ 5 (loadingScreen_ model)


loadingScreen_ : Model -> Element msg
loadingScreen_ context =
    Loading.view
        { progress = context.progress
        , loading = context.loading
        }


fade_ : Animation
fade_ =
    Animations.fadeIn 1000
        [ Animation.linear
        , Animation.delay 200
        ]


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
