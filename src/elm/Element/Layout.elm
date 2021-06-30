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
import Element.Keyed as Keyed
import Element.Palette as Palette
import Element.Text as Text
import Game.Level.Progress exposing (Progress)
import Html exposing (Html)
import Simple.Animation as Animation exposing (Animation)
import Simple.Animation.Animated as Animated
import Utils.Animated as Animated
import Utils.Element as Element
import Utils.Html.Style as Style
import View.Loading as Loading



-- Layout


type Scene msg
    = Scene (Scene_ msg)


type alias Scene_ msg =
    { el : Element msg
    , attributes : List (Attribute msg)
    , fadeIn : Bool
    }


type alias Model =
    { loading : Loading.Screen
    , progress : Progress
    }


type alias Layout msg =
    { model : Model
    , menu : Element msg
    , scene : ( String, Scene msg )
    , backdrop : Maybe ( String, Scene msg )
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
map toMsg (Scene scene_) =
    Scene
        { el = Element.map toMsg scene_.el
        , attributes = List.map (Element.mapAttribute toMsg) scene_.attributes
        , fadeIn = scene_.fadeIn
        }



-- View


view_ : List (Attribute msg) -> Element msg -> Html msg
view_ attrs =
    Element.layoutWith layoutOptions
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


fadeIn_ : List (Attribute msg) -> Element msg -> Html msg
fadeIn_ attributes el =
    Animated.div fade_
        (Style.center
            [ Style.absolute
            , Style.zIndex 2
            ]
        )
        [ view_ attributes el ]


view : Layout msg -> Html msg
view layout =
    Element.layoutWith layoutOptions
        (List.concat
            [ [ width fill
              , height fill
              , Element.class "overflow-y-scroll momentum-scroll"
              , Text.fonts
              , Palette.background1
              ]
            , layout.scene
                |> Tuple.second
                |> attributes_
            , layout.backdrop
                |> Maybe.map (Tuple.second >> attributes_)
                |> Maybe.withDefault []
            , [ inFront (viewLoadingScreen layout.model)
              , behindContent (viewBackdrop layout.backdrop)
              ]
            ]
        )
        (viewScene layout.scene)


viewLoadingScreen : Model -> Element msg
viewLoadingScreen context =
    Loading.view
        { progress = context.progress
        , loading = context.loading
        }


viewBackdrop : Maybe ( String, Scene msg ) -> Element msg
viewBackdrop =
    Element.showIfJust viewScene


viewScene : ( String, Scene msg ) -> Element msg
viewScene ( id, Scene scene_ ) =
    if scene_.fadeIn then
        Animated.el fade_
            [ width fill
            , centerY
            , centerX
            , explain Debug.todo
            , height fill
            ]
            (viewScene_ id scene_)

    else
        viewScene_ id scene_


viewScene_ : String -> Scene_ msg -> Element msg
viewScene_ id scene_ =
    Keyed.el
        [ width fill
        , height fill
        , centerY
        , centerX
        ]
        ( id, scene_.el )


attributes_ : Scene msg -> List (Attribute msg)
attributes_ (Scene s) =
    s.attributes


fade_ : Animation
fade_ =
    Animations.fadeIn 1000
        [ Animation.linear
        , Animation.delay 200
        ]


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
