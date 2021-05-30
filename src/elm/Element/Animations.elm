module Element.Animations exposing
    ( fadeIn
    , fadeOut
    , hover
    )

import Simple.Animation as Animation exposing (Animation)
import Simple.Animation.Property as P


fadeIn : Animation.Millis -> List Animation.Option -> Animation
fadeIn duration options =
    Animation.fromTo
        { duration = duration
        , options = options
        }
        [ P.opacity 0 ]
        [ P.opacity 1 ]


fadeOut : Animation.Millis -> List Animation.Option -> Animation
fadeOut duration options =
    Animation.fromTo
        { duration = duration
        , options = options
        }
        [ P.opacity 1 ]
        [ P.opacity 0 ]


hover : Animation
hover =
    Animation.steps
        { startAt = [ P.y 0 ]
        , options = [ Animation.loop ]
        }
        [ Animation.step 750 [ P.y -5 ]
        , Animation.step 750 [ P.y 0 ]
        ]
