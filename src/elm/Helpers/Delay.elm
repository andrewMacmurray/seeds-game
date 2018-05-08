module Helpers.Delay exposing (..)

import Delay
import Task
import Time exposing (millisecond)


sequenceMs : List ( Float, msg ) -> Cmd msg
sequenceMs steps =
    Delay.sequence <| Delay.withUnit millisecond <| steps


delayMs : Float -> msg -> Cmd msg
delayMs time =
    Delay.after time millisecond


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
