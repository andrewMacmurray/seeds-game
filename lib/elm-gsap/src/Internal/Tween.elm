module Internal.Tween exposing
    ( Tween
    , animate
    , from
    , fromTo
    , position_
    , to
    )

import Animation
import Animation.Property exposing (Property)
import Html exposing (Html)
import Html.Attributes as Attribute
import Internal.Animation
import Internal.Events exposing (Event)
import Internal.Position exposing (Position)
import Internal.Property
import Json.Encode as Encode



-- Tween


type Tween msg
    = To (Options msg) (List Property)
    | From (Options msg) (List Property)
    | FromTo (Options msg) ( List Property, List Property )


type alias Options msg =
    { position : Maybe Position
    , animation : Internal.Animation.Options msg
    }



-- Default Options


defaultOptions : Animation.Options msg -> Options msg
defaultOptions animation_ =
    { position = Nothing
    , animation = animation_
    }



-- Construct


fromTo : ( List Property, List Property ) -> Animation.Options msg -> Tween msg
fromTo fromTo_ animation_ =
    FromTo (defaultOptions animation_) fromTo_


to : List Property -> Animation.Options msg -> Tween msg
to properties_ animation_ =
    To (defaultOptions animation_) properties_


from : List Property -> Animation.Options msg -> Tween msg
from properties_ animation_ =
    From (defaultOptions animation_) properties_



-- Configure


position_ : Position -> Tween msg -> Tween msg
position_ p =
    updateOptions (\options -> { options | position = Just p })


updateOptions : (Options msg -> Options msg) -> Tween msg -> Tween msg
updateOptions f animation =
    case animation of
        FromTo options_ tween_ ->
            FromTo (f options_) tween_

        From options_ tween_ ->
            From (f options_) tween_

        To options_ tween_ ->
            To (f options_) tween_



-- Animate


animate : Tween msg -> Html msg -> Html msg
animate animation element_ =
    let
        toElement xs =
            tweenElement xs [ element_ ]

        target_ =
            Internal.Animation.target_
    in
    case animation of
        FromTo options fromTo_ ->
            toElement (encodeFromTo (target_ options.animation) options fromTo_ :: handleEvents options.animation)

        From options from_ ->
            toElement (encodeFrom (target_ options.animation) options from_ :: handleEvents options.animation)

        To options to_ ->
            toElement (encodeTo (target_ options.animation) options to_ :: handleEvents options.animation)


handleEvents : Internal.Animation.Options msg -> List (Html.Attribute msg)
handleEvents =
    Internal.Animation.events >> List.map Internal.Events.on


encodeTo : Maybe String -> Options msg -> List Property -> Html.Attribute msg
encodeTo selector_ options to_ =
    encodeAnimation_ selector_ options.position [ ( "to", encodeTween_ options.animation to_ ) ]


encodeFrom : Maybe String -> Options msg -> List Property -> Html.Attribute msg
encodeFrom selector_ options from_ =
    encodeAnimation_ selector_ options.position [ ( "from", encodeTween_ options.animation from_ ) ]


encodeFromTo : Maybe String -> Options msg -> ( List Property, List Property ) -> Html.Attribute msg
encodeFromTo selector_ options ( from_, to_ ) =
    encodeAnimation_ selector_
        options.position
        [ ( "from", encodeProperties_ from_ )
        , ( "to", encodeTween_ options.animation to_ )
        ]


encodeProperties_ =
    List.map Internal.Property.encode >> Encode.object


encodeTween_ anim properties_ =
    List.map Internal.Property.encode properties_
        |> withAnimation anim
        |> Encode.object


withAnimation anim xs =
    Internal.Animation.encode anim ++ xs


withPosition : Maybe Position -> List ( String, Encode.Value ) -> List ( String, Encode.Value )
withPosition position xs =
    position
        |> Maybe.map (\p -> ( "position", Internal.Position.encode p ) :: xs)
        |> Maybe.withDefault xs


withTarget : Maybe String -> List ( String, Encode.Value ) -> List ( String, Encode.Value )
withTarget target_ xs =
    target_
        |> Maybe.map (\t -> ( "target", Encode.string t ) :: xs)
        |> Maybe.withDefault xs


encodeAnimation_ : Maybe String -> Maybe Position -> List ( String, Encode.Value ) -> Html.Attribute msg
encodeAnimation_ target_ position =
    withTarget target_
        >> withPosition position
        >> Encode.object
        >> Encode.encode 0
        >> Attribute.attribute "animation"


tweenElement : List (Html.Attribute msg) -> List (Html msg) -> Html msg
tweenElement attributes children =
    Html.node "tween-element" attributes children
