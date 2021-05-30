module Element.Seed exposing
    ( Options
    , chrysanthemum
    , fill
    , grey
    , lupin
    , marigold
    , rose
    , size
    , sunflower
    , view
    )

import Element exposing (Attribute, Element)
import Element.Palette as Palette
import Element.Seed.Circle as Circle
import Element.Seed.Mono as Mono
import Element.Seed.Twin as Twin
import Seed exposing (Seed)



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
    Element.el [ toWidth options.size ] el_


toWidth : Size -> Attribute msg
toWidth size_ =
    case size_ of
        Fill ->
            Element.width Element.fill

        Pixels n ->
            Element.width (Element.px n)
