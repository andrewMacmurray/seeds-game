module Element.Animation exposing (springy)

import Simple.Animation as Animation


springy : Animation.Option
springy =
    Animation.cubic 0.1 1.3 0.49 1
