module Game.Config.World.One exposing (world)

import Element.Palette as Palette
import Game.Board.Coord as Coord exposing (Coord)
import Game.Board.Wall as Wall exposing (s, w)
import Game.Config.Level as Level
import Game.Level.Tile as Tile
import Game.Level.Tile.Constant as Constant
import Game.Level.Tutorial as Tutorial
import Seed exposing (Seed(..))



-- World One


world : Level.World
world =
    Level.world
        { seed = Sunflower
        , backdropColor = Palette.yellow
        , textColor = Palette.textYellow
        , textCompleteColor = Palette.white
        , textBackgroundColor = Palette.brown3
        }
        levels


levels : List Level.Level
levels =
    [ Level.withTutorial l1Tutorial
        { walls = Wall.fromCoords l1Walls
        , startTiles = []
        , boardSize = { x = 5, y = 5 }
        , moves = 10
        , tileSettings =
            [ Tile.seed
                { seed = Sunflower
                , probability = 100
                , targetScore = 60
                }
            ]
        }
    , Level.withTutorial l2Tutorial
        { walls = Wall.fromCoords l2Walls
        , startTiles = l2StartTiles
        , boardSize = { x = 6, y = 6 }
        , moves = 10
        , tileSettings =
            [ Tile.seed
                { seed = Sunflower
                , probability = 50
                , targetScore = 35
                }
            , Tile.rain
                { probability = 50
                , targetScore = 35
                }
            ]
        }
    , Level.level
        { walls = Wall.fromCoords []
        , startTiles = l3StartTiles
        , boardSize = { x = 7, y = 7 }
        , moves = 10
        , tileSettings =
            [ Tile.seed
                { seed = Sunflower
                , probability = 20
                , targetScore = 50
                }
            , Tile.rain
                { probability = 20
                , targetScore = 50
                }
            ]
        }
    , Level.withTutorial l4Tutorial
        { walls = Wall.fromCoords l4Walls
        , startTiles = l4StartTiles
        , boardSize = { x = 7, y = 7 }
        , moves = 10
        , tileSettings =
            [ Tile.rain
                { probability = 33
                , targetScore = 15
                }
            , Tile.seed
                { seed = Sunflower
                , probability = 33
                , targetScore = 10
                }
            , Tile.sun
                { probability = 33
                , targetScore = 15
                }
            ]
        }
    , Level.withTutorial l5Tutorial
        { walls = Wall.fromCoords l5Walls
        , startTiles = l5StartTiles
        , moves = 15
        , boardSize = { x = 8, y = 8 }
        , tileSettings =
            [ Tile.rain
                { probability = 50
                , targetScore = 75
                }
            , Tile.seed
                { seed = Sunflower
                , probability = 50
                , targetScore = 75
                }
            , Tile.sun
                { probability = 50
                , targetScore = 75
                }
            , Tile.burst
                { probability = 10
                }
            ]
        }
    , Level.level
        { walls = Wall.fromCoords l6Walls
        , moves = 10
        , startTiles = l6StartTiles
        , boardSize = { x = 8, y = 8 }
        , tileSettings =
            [ Tile.rain
                { probability = 33
                , targetScore = 50
                }
            , Tile.seed
                { seed = Sunflower
                , probability = 33
                , targetScore = 50
                }
            , Tile.sun
                { probability = 33
                , targetScore = 50
                }
            , Tile.burst
                { probability = 2
                }
            ]
        }
    , Level.level
        { walls = Wall.fromCoords l7Walls
        , moves = 8
        , startTiles = l7StartTiles
        , boardSize = { x = 8, y = 8 }
        , tileSettings =
            [ Tile.rain
                { probability = 33
                , targetScore = 50
                }
            , Tile.seed
                { seed = Sunflower
                , probability = 33
                , targetScore = 50
                }
            , Tile.sun
                { probability = 33
                , targetScore = 50
                }
            , Tile.burst
                { probability = 5
                }
            ]
        }
    , Level.level
        { walls = Wall.invisible l8Invisibles ++ Wall.fromCoords l8Walls
        , moves = 8
        , startTiles = l8StartTiles
        , boardSize = { x = 8, y = 8 }
        , tileSettings =
            [ Tile.rain
                { probability = 20
                , targetScore = 30
                }
            , Tile.seed
                { seed = Sunflower
                , probability = 31
                , targetScore = 50
                }
            , Tile.sun
                { probability = 20
                , targetScore = 30
                }
            , Tile.burst
                { probability = 5
                }
            ]
        }
    , Level.level
        { walls = []
        , moves = 5
        , startTiles = []
        , boardSize = { x = 8, y = 8 }
        , tileSettings =
            [ Tile.rain
                { probability = 31
                , targetScore = 30
                }
            , Tile.seed
                { seed = Sunflower
                , probability = 31
                , targetScore = 50
                }
            , Tile.sun
                { probability = 31
                , targetScore = 30
                }
            , Tile.burst
                { probability = 5
                }
            ]
        }
    ]


l1Walls : List Coord
l1Walls =
    Wall.coords
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
            Tutorial.horizontalTiles { from = Coord.fromXY 3 4, length = 3 }
    in
    Tutorial.tutorial
        (Tutorial.step "Connect seeds to save them" highlightTiles)
        [ Tutorial.autoStep "Collect seeds to complete the level" Tutorial.seedBank
        ]


l2Walls : List Coord
l2Walls =
    Wall.coords
        [ [ s, s, s, s, s, s ]
        , [ s, w, s, s, w, s ]
        , [ s, s, s, s, s, s ]
        , [ s, s, s, s, s, s ]
        , [ s, w, s, s, w, s ]
        , [ s, s, s, s, s, s ]
        ]


l2StartTiles : List Constant.Tile
l2StartTiles =
    List.concat
        [ Constant.square (Constant.sunflower 1 1) { size = 6 }
        , Constant.square (Constant.rain 2 2) { size = 4 }
        ]


l2Tutorial : Tutorial.Tutorial
l2Tutorial =
    let
        highlightTiles =
            Tutorial.highlightMultiple
                [ Tutorial.verticalTiles { from = Coord.fromXY 4 2, length = 4 }
                , Tutorial.verticalTiles { from = Coord.fromXY 5 3, length = 2 }
                , Tutorial.horizontalTiles { from = Coord.fromXY 4 3, length = 2 }
                , Tutorial.horizontalTiles { from = Coord.fromXY 4 4, length = 2 }
                ]
    in
    Tutorial.tutorial
        (Tutorial.step "Collect rain for our seeds" highlightTiles)
        [ Tutorial.autoStep "But don't run out of moves!" Tutorial.remainingMoves
        ]


l3StartTiles : List Constant.Tile
l3StartTiles =
    List.concat
        [ Constant.square (Constant.rain 6 1) { size = 2 }
        , Constant.corner (Constant.sunflower 5 3) { size = 3, facing = Constant.TopRight }
        , Constant.corner (Constant.rain 4 4) { size = 4, facing = Constant.TopRight }
        , Constant.corner (Constant.sunflower 3 5) { size = 5, facing = Constant.TopRight }
        , Constant.corner (Constant.rain 2 6) { size = 6, facing = Constant.TopRight }
        , Constant.corner (Constant.sunflower 1 7) { size = 7, facing = Constant.TopRight }
        ]


l4Walls : List Coord
l4Walls =
    Wall.coords
        [ [ s, s, s, s, s, s, s ]
        , [ s, s, w, s, w, s, s ]
        , [ s, s, w, s, w, s, s ]
        , [ s, s, s, s, s, s, s ]
        , [ s, s, w, s, w, s, s ]
        , [ s, s, w, s, w, s, s ]
        , [ s, s, s, s, s, s, s ]
        ]


l4StartTiles : List Constant.Tile
l4StartTiles =
    List.concat
        [ Constant.corner (Constant.rain 1 1) { size = 4, facing = Constant.BottomRight }
        , Constant.corner (Constant.sun 7 7) { size = 4, facing = Constant.TopLeft }
        ]


l4Tutorial : Tutorial.Tutorial
l4Tutorial =
    let
        highlightTiles =
            Tutorial.highlightMultiple
                [ Tutorial.horizontalTiles { from = Coord.fromXY 4 7, length = 4 }
                , Tutorial.verticalTiles { from = Coord.fromXY 7 4, length = 4 }
                ]
    in
    Tutorial.tutorial
        (Tutorial.step "Harvest the sun's warmth for our seeds" highlightTiles)
        []


l5Walls : List Coord
l5Walls =
    Wall.coords
        [ [ s, s, s, s, s, s, s, s ]
        , [ s, w, s, s, s, s, w, s ]
        , [ s, w, s, s, s, s, w, s ]
        , [ s, s, s, s, s, s, s, s ]
        , [ s, s, s, s, s, s, s, s ]
        , [ s, w, s, s, s, s, w, s ]
        , [ s, w, s, s, s, s, w, s ]
        , [ s, s, s, s, s, s, s, s ]
        ]


l5StartTiles : List Constant.Tile
l5StartTiles =
    List.concat
        [ Constant.square (Constant.sun 1 1) { size = 8 }
        , Constant.square (Constant.sunflower 2 2) { size = 6 }
        , Constant.rectangle (Constant.sun 4 1) { x = 2, y = 8 }
        , Constant.square (Constant.burst 4 4) { size = 2 }
        ]


l5Tutorial : Tutorial.Tutorial
l5Tutorial =
    let
        highlightTiles =
            Tutorial.highlightMultiple
                [ Tutorial.verticalTiles { from = Coord.fromXY 4 5, length = 3 }
                , Tutorial.verticalTiles { from = Coord.fromXY 5 6, length = 2 }
                , Tutorial.horizontalTiles { from = Coord.fromXY 4 6, length = 2 }
                , Tutorial.horizontalTiles { from = Coord.fromXY 4 7, length = 2 }
                ]
    in
    Tutorial.tutorial
        (Tutorial.step "Bursts clear all tiles of the same color" highlightTiles)
        [ Tutorial.autoStep "Longer trails mean bigger bursts!" Tutorial.noHighlight ]


l6Walls : List Coord
l6Walls =
    Wall.coords
        [ [ s, w, s, s, s, s, w, s ]
        , [ s, s, s, s, s, s, s, s ]
        , [ s, w, s, s, s, s, w, s ]
        , [ s, w, w, s, s, w, w, s ]
        , [ s, w, s, s, s, s, w, s ]
        , [ s, s, s, s, s, s, s, s ]
        , [ s, w, s, s, s, s, w, s ]
        , [ s, s, s, s, s, s, s, s ]
        ]


l6StartTiles : List Constant.Tile
l6StartTiles =
    List.concat
        [ Constant.line (Constant.rain 3 1) { length = 8, direction = Constant.Vertical }
        , Constant.line (Constant.sun 6 1) { length = 8, direction = Constant.Vertical }
        , [ Constant.burst 4 5
          , Constant.burst 5 4
          ]
        ]


l7Walls : List Coord
l7Walls =
    Wall.coords
        [ [ s, s, s, s, s, s, s, s ]
        , [ s, s, s, s, s, s, s, s ]
        , [ s, s, s, s, s, s, s, s ]
        , [ s, s, s, w, w, s, s, s ]
        , [ s, s, s, w, w, s, s, s ]
        , [ s, s, s, s, s, s, s, s ]
        , [ s, s, s, s, s, s, s, s ]
        , [ s, s, s, s, s, s, s, s ]
        ]


l7StartTiles : List Constant.Tile
l7StartTiles =
    List.concat
        [ Constant.square (Constant.sunflower 1 1) { size = 8 }
        , Constant.square (Constant.sun 2 2) { size = 6 }
        , Constant.square (Constant.rain 3 3) { size = 4 }
        ]


l8Walls : List Coord
l8Walls =
    Wall.coords
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
    Wall.coords
        [ [ w, w, s, s, s, s, w, w ]
        , [ w, w, s, s, s, s, w, w ]
        , [ s, s, s, s, s, s, s, s ]
        , [ s, s, s, s, s, s, s, s ]
        , [ s, s, s, s, s, s, s, s ]
        , [ s, s, s, s, s, s, s, s ]
        , [ w, w, s, s, s, s, w, w ]
        , [ w, w, s, s, s, s, w, w ]
        ]


l8StartTiles : List Constant.Tile
l8StartTiles =
    List.concat
        [ Constant.square (Constant.sunflower 4 4) { size = 2 }
        , Constant.square (Constant.rain 2 4) { size = 2 }
        , Constant.square (Constant.rain 6 4) { size = 2 }
        , Constant.square (Constant.sun 4 6) { size = 2 }
        , Constant.square (Constant.sun 4 2) { size = 2 }
        , [ Constant.burst 1 4, Constant.burst 8 5 ]
        ]
