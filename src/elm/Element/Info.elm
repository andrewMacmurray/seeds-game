module Element.Info exposing
    ( State
    , hidden
    , isHidden
    , isVisible
    , leaving
    , view
    , visible
    )

import Element exposing (..)
import Element.Animation as Animation
import Element.Border as Border
import Element.Palette as Palette
import Element.Scale as Scale
import Simple.Animation as Animation exposing (Animation)
import Simple.Animation.Property as P
import Utils.Animated as Animated



-- Info


type State a
    = Visible Direction a
    | Hidden


type Direction
    = Appearing
    | Leaving



-- Construct


visible : a -> State a
visible =
    Visible Appearing


leaving : State a -> State a
leaving infoWindow =
    case infoWindow of
        Visible _ content_ ->
            Visible Leaving content_

        Hidden ->
            Hidden


hidden : State a
hidden =
    Hidden


isVisible : State a -> Bool
isVisible info =
    case info of
        Visible _ _ ->
            True

        Hidden ->
            False


isHidden : State a -> Bool
isHidden =
    isVisible >> not



-- View


type alias View a msg =
    { content : a -> Element msg
    , info : State a
    }


view : View a msg -> Element msg
view config =
    case config.info of
        Visible direction x ->
            infoContainer_ direction (config.content x)

        Hidden ->
            none


infoContainer_ : Direction -> Element msg -> Element msg
infoContainer_ direction content =
    Animated.el (animate direction)
        [ centerX
        , centerY
        , paddingXY Scale.medium 0
        , width (fill |> maximum 400)
        ]
        (el
            [ centerX
            , centerY
            , height (fill |> minimum 200)
            , padding Scale.large
            , width fill
            , Border.rounded 8
            , Palette.seedPodBackground
            ]
            (el
                [ centerX
                , centerY
                ]
                content
            )
        )


animate : Direction -> Animation
animate direction =
    case direction of
        Appearing ->
            Animation.fromTo
                { duration = 800
                , options = [ Animation.springy2 ]
                }
                [ P.opacity 0, P.y -300 ]
                [ P.opacity 1 ]

        Leaving ->
            Animation.fromTo
                { duration = 600
                , options = [ Animation.easeInBack ]
                }
                [ P.y 0, P.opacity 1 ]
                [ P.y 300, P.opacity 0 ]
