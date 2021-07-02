module Scene.Level.Tutorial exposing
    ( Model
    , view
    )

import Element exposing (Element, behindContent)
import Element.Palette as Palette
import Element.Text as Text
import Element.Transition as Transition
import Game.Board as Board
import Game.Board.Coord as Coord exposing (Coord)
import Game.Level.Tile as Tile
import Game.Level.Tutorial as Tutorial exposing (Tutorial)
import Scene.Level.Board as Board
import Scene.Level.Board.Tile.Position as Position
import Scene.Level.Board.Tile.Scale as Scale
import Svg exposing (Svg)
import Svg.Attributes exposing (fillOpacity, id, mask)
import Utils.Element as Element
import Utils.Svg as Svg exposing (..)
import Window exposing (Window)



-- Tutorial


type alias Model =
    { window : Window
    , boardSize : Board.Size
    , tileSettings : List Tile.Setting
    , tutorial : Tutorial
    }


type alias ViewModel =
    { window : Window
    , boardSize : Board.Size
    , tileSettings : List Tile.Setting
    , highlight : Tutorial.Highlight
    , isVisible : Bool
    , text : String
    }



-- View


view : Model -> Element msg
view model =
    case model.tutorial of
        Tutorial.InProgress c ->
            view_ (toViewModel model c)

        Tutorial.Complete ->
            Element.none


view_ : ViewModel -> Element msg
view_ model =
    Element.el
        [ Element.width Element.fill
        , Element.height Element.fill
        , Transition.alpha 1000
        , Element.visibleIf model.isVisible
        , Element.disableTouch
        , behindContent (highlightOverlay model)
        ]
        (text model)


toViewModel : Model -> Tutorial.Steps -> ViewModel
toViewModel model config =
    { window = model.window
    , boardSize = model.boardSize
    , tileSettings = model.tileSettings
    , text = .text (Tutorial.stepConfig config.current)
    , isVisible = config.visible
    , highlight = .highlight (Tutorial.stepConfig config.current)
    }


text : ViewModel -> Element msg
text model =
    Text.text
        [ Text.white
        , Element.centerX
        , Element.alignBottom
        , Element.moveUp (offsetBottom model)
        ]
        model.text


offsetBottom : ViewModel -> Float
offsetBottom model =
    toFloat (Board.offsetBottom model - 60)


highlightOverlay : ViewModel -> Element msg
highlightOverlay model =
    Element.html
        (Svg.window model.window
            [ Svg.disableTouch ]
            [ highlightMask model
            , Svg.rect
                [ Svg.width_ (toFloat model.window.width)
                , Svg.height_ (toFloat model.window.height)
                , fillOpacity "0.4"
                , mask (String.concat [ "url(#", maskId, ")" ])
                ]
                []
            ]
        )


highlightMask : ViewModel -> Svg msg
highlightMask model =
    Svg.mask [ id maskId ]
        (List.concat
            [ [ maskBackground model ]
            , highlightCenterSeedBank model
            , remainingMovesHighlight model
            , tileHighlights model
            , connectingBlock model
            ]
        )


maskId : String
maskId =
    "tutorial-overlay-mask"


remainingMovesHighlight : ViewModel -> List (Svg msg)
remainingMovesHighlight model =
    let
        left =
            leftEdge model + 26
    in
    case model.highlight of
        Tutorial.RemainingMoves ->
            [ Svg.circle
                [ fill_ Palette.black
                , cx_ left
                , cy_ (Board.scoreIconSize + 12)
                , r_ (Board.scoreIconSize + 5)
                ]
                []
            ]

        _ ->
            []


highlightCenterSeedBank : ViewModel -> List (Svg msg)
highlightCenterSeedBank model =
    case model.highlight of
        Tutorial.SeedBank ->
            [ Svg.circle
                [ fill_ Palette.black
                , cx_ (toFloat model.window.width / 2)
                , cy_ (Board.scoreIconSize + 10)
                , r_ (Board.scoreIconSize + 3)
                ]
                []
            ]

        _ ->
            []


maskBackground : ViewModel -> Svg msg
maskBackground model =
    Svg.rect
        [ width_ (toFloat model.window.width)
        , height_ (toFloat model.window.height)
        , Svg.fill_ Palette.white
        ]
        []


tileHighlights : ViewModel -> List (Svg msg)
tileHighlights model =
    case model.highlight of
        Tutorial.HorizontalTiles { from, length } ->
            List.range (Coord.x from) (Coord.x from + length - 1)
                |> List.map (\x -> Coord.fromXY x (Coord.y from))
                |> List.map (moveHighlight model)

        Tutorial.VerticalTiles { from, length } ->
            List.range (Coord.y from) (Coord.y from + length - 1)
                |> List.map (\y -> Coord.fromXY (Coord.x from) y)
                |> List.map (moveHighlight model)

        Tutorial.Multiple hx ->
            List.concatMap (\h -> tileHighlights { model | highlight = h }) hx

        _ ->
            []


connectingBlock : ViewModel -> List (Svg msg)
connectingBlock model =
    case model.highlight of
        Tutorial.HorizontalTiles { from, length } ->
            let
                p1 =
                    Position.fromCoord model.window from

                p2 =
                    Position.fromCoord model.window (Coord.translateX (length - 2) from)

                { left, top } =
                    boardOffset model

                { width, height } =
                    tileSize model
            in
            [ Svg.rect
                [ fill_ Palette.black
                , x_ (p1.x + left - (width / 2))
                , y_ (p1.y + top - height)
                , width_ (p2.x - p1.x + width)
                , height_ height
                ]
                []
            ]

        Tutorial.VerticalTiles { from, length } ->
            let
                p1 =
                    Position.fromCoord model.window from

                p2 =
                    Position.fromCoord model.window (Coord.translateY (length - 2) from)

                { left, top } =
                    boardOffset model

                { width, height } =
                    tileSize model
            in
            [ Svg.rect
                [ fill_ Palette.black
                , x_ (p1.x + left - width)
                , y_ (p1.y + top - (height / 2))
                , height_ (p2.y - p1.y + height)
                , width_ width
                ]
                []
            ]

        Tutorial.Multiple hx ->
            List.concatMap (\h -> connectingBlock { model | highlight = h }) hx

        _ ->
            []


moveHighlight : ViewModel -> Coord -> Svg msg
moveHighlight model coord =
    let
        { x, y } =
            Position.fromCoord model.window coord

        { left, top } =
            boardOffset model

        { width, height } =
            tileSize model
    in
    Svg.ellipse
        [ fill_ Palette.black
        , rx_ (width / 2)
        , ry_ (height / 2)
        , cx_ (x + left - (width / 2))
        , cy_ (y + top - (height / 2))
        ]
        []



-- Helpers


leftEdge : ViewModel -> Float
leftEdge model =
    toFloat (model.window.width - Board.fullWidth model.window) / 2


boardOffset : ViewModel -> { top : Float, left : Float }
boardOffset model =
    { top = toFloat (Board.offsetTop model)
    , left = toFloat (Board.offsetLeft model)
    }


tileSize : ViewModel -> { height : Float, width : Float }
tileSize model =
    { height = toFloat (Scale.outerHeight model.window)
    , width = toFloat (Scale.outerWidth model.window)
    }
