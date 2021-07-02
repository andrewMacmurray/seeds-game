module Element.Button exposing
    ( Option
    , button
    , decorative
    , fill
    , gold
    , large
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
    | Sizing Sizing


type Color
    = Orange
    | Gold
    | White


type Fill
    = Solid


type Size
    = Large
    | Regular
    | Small


type Sizing
    = Fit
    | Fill



-- Option


orange : Option
orange =
    Color Orange


gold : Option
gold =
    Color Gold


white : Option
white =
    Color White


small : Option
small =
    Size Small


large : Option
large =
    Size Large


fill : Option
fill =
    Sizing Fill



-- Combined


type alias Combined_ msg =
    { label : String
    , onClick : Maybe msg
    }


type alias Button_ msg =
    { label : String
    , onClick : Maybe msg
    , color : Color
    , fill : Fill
    , size : Size
    , sizing : Sizing
    }


defaults : String -> Maybe msg -> Button_ msg
defaults label msg =
    { label = label
    , onClick = msg
    , color = Orange
    , fill = Solid
    , size = Regular
    , sizing = Fit
    }


combineOptions : List Option -> Combined_ msg -> Button_ msg
combineOptions options btn =
    List.foldl combineOption (defaults btn.label btn.onClick) options


combineOption : Option -> Button_ msg -> Button_ msg
combineOption option options =
    case option of
        Color color ->
            { options | color = color }

        Size size ->
            { options | size = size }

        Sizing sizing ->
            { options | sizing = sizing }



-- Button


type alias Button msg =
    { label : String
    , onClick : msg
    }


button : List Option -> Button msg -> Element msg
button options btn =
    toElement
        (combineOptions options
            { onClick = Just btn.onClick
            , label = btn.label
            }
        )



-- Decorative


type alias Decorative =
    String


decorative : List Option -> Decorative -> Element msg
decorative options label =
    toElement
        (combineOptions options
            { onClick = Nothing
            , label = label
            }
        )



-- Internal


toElement : Button_ msg -> Element msg
toElement button_ =
    Input.button (attributes button_)
        { onPress = button_.onClick
        , label = toLabel button_
        }


attributes : Button_ msg -> List (Attribute msg)
attributes button_ =
    [ toPadding button_
    , toSizing button_
    , Background.color (toBackground button_)
    , Border.rounded 40
    ]


toPadding : Button_ msg -> Attribute msg
toPadding button_ =
    case button_.size of
        Large ->
            paddingXY (Scale.medium + Scale.extraSmall) Scale.small

        Regular ->
            paddingXY Scale.medium Scale.small

        Small ->
            paddingXY Scale.small Scale.small


toSizing : Button_ msg -> Attribute msg
toSizing button_ =
    case button_.sizing of
        Fit ->
            Element.width Element.shrink

        Fill ->
            Element.width Element.fill


toBackground : Button_ msg -> Element.Color
toBackground button_ =
    case button_.color of
        Orange ->
            Palette.lightOrange

        White ->
            Palette.white

        Gold ->
            Palette.lightGold


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
        Large ->
            [ Text.f4
            , Text.wideSpaced
            ]

        Regular ->
            [ Text.f5
            , Text.mediumSpaced
            ]

        Small ->
            [ Text.f6
            , Text.spaced
            ]


toLabel : Button_ msg -> Element msg
toLabel button_ =
    Text.text
        (List.append (toFontSize button_)
            [ Text.color (toColor button_)
            , Element.centerX
            ]
        )
        (String.toUpper button_.label)
