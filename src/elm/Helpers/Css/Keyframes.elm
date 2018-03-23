module Helpers.Css.Keyframes exposing (..)

import Helpers.Css.Style exposing (keyframesAnimation)


type alias KeyframesAnimation a =
    { name : String
    , frames : List a
    }


map : (a -> String) -> KeyframesAnimation a -> String
map f { frames, name } =
    frames
        |> List.map f
        |> keyframesAnimation name


map2 : (a -> b -> String) -> KeyframesAnimation ( a, b ) -> String
map2 f { frames, name } =
    frames
        |> List.map (uncurry f)
        |> keyframesAnimation name


map3 : (a -> b -> c -> String) -> KeyframesAnimation ( a, b, c ) -> String
map3 f { frames, name } =
    frames
        |> List.map (\( a, b, c ) -> f a b c)
        |> keyframesAnimation name
