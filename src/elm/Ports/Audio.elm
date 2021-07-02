port module Ports.Audio exposing
    ( fadeOut
    , onIntroStarted
    , playIntro
    )

-- Intro


playIntro : Cmd msg
playIntro =
    playIntroMusic ()


port playIntroMusic : () -> Cmd msg


onIntroStarted : msg -> Sub msg
onIntroStarted msg =
    introMusicPlaying (always msg)


port introMusicPlaying : (Bool -> msg) -> Sub msg



-- Fade


fadeOut : Cmd msg
fadeOut =
    fadeMusic ()


port fadeMusic : () -> Cmd msg
