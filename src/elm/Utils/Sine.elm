module Utils.Sine exposing
    ( Wave
    , wave
    )

-- Sine Wave


type alias Wave a =
    { left : a
    , center : a
    , right : a
    }



{- increasing n+1 integers produces a sine wave like pattern from elements in the given config

   List.map (wave { left : "X", center : "Y", right: "Z" }) [0,1,2,3,4,5,6,7]
   -- ["Y", "Z", "Y", "X", "Y", "Z", "Y", "X"]
-}


wave : Wave a -> Int -> a
wave { left, center, right } n =
    if offsetSine n == 0 then
        center

    else if offsetSine n == 1 then
        right

    else
        left


offsetSine : Int -> Int
offsetSine =
    toFloat
        >> (*) 90
        >> degrees
        >> sin
        >> round
