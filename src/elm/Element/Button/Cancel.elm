module Element.Button.Cancel exposing (button)

import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Events exposing (onClick)
import Element.Palette as Palette
import Element.Scale as Scale exposing (corners)
import Element.Text as Text



-- Cancelable Button


type alias Options msg =
    { onCancel : msg
    , onClick : msg
    , confirmText : String
    }


button : Options msg -> Element msg
button options =
    row []
        [ el
            [ onClick options.onCancel
            , Background.color Palette.lime4
            , pointer
            , paddingEach
                { left = Scale.medium + Scale.small
                , right = Scale.medium
                , top = Scale.medium
                , bottom = Scale.medium
                }
            , Border.roundEach { corners | bottomLeft = 40, topLeft = 40 }
            ]
            (Text.text [ Text.color Palette.white ] "X")
        , el
            [ onClick options.onClick
            , pointer
            , Background.color Palette.lime5
            , paddingEach
                { left = Scale.medium
                , right = Scale.medium + Scale.small
                , top = Scale.medium
                , bottom = Scale.medium
                }
            , Border.roundEach { corners | bottomRight = 40, topRight = 40 }
            ]
            (Text.text [ Text.color Palette.white ] options.confirmText)
        ]
