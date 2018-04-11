module Helpers.Wave exposing (..)


type alias Wave a =
    { left : a
    , center : a
    , right : a
    }



{- increasing n integers produce a sin like pattern with elements in the config

   List.map (wave { left : "X", center : "Y", right: "Z" }) [0,1,2,3,4,5,6,7]
   -- ["Y", "Z", "Y", "X", "Y", "Z", "Y", "X"]
-}


wave : Wave a -> Int -> a
wave { left, center, right } n =
    let
        offsetSin =
            toFloat n
                |> (*) 90
                |> degrees
                |> sin
                |> round
    in
        if offsetSin == 0 then
            center
        else if offsetSin == 1 then
            right
        else
            left
