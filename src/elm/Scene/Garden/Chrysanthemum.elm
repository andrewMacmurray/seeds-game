module Scene.Garden.Chrysanthemum exposing (roundHills)

import Angle
import Arc2d exposing (Arc2d)
import Element.Palette as Palette
import Geometry.Svg as Svg
import Pixels exposing (Pixels)
import Point2d
import Svg exposing (Svg)
import Triangle2d exposing (Triangle2d)
import Utils.Geometry exposing (down, mirror)
import Utils.Svg as Svg
import Window exposing (Window, vh, vw)


roundHills : Window -> Svg msg
roundHills window =
    Svg.g []
        [ roundHill Palette.pinkRed window
        , mirror window (roundHill Palette.purple window)
        , centerRound window
        , framingHill Palette.darkRed window
        , mirror window (framingHill Palette.darkRed window)
        ]


centerRound w =
    Svg.arc2d [] (centerRound_ w)


centerRound_ w =
    Arc2d.from
        (Point2d.pixels (vw w / 4) (vh w))
        (Point2d.pixels (3 * (vw w / 4)) (vh w))
        (Angle.degrees 90)


framingHill color window =
    Svg.triangle2d [ Svg.fill_ color ] (framingHill_ window)


framingHill_ window =
    Triangle2d.from
        (Point2d.pixels 0 (vh window - (vh window / 4)))
        (Point2d.pixels (vw window / 3) (vh window))
        (Point2d.pixels 0 (vh window))


roundHill color window =
    Svg.g []
        [ Svg.arc2d [ Svg.fill_ color ] (roundHill_ window)
        , Svg.triangle2d [ Svg.fill_ color ] (roundHillBase_ window)
        ]


roundHill_ : Window -> Arc2d Pixels coordinates
roundHill_ window =
    Arc2d.translateBy (down 300)
        (Arc2d.from
            (Point2d.pixels 0 0)
            (Point2d.pixels (vw window / 2 + 300) (vh window))
            (Angle.degrees 90)
        )


roundHillBase_ : Window -> Triangle2d Pixels coordinates
roundHillBase_ window =
    Triangle2d.translateBy (down 299)
        (Triangle2d.from
            (Point2d.pixels 0 0)
            (Point2d.pixels (vw window / 2 + 300) (vh window))
            (Point2d.pixels 0 (vh window))
        )
