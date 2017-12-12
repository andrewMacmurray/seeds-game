module Views.Board.Styles exposing (..)

import Data.Color exposing (blockYellow)
import Data.Level.Board.Block exposing (getTileState)
import Data.Level.Board.Tile exposing (..)
import Data.Level.Score exposing (scoreTileTypes)
import Dict exposing (Dict)
import Helpers.Style exposing (..)
import Scenes.Level.Types as Level exposing (..)
import Window


boardMarginTop : Level.Model -> Style
boardMarginTop model =
    marginTop <| boardOffsetTop model


boardOffsetTop : ScaleConfig model -> Int
boardOffsetTop model =
    (model.window.height - boardHeight model.tileSize model.boardScale) // 2 + model.topBarHeight // 2


boardHeight : TileSize -> Int -> Int
boardHeight tileSize boardScale =
    round tileSize.y * boardScale


boardWidth : TileSize -> Int -> Int
boardWidth tileSize boardScale =
    round tileSize.x * boardScale


tileCoordsStyles : TileSize -> Coord -> List Style
tileCoordsStyles tileSize coord =
    let
        ( y, x ) =
            tilePosition tileSize coord
    in
        [ transformStyle <| translate x y ]


tilePosition : TileSize -> Coord -> ( Float, Float )
tilePosition tileSize ( y, x ) =
    ( (toFloat y) * tileSize.y
    , (toFloat x) * tileSize.x
    )


wallStyles : Move -> List Style
wallStyles ( _, block ) =
    case block of
        Wall ->
            [ backgroundColor blockYellow
            , widthStyle 45
            , heightStyle 45
            ]

        _ ->
            []


enteringStyles : Move -> List Style
enteringStyles ( _, block ) =
    let
        tile =
            getTileState block
    in
        case tile of
            Entering tile ->
                [ animationStyle "bounce-down 1s linear"
                ]

            _ ->
                []


growingStyles : Move -> List Style
growingStyles ( coord, block ) =
    let
        tile =
            getTileState block

        transitionDelay =
            ((growingOrder block) % 5) * 70
    in
        case tile of
            Growing SeedPod _ ->
                [ transformStyle <| scale 4
                , transitionStyle "0.4s ease"
                , opacityStyle 0
                , transitionDelayStyle transitionDelay
                , ( "pointer-events", "none" )
                ]

            Growing Seed _ ->
                [ animationStyle "bulge 0.5s ease"
                ]

            _ ->
                []


fallingStyles : Move -> List Style
fallingStyles ( _, block ) =
    let
        tile =
            getTileState block
    in
        case tile of
            Falling tile distance ->
                [ animationStyle <| "bounce-down-" ++ (toString (distance)) ++ " 0.9s linear"
                , fillModeStyle "forwards"
                ]

            _ ->
                []


leavingStyles : Level.Model -> Move -> List Style
leavingStyles model (( _, tile ) as move) =
    if isLeaving tile then
        [ transitionStyle "0.8s ease"
        , opacityStyle 0.2
        , transitionDelayStyle <| ((leavingOrder tile) % 5) * 80
        , handleExitDirection move model
        ]
    else
        []


releasingStyles : Move -> List Style
releasingStyles ( _, tile ) =
    if isReleasing tile then
        [ transitionStyle "0.3s"
        , transformStyle <| scale 1
        ]
    else
        []


handleExitDirection : Move -> Level.Model -> Style
handleExitDirection ( coord, block ) model =
    let
        tile =
            getTileState block
    in
        case tile of
            Leaving Rain _ ->
                getLeavingStyle Rain model

            Leaving Sun _ ->
                getLeavingStyle Sun model

            Leaving Seed _ ->
                getLeavingStyle Seed model

            _ ->
                emptyStyle


getLeavingStyle : TileType -> Level.Model -> Style
getLeavingStyle tileType model =
    newLeavingStyles model
        |> Dict.get (toString tileType)
        |> Maybe.withDefault ""
        |> transformStyle


newLeavingStyles : Level.Model -> Dict String String
newLeavingStyles model =
    model.tileSettings
        |> scoreTileTypes
        |> List.indexedMap (prepareLeavingStyle model)
        |> Dict.fromList


prepareLeavingStyle : Level.Model -> Int -> TileType -> ( String, String )
prepareLeavingStyle model i tileType =
    ( toString tileType
    , translateScale (exitXDistance i model) -(exitYdistance model) 0.5
    )


exitXDistance : Int -> Level.Model -> Int
exitXDistance n model =
    let
        scoreWidth =
            model.scoreIconSize * 2

        scoreBarWidth =
            (List.length model.tileSettings) * scoreWidth

        baseOffset =
            (boardWidth model.tileSize model.boardScale - scoreBarWidth) // 2
    in
        baseOffset + (n * scoreWidth) + (model.scoreIconSize + 3)


exitYdistance : Level.Model -> Int
exitYdistance model =
    (boardOffsetTop model) - 9


moveTracerStyles : Move -> List Style
moveTracerStyles (( coord, tile ) as move) =
    if isDragging tile then
        [ animationStyle "bulge-fade 0.8s ease"
        , fillModeStyle "forwards"
        ]
    else
        [ displayStyle "none"
        ]


draggingStyles : Maybe MoveShape -> Move -> List Style
draggingStyles moveShape ( _, tileState ) =
    if moveShape == Just Square then
        [ transitionStyle "0.5s ease"
        ]
    else if isLeaving tileState then
        [ transitionStyle "0.1s ease"
        ]
    else if isDragging tileState then
        [ transformStyle <| scale 0.8
        , transitionStyle "0.3s ease"
        ]
    else
        []


tileWidthHeightStyles : TileSize -> List Style
tileWidthHeightStyles { x, y } =
    [ widthStyle x
    , heightStyle y
    ]


baseTileClasses : List String
baseTileClasses =
    [ "br-100"
    , centerBlock
    ]


centerBlock : String
centerBlock =
    "ma absolute top-0 left-0 right-0 bottom-0"
