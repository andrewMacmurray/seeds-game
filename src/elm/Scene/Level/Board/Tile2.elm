module Scene.Level.Board.Tile2 exposing (currentMove, view)

import Board
import Board.Block as Block exposing (Block)
import Board.Coord as Coord exposing (Coord)
import Board.Move as Move exposing (Move)
import Board.Tile as Tile exposing (Tile)
import Element exposing (..)
import Element.Dot as Dot
import Element.Icon.Burst as Burst
import Element.Palette as Palette
import Element.Seed as Seed2
import Element.Transition as Transition
import Level.Setting.Tile as Tile
import Scene.Level.Board.Tile.Leaving2 as Leaving
import Scene.Level.Board.Tile.Stroke as Stroke
import Scene.Level.Board.Tile.Style as Tile
import Scene.Level.Board.Tile.Wall as Wall
import Seed exposing (Seed)
import Simple.Animation as Animation exposing (Animation)
import Simple.Animation.Property as P
import Simple.Transition as Transition
import Utils.Animated as Animated
import Utils.Element as Element
import Window exposing (Window)



-- Model


type alias Model =
    { isBursting : Bool
    , window : Window
    , settings : List Tile.Setting
    , boardSize : Board.Size
    , move : Move
    }



-- View2


type alias Tile_ msg =
    { animation : Maybe Animation
    , transition : Transition.Millis
    , transitionDelay : Transition.Millis
    , element : Element msg
    , tracer : Maybe Tracer
    , width : Int
    , height : Int
    , scale : Float
    , alpha : Float
    , offsetX : Float
    , offsetY : Float
    }


type alias Tracer =
    { animation : Animation
    }


toTileModel : Model -> Tile_ msg
toTileModel model =
    { animation = Nothing
    , transition = 0
    , transitionDelay = 0
    , element = tileElement model
    , tracer = Nothing
    , width = tileWidth model.window
    , height = tileHeight model.window
    , scale = 1
    , alpha = 1
    , offsetX = offsetX model
    , offsetY = offsetY model
    }



-- View


type alias CurrentMove =
    { window : Window
    , settings : List Tile.Setting
    , boardSize : Board.Size
    , move : Move
    }


currentMove : CurrentMove -> Element msg
currentMove model =
    toTileModel
        { isBursting = False
        , window = model.window
        , settings = model.settings
        , boardSize = model.boardSize
        , move = model.move
        }
        |> view_


view : Model -> Element msg
view model =
    toTileModel model
        |> withDragging model
        |> withTracer model
        |> withLeaving model
        |> view_


view_ : Tile_ msg -> Element msg
view_ model =
    el
        [ width (px model.width)
        , height (px model.height)
        , scale model.scale
        , alpha model.alpha
        , transitionAll model
        , moveRight model.offsetX
        , moveDown model.offsetY
        ]
        (el
            [ behindContent (viewTracer model)
            , centerX
            , centerY
            ]
            model.element
        )


viewTracer : Tile_ msg -> Element msg
viewTracer model =
    Element.showIfJust (viewTracer_ model) model.tracer


viewTracer_ : Tile_ msg -> Tracer -> Element msg
viewTracer_ model tracer =
    Animated.el tracer.animation
        [ centerX
        , centerY
        ]
        model.element



-- From Model


tileElement : Model -> Element msg
tileElement model =
    case Move.block model.move of
        Block.Wall color ->
            Wall.view_ model color

        Block.Space state ->
            toTileElement model state


toTileElement : Model -> Tile.State -> Element msg
toTileElement model state =
    case Tile.get state of
        Just Tile.Rain ->
            Dot.solid
                { size = tileSize model
                , color = Palette.blue5
                }

        Just Tile.Sun ->
            Dot.solid
                { size = tileSize model
                , color = Palette.gold
                }

        Just Tile.SeedPod ->
            Dot.split
                { size = tileSize model
                , left = Palette.lime5
                , right = Palette.lime4
                }

        Just (Tile.Seed seed_) ->
            toSeedElement model seed_

        Just (Tile.Burst tile_) ->
            toBurstElement model tile_

        Nothing ->
            none


toSeedElement : Model -> Seed -> Element msg
toSeedElement model seed =
    Seed2.view (seedSize model) seed


seedSize : Model -> Seed2.Options
seedSize =
    tileSize >> Seed2.size


toBurstElement : Model -> Maybe Tile -> Element msg
toBurstElement model tile =
    el [ width (px (tileSize model)) ] (toBurstElement_ model tile)


toBurstElement_ : Model -> Maybe Tile -> Element msg
toBurstElement_ model tile =
    case tile of
        Just tile_ ->
            if Block.isLeaving (Move.block model.move) then
                Burst.active
                    { color = Stroke.darker tile_
                    , border = Stroke.darker tile_
                    }

            else
                Burst.active
                    { color = Stroke.darker tile_
                    , border = Stroke.lighter tile_
                    }

        Nothing ->
            Burst.inactive


transitionAll : Tile_ msg -> Attribute msg
transitionAll tile =
    Transition.all_
        { duration = tile.transition
        , options = [ Transition.delay tile.transitionDelay ]
        }
        [ Transition.opacity
        , Transition.transform
        ]



-- View
--view : Model -> Element msg
--view model =
--    column (attributes model)
--        [ viewTile model
--        , viewWall model
--        ]
--
--
--attributes : Model -> List (Attribute msg)
--attributes model =
--    List.concat
--        [ baseAttributes model
--        , leavingAttributes model
--        ]
--
--
--baseAttributes : Model -> List (Attribute msg)
--baseAttributes model =
--    [ width (px (tileWidth model.window))
--    , height (px (tileHeight model.window))
--    , inFront (viewTracer model)
--    ]
--
--
--leavingAttributes : Model -> List (Attribute msg)
--leavingAttributes model =
--    Leaving.attributes (leavingViewModel model)
--        [ moveRight (offsetX model)
--        , moveDown (offsetY model)
--        ]
--
--
--viewTracer : Model -> Element msg
--viewTracer model =
--    Element.showIf model.withTracer (tracer_ model)
--
--
--tracer_ : Model -> Element msg
--tracer_ model =
--    viewTileWith (Tile.moveTracerStyles model.move) model
--
--
--viewWall : Model -> Element msg
--viewWall model =
--    Wall.view
--        { window = model.window
--        , move = model.move
--        }
--
--
--viewTile : Model -> Element msg
--viewTile model =
--    viewTileWith (Tile.draggingStyles model.isBursting model.move) model
--
--
--viewTileWith : List Style -> Model -> Element msg
--viewTileWith extraStyles model =
--    html
--        (Html.div
--            [ Style.styles
--                [ extraStyles
--                , baseTileStyles model
--                ]
--            , Style.classes Tile.baseClasses
--            ]
--            [ innerTileElement (Move.block model.move) ]
--        )
--
--
--baseTileStyles : Model -> List Style
--baseTileStyles { move, window } =
--    let
--        block =
--            Move.block move
--    in
--    List.concat
--        [ Tile.growingStyles move
--        , Tile.enteringStyles move
--        , Tile.fallingStyles move
--        , Tile.releasingStyles move
--        , Style.size (roundFloat (Tile.size block * Tile.scale window))
--        , Tile.background block
--        ]
--
--
--roundFloat : Float -> Float
--roundFloat =
--    round >> toFloat
--
--
--innerTileElement : Block -> Html msg
--innerTileElement block =
--    case Block.tile block of
--        Just (Tile.Seed seedType) ->
--            Seed.view seedType
--
--        Just (Tile.Burst tile) ->
--            viewBurst block tile
--
--        _ ->
--            Html.span [] []
--
--
--viewBurst : Block -> Maybe Tile -> Html msg
--viewBurst block tile =
--    Html.div
--        [ Style.style (Tile.burstStyles block) ]
--        [ renderBurst_ tile (Block.isLeaving block) ]
--
--
--renderBurst_ : Maybe Tile -> Bool -> Html msg
--renderBurst_ tile isLeaving =
--    Html.text ""
--
--case tile of
--    Just tile_ ->
--        if isLeaving then
--            Burst.active
--                (Tile.strokeColors tile_)
--                (Tile.strokeColors tile_)
--
--        else
--            Burst.active
--                (Tile.strokeColors tile_)
--                (Tile.lighterStrokeColor tile_)
--
--    Nothing ->
--        Burst.inactive
-- Config


tileWidth : Window -> Int
tileWidth window =
    round (Tile.baseSizeX * Tile.scale window)


tileHeight : Window -> Int
tileHeight window =
    round (Tile.baseSizeY * Tile.scale window)


tileSize : Model -> Int
tileSize model =
    round (Tile.size (Move.block model.move) * Tile.scale model.window)


offsetX : Model -> Float
offsetX =
    position >> .x


offsetY : Model -> Float
offsetY =
    position >> .y


type alias Position =
    { x : Float
    , y : Float
    }


position : Model -> Position
position model =
    model.move
        |> Move.coord
        |> position_ model.window


position_ : Window -> Coord -> Position
position_ window coord =
    { x = toFloat (Coord.x coord * tileWidth window)
    , y = toFloat (Coord.y coord * tileHeight window)
    }


withDragging : Model -> Tile_ msg -> Tile_ msg
withDragging model tileModel =
    let
        block =
            Move.block model.move
    in
    if Block.isLeaving block then
        { tileModel | transition = 100 }

    else if model.isBursting then
        { tileModel | transition = 500 }

    else if Block.isDragging block && not (Block.isBurst block) then
        { tileModel | transition = 300, scale = 0.8 }

    else if Block.isDragging block && Block.isBurst block then
        { tileModel | transition = 100, scale = 1.3 }

    else
        tileModel


withTracer : Model -> Tile_ msg -> Tile_ msg
withTracer model tileModel =
    case Move.tileState model.move of
        Tile.Dragging (Tile.Burst _) _ _ ->
            { tileModel | tracer = Just { animation = bulgeFade [ Animation.loop ] } }

        Tile.Dragging _ _ _ ->
            { tileModel | tracer = Just { animation = bulgeFade [] } }

        Tile.Active _ ->
            { tileModel | tracer = Just { animation = bulgeFade [ Animation.loop ] } }

        _ ->
            tileModel


bulgeFade : List Animation.Option -> Animation
bulgeFade options =
    Animation.fromTo
        { duration = 1000
        , options = options
        }
        [ P.scale 1, P.opacity 1 ]
        [ P.scale 3, P.opacity 0 ]


withLeaving : Model -> Tile_ msg -> Tile_ msg
withLeaving model tileModel =
    let
        updates =
            Leaving.apply (leavingViewModel model) tileModel
    in
    { tileModel
        | offsetX = updates.offsetX
        , offsetY = updates.offsetY
        , scale = updates.scale
        , transition = updates.transition
        , transitionDelay = updates.transitionDelay
        , alpha = updates.alpha
    }



-- View Models


leavingViewModel : Model -> Leaving.Model
leavingViewModel model =
    { window = model.window
    , boardSize = model.boardSize
    , settings = model.settings
    , move = model.move
    }
