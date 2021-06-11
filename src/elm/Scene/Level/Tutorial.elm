module Scene.Level.Tutorial exposing
    ( Model
    , Step
    , Tutorial
    , autoStep
    , hideStep
    , highlightMultiple
    , horizontalTiles
    , inProgress
    , isAutoStep
    , nextStep
    , noHighlight
    , none
    , remainingMoves
    , seedBank
    , showStep
    , step
    , tutorial
    , verticalTiles
    , view
    )

import Board
import Board.Coord as Coord exposing (Coord)
import Css.Color as Color
import Element exposing (Element, behindContent)
import Element.Animations as Animations
import Element.Text as Text
import Level.Setting.Tile as Tile
import Scene.Level.Board.Style as Board
import Scene.Level.Board.Tile.Scale as Scale
import Scene.Level.Board.Tile.Style as Tile
import Simple.Animation exposing (Animation)
import Svg exposing (Svg)
import Svg.Attributes exposing (fill, fillOpacity, id, mask)
import Utils.Animated as Animated
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


type Tutorial
    = InProgress Steps
    | Complete


type alias Steps =
    { current : Step
    , remaining : List Step
    , visible : Bool
    }


type Step
    = AutoHide Step_
    | WaitForUserAction Step_


type alias Step_ =
    { text : String
    , highlight : Highlight
    }


type Highlight
    = HorizontalTiles TilesHighlight
    | VerticalTiles TilesHighlight
    | Multiple (List Highlight)
    | RemainingMoves
    | SeedBank
    | NoHighlight


type alias TilesHighlight =
    { from : Coord
    , length : Int
    }



-- Steps


tutorial : Step -> List Step -> Tutorial
tutorial step_ steps_ =
    InProgress
        { current = step_
        , remaining = steps_
        , visible = False
        }


step : String -> Highlight -> Step
step text_ =
    WaitForUserAction << Step_ text_


autoStep : String -> Highlight -> Step
autoStep text_ =
    AutoHide << Step_ text_


stepConfig : Step -> Step_
stepConfig step_ =
    case step_ of
        AutoHide config ->
            config

        WaitForUserAction config ->
            config


showStep : Tutorial -> Tutorial
showStep tutorial_ =
    case tutorial_ of
        InProgress config ->
            InProgress { config | visible = True }

        Complete ->
            Complete


hideStep : Tutorial -> Tutorial
hideStep tutorial_ =
    case tutorial_ of
        InProgress config ->
            InProgress { config | visible = False }

        Complete ->
            Complete


nextStep : Tutorial -> Tutorial
nextStep tutorial_ =
    case tutorial_ of
        InProgress config ->
            toNextStep config

        Complete ->
            Complete


toNextStep : Steps -> Tutorial
toNextStep config =
    case List.head config.remaining of
        Just step_ ->
            InProgress
                { config
                    | current = step_
                    , remaining = List.drop 1 config.remaining
                    , visible = True
                }

        Nothing ->
            Complete


inProgress : Tutorial -> Bool
inProgress tutorial_ =
    case tutorial_ of
        InProgress _ ->
            True

        Complete ->
            False


isAutoStep : Tutorial -> Bool
isAutoStep tutorial_ =
    case tutorial_ of
        InProgress config ->
            case config.current of
                AutoHide _ ->
                    True

                WaitForUserAction _ ->
                    False

        Complete ->
            False


none : Tutorial
none =
    Complete



-- Highlight


horizontalTiles : TilesHighlight -> Highlight
horizontalTiles =
    HorizontalTiles


verticalTiles : TilesHighlight -> Highlight
verticalTiles =
    VerticalTiles


remainingMoves : Highlight
remainingMoves =
    RemainingMoves


seedBank : Highlight
seedBank =
    SeedBank


noHighlight : Highlight
noHighlight =
    NoHighlight


highlightMultiple : List Highlight -> Highlight
highlightMultiple =
    Multiple



-- View


type alias ViewModel =
    { window : Window
    , boardSize : Board.Size
    , tileSettings : List Tile.Setting
    , highlight : Highlight
    , visible : Bool
    , text : String
    }


view : Model -> Element msg
view model =
    case model.tutorial of
        InProgress c ->
            view_ (toViewModel model c)

        Complete ->
            Element.none


view_ : ViewModel -> Element msg
view_ model =
    Animated.el (visibility model)
        [ Element.disableTouch
        , Element.width Element.fill
        , Element.height Element.fill
        , behindContent (highlightOverlay model)
        ]
        (text model)


toViewModel : Model -> Steps -> ViewModel
toViewModel model config =
    { window = model.window
    , boardSize = model.boardSize
    , tileSettings = model.tileSettings
    , text = .text (stepConfig config.current)
    , visible = config.visible
    , highlight = .highlight (stepConfig config.current)
    }


visibility : ViewModel -> Animation
visibility model =
    if model.visible then
        Animations.fadeIn 1200 []

    else
        Animations.fadeOut 1000 []


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
        RemainingMoves ->
            [ Svg.circle
                [ fill Color.black
                , cx_ left
                , cy_ <| Board.scoreIconSize + 12
                , r_ <| Board.scoreIconSize + 5
                ]
                []
            ]

        _ ->
            []


highlightCenterSeedBank : ViewModel -> List (Svg msg)
highlightCenterSeedBank model =
    case model.highlight of
        SeedBank ->
            [ Svg.circle
                [ fill Color.black
                , cx_ <| toFloat model.window.width / 2
                , cy_ <| Board.scoreIconSize + 10
                , r_ <| Board.scoreIconSize + 3
                ]
                []
            ]

        _ ->
            []


maskBackground : ViewModel -> Svg msg
maskBackground model =
    Svg.rect
        [ width_ <| toFloat model.window.width
        , height_ <| toFloat model.window.height
        , fill Color.white
        ]
        []


tileHighlights : ViewModel -> List (Svg msg)
tileHighlights model =
    case model.highlight of
        HorizontalTiles { from, length } ->
            List.range (Coord.x from) (Coord.x from + length - 1)
                |> List.map (\x -> Coord.fromXY x (Coord.y from))
                |> List.map (moveHighlight model)

        VerticalTiles { from, length } ->
            List.range (Coord.y from) (Coord.y from + length - 1)
                |> List.map (\y -> Coord.fromXY (Coord.x from) y)
                |> List.map (moveHighlight model)

        Multiple hx ->
            List.concatMap (\h -> tileHighlights { model | highlight = h }) hx

        _ ->
            []


connectingBlock : ViewModel -> List (Svg msg)
connectingBlock model =
    case model.highlight of
        HorizontalTiles { from, length } ->
            let
                p1 =
                    Tile.position model.window from

                p2 =
                    Tile.position model.window (Coord.translateX (length - 2) from)

                { left, top } =
                    boardOffset model

                { width, height } =
                    tileSize model
            in
            [ Svg.rect
                [ fill Color.black
                , x_ <| p1.x + left - (width / 2)
                , y_ <| p1.y + top - height
                , width_ <| p2.x - p1.x + width
                , height_ height
                ]
                []
            ]

        VerticalTiles { from, length } ->
            let
                p1 =
                    Tile.position model.window from

                p2 =
                    Tile.position model.window (Coord.translateY (length - 2) from)

                { left, top } =
                    boardOffset model

                { width, height } =
                    tileSize model
            in
            [ Svg.rect
                [ fill Color.black
                , x_ <| p1.x + left - width
                , y_ <| p1.y + top - (height / 2)
                , height_ <| p2.y - p1.y + height
                , width_ width
                ]
                []
            ]

        Multiple hx ->
            List.concatMap (\h -> connectingBlock { model | highlight = h }) hx

        _ ->
            []


moveHighlight : ViewModel -> Coord -> Svg msg
moveHighlight model coord =
    let
        { x, y } =
            Tile.position model.window coord

        { left, top } =
            boardOffset model

        { width, height } =
            tileSize model
    in
    Svg.ellipse
        [ fill Color.black
        , rx_ <| width / 2
        , ry_ <| height / 2
        , cx_ <| x + left - (width / 2)
        , cy_ <| y + top - (height / 2)
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
