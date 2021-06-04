module Element.Animation.Bounce exposing
    ( Bounce
    , animation
    , springy
    , stiff
    )

import Simple.Animation as Animation exposing (Animation)
import Simple.Animation.Property exposing (Property)



-- Options


type alias Options =
    { options : List Animation.Option
    , duration : Animation.Millis
    , bounce : Bounce
    , property : Float -> Property
    , from : Float
    , to : Float
    }



-- Bounce


type alias Bounce =
    { bounces : Int
    , stiffness : Float
    }


springy : Bounce
springy =
    { bounces = 5
    , stiffness = 1.5
    }


stiff : Bounce
stiff =
    { bounces = 3
    , stiffness = 4
    }



-- Animation


animation : Options -> Animation
animation options =
    Animation.steps
        { startAt = [ options.property options.from ]
        , options = options.options ++ [ Animation.linear ]
        }
        (List.map (toStep options) points)


toStep : Options -> Int -> Animation.Step
toStep options =
    toValue options >> toStep_ options


toStep_ : Options -> Float -> Animation.Step
toStep_ options value =
    Animation.step (options.duration // resolution) [ options.property value ]


toValue : Options -> Int -> Float
toValue options i =
    options.from + interpolateOffset options i


interpolateOffset : Options -> Int -> Float
interpolateOffset options i =
    interpolate options.bounce (toFloat i / resolution) * (options.to - options.from)


points : List Int
points =
    List.range 0 resolution


resolution : number
resolution =
    20



-- Interpolate


interpolate : Bounce -> Float -> Float
interpolate bounce time =
    let
        bounces =
            toFloat bounce.bounces

        stiffness =
            bounce.stiffness
    in
    if time >= 1 then
        1

    else
        let
            t =
                time * toFloat (limit stiffness)
        in
        1 - exp stiffness t * oscillation bounces stiffness t


alpha : Float -> Float
alpha stiffness =
    stiffness / 100


omega : Float -> Float -> Float
omega bounces stiffness =
    (bounces + 0.5) * (pi / toFloat (limit stiffness))


limit : Float -> Int
limit stiffness =
    floor (logBase e (threshold stiffness) / -(alpha stiffness))


threshold : Float -> Float
threshold stiffness =
    0.005 / (10 ^ stiffness)


exp : Float -> Float -> Float
exp stiffness t =
    e ^ (-(alpha stiffness) * t)


oscillation : Float -> Float -> Float -> Float
oscillation bounces stiffness t =
    cos (omega bounces stiffness * t)
