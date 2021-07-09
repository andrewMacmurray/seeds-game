module Element.Seed exposing
    ( Options
    , extraSmall
    , fill
    , grey
    , grey_
    , large
    , medium
    , size
    , small
    , svg
    , view
    )

import Element exposing (Element)
import Element.Icon as Icon
import Element.Palette as Palette
import Element.Seed.Circle as Circle
import Element.Seed.Mono as Mono
import Element.Seed.Twin as Twin
import Seed exposing (Seed)
import Svg exposing (Svg)
import Utils.Element as Element


type alias Icon msg =
    { el : Element msg
    , svg : Svg msg
    }



-- Options


type Size
    = Fill
    | Pixels Int


type alias Options =
    { size : Size
    }


fill : Options
fill =
    { size = Fill
    }


size : Int -> Options
size n =
    { size = Pixels n
    }


large : Options
large =
    size 75


medium : Options
medium =
    size 50


small : Options
small =
    size 35


extraSmall : Options
extraSmall =
    size 20



-- View


view : Options -> Seed -> Element msg
view options =
    view_ >> .el >> sized options


svg : Seed -> Svg msg
svg =
    view_ >> .svg


view_ : Seed -> Icon.Dual msg
view_ seed =
    case seed of
        Seed.Sunflower ->
            sunflower

        Seed.Chrysanthemum ->
            chrysanthemum

        Seed.Cornflower ->
            cornflower

        Seed.Lupin ->
            lupin

        Seed.Marigold ->
            marigold

        Seed.Rose ->
            rose



-- Greyed Out


grey : Options -> Element msg
grey options =
    greyIcon
        |> .el
        |> sized options


grey_ : Svg msg
grey_ =
    .svg greyIcon


greyIcon : Icon.Dual msg
greyIcon =
    Mono.seed
        { color = Palette.transparentGray
        }



-- Individual


rose : Icon.Dual msg
rose =
    Mono.seed
        { color = Palette.mauve4
        }


chrysanthemum : Icon.Dual msg
chrysanthemum =
    Circle.seed
        { background = Palette.mauve4
        , center = Palette.orange
        }


sunflower : Icon.Dual msg
sunflower =
    Twin.seed
        { left = Palette.brown1
        , right = Palette.brown7
        }


cornflower : Icon.Dual msg
cornflower =
    Twin.seed
        { left = Palette.midnightBlue
        , right = Palette.blueGrey
        }


marigold : Icon.Dual msg
marigold =
    Twin.seed
        { left = Palette.gold
        , right = Palette.darkRed
        }


lupin : Icon.Dual msg
lupin =
    Twin.seed
        { left = Palette.crimson
        , right = Palette.brown5
        }



-- Utils


sized : Options -> Element msg -> Element msg
sized options el_ =
    case options.size of
        Fill ->
            el_

        Pixels n ->
            Element.square n [] el_
