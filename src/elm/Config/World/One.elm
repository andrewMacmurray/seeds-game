module Config.World.One exposing (world)

import Board.Coord as Coord exposing (Coord)
import Board.Wall as Wall exposing (s, w)
import Config.Level as Level
import Css.Color as Color
import Level.Setting.Start as Start
import Level.Setting.Tile exposing (..)
import Scenes.Level.Tutorial as Tutorial
import Seed exposing (Seed(..))


world : Level.World
world =
    Level.world
        { seed = Sunflower
        , backdropColor = Color.yellow
        , textColor = Color.darkYellow
        , textCompleteColor = Color.yellow
        , textBackgroundColor = Color.lightBrown
        }
        levels


levels : List Level.Level
levels =
    [ Level.withTutorial l1Tutorial
        { walls = Wall.walls l1Walls
        , startTiles = []
        , boardSize = { x = 5, y = 5 }
        , moves = 10
        , tileSettings =
            [ seed
                Sunflower
                (Probability 100)
                (TargetScore 60)
            ]
        }
    , Level.withTutorial l2Tutorial
        { walls = Wall.walls l2Walls
        , startTiles = l2StartTiles
        , boardSize = { x = 6, y = 6 }
        , moves = 10
        , tileSettings =
            [ seed
                Sunflower
                (Probability 50)
                (TargetScore 35)
            , rain
                (Probability 50)
                (TargetScore 35)
            ]
        }
    , Level.level
        { walls = Wall.walls []
        , startTiles = l3StartTiles
        , boardSize = { x = 7, y = 7 }
        , moves = 10
        , tileSettings =
            [ seed
                Sunflower
                (Probability 20)
                (TargetScore 50)
            , rain
                (Probability 20)
                (TargetScore 50)
            ]
        }
    , Level.withTutorial l4Tutorial
        { walls = Wall.walls l4Walls
        , startTiles = l4StartTiles
        , boardSize = { x = 7, y = 7 }
        , moves = 10
        , tileSettings =
            [ rain
                (Probability 33)
                (TargetScore 15)
            , seed
                Sunflower
                (Probability 33)
                (TargetScore 10)
            , sun
                (Probability 33)
                (TargetScore 15)
            ]
        }
    , Level.withTutorial l5Tutorial
        { walls = Wall.walls l5Walls
        , startTiles = l5StartTiles
        , moves = 15
        , boardSize = { x = 8, y = 8 }
        , tileSettings =
            [ rain
                (Probability 50)
                (TargetScore 75)
            , seed
                Sunflower
                (Probability 50)
                (TargetScore 75)
            , sun
                (Probability 50)
                (TargetScore 75)
            , burst
                (Probability 10)
            ]
        }
    , Level.level
        { walls = Wall.walls l6Walls
        , moves = 20
        , startTiles = l6StartTiles
        , boardSize = { x = 8, y = 8 }
        , tileSettings =
            [ rain
                (Probability 33)
                (TargetScore 50)
            , seed
                Sunflower
                (Probability 33)
                (TargetScore 50)
            , sun
                (Probability 33)
                (TargetScore 50)
            , burst
                (Probability 2)
            ]
        }
    , Level.level
        { walls = Wall.walls l7Walls
        , moves = 8
        , startTiles = l7StartTiles
        , boardSize = { x = 8, y = 8 }
        , tileSettings =
            [ seed
                Sunflower
                (Probability 33)
                (TargetScore 50)
            , sun
                (Probability 33)
                (TargetScore 50)
            , rain
                (Probability 33)
                (TargetScore 50)
            , burst
                (Probability 5)
            ]
        }
    , Level.level
        { walls = Wall.invisible l8Invisibles ++ Wall.walls l8Walls
        , moves = 10
        , startTiles = l8StartTiles
        , boardSize = { x = 8, y = 8 }
        , tileSettings =
            [ rain
                (Probability 20)
                (TargetScore 30)
            , seed
                Sunflower
                (Probability 31)
                (TargetScore 50)
            , sun
                (Probability 20)
                (TargetScore 30)
            , burst
                (Probability 5)
            ]
        }
    , Level.level
        { walls = []
        , moves = 5
        , startTiles = []
        , boardSize = { x = 8, y = 8 }
        , tileSettings =
            [ rain
                (Probability 31)
                (TargetScore 30)
            , seed
                Sunflower
                (Probability 31)
                (TargetScore 50)
            , sun
                (Probability 31)
                (TargetScore 30)
            , burst
                (Probability 5)
            ]
        }
    ]


l1Walls : List Coord
l1Walls =
    Wall.toCoords
        [ [ s, s, s, s, s ]
        , [ s, s, s, s, s ]
        , [ s, w, s, w, s ]
        , [ s, s, s, s, s ]
        , [ s, s, s, s, s ]
        ]


l1Tutorial : Tutorial.Tutorial
l1Tutorial =
    let
        highlightTiles =
            Tutorial.highlightHorizontalTiles { from = Coord.fromXY 3 4, length = 3 }
    in
    Tutorial.tutorial
        (Tutorial.step "Connect seeds to save them" highlightTiles)
        [ Tutorial.autoStep "Fill the seed bank to complete the level" Tutorial.highlightSeedBank
        ]


l2Walls : List Coord
l2Walls =
    Wall.toCoords
        [ [ s, s, s, s, s, s ]
        , [ s, w, s, s, w, s ]
        , [ s, s, s, s, s, s ]
        , [ s, s, s, s, s, s ]
        , [ s, w, s, s, w, s ]
        , [ s, s, s, s, s, s ]
        ]


l2StartTiles : List Start.Tile
l2StartTiles =
    List.concat
        [ Start.square (Start.sunflower 1 1) { size = 6 }
        , Start.square (Start.rain 2 2) { size = 4 }
        ]


l2Tutorial : Tutorial.Tutorial
l2Tutorial =
    let
        highlightTiles =
            Tutorial.highlightMultiple
                [ Tutorial.highlightVerticalTiles { from = Coord.fromXY 4 2, length = 4 }
                , Tutorial.highlightVerticalTiles { from = Coord.fromXY 5 3, length = 2 }
                , Tutorial.highlightHorizontalTiles { from = Coord.fromXY 4 3, length = 2 }
                , Tutorial.highlightHorizontalTiles { from = Coord.fromXY 4 4, length = 2 }
                ]
    in
    Tutorial.tutorial
        (Tutorial.step "Collect rain for our seeds" highlightTiles)
        [ Tutorial.autoStep "But don't run out of moves!" Tutorial.highlightRemainingMoves
        ]


l3StartTiles : List Start.Tile
l3StartTiles =
    List.concat
        [ Start.square (Start.rain 6 1) { size = 2 }
        , Start.corner (Start.sunflower 5 3) { size = 3, facing = Start.TopRight }
        , Start.corner (Start.rain 4 4) { size = 4, facing = Start.TopRight }
        , Start.corner (Start.sunflower 3 5) { size = 5, facing = Start.TopRight }
        , Start.corner (Start.rain 2 6) { size = 6, facing = Start.TopRight }
        , Start.corner (Start.sunflower 1 7) { size = 7, facing = Start.TopRight }
        ]


l4Walls : List Coord
l4Walls =
    Wall.toCoords
        [ [ s, s, s, s, s, s, s ]
        , [ s, s, w, s, w, s, s ]
        , [ s, s, w, s, w, s, s ]
        , [ s, s, s, s, s, s, s ]
        , [ s, s, w, s, w, s, s ]
        , [ s, s, w, s, w, s, s ]
        , [ s, s, s, s, s, s, s ]
        ]


l4StartTiles : List Start.Tile
l4StartTiles =
    List.concat
        [ Start.corner (Start.rain 1 1) { size = 4, facing = Start.BottomRight }
        , Start.corner (Start.sun 7 7) { size = 4, facing = Start.TopLeft }
        ]


l4Tutorial : Tutorial.Tutorial
l4Tutorial =
    let
        highlightTiles =
            Tutorial.highlightMultiple
                [ Tutorial.highlightHorizontalTiles { from = Coord.fromXY 4 7, length = 4 }
                , Tutorial.highlightVerticalTiles { from = Coord.fromXY 7 4, length = 4 }
                ]
    in
    Tutorial.tutorial
        (Tutorial.step "Harvest the sun's warmth for our seeds" highlightTiles)
        []


l5Walls : List Coord
l5Walls =
    Wall.toCoords
        [ [ s, s, s, s, s, s, s, s ]
        , [ s, w, s, s, s, s, w, s ]
        , [ s, w, s, s, s, s, w, s ]
        , [ s, s, s, s, s, s, s, s ]
        , [ s, s, s, s, s, s, s, s ]
        , [ s, w, s, s, s, s, w, s ]
        , [ s, w, s, s, s, s, w, s ]
        , [ s, s, s, s, s, s, s, s ]
        ]


l5StartTiles : List Start.Tile
l5StartTiles =
    List.concat
        [ Start.square (Start.sun 1 1) { size = 8 }
        , Start.square (Start.sunflower 2 2) { size = 6 }
        , Start.rectangle (Start.sun 4 1) { x = 2, y = 8 }
        , Start.square (Start.burst 4 4) { size = 2 }
        ]


l5Tutorial : Tutorial.Tutorial
l5Tutorial =
    let
        highlightTiles =
            Tutorial.highlightMultiple
                [ Tutorial.highlightVerticalTiles { from = Coord.fromXY 4 5, length = 3 }
                , Tutorial.highlightVerticalTiles { from = Coord.fromXY 5 6, length = 2 }
                , Tutorial.highlightHorizontalTiles { from = Coord.fromXY 4 6, length = 2 }
                , Tutorial.highlightHorizontalTiles { from = Coord.fromXY 4 7, length = 2 }
                ]
    in
    Tutorial.tutorial
        (Tutorial.step "Bursts clear all tiles of the same color" highlightTiles)
        [ Tutorial.autoStep "Longer trails mean bigger bursts!" Tutorial.noHighlight ]


l6Walls : List Coord
l6Walls =
    Wall.toCoords
        [ [ s, w, s, s, s, s, w, s ]
        , [ s, s, s, s, s, s, s, s ]
        , [ s, w, s, s, s, s, w, s ]
        , [ s, w, w, s, s, w, w, s ]
        , [ s, w, s, s, s, s, w, s ]
        , [ s, s, s, s, s, s, s, s ]
        , [ s, w, s, s, s, s, w, s ]
        , [ s, s, s, s, s, s, s, s ]
        ]


l6StartTiles : List Start.Tile
l6StartTiles =
    List.concat
        [ Start.line (Start.rain 3 1) { length = 8, direction = Start.Vertical }
        , Start.line (Start.sun 6 1) { length = 8, direction = Start.Vertical }
        , [ Start.burst 4 5
          , Start.burst 5 4
          ]
        ]


l7Walls : List Coord
l7Walls =
    Wall.toCoords
        [ [ s, s, s, s, s, s, s, s ]
        , [ s, s, s, s, s, s, s, s ]
        , [ s, s, s, s, s, s, s, s ]
        , [ s, s, s, w, w, s, s, s ]
        , [ s, s, s, w, w, s, s, s ]
        , [ s, s, s, s, s, s, s, s ]
        , [ s, s, s, s, s, s, s, s ]
        , [ s, s, s, s, s, s, s, s ]
        ]


l7StartTiles : List Start.Tile
l7StartTiles =
    List.concat
        [ Start.square (Start.sunflower 1 1) { size = 8 }
        , Start.square (Start.sun 2 2) { size = 6 }
        , Start.square (Start.rain 3 3) { size = 4 }
        ]


l8Walls : List Coord
l8Walls =
    Wall.toCoords
        [ [ s, s, s, s, s, s, s, s ]
        , [ s, s, s, s, s, s, s, s ]
        , [ s, s, w, s, s, w, s, s ]
        , [ s, s, s, s, s, s, s, s ]
        , [ s, s, s, s, s, s, s, s ]
        , [ s, s, w, s, s, w, s, s ]
        , [ s, s, s, s, s, s, s, s ]
        , [ s, s, s, s, s, s, s, s ]
        ]


l8Invisibles : List Coord
l8Invisibles =
    Wall.toCoords
        [ [ w, w, s, s, s, s, w, w ]
        , [ w, w, s, s, s, s, w, w ]
        , [ s, s, s, s, s, s, s, s ]
        , [ s, s, s, s, s, s, s, s ]
        , [ s, s, s, s, s, s, s, s ]
        , [ s, s, s, s, s, s, s, s ]
        , [ w, w, s, s, s, s, w, w ]
        , [ w, w, s, s, s, s, w, w ]
        ]


l8StartTiles : List Start.Tile
l8StartTiles =
    List.concat
        [ Start.square (Start.sunflower 4 4) { size = 2 }
        , Start.square (Start.rain 2 4) { size = 2 }
        , Start.square (Start.rain 6 4) { size = 2 }
        , Start.square (Start.sun 4 6) { size = 2 }
        , Start.square (Start.sun 4 2) { size = 2 }
        , [ Start.burst 1 4, Start.burst 8 5 ]
        ]
