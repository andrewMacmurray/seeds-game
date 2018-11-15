module Data.Window exposing
    ( Size(..)
    , Window
    , padding
    , size
    )


type alias Window =
    { width : Int
    , height : Int
    }


type Size
    = Small
    | Medium
    | Large


size : Window -> Size
size window =
    if smallestDimension window < 480 then
        Small

    else if smallestDimension window > 480 && smallestDimension window < 720 then
        Medium

    else
        Large


smallestDimension : Window -> Int
smallestDimension { height, width } =
    if height >= width then
        width

    else
        height


padding : number
padding =
    35
