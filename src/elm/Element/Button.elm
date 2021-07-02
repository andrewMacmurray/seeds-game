module Element.Button exposing
    ( Option
    , button
    , decorative
    , fill
    , gold
    , hollow
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
    = Size Size
    | Sizing Sizing
    | Background Background


type Background
    = Solid Color
    | Hollow


type Color
    = Orange
    | Gold
    | White


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
    solid_ Orange


gold : Option
gold =
    solid_ Gold


white : Option
white =
    solid_ White


small : Option
small =
    Size Small


large : Option
large =
    Size Large


fill : Option
fill =
    Sizing Fill


hollow : Option
hollow =
    Background Hollow


solid_ : Color -> Option
solid_ =
    Background << Solid



-- Combined


type alias Combined_ msg =
    { label : String
    , onClick : Maybe msg
    }


type alias Button_ msg =
    { label : String
    , onClick : Maybe msg
    , background : Background
    , size : Size
    , sizing : Sizing
    }


defaults : String -> Maybe msg -> Button_ msg
defaults label msg =
    { label = label
    , onClick = msg
    , background = Solid Orange
    , size = Regular
    , sizing = Fit
    }


combineOptions : List Option -> Combined_ msg -> Button_ msg
combineOptions options btn =
    List.foldl combineOption (defaults btn.label btn.onClick) options


combineOption : Option -> Button_ msg -> Button_ msg
combineOption option options =
    case option of
        Size size ->
            { options | size = size }

        Sizing sizing ->
            { options | sizing = sizing }

        Background background ->
            { options | background = background }



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
    , Border.color (toBorder button_)
    , Border.width 2
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


toBorder : Button_ msg -> Element.Color
toBorder button_ =
    case button_.background of
        Hollow ->
            Palette.white

        Solid color_ ->
            backgroundColor color_


toBackground : Button_ msg -> Element.Color
toBackground button_ =
    case button_.background of
        Hollow ->
            Palette.transparent

        Solid color_ ->
            backgroundColor color_


backgroundColor : Color -> Element.Color
backgroundColor color =
    case color of
        Orange ->
            Palette.lightOrange

        White ->
            Palette.white

        Gold ->
            Palette.lightGold


toColor : Button_ msg -> Element.Color
toColor button_ =
    case button_.background of
        Hollow ->
            Palette.white

        Solid White ->
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
