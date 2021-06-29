module Element.Layout exposing
    ( Scene
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
import Html exposing (Html)
import Simple.Animation as Animation exposing (Animation)
import Simple.Animation.Animated as Animated
import Utils.Element as Element
import View.LoadingScreen exposing (LoadingScreen)



-- Layout


type Scene msg
    = Scene (Scene_ msg)


type alias Scene_ msg =
    { el : Element msg
    , attributes : List (Attribute msg)
    , fadeIn : Bool
    }


type alias Context context =
    { context | loadingScreen : LoadingScreen }


type alias Layout context msg =
    { context : Context context
    , menu : Element msg
    , scene : ( String, Scene msg )
    , backdrop : Maybe ( String, Scene msg )
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


view : Layout context msg -> Html msg
view layout =
    Element.layoutWith layoutOptions
        (List.append
            [ width fill
            , height fill
            , Element.class "overflow-y-scroll momentum-scroll"
            , Text.fonts
            , behindContent (viewBackdrop layout.backdrop)
            , Palette.background1
            ]
            (layout.scene
                |> Tuple.second
                |> attributes_
            )
        )
        (viewScene layout.scene)


viewBackdrop =
    Element.showIfJust viewScene


viewScene : ( String, Scene msg ) -> Element msg
viewScene ( id, Scene scene_ ) =
    Keyed.el
        [ width fill
        , height fill
        ]
        ( id, scene_.el )


scene : List (Attribute msg) -> Element msg -> Scene msg
scene attrs el =
    Scene
        { el = el
        , attributes = attrs
        , fadeIn = False
        }


attributes_ (Scene s) =
    s.attributes



-- Fade In


fadeIn : List (Attribute msg) -> Element msg -> Scene msg
fadeIn attrs el =
    Scene
        { el = el
        , attributes = attrs
        , fadeIn = False
        }


fade : List (Html.Attribute msg) -> List (Html msg) -> Html msg
fade =
    Animated.div fade_


fade_ : Animation
fade_ =
    Animations.fadeIn 1000
        [ Animation.linear
        , Animation.delay 200
        ]



-- Internal


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
