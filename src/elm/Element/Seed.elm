module Element.Seed exposing
    ( Options
    , chrysanthemum
    , cornflower
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


type alias Options msg =
    { size : Size
    , attributes : List (Attribute msg)
    }


fill =
    Fill


size =
    Pixels



-- View


view : Options msg -> Seed -> Element msg
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


grey : Options msg -> Element msg
grey =
    sized
        (Mono.seed
            { color = Palette.transparentGray
            }
        )


rose : Options msg -> Element msg
rose =
    sized
        (Mono.seed
            { color = Palette.mauve4
            }
        )


chrysanthemum : Options msg -> Element msg
chrysanthemum =
    sized
        (Circle.seed
            { background = Palette.mauve4
            , center = Palette.orange
            }
        )


sunflower : Options msg -> Element msg
sunflower =
    sized
        (Twin.seed
            { left = Palette.chocolate
            , right = Palette.lightBrown
            }
        )


cornflower : Options msg -> Element msg
cornflower =
    sized
        (Twin.seed
            { left = Palette.midnightBlue
            , right = Palette.blueGrey
            }
        )


marigold : Options msg -> Element msg
marigold =
    sized
        (Twin.seed
            { left = Palette.gold
            , right = Palette.darkRed
            }
        )


lupin : Options msg -> Element msg
lupin =
    sized
        (Twin.seed
            { left = Palette.crimson
            , right = Palette.brown
            }
        )


sized : Element msg -> Options msg -> Element msg
sized el_ options =
    Element.el (attributes options) el_


attributes : Options msg -> List (Attribute msg)
attributes options =
    List.append [ toWidth options.size ] options.attributes


toWidth : Size -> Attribute msg
toWidth size_ =
    case size_ of
        Fill ->
            Element.width Element.fill

        Pixels n ->
            Element.width (Element.px n)
