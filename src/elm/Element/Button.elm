module Element.Button exposing
    ( Option
    , button
    , orange
    , small
    , white
    )

import Element exposing (Attribute, Element, paddingXY)
import Element.Background as Background
import Element.Border as Border
import Element.Input as Input
import Element.Palette as Palette
import Element.Scale as Scale
import Element.Text as Text



-- Options


type Option
    = Color Color
    | Size Size


type Color
    = Orange
    | White


type Fill
    = Solid


type Size
    = Regular
    | Small



-- Option


orange : Option
orange =
    Color Orange


white : Option
white =
    Color White


small : Option
small =
    Size Small



-- Combined


type alias Button_ msg =
    { label : String
    , onClick : msg
    , color : Color
    , fill : Fill
    , size : Size
    }


defaults : String -> msg -> Button_ msg
defaults label msg =
    { label = label
    , onClick = msg
    , color = Orange
    , fill = Solid
    , size = Regular
    }


combineOptions : { label : String, onClick : msg } -> List Option -> Button_ msg
combineOptions btn =
    List.foldl combineOption (defaults btn.label btn.onClick)


combineOption : Option -> Button_ msg -> Button_ msg
combineOption option options =
    case option of
        Color color ->
            { options | color = color }

        Size size ->
            { options | size = size }



-- Button


type alias Button msg =
    { label : String
    , onClick : msg
    }


button : List Option -> Button msg -> Element msg
button options btn =
    toElement (combineOptions btn options)



-- Internal


toElement : Button_ msg -> Element msg
toElement button_ =
    Input.button (attributes button_)
        { onPress = Just button_.onClick
        , label = toLabel button_
        }


attributes : Button_ msg -> List (Attribute msg)
attributes button_ =
    [ paddingXY Scale.medium Scale.small
    , Background.color (toBackground button_)
    , Border.rounded 40
    ]


toBackground : Button_ msg -> Element.Color
toBackground button_ =
    case button_.color of
        Orange ->
            Palette.lightOrange

        White ->
            Palette.white


toColor : Button_ msg -> Element.Color
toColor button_ =
    case button_.color of
        White ->
            Palette.black

        _ ->
            Palette.white


toFontSize : Button_ msg -> List (Attribute msg)
toFontSize button_ =
    case button_.size of
        Regular ->
            [ Text.medium
            , Text.wideSpaced
            ]

        Small ->
            [ Text.small
            , Text.spaced
            ]


toLabel : Button_ msg -> Element msg
toLabel button_ =
    Text.text
        (List.append (toFontSize button_)
            [ Text.color (toColor button_)
            ]
        )
        (String.toUpper button_.label)
