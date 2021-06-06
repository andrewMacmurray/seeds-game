module Scene.Level.Board.Tile3 exposing
    ( overlay
    , view
    )

import Board
import Board.Block as Block exposing (Block)
import Board.Coord as Coord exposing (Coord)
import Board.Move as Move exposing (Move)
import Board.Tile as Tile exposing (Tile)
import Css.Transform as Transform
import Element.Animation.Bounce as Bounce
import Element.Dot as Dot
import Element.Icon.Burst as Burst
import Element.Palette as Palette
import Html exposing (Attribute, Html, div)
import Level.Setting.Tile as Tile
import Scene.Level.Board.Tile.Leaving as Leaving
import Scene.Level.Board.Tile.Stroke as Stroke
import Scene.Level.Board.Tile.Style as Tile
import Scene.Level.Board.Tile.Wall as Wall
import Seed exposing (Seed)
import Simple.Animation as Animation exposing (Animation)
import Simple.Animation.Animated as Animated
import Simple.Animation.Property as P
import Simple.Transition as Transition
import Utils.Html as Html
import Utils.Html.Style as Style
import View.Seed as Seed
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
    { animation : Maybe TileAnimation
    , transition : Transition.Millis
    , transitionDelay : Transition.Millis
    , element : Html msg
    , tracer : Maybe Tracer
    , width : Int
    , height : Int
    , scale : Float
    , alpha : Float
    , offsetX : Float
    , offsetY : Float
    }


type TileAnimation
    = Outer Animation
    | Inner Animation


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


overlay : Overlay -> Html msg
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
        Html.none


needsOverlay : Block -> Bool
needsOverlay block =
    Block.isDragging block || Block.isStatic block


view : Model -> Html msg
view model =
    toTileModel model
        |> withDragging model
        |> withTracer model
        |> withLeaving model
        |> withFalling model
        |> withEntering model
        |> withGrowing model
        |> view_


view_ : Tile_ msg -> Html msg
view_ model =
    animateOuter model.animation
        [ Style.absolute ]
        [ div
            [ Style.width model.width
            , Style.height model.height
            , Style.opacity model.alpha
            , Style.pointer
            , transitionAll model
            , Style.transform
                [ Transform.translate model.offsetX model.offsetY
                , Transform.scale model.scale
                ]
            ]
            [ animateInner model.animation
                []
                [ viewTracer model
                , model.element
                ]
            ]
        ]


animateOuter : Maybe TileAnimation -> List (Attribute msg) -> List (Html msg) -> Html msg
animateOuter =
    Maybe.map animateOuter_ >> Maybe.withDefault div


animateInner : Maybe TileAnimation -> List (Attribute msg) -> List (Html msg) -> Html msg
animateInner =
    Maybe.map animateInner_ >> Maybe.withDefault div


animateInner_ : TileAnimation -> List (Attribute msg) -> List (Html msg) -> Html msg
animateInner_ anim =
    case anim of
        Inner a ->
            Animated.div a

        Outer _ ->
            div


animateOuter_ : TileAnimation -> List (Attribute msg) -> List (Html msg) -> Html msg
animateOuter_ anim =
    case anim of
        Outer a ->
            Animated.div a

        Inner _ ->
            div


viewTracer : Tile_ msg -> Html msg
viewTracer model =
    showIfJust (viewTracer_ model) model.tracer


viewTracer_ : Tile_ msg -> Tracer -> Html msg
viewTracer_ model tracer =
    Animated.div tracer.animation (Style.center [ Style.absolute ]) [ model.element ]


showIfJust f =
    Maybe.map f >> Maybe.withDefault Html.none



-- From Model


tileElement : Model -> Html msg
tileElement model =
    case Move.block model.move of
        Block.Wall color ->
            Wall.html model color

        Block.Space state ->
            toTileElement model state


toTileElement : Model -> Tile.State -> Html msg
toTileElement model state =
    case Tile.get state of
        Just Tile.Rain ->
            Dot.html (Style.center [ Style.absolute ])
                { size = tileSize model
                , color = Palette.blue5
                }

        Just Tile.Sun ->
            Dot.html (Style.center [ Style.absolute ])
                { size = tileSize model
                , color = Palette.gold
                }

        Just Tile.SeedPod ->
            Dot.split_
                { size = tileSize model
                , left = Palette.lime5
                , right = Palette.lime4
                }

        Just (Tile.Seed seed_) ->
            toSeedElement model seed_

        Just (Tile.Burst tile_) ->
            toBurstElement model tile_

        Nothing ->
            Html.none


toSeedElement : Model -> Seed -> Html msg
toSeedElement model seed =
    Html.square (tileSize model) (Style.center [ Style.absolute ]) [ Seed.view seed ]


toBurstElement : Model -> Maybe Tile -> Html msg
toBurstElement model tile =
    burstWrapper model (viewBurst_ model tile)


burstWrapper : Model -> Html msg -> Html msg
burstWrapper model el_ =
    div
        (Style.center
            [ Style.width (tileSize model)
            , Style.height (tileSize model)
            , Style.absolute
            ]
        )
        [ el_ ]


viewBurst_ : Model -> Maybe Tile -> Html msg
viewBurst_ model tile =
    case tile of
        Just tile_ ->
            viewActiveBurst model tile_

        Nothing ->
            Burst.inactive_


viewActiveBurst : Model -> Tile -> Html msg
viewActiveBurst model tile_ =
    if Block.isLeaving (Move.block model.move) then
        Burst.active_
            { color = Stroke.darker tile_
            , border = Stroke.darker tile_
            }

    else
        Burst.active_
            { color = Stroke.darker tile_
            , border = Stroke.lighter tile_
            }


transitionAll : Tile_ msg -> Attribute msg
transitionAll tile =
    Transition.all
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
withDragging model =
    withDragging_ model (Move.block model.move)


withDragging_ : Model -> Block -> Tile_ msg -> Tile_ msg
withDragging_ model block tileModel =
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
            { tileModel | animation = Just (Outer (bounceFall model distance)) }

        _ ->
            tileModel


withEntering : Model -> Tile_ msg -> Tile_ msg
withEntering model tileModel =
    case Move.tileState model.move of
        Tile.Entering _ ->
            { tileModel | animation = Just (Outer bounceEnter) }

        _ ->
            tileModel


withGrowing : Model -> Tile_ msg -> Tile_ msg
withGrowing model tileModel =
    case Move.tileState model.move of
        Tile.Growing Tile.SeedPod _ ->
            { tileModel
                | alpha = 0
                , scale = 4
                , transition = 400
                , transitionDelay = growingDelay (Move.block model.move)
            }

        Tile.Growing (Tile.Seed _) _ ->
            { tileModel | animation = Just (Inner growSeed) }

        _ ->
            tileModel


growingDelay : Block -> Int
growingDelay block =
    modBy 5 (Block.growingOrder block) * 70


growSeed : Animation
growSeed =
    Animation.steps
        { startAt = [ P.scale 0.5 ]
        , options = []
        }
        [ Animation.step 250 [ P.scale 1.3 ]
        , Animation.step 250 [ P.scale 1 ]
        ]


bounceFall : Model -> Int -> Animation
bounceFall model distance =
    Bounce.animation
        { duration = 900
        , options = []
        , property = P.y
        , from = 0
        , to = toFloat (distance * tileHeight model.window)
        , bounce = Bounce.stiff
        }


bounceEnter : Animation
bounceEnter =
    Bounce.animation
        { duration = 700
        , options = []
        , property = P.y
        , from = -200
        , to = 0
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
