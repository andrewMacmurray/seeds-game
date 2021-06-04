module Element.Animation exposing
    ( springy1
    , springy2
    )

import Simple.Animation as Animation exposing (Animation)


springy1 : Animation.Option
springy1 =
    Animation.cubic 0.1 1.3 0.49 1


springy2 : Animation.Option
springy2 =
    Animation.cubic 0.3 1.1 0.1 1.1
