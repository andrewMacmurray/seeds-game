module Helpers.Delay exposing (delay, pause, sequence, trigger)

import Delay
import Task


sequence : List ( Float, msg ) -> Cmd msg
sequence steps =
    Delay.sequence <| Delay.withUnit Delay.Millisecond <| steps


delay : Float -> msg -> Cmd msg
delay time =
    Delay.after time Delay.Millisecond


trigger : msg -> Cmd msg
trigger msg =
    Task.succeed msg |> Task.perform identity


pause : Float -> List ( Float, msg ) -> List ( Float, msg )
pause pauseDuration steps =
    steps
        |> List.head
        |> Maybe.map (\( n, msg ) -> ( n + pauseDuration, msg ))
        |> Maybe.map (\newDelay -> [ newDelay ] ++ List.drop 1 steps)
        |> Maybe.withDefault []
