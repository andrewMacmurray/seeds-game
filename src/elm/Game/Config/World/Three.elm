module Game.Config.World.Three exposing (world)

import Element.Palette as Palette
import Game.Board.Coord exposing (Coord)
import Game.Board.Wall as Wall exposing (s, w)
import Game.Config.Level as Level
import Game.Level.Tile as Tile
import Game.Level.Tile.Constant as Constant
import Seed exposing (Seed(..))



-- World Three


world : Level.World
world =
    Level.world
        { seed = Cornflower
        , backdropColor = Palette.blue2
        , textColor = Palette.white
        , textCompleteColor = Palette.white
        , textBackgroundColor = Palette.blue5
        }
        levels


levels : List Level.Level
levels =
    [ Level.level
        { walls = Wall.fromCoords l1Walls
        , startTiles = []
        , boardSize = { x = 6, y = 8 }
        , moves = 20
        , tileSettings =
            [ Tile.rain
                { probability = 20
                , targetScore = 40
                }
            , Tile.seed
                { seed = Cornflower
                , probability = 20
                , targetScore = 80
                }
            , Tile.seedPod
                { probability = 40
                }
            , Tile.burst
                { probability = 5
                }
            ]
        }
    , Level.level
        { walls = Wall.corners
        , moves = 10
        , startTiles = l2StartingTiles
        , boardSize = { x = 8, y = 8 }
        , tileSettings =
            [ Tile.seed
                { seed = Sunflower
                , probability = 25
                , targetScore = 30
                }
            , Tile.seed
                { seed = Cornflower
                , probability = 25
                , targetScore = 30
                }
            , Tile.rain
                { probability = 25
                , targetScore = 20
                }
            , Tile.seedPod
                { probability = 25
                }
            ]
        }
    , Level.level
        { walls = []
        , moves = 10
        , boardSize = { x = 8, y = 8 }
        , startTiles = []
        , tileSettings =
            [ Tile.seed
                { seed = Chrysanthemum
                , probability = 25
                , targetScore = 30
                }
            , Tile.seed
                { seed = Cornflower
                , probability = 25
                , targetScore = 30
                }
            , Tile.seed
                { seed = Sunflower
                , probability = 25
                , targetScore = 30
                }
            , Tile.rain
                { probability = 25
                , targetScore = 30
                }
            , Tile.seedPod
                { probability = 25
                }
            , Tile.burst
                { probability = 10
                }
            ]
        }
    ]


l1Walls : List Coord
l1Walls =
    Wall.coords
        [ [ s, s, s, s, s, s ]
        , [ w, w, w, s, s, s ]
        , [ s, s, s, s, s, s ]
        , [ s, s, s, w, w, w ]
        , [ s, s, s, s, s, s ]
        , [ w, w, w, s, s, s ]
        , [ s, s, s, s, s, s ]
        , [ s, s, s, s, s, s ]
        ]


l2StartingTiles : List Constant.Tile
l2StartingTiles =
    Constant.square (Constant.burst 4 4) { size = 2 }
