module Element.Layout exposing (view)

import Element exposing (..)
import Element.Palette as Palette
import Element.Text as Text
import Html exposing (Html)
import Utils.Element as Element


view : List (Attribute msg) -> Element msg -> Html msg
view attrs =
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
