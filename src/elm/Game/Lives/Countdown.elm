module Game.Lives.Countdown exposing
    ( Countdown
    , init
    , view
    )

-- Countdown


type alias Countdown =
    { minutes : Int
    , seconds : Int
    }



-- Init


init : Int -> Int -> Countdown
init minutes seconds =
    { minutes = minutes
    , seconds = seconds
    }



-- View


view : Countdown -> String
view countdown =
    String.fromInt countdown.minutes ++ ":" ++ viewSecond countdown.seconds


viewSecond : Int -> String
viewSecond n =
    if n < 10 then
        "0" ++ String.fromInt n

    else
        String.fromInt n
