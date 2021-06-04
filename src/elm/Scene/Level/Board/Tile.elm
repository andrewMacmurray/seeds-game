module Scene.Level.Board.Tile exposing
    ( overlay
    , view
    )

import Board
import Board.Block as Block exposing (Block)
import Board.Coord as Coord exposing (Coord)
import Board.Move as Move exposing (Move)
import Board.Tile as Tile exposing (Tile)
import Element exposing (..)
import Element.Animation.Bounce as Bounce
import Element.Dot as Dot
import Element.Icon.Burst as Burst
import Element.Palette as Palette
import Element.Seed as Seed2
import Element.Transition as Transition
import Level.Setting.Tile as Tile
import Scene.Level.Board.Tile.Leaving as Leaving
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



-- View


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


type alias Overlay =
    { window : Window
    , settings : List Tile.Setting
    , boardSize : Board.Size
    , move : Move
    }


overlay : Overlay -> Element msg
overlay model =
    if needsOverlay (Move.block model.move) then
        view_
            (toTileModel
                { isBursting = False
                , window = model.window
                , settings = model.settings
                , boardSize = model.boardSize
                , move = model.move
                }
            )

    else
        none


needsOverlay : Block -> Bool
needsOverlay block =
    Block.isDragging block || Block.isStatic block


view : Model -> Element msg
view model =
    toTileModel model
        |> withDragging model
        |> withTracer model
        |> withLeaving model
        |> withFalling model
        |> view_


view_ : Tile_ msg -> Element msg
view_ model =
    animated model.animation
        []
        (el
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
        )


animated : Maybe Animation -> List (Attribute msg) -> Element msg -> Element msg
animated =
    Maybe.map Animated.el >> Maybe.withDefault el


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
    burstSize model (viewBurst_ model tile)


burstSize : Model -> Element msg -> Element msg
burstSize model =
    el [ width (px (tileSize model)) ]


viewBurst_ : Model -> Maybe Tile -> Element msg
viewBurst_ model tile =
    case tile of
        Just tile_ ->
            viewActiveBurst model tile_

        Nothing ->
            Burst.inactive


viewActiveBurst : Model -> Tile -> Element msg
viewActiveBurst model tile_ =
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


transitionAll : Tile_ msg -> Attribute msg
transitionAll tile =
    Transition.all_
        { duration = tile.transition
        , options = [ Transition.delay tile.transitionDelay ]
        }
        [ Transition.opacity
        , Transition.transform
        ]



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


withFalling : Model -> Tile_ msg -> Tile_ msg
withFalling model tileModel =
    case Move.tileState model.move of
        Tile.Falling _ distance ->
            { tileModel | animation = Just (bounceDown model distance) }

        _ ->
            tileModel


bounceDown : Model -> Int -> Animation
bounceDown model distance =
    Bounce.animation
        { duration = 900
        , options = []
        , property = P.y
        , from = 0
        , to = toFloat (distance * tileHeight model.window)
        , bounce = Bounce.stiff
        }



-- View Models


leavingViewModel : Model -> Leaving.Model
leavingViewModel model =
    { window = model.window
    , boardSize = model.boardSize
    , settings = model.settings
    , move = model.move
    }
