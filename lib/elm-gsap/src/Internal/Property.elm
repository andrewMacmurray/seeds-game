module Internal.Property exposing
    ( Origin(..)
    , Property(..)
    , TransformOrigin(..)
    , encode
    )

import Animation.Ease as Ease
import Internal.Ease as Internal
import Json.Encode as Encode



-- Property


type Property
    = Opacity Float
    | Rotation Float
    | X Float
    | Y Float
    | Scale Float
    | Duration Float
    | Ease Ease.Ease
    | Stagger Float
    | TransformOrigin TransformOrigin
    | Raw_ String String


type TransformOrigin
    = Percent Float Float
    | Origin Origin


type Origin
    = Top
    | Bottom
    | Left
    | Right
    | Center
    | TopRight
    | TopLeft
    | BottomRight
    | BottomLeft



-- Encode


encode : Property -> ( String, Encode.Value )
encode prop =
    case prop of
        Opacity opacity_ ->
            ( "opacity", Encode.float opacity_ )

        X x_ ->
            ( "x", Encode.float x_ )

        Y y_ ->
            ( "y", Encode.float y_ )

        Scale scale_ ->
            ( "scale", Encode.float scale_ )

        Duration duration_ ->
            ( "duration", Encode.float duration_ )

        Rotation rotation_ ->
            ( "rotation", Encode.float rotation_ )

        Ease ease_ ->
            ( "ease", Internal.encode ease_ )

        Stagger stagger_ ->
            ( "stagger"
            , Encode.object
                [ ( "each", Encode.float stagger_ )
                , ( "from", Encode.string "end" )
                ]
            )

        TransformOrigin origin ->
            ( "transformOrigin", Encode.string (originToString origin) )

        Raw_ prop_ val_ ->
            ( prop_, Encode.string val_ )


originToString : TransformOrigin -> String
originToString origin =
    case origin of
        Origin direction_ ->
            directionToString direction_

        Percent p1 p2 ->
            percent p1 ++ " " ++ percent p2


percent : Float -> String
percent n =
    String.fromFloat n ++ "%"


directionToString : Origin -> String
directionToString d =
    case d of
        Left ->
            "left"

        Bottom ->
            "bottom"

        Top ->
            "top"

        Right ->
            "right"

        Center ->
            "center"

        TopRight ->
            "top right"

        TopLeft ->
            "top left"

        BottomRight ->
            "bottom right"

        BottomLeft ->
            "bottom left"
