module Internal.Events exposing
    ( Event(..)
    , on
    )

import Html exposing (Attribute)
import Html.Events
import Json.Decode as Decode



-- Event


type Event msg
    = OnComplete msg
    | OnStart msg
    | OnRepeat msg



-- Handler


on : Event msg -> Attribute msg
on evt =
    case evt of
        OnComplete msg ->
            onComplete msg

        OnStart msg ->
            onStart msg

        OnRepeat msg ->
            onRepeat msg



-- Internal


onComplete : msg -> Attribute msg
onComplete =
    on_ "gsapanimationcomplete"


onStart : msg -> Attribute msg
onStart =
    on_ "gsapanimationstart"


onRepeat : msg -> Attribute msg
onRepeat =
    on_ "gsapanimationrepeat"


on_ : String -> msg -> Attribute msg
on_ name =
    Html.Events.on name << Decode.succeed
