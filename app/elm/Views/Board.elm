module Views.Board exposing (..)

import Data.Moves.Check exposing (isInCurrentMove)
import Data.Tiles exposing (growingOrder, isLeaving, leavingOrder, tileColorMap, tilePaddingMap)
import Dict
import Helpers.Style exposing (classes, px, styles, translate)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onMouseDown, onMouseEnter, onMouseUp)
import Model exposing (..)


renderBoard : Model -> Html Msg
renderBoard model =
    model.board
        |> Dict.toList
        |> List.map (renderTile model)
        |> renderContainer model


renderContainer : Model -> List (Html Msg) -> Html Msg
renderContainer model =
    div
        [ class "relative z-3 center mt6 flex flex-wrap"
        , style [ ( "width", px <| boardWidth model ) ]
        ]


boardWidth : Model -> Float
boardWidth { tileSettings, boardSettings } =
    tileSettings.sizeX * toFloat (boardSettings.sizeX)


renderTile : Model -> Move -> Html Msg
renderTile model (( coord, tile ) as move) =
    div
        [ style <|
            styles
                [ baseTileStyles model
                , [ tileCoordsStyles model coord ]
                , leavingStyles model move
                , fallingStyles model move
                , growingStyles model move
                , enteringStyles model move
                ]
        , class "dib flex items-center justify-center absolute pointer"
        , hanldeMoveEvents model move
          -- debug id
        , id <| toString coord
        ]
        [ innerTile model move ]


tileCoordsStyles : Model -> Coord -> ( String, String )
tileCoordsStyles model coord =
    let
        ( y, x ) =
            tilePosition model coord
    in
        ( "transform", translate x y )


tilePosition : Model -> Coord -> ( Float, Float )
tilePosition model ( y, x ) =
    ( (toFloat y) * model.tileSettings.sizeY
    , (toFloat x) * model.tileSettings.sizeX
    )


handleStop : Model -> List (Attribute Msg)
handleStop model =
    if model.isDragging then
        [ onMouseUp StopMove ]
    else
        []


hanldeMoveEvents : Model -> Move -> Attribute Msg
hanldeMoveEvents model move =
    if model.isDragging then
        onMouseEnter (CheckMove move)
    else
        onMouseDown (StartMove move)


innerTile : Model -> Move -> Html Msg
innerTile model (( coord, tile ) as move) =
    let
        innerTileClasses =
            classes
                [ "br-100 absolute"
                , tileColorMap tile
                , draggingClasses model move
                ]
    in
        div
            [ class innerTileClasses
            , style [ ( "padding", tilePaddingMap tile ) ]
            ]
            [ debugTile coord ]


debugTile : Coord -> Html Msg
debugTile coord =
    p [ class "absolute left-0 right-0 f6 no-select mid-gray dn" ] [ text <| toString coord ]


enteringStyles : Model -> Move -> List ( String, String )
enteringStyles model ( coord, tile ) =
    let
        ( y, x ) =
            tilePosition model coord
    in
        case tile of
            Empty ->
                [ ( "transform", translate x -1000 )
                , ( "transition", "0.5s ease" )
                ]

            Entering tile ->
                [ ( "transform", translate x y )
                , ( "transition", "0.5s ease" )
                ]

            _ ->
                []


growingStyles : Model -> Move -> List ( String, String )
growingStyles model ( coord, tile ) =
    let
        ( y, x ) =
            tilePosition model coord

        transitionDelay =
            growingOrder tile
                |> (\x -> x % 5)
                |> (*) 70
                |> toString
                |> (\x -> x ++ "ms")
    in
        case tile of
            Growing SeedPod _ ->
                [ ( "transform", (translate x y) ++ " scale(4)" )
                , ( "opacity", "0" )
                , ( "transition", "0.4s ease" )
                , ( "transition-delay", transitionDelay )
                ]

            Growing Seed _ ->
                [ ( "transform", (translate x y) ++ " scale(1)" )
                , ( "opacity", "1" )
                , ( "transition", "0.4s ease" )
                , ( "transition-delay", transitionDelay )
                ]

            _ ->
                []


fallingStyles : Model -> Move -> List ( String, String )
fallingStyles model ( coord, tile ) =
    let
        ( y, x ) =
            tilePosition model coord
    in
        case tile of
            Falling tile distance ->
                [ ( "transform", translate x (y + (model.tileSettings.sizeY * (toFloat distance))) )
                , ( "transition", "0.3s ease" )
                ]

            _ ->
                []


leavingStyles : Model -> Move -> List ( String, String )
leavingStyles model (( ( y, x ), tile ) as move) =
    if isLeaving tile then
        [ handleExitDirection move model
        , ( "transition", "0.8s ease" )
        , ( "transition-delay", (toString (((leavingOrder tile) % 5) * 80)) ++ "ms" )
        ]
    else
        []


handleExitDirection : Move -> Model -> ( String, String )
handleExitDirection ( coord, tile ) model =
    case tile of
        Leaving Rain _ ->
            ( "transform", exitLeft )

        Leaving Sun _ ->
            ( "transform", exitRight model )

        Leaving Seed _ ->
            ( "transform", exitTop model )

        _ ->
            tileCoordsStyles model coord


exitRight : Model -> String
exitRight model =
    translate (model.tileSettings.sizeY * (toFloat (model.boardSettings.sizeY - 1))) -80


exitTop : Model -> String
exitTop model =
    translate ((model.tileSettings.sizeY * ((toFloat model.boardSettings.sizeY) / 2)) - (model.tileSettings.sizeX / 2)) -80


exitLeft : String
exitLeft =
    translate 0 -80


draggingClasses : Model -> Move -> String
draggingClasses model coord =
    if isInCurrentMove coord model.currentMove then
        "scale-half t3 ease"
    else
        "scale-full"


baseTileStyles : Model -> List ( String, String )
baseTileStyles { tileSettings } =
    [ ( "width", px tileSettings.sizeX )
    , ( "height", px tileSettings.sizeY )
    ]
