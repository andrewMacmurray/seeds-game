module Helpers.Effect exposing (..)

import Delay
import Dom
import Dom.Scroll exposing (toY)
import Task
import Time exposing (millisecond)
import Window exposing (Size, resizes, size)


-- Delay Helpers


sequenceMs : List ( Float, msg ) -> Cmd msg
sequenceMs steps =
    Delay.sequence <| Delay.withUnit millisecond <| steps


trigger : msg -> Cmd msg
trigger msg =
    Task.succeed msg |> Task.perform identity


pause : Float -> List ( Float, msg ) -> List ( Float, msg )
pause pauseDuration steps =
    steps
        |> List.head
        |> Maybe.map (\( n, msg ) -> ( n + pauseDuration, msg ))
        |> Maybe.map (\newDelay -> [ newDelay ] ++ (List.drop 1 steps))
        |> Maybe.withDefault []



-- Dom Scroll Helpers


scrollHubToLevel : (Result Dom.Error () -> msg) -> Float -> Size -> Cmd msg
scrollHubToLevel msg offset window =
    let
        targetDistance =
            offset - toFloat (window.height // 2) + 60
    in
        toY "hub" targetDistance |> Task.attempt msg
