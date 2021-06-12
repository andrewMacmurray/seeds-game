module Scene.Level.Board.Tile exposing
    ( current
    , view
    )

import Css.Transform as Transform
import Element exposing (Color)
import Element.Animation.Bounce as Bounce
import Element.Dot as Dot
import Element.Icon.Burst as Burst
import Element.Palette as Palette
import Game.Board as Board
import Game.Board.Block as Block exposing (Block)
import Game.Board.Move as Move exposing (Move)
import Game.Board.Tile as Tile exposing (Tile)
import Html exposing (Attribute, Html, div)
import Level.Setting.Tile as Tile
import Scene.Level.Board.Tile.Leaving as Leaving
import Scene.Level.Board.Tile.Position as Position
import Scene.Level.Board.Tile.Scale as Scale
import Scene.Level.Board.Tile.Stroke as Stroke
import Seed exposing (Seed)
import Simple.Animation as Animation exposing (Animation)
import Simple.Animation.Animated as Animated
import Simple.Animation.Property as P
import Simple.Transition as Transition
import Utils.Html as Html
import Utils.Html.Style as Style
import View.Seed as Seed
import Window exposing (Window)



-- Tile


type alias Model =
    { isBursting : Bool
    , window : Window
    , settings : List Tile.Setting
    , boardSize : Board.Size
    , move : Move
    }



-- View Model


type alias ViewModel msg =
    { animation : Maybe TileAnimation
    , transition : Transition.Millis
    , transitionDelay : Transition.Millis
    , element : Html msg
    , tracer : Maybe Tracer
    , width : Int
    , height : Int
    , scale : Float
    , opacity : Float
    , offsetX : Float
    , offsetY : Float
    }


type TileAnimation
    = Outer Animation
    | Inner Animation


type alias Tracer =
    { animation : Animation
    }


toTileModel : Model -> ViewModel msg
toTileModel model =
    { animation = Nothing
    , transition = 0
    , transitionDelay = 0
    , element = tileElement model
    , tracer = Nothing
    , width = Scale.outerWidth model.window
    , height = Scale.outerHeight model.window
    , scale = 1
    , opacity = 1
    , offsetX = Position.x model
    , offsetY = Position.y model
    }



-- Current


type alias Current =
    { isDragging : Bool
    , isBursting : Bool
    , window : Window
    , settings : List Tile.Setting
    , boardSize : Board.Size
    , move : Move
    }


current : Current -> Html msg
current model =
    if Move.isCurrent model.move && model.isDragging then
        { isBursting = False
        , window = model.window
        , settings = model.settings
        , boardSize = model.boardSize
        , move = model.move
        }
            |> toTileModel
            |> withDragging model
            |> view_

    else
        Html.none



-- View


view : Model -> Html msg
view model =
    toTileModel model
        |> withDragging model
        |> withTracer model
        |> withLeaving model
        |> withFalling model
        |> withEntering model
        |> withGrowing model
        |> withReleasing model
        |> view_



-- Internal


view_ : ViewModel msg -> Html msg
view_ model =
    animateOuter model.animation
        [ Style.absolute ]
        [ div
            [ Style.width model.width
            , Style.height model.height
            , Style.opacity model.opacity
            , Style.pointer
            , transitionAll model
            , Style.transform
                [ Transform.translate model.offsetX model.offsetY
                , Transform.scale model.scale
                ]
            ]
            [ animateInner model.animation
                (Style.center [ Style.absolute ])
                [ viewTracer model
                , model.element
                ]
            ]
        ]


transitionAll : ViewModel msg -> Attribute msg
transitionAll tile =
    Transition.all
        { duration = tile.transition
        , options = [ Transition.delay tile.transitionDelay ]
        }
        [ Transition.opacity
        , Transition.transform
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


viewTracer : ViewModel msg -> Html msg
viewTracer model =
    Html.showIfJust (viewTracer_ model) model.tracer


viewTracer_ : ViewModel msg -> Tracer -> Html msg
viewTracer_ model tracer =
    Animated.div tracer.animation (Style.center [ Style.absolute ]) [ model.element ]



-- From Model


tileElement : Model -> Html msg
tileElement model =
    case Move.block model.move of
        Block.Wall color ->
            toWallElement model color

        Block.Space state ->
            toTileElement model state


toTileElement : Model -> Tile.State -> Html msg
toTileElement model state =
    case Tile.get state of
        Just Tile.Rain ->
            Dot.html (Style.center [ Style.absolute ])
                { size = innerTileSize model
                , color = Palette.blue5
                }

        Just Tile.Sun ->
            Dot.html (Style.center [ Style.absolute ])
                { size = innerTileSize model
                , color = Palette.gold
                }

        Just Tile.SeedPod ->
            Dot.split_ (Style.center [ Style.absolute ])
                { size = innerTileSize model
                , left = Palette.lime5
                , right = Palette.lime4
                }

        Just (Tile.Seed seed_) ->
            toSeedElement model seed_

        Just (Tile.Burst tile_) ->
            toBurstElement model tile_

        Nothing ->
            Html.none



-- Wall


toWallElement : Model -> Color -> Html msg
toWallElement model color =
    Html.square (wallSize model) (Style.center [ Style.background color ]) []


wallSize : Model -> Int
wallSize model =
    round (Scale.factor model.window * 45)



-- Seed


toSeedElement : Model -> Seed -> Html msg
toSeedElement model seed =
    Html.square (innerTileSize model) (Style.center [ Style.absolute ]) [ Seed.view seed ]



-- Burst


toBurstElement : Model -> Maybe Tile -> Html msg
toBurstElement model tile =
    burstWrapper model (viewBurst_ model tile)


burstWrapper : Model -> Html msg -> Html msg
burstWrapper model el_ =
    div
        (Style.center
            [ Style.width (innerTileSize model)
            , Style.height (innerTileSize model)
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


innerTileSize : Model -> Int
innerTileSize model =
    Scale.innerSize model



-- Dragging


type alias DraggingModel model =
    { model
        | isBursting : Bool
        , move : Move
    }


withDragging : DraggingModel model -> ViewModel msg -> ViewModel msg
withDragging model =
    withDragging_ model (Move.block model.move)


withDragging_ : DraggingModel model -> Block -> ViewModel msg -> ViewModel msg
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



-- Tracer


withTracer : Model -> ViewModel msg -> ViewModel msg
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



-- Leaving


withLeaving : Model -> ViewModel msg -> ViewModel msg
withLeaving model tileModel =
    if isLeaving (Move.block model.move) then
        { tileModel
            | transition = 800
            , transitionDelay = delay (Move.block model.move)
            , offsetX = leavingOffset .x tileModel.offsetX model
            , offsetY = leavingOffset .y tileModel.offsetY model
            , scale = 0.5
            , opacity = 0.2
        }

    else if Block.isLeaving (Move.block model.move) then
        { tileModel
            | transition = 800
            , scale = 8
            , opacity = 0
        }

    else
        tileModel


leavingOffset : (Leaving.Offsets -> Float) -> Float -> Model -> Float
leavingOffset get default =
    leavingViewModel
        >> Leaving.offsets
        >> Maybe.map get
        >> Maybe.withDefault default


isLeaving : Block -> Bool
isLeaving block =
    Block.isLeaving block && not (Block.isBurst block)


delay : Block -> Int
delay block =
    modBy 5 (Block.leavingOrder block) * 80


leavingViewModel : Model -> Leaving.Model
leavingViewModel model =
    { window = model.window
    , boardSize = model.boardSize
    , settings = model.settings
    , move = model.move
    }



-- Falling


withFalling : Model -> ViewModel msg -> ViewModel msg
withFalling model tileModel =
    case Move.tileState model.move of
        Tile.Falling _ distance ->
            { tileModel | animation = Just (Outer (bounceFall model distance)) }

        _ ->
            tileModel



-- Entering


withEntering : Model -> ViewModel msg -> ViewModel msg
withEntering model tileModel =
    case Move.tileState model.move of
        Tile.Entering _ ->
            { tileModel | animation = Just (Outer bounceEnter) }

        _ ->
            tileModel



-- Growing


withGrowing : Model -> ViewModel msg -> ViewModel msg
withGrowing model tileModel =
    case Move.tileState model.move of
        Tile.Growing Tile.SeedPod _ ->
            { tileModel
                | opacity = 0
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
        , to = toFloat (distance * Scale.outerHeight model.window)
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



-- Releasing


withReleasing : Model -> ViewModel msg -> ViewModel msg
withReleasing model tileModel =
    case Move.tileState model.move of
        Tile.Releasing _ order ->
            { tileModel | transition = 200 + (30 * order) }

        _ ->
            tileModel
