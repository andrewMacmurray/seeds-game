module Scene.Garden.Chrysanthemum exposing (hills, view)

import Angle
import Arc2d exposing (Arc2d)
import Circle2d
import Element exposing (..)
import Element.Palette as Palette
import Geometry.Svg as Svg
import Pixels exposing (Pixels)
import Point2d
import Scene.Garden.Flower as Flower
import Simple.Animation as Animation
import Svg exposing (Svg)
import Utils.Geometry as Geometry exposing (down)
import Utils.Svg as Svg
import View.Flower.Chrysanthemum as Chrysanthemum
import Window exposing (Window, vh, vw)



-- Description


description : String
description =
    "Chrysanthemums are native to Asia and Northeastern Europe, with the largest variety in China. They bloom early in Autumn, in many different colours and shapes. The Ancient Chinese used Chrysanthemum roots in pain relief medicine."



-- View


view : Flower.Config msg -> Element msg
view model =
    Flower.view
        { backdrop = Palette.purple
        , hills = hills model.window
        , flowers = flowers
        , description = description
        , isVisible = model.isVisible
        , onHide = model.onHide
        }


flowers : Element msg
flowers =
    row [ centerX ]
        [ el [ width (px 90), alignBottom, moveRight 10 ] (chrysanthemum 2200)
        , el [ width (px 150), moveUp 60 ] (chrysanthemum 2000)
        , el [ width (px 90), alignBottom, moveLeft 10 ] (chrysanthemum 2400)
        ]


chrysanthemum : Animation.Millis -> Element msg
chrysanthemum =
    html << Chrysanthemum.animated


hills : Window -> Svg msg
hills window =
    Svg.window window
        []
        [ middleHill -100 window Palette.purple
        , roundHill 0 Palette.pinkRed window
        , Geometry.mirror window (roundHill 0 Palette.orange window)
        , middleHill 0 window Palette.darkPurple
        , roundHill 300 Palette.gold window
        , Geometry.mirror window (roundHill 300 Palette.darkRed window)
        , middleHill 300 window Palette.lightGold
        ]


centerRound_ w =
    Arc2d.from
        (Point2d.pixels (vw w / 4) (vh w))
        (Point2d.pixels (3 * (vw w / 4)) (vh w))
        (Angle.degrees 90)


centerPoint w =
    Arc2d.pointOn (centerRound_ w) 0.5


middleHill y w c =
    Svg.circle2d [ Svg.fill_ c ] (middleHill_ y w)


roundHill y color window =
    Svg.circle2d [ Svg.fill_ color ] (roundHill_ y window)


middleHill_ y w =
    Circle2d.translateBy (down y)
        (Circle2d.atPoint
            (Point2d.pixels (vw w / 2) (vh w - 60))
            (Pixels.pixels 500)
        )


roundHill_ y w =
    Circle2d.translateBy (down y)
        (Circle2d.atPoint
            (Point2d.pixels (vw w / 6) 500)
            (Pixels.pixels 500)
        )
