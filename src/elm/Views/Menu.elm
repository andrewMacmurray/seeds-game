module Views.Menu exposing (MsgConfig, view)

import Css.Color as Color
import Css.Style as Style exposing (backgroundColor, borderRadiusBottomLeft, borderRadiusTopLeft, color, height, opacity, style, transform, width)
import Css.Transform exposing (translateX)
import Css.Transition exposing (transitionAll)
import Helpers.Attribute as Attribute
import Html exposing (Html, div, text)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Shared


type alias MsgConfig msg =
    { open : msg
    , close : msg
    }


view : MsgConfig msg -> Shared.Data -> Html msg
view msg shared =
    div [ class "absolute top-0 right-0 w-100" ]
        [ menuButton msg shared
        , div [ class "absolute z-999", enableWhenOpen shared.menuOpen ]
            [ div
                [ style
                    [ height <| toFloat shared.window.height
                    , width <| toFloat shared.window.width
                    , backgroundColor Color.black
                    , overlayVisibility shared.menuOpen
                    , transitionAll 300 []
                    ]
                , enableWhenOpen shared.menuOpen
                , onClick msg.close
                ]
                []
            , div
                [ style
                    [ Style.background Color.seedPodGradient
                    , height <| toFloat shared.window.height
                    , color Color.white
                    , width 300
                    , borderRadiusBottomLeft 20
                    , borderRadiusTopLeft 20
                    , menuPosition shared.menuOpen
                    , transitionAll 300 []
                    ]
                , class "absolute right-0 top-0"
                ]
                []
            ]
        ]


overlayVisibility menuOpen =
    if menuOpen then
        opacity 0.6

    else
        opacity 0


enableWhenOpen menuOpen =
    if menuOpen then
        Attribute.empty

    else
        class "touch-disabled"


menuButton { open, close } shared =
    if shared.menuOpen then
        div [ onClick close ] [ menuButtonContent ]

    else
        div [ onClick open ] [ menuButtonContent ]


menuButtonContent =
    div [ class "absolute pointer right-1 top-1 z-9999" ] [ text "menu" ]


menuPosition menuOpen =
    if menuOpen then
        transform [ translateX 0 ]

    else
        transform [ translateX 300 ]
