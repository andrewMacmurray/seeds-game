module Utils.Delay exposing (after, sequence, trigger)

import Delay
import Task


sequence : List ( Float, msg ) -> Cmd msg
sequence steps =
    Delay.sequence <| Delay.withUnit Delay.Millisecond <| steps


after : Float -> msg -> Cmd msg
after time =
    Delay.after time Delay.Millisecond


trigger : msg -> Cmd msg
trigger msg =
    Task.succeed msg |> Task.perform identity
