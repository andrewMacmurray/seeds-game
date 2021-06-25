module Element.Animation exposing
    ( frame
    , frames
    , none
    , springy1
    , springy2
    )

import Simple.Animation as Animation exposing (Animation)
import Simple.Animation.Property exposing (Property)



-- Eases


springy1 : Animation.Option
springy1 =
    Animation.cubic 0.1 1.3 0.49 1


springy2 : Animation.Option
springy2 =
    Animation.cubic 0.3 1.1 0.1 1.1



-- None


none : Animation
none =
    Animation.fromTo { duration = 0, options = [] } [] []



-- Frames Animation


type alias Frames =
    { duration : Animation.Millis
    , options : List Animation.Option
    , startAt : List Property
    }


type Frame
    = Frame Float (List Property)


frames : Frames -> List Frame -> Animation
frames options fx =
    Animation.steps
        { startAt = options.startAt
        , options = options.options
        }
        (toSteps options fx)


toSteps : Frames -> List Frame -> List Animation.Step
toSteps options =
    List.map (toStep options)


toStep : Frames -> Frame -> Animation.Step
toStep options (Frame percent props) =
    Animation.step (stepDuration options percent) props


stepDuration : Frames -> Float -> Int
stepDuration options pc =
    round (toFloat options.duration / 100 * pc)


frame : Float -> List Property -> Frame
frame =
    Frame
