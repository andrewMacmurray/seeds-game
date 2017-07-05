module Helpers.Dict exposing (..)

import Dict exposing (Dict)


mapValues : (b -> b) -> Dict comparable b -> Dict comparable b
mapValues f dict =
    Dict.map (\_ val -> f val) dict
