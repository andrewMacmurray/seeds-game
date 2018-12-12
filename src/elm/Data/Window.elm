module Data.Window exposing
    ( Size(..)
    , Width(..)
    , Window
    , padding
    , size
    , smallestDimension
    , width
    )


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


size : Window -> Size
size window =
    if smallestDimension window < 480 then
        Small

    else if smallestDimension window > 480 && smallestDimension window < 720 then
        Medium

    else
        Large


width window =
    if window.width >= 980 then
        Wide

    else if window.width >= 580 && window.width < 980 then
        MediumWidth

    else
        Narrow


smallestDimension : Window -> Int
smallestDimension window =
    if window.height >= window.width then
        window.width

    else
        window.height


padding : number
padding =
    35
