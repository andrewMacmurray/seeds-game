module Utils.Animation exposing (..)

import Formatting exposing (..)
import Utils.Style exposing (scale_, transform_, translateY_)


animation : String -> String -> String
animation =
    print animation_


animation_ : Format r (String -> String -> r)
animation_ =
    s "@keyframes " <> string <> s " { " <> string <> s " }"


step_ : Format r a -> Format r (Int -> a)
step_ formatter =
    int <> s "% { " <> formatter <> s "; }"
