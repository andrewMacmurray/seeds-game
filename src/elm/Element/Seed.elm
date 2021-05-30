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

import Element exposing (Attribute, Element, el)
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


view : Options -> List (Attribute msg) -> Seed -> Element msg
view options attrs seed =
    case seed of
        Seed.Sunflower ->
            sunflower options attrs

        Seed.Chrysanthemum ->
            chrysanthemum options attrs

        Seed.Cornflower ->
            cornflower options attrs

        Seed.Lupin ->
            lupin options attrs

        Seed.Marigold ->
            marigold options attrs

        Seed.Rose ->
            rose options attrs



-- Individual


grey : Options -> List (Attribute msg) -> Element msg
grey options attrs =
    seed_ options
        attrs
        (Mono.seed []
            { color = Palette.transparentGray
            }
        )


rose : Options -> List (Attribute msg) -> Element msg
rose options attrs =
    Mono.seed []
        { color = Palette.mauve4
        }


chrysanthemum : Options -> List (Attribute msg) -> Element msg
chrysanthemum options attrs =
    Circle.seed []
        { background = Palette.mauve4
        , center = Palette.orange
        }


sunflower : Options -> List (Attribute msg) -> Element msg
sunflower options attrs =
    Twin.seed []
        { left = Palette.chocolate
        , right = Palette.lightBrown
        }


cornflower : Options -> List (Attribute msg) -> Element msg
cornflower options attrs =
    Twin.seed []
        { left = Palette.midnightBlue
        , right = Palette.blueGrey
        }


marigold : Options -> List (Attribute msg) -> Element msg
marigold options attrs =
    Twin.seed []
        { left = Palette.gold
        , right = Palette.darkRed
        }


lupin : Options -> List (Attribute msg) -> Element msg
lupin options attrs =
    seed_ options
        attrs
        (Twin.seed []
            { left = Palette.crimson
            , right = Palette.brown
            }
        )


seed_ options attrs =
    el (attributes options attrs)


attributes : Options -> List (Attribute msg) -> List (Attribute msg)
attributes options =
    List.append [ toWidth options.size ]


toWidth : Size -> Attribute msg
toWidth size_ =
    case size_ of
        Fill ->
            Element.width Element.fill

        Pixels n ->
            Element.width (Element.px n)
