module Internal.Animation exposing
    ( Options
    , delay
    , duration
    , ease
    , encode
    , events
    , infinite
    , onComplete
    , onRepeat
    , onStart
    , options
    , repeat
    , repeatDelay
    , target
    , target_
    , yoyo
    )

import Animation.Ease exposing (Ease)
import Internal.Ease as Ease
import Internal.Events exposing (Event(..))
import Json.Encode as Encode



-- Animation


type Options msg
    = Options (Internal msg)


type alias Internal msg =
    { repeat : Maybe Repeat
    , repeatDelay : Maybe Float
    , yoyo : Maybe Yoyo
    , delay : Maybe Float
    , ease : Maybe Ease
    , duration : Maybe Float
    , target : Maybe String
    , events : List (Event msg)
    }


type Repeat
    = Infinite
    | Count Int


type Yoyo
    = Yoyo



-- Defaults


defaultOptions : Internal msg
defaultOptions =
    { repeat = Nothing
    , yoyo = Nothing
    , repeatDelay = Nothing
    , delay = Nothing
    , ease = Nothing
    , duration = Nothing
    , target = Nothing
    , events = []
    }



-- Timeline


options : Options msg
options =
    Options defaultOptions



-- Configure


infinite : Options msg -> Options msg
infinite =
    updateOptions (\options_ -> { options_ | repeat = Just Infinite })


repeat : Int -> Options msg -> Options msg
repeat n =
    updateOptions (\options_ -> { options_ | repeat = Just (Count n) })


duration : Float -> Options msg -> Options msg
duration d =
    updateOptions (\options_ -> { options_ | duration = Just d })


repeatDelay : Float -> Options msg -> Options msg
repeatDelay n =
    updateOptions (\options_ -> { options_ | repeatDelay = Just n })


delay : Float -> Options msg -> Options msg
delay n =
    updateOptions (\options_ -> { options_ | delay = Just n })


ease : Ease -> Options msg -> Options msg
ease ease_ =
    updateOptions (\options_ -> { options_ | ease = Just ease_ })


yoyo : Options msg -> Options msg
yoyo =
    updateOptions (\options_ -> { options_ | yoyo = Just Yoyo })



-- Target


target : String -> Options msg -> Options msg
target selector =
    updateOptions (\options_ -> { options_ | target = Just selector })


target_ : Options msg -> Maybe String
target_ (Options options_) =
    options_.target



-- Events


onComplete : msg -> Options msg -> Options msg
onComplete msg =
    updateOptions (\options_ -> { options_ | events = OnComplete msg :: options_.events })


onStart : msg -> Options msg -> Options msg
onStart msg =
    updateOptions (\options_ -> { options_ | events = OnStart msg :: options_.events })


onRepeat : msg -> Options msg -> Options msg
onRepeat msg =
    updateOptions (\options_ -> { options_ | events = OnRepeat msg :: options_.events })


events : Options msg -> List (Event msg)
events (Options options_) =
    options_.events



-- Util


updateOptions : (Internal msg -> Internal msg) -> Options msg -> Options msg
updateOptions f (Options options_) =
    Options (f options_)



-- Encode


encode : Options msg -> List ( String, Encode.Value )
encode (Options options_) =
    []
        |> addOptional encodeRepeat options_.repeat
        |> addOptional encodeRepeatDelay options_.repeatDelay
        |> addOptional encodeDelay options_.delay
        |> addOptional encodeEase options_.ease
        |> addOptional encodeYoyo options_.yoyo
        |> addOptional encodeDuration options_.duration


encodeYoyo : Yoyo -> ( String, Encode.Value )
encodeYoyo _ =
    ( "yoyo", Encode.bool True )


encodeDuration : Float -> ( String, Encode.Value )
encodeDuration d =
    ( "duration", Encode.float d )


encodeDelay : Float -> ( String, Encode.Value )
encodeDelay n =
    ( "delay", Encode.float n )


encodeRepeatDelay : Float -> ( String, Encode.Value )
encodeRepeatDelay n =
    ( "repeatDelay", Encode.float n )


encodeEase : Ease -> ( String, Encode.Value )
encodeEase e =
    ( "ease", Ease.encode e )


encodeRepeat : Repeat -> ( String, Encode.Value )
encodeRepeat repeat_ =
    case repeat_ of
        Infinite ->
            ( "repeat", Encode.int -1 )

        Count n ->
            ( "repeat", Encode.int n )



-- Utils


addOptional :
    (val -> ( String, Encode.Value ))
    -> Maybe val
    -> List ( String, Encode.Value )
    -> List ( String, Encode.Value )
addOptional encoder val values =
    val
        |> Maybe.map (\v -> values ++ [ encoder v ])
        |> Maybe.withDefault values
