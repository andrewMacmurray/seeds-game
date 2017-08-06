module Helpers.Delay exposing (..)

import Time exposing (millisecond)
import Delay


sequenceMs : List ( Float, msg ) -> Cmd msg
sequenceMs steps =
    Delay.sequence <| Delay.withUnit millisecond <| steps
