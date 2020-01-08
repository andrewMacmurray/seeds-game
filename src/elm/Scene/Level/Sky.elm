module Scene.Level.Sky exposing
    ( alternateColor
    , color
    , textColor
    )

import Css.Color as Color
import Scene.Level.Challenge as Challenge



-- Sky


type Sky
    = Day
    | Afternoon
    | Sunset
    | Night



-- Query


color : Challenge.TimeRemaining -> Color.Color
color =
    skyFromTimeRemaining >> skyToColor


alternateColor : Challenge.TimeRemaining -> Color.Color
alternateColor =
    skyFromTimeRemaining >> skyToAlternateColor


textColor : Challenge.TimeRemaining -> Color.Color
textColor =
    skyFromTimeRemaining >> skyToTextColor



-- Helpers


skyToColor : Sky -> Color.Color
skyToColor sky =
    case sky of
        Day ->
            Color.lightYellow

        Afternoon ->
            gold

        Sunset ->
            red

        Night ->
            Color.midnightBlue


skyToAlternateColor : Sky -> Color.Color
skyToAlternateColor sky =
    case sky of
        Day ->
            Color.washedYellow

        Afternoon ->
            lightYellow

        Sunset ->
            Color.rgb 255 215 131

        Night ->
            fadedMidnightBlue


skyToTextColor sky =
    case sky of
        Day ->
            Color.gold

        Afternoon ->
            Color.gold

        Sunset ->
            Color.rgb 129 103 42

        Night ->
            Color.white


skyFromTimeRemaining : Challenge.TimeRemaining -> Sky
skyFromTimeRemaining timeRemaining =
    let
        percent =
            Challenge.percentTimeRemaining timeRemaining
    in
    if percent >= 75 then
        Day

    else if percent >= 50 then
        Afternoon

    else if percent >= 33 then
        Sunset

    else
        Night



-- Colors


lightYellow : Color.Color
lightYellow =
    Color.rgb 255 250 126


gold : Color.Color
gold =
    Color.rgb 255 214 15


red : Color.Color
red =
    Color.rgb 255 82 18


darkRed : Color.Color
darkRed =
    Color.rgb 216 1 1


fadedMidnightBlue : Color.Color
fadedMidnightBlue =
    Color.rgb 28 59 78
