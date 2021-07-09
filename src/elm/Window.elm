module Window exposing
    ( Size(..)
    , Width(..)
    , Window
    , size
    , vh
    , vw
    , whenNarrow
    , width
    )

-- Window


type alias Window =
    { width : Int
    , height : Int
    }


type Size
    = Small
    | Medium
    | Large


type Width
    = Narrow
    | MediumWidth
    | Wide



-- Query


size : Window -> Size
size window =
    if smallestDimension window < 480 then
        Small

    else if smallestDimension window > 480 && smallestDimension window < 720 then
        Medium

    else
        Large


width : Window -> Width
width window =
    if window.width >= 980 then
        Wide

    else if window.width >= 580 && window.width < 980 then
        MediumWidth

    else
        Narrow


vw : Window -> Float
vw window =
    toFloat window.width


vh : Window -> Float
vh window =
    toFloat window.height


whenNarrow : a -> a -> Window -> a
whenNarrow a b window =
    case width window of
        Narrow ->
            a

        _ ->
            b



-- Helpers


smallestDimension : Window -> Int
smallestDimension window =
    if window.height >= window.width then
        window.width

    else
        window.height
