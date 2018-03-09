module Views.Icons.Heart exposing (..)

import Config.Color exposing (..)
import Helpers.Style exposing (svgStyle)
import Svg exposing (Svg)
import Svg.Attributes exposing (..)


heart : Bool -> Svg msg
heart active =
    let
        ( left, right ) =
            heartColors active
    in
        Svg.svg
            [ viewBox "0 0 57 50"
            , height "100%"
            , width "100%"
            ]
            [ Svg.g []
                [ Svg.path
                    [ d "M28.4 6s.2-.4 1-1.2c6.2-6 16.2-6 22.3 0 6.1 6 6.1 16 0 22l-22.4 22c-.2.3-.6.4-1 .4V6z"
                    , fill right
                    , style <| svgStyle "transition" "1s ease"
                    ]
                    []
                , Svg.path
                    [ d "M28.4 6s-.2-.4-1-1.2c-6.2-6-16.2-6-22.3 0-6.1 6-6.1 16 0 22l22.3 22c.3.3.6.4 1 .4V6z"
                    , fill left
                    , style <| svgStyle "transition" "1s ease"
                    ]
                    []
                ]
            ]


heartColors : Bool -> ( String, String )
heartColors active =
    if active then
        ( pinkRed, crimson )
    else
        ( silver, lightGray )
