module Scenes.Level.Tutorial exposing
    ( Step
    , Tutorial
    , ViewModel
    , autoStep
    , hideStep
    , highlightHorizontalTiles
    , highlightMultiple
    , highlightRemainingMoves
    , highlightSeedBank
    , highlightVerticalTiles
    , inProgress
    , isAutoStep
    , nextStep
    , noHighlight
    , none
    , showStep
    , step
    , tutorial
    , view
    )

import Board
import Board.Coord as Coord exposing (Coord)
import Css.Animation as Animation
import Css.Color as Color
import Css.Style as Style
import Html exposing (Html)
import Html.Attributes as Attribute
import Svg exposing (Svg)
import Svg.Attributes exposing (fill, fillOpacity, id, mask)
import Utils.Svg exposing (..)
import Views.Board.Style as Board
import Views.Board.Tile.Style as Tile
import Window exposing (Window)



-- Tutorial


type Tutorial
    = InProgress Steps
    | Complete


type alias Steps =
    { current : Step
    , remaining : List Step
    , visible : Bool
    }


type Step
    = AutoHide StepConfig
    | WaitForUserAction StepConfig


type alias StepConfig =
    { text : String
    , highlight : Highlight
    }


type Highlight
    = HorizontalTiles { from : Coord, length : Int }
    | VerticalTiles { from : Coord, length : Int }
    | Multiple (List Highlight)
    | RemainingMoves
    | SeedBank
    | NoHighlight


type alias ViewModel =
    { window : Window
    , boardSize : Board.Size
    , tutorial : Tutorial
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
    WaitForUserAction << StepConfig text_


autoStep : String -> Highlight -> Step
autoStep text_ =
    AutoHide << StepConfig text_


stepConfig : Step -> StepConfig
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


highlightHorizontalTiles : { from : Coord, length : Int } -> Highlight
highlightHorizontalTiles =
    HorizontalTiles


highlightVerticalTiles : { from : Coord, length : Int } -> Highlight
highlightVerticalTiles =
    VerticalTiles


highlightRemainingMoves : Highlight
highlightRemainingMoves =
    RemainingMoves


highlightSeedBank : Highlight
highlightSeedBank =
    SeedBank


noHighlight : Highlight
noHighlight =
    NoHighlight


highlightMultiple : List Highlight -> Highlight
highlightMultiple =
    Multiple



-- View


type alias InternalViewModel =
    { window : Window
    , boardSize : Board.Size
    , highlight : Highlight
    , visible : Bool
    , text : String
    }


view : ViewModel -> Html msg
view model =
    case model.tutorial of
        InProgress c ->
            let
                config =
                    stepConfig c.current

                vm =
                    { window = model.window
                    , boardSize = model.boardSize
                    , text = config.text
                    , visible = c.visible
                    , highlight = config.highlight
                    }
            in
            Html.div [ Attribute.class "w-100 h-100 fixed z-7 top-0 touch-disabled", Style.style <| visibility vm ]
                [ highlightOverlay vm
                , text vm
                ]

        Complete ->
            Html.span [] []


visibility : InternalViewModel -> List Style.Style
visibility model =
    if model.visible then
        [ Animation.animation "fade-in" 1200 []
        , Style.opacity 0
        ]

    else
        [ Style.opacity 1
        , Animation.animation "fade-out" 1000 []
        ]


text : InternalViewModel -> Html msg
text model =
    let
        offsetBottom =
            boardViewModel model
                |> Board.offsetBottom
                |> (\offset -> offset - 60)
                |> toFloat
    in
    Html.p
        [ Attribute.class "absolute z-7 bottom-0 tc left-0 right-0"
        , Style.style
            [ Style.color Color.white
            , Style.bottom offsetBottom
            ]
        ]
        [ Html.text model.text ]


highlightOverlay : InternalViewModel -> Html msg
highlightOverlay model =
    Svg.svg [ windowViewBox_ model.window ]
        [ highlightMask model
        , Svg.rect
            [ width_ <| toFloat model.window.width
            , height_ <| toFloat model.window.height
            , fillOpacity "0.4"
            , mask <| String.concat [ "url(#", maskId, ")" ]
            ]
            []
        ]


highlightMask : InternalViewModel -> Svg msg
highlightMask model =
    Svg.mask [ id maskId ]
        (List.concat
            [ [ maskBackground model ]
            , highlightCenterSeedBank model
            , remainingMoves model
            , tileHighlights model
            , connectingBlock model
            ]
        )


maskId : String
maskId =
    "tutorial-overlay-mask"


remainingMoves : InternalViewModel -> List (Svg msg)
remainingMoves model =
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


highlightCenterSeedBank : InternalViewModel -> List (Svg msg)
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


maskBackground : InternalViewModel -> Svg msg
maskBackground model =
    Svg.rect
        [ width_ <| toFloat model.window.width
        , height_ <| toFloat model.window.height
        , fill Color.white
        ]
        []


tileHighlights : InternalViewModel -> List (Svg msg)
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


connectingBlock : InternalViewModel -> List (Svg msg)
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


moveHighlight : InternalViewModel -> Coord -> Svg msg
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


leftEdge : InternalViewModel -> Float
leftEdge model =
    toFloat (model.window.width - Board.fullWidth model.window) / 2


boardOffset : InternalViewModel -> { top : Float, left : Float }
boardOffset model =
    { top = toFloat <| Board.offsetTop (boardViewModel model)
    , left = toFloat <| Board.offsetLeft (boardViewModel model)
    }


tileSize : InternalViewModel -> { height : Float, width : Float }
tileSize model =
    { height = toFloat <| Tile.height model.window
    , width = toFloat <| Tile.width model.window
    }



-- View Models


boardViewModel : InternalViewModel -> Board.ViewModel
boardViewModel model =
    { window = model.window
    , boardSize = model.boardSize
    }
