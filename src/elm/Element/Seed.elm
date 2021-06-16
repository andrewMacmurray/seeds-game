module Element.Seed exposing
    ( Options
    , chrysanthemum
    , extraSmall
    , fill
    , grey
    , lupin
    , marigold
    , medium
    , rose
    , size
    , small
    , sunflower
    , view
    )

import Element exposing (Attribute, Element)
import Element.Palette as Palette
import Element.Seed.Circle as Circle
import Element.Seed.Mono as Mono
import Element.Seed.Twin as Twin
import Seed exposing (Seed)
import Utils.Element as Element



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
view options seed =
    case seed of
        Seed.Sunflower ->
            sunflower options

        Seed.Chrysanthemum ->
            chrysanthemum options

        Seed.Cornflower ->
            cornflower options

        Seed.Lupin ->
            lupin options

        Seed.Marigold ->
            marigold options

        Seed.Rose ->
            rose options



-- Individual


grey : Options -> Element msg
grey =
    sized
        (Mono.seed
            { color = Palette.transparentGray
            }
        )


rose : Options -> Element msg
rose =
    sized
        (Mono.seed
            { color = Palette.mauve4
            }
        )


chrysanthemum : Options -> Element msg
chrysanthemum =
    sized
        (Circle.seed
            { background = Palette.mauve4
            , center = Palette.orange
            }
        )


sunflower : Options -> Element msg
sunflower =
    sized
        (Twin.seed
            { left = Palette.chocolate
            , right = Palette.lightBrown
            }
        )


cornflower : Options -> Element msg
cornflower =
    sized
        (Twin.seed
            { left = Palette.midnightBlue
            , right = Palette.blueGrey
            }
        )


marigold : Options -> Element msg
marigold =
    sized
        (Twin.seed
            { left = Palette.gold
            , right = Palette.darkRed
            }
        )


lupin : Options -> Element msg
lupin =
    sized
        (Twin.seed
            { left = Palette.crimson
            , right = Palette.brown
            }
        )


sized : Element msg -> Options -> Element msg
sized el_ options =
    case options.size of
        Fill ->
            el_

        Pixels n ->
            Element.square n [] el_
