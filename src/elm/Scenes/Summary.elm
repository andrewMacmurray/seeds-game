module Scenes.Summary exposing
    ( Model
    , Msg
    , getShared
    , init
    , update
    , updateShared
    , view
    )

import Css.Animation as Animation exposing (animation, linear)
import Css.Color as Color exposing (darkYellow, gold, rainBlue, washedYellow)
import Css.Style as Style exposing (..)
import Css.Transform as Transform exposing (scale, translateX, translateY)
import Css.Transition as Transition exposing (transition, transitionAll)
import Data.Board.Types exposing (..)
import Data.Levels as Levels
import Data.Progress as Progress exposing (Progress)
import Data.Wave exposing (wave)
import Exit exposing (continue, exit)
import Helpers.Delay exposing (after, sequence, trigger)
import Html exposing (..)
import Html.Attributes exposing (class)
import Html.Keyed as Keyed
import Ports exposing (cacheProgress)
import Shared exposing (Window)
import Views.Flowers.Sunflower as Sunflower
import Views.Icons.RainBank exposing (..)
import Views.Icons.SeedBank exposing (seedBank)
import Views.Icons.SunBank exposing (sunBank, sunBankFull)
import Views.Landscape.SunflowerMeadow as SunflowerMeadow
import Views.Seed.All exposing (renderSeed)
import Worlds



-- Model


type alias Model =
    { shared : Shared.Data
    , textState : TextState
    , seedBankState : SeedBankState
    , resourceState : ResourceState
    , levelSuccessVisible : Bool
    }


type Msg
    = IncrementProgress
    | CacheProgress
    | ShowLevelSuccess
    | BeginSeedBankTransformation
    | BloomWorldFlower
    | BackToHub
    | ShowFirstText
    | HideFirstText
    | ShowSecondText
    | HidenSecondText


type SeedBankState
    = Visible
    | Leaving
    | Blooming


type ResourceState
    = Waiting
    | Filling
    | Hidden


type TextState
    = First TextVisible
    | Second TextVisible


type alias TextVisible =
    Bool



-- Shared


getShared : Model -> Shared.Data
getShared model =
    model.shared


updateShared : (Shared.Data -> Shared.Data) -> Model -> Model
updateShared f model =
    { model | shared = f model.shared }



-- Init


init : Shared.Data -> ( Model, Cmd Msg )
init shared =
    ( initialState shared
    , after 1500 IncrementProgress
    )


initialState : Shared.Data -> Model
initialState shared =
    { shared = shared
    , textState = First False
    , seedBankState = Visible
    , resourceState = Waiting
    , levelSuccessVisible = False
    }



-- Update


update : Msg -> Model -> Exit.Status ( Model, Cmd Msg )
update msg model =
    case msg of
        IncrementProgress ->
            continue (incrementProgress model) [ trigger CacheProgress ]

        CacheProgress ->
            continue model
                [ cacheProgress <| Progress.toCache model.shared.progress
                , handleSuccessMessage model
                ]

        ShowLevelSuccess ->
            continue { model | levelSuccessVisible = True } []

        BeginSeedBankTransformation ->
            continue
                { model
                    | seedBankState = Leaving
                    , resourceState = Hidden
                }
                []

        BloomWorldFlower ->
            continue { model | seedBankState = Blooming } []

        ShowFirstText ->
            continue { model | textState = First True } []

        HideFirstText ->
            continue { model | textState = First False } []

        ShowSecondText ->
            continue { model | textState = Second True } []

        HidenSecondText ->
            continue { model | textState = Second False } []

        BackToHub ->
            exit model


handleSuccessMessage : Model -> Cmd Msg
handleSuccessMessage { shared } =
    if Progress.currentWorldComplete Worlds.all shared.progress then
        sequence
            [ ( 3000, BeginSeedBankTransformation )
            , ( 4000, BloomWorldFlower )
            , ( 2000, ShowFirstText )
            , ( 3000, HideFirstText )
            , ( 1000, ShowSecondText )
            , ( 3000, HidenSecondText )
            , ( 2000, BackToHub )
            ]

    else
        sequence
            [ ( 2000, ShowLevelSuccess )
            , ( 2500, BackToHub )
            ]


incrementProgress : Model -> Model
incrementProgress model =
    { model
        | resourceState = Filling
        , shared =
            model.shared
                |> Shared.incrementProgress Worlds.all
                |> Shared.incrementMessageIndex
    }



-- View


view : Model -> Html msg
view model =
    div
        [ style
            [ height <| toFloat model.shared.window.height
            , backgroundColor model.seedBankState
            , transition "background" 3000 [ Transition.linear ]
            , animation "fade-in" 1000 [ Animation.linear ]
            ]
        , class "fixed z-5 w-100 top-0 left-0"
        ]
        [ renderFlowerLayer model
        , renderResourcesLayer model
        ]


backgroundColor : SeedBankState -> Style
backgroundColor seedBankState =
    case seedBankState of
        Leaving ->
            background Color.lightGold

        Blooming ->
            background Color.meadowGreen

        _ ->
            background Color.washedYellow


renderFlowerLayer : Model -> Html msg
renderFlowerLayer model =
    case model.seedBankState of
        Leaving ->
            Keyed.node "div"
                []
                [ ( "meadow"
                  , div [ class "w-100 absolute z-1 top-0 left-0" ]
                        [ SunflowerMeadow.animated model.shared.window SunflowerMeadow.Hidden ]
                  )
                ]

        Blooming ->
            Keyed.node "div"
                []
                [ ( "flowers"
                  , div []
                        [ div
                            [ style [ height <| toFloat model.shared.window.height, marginTop -40 ]
                            , class "w-100 absolute z-3 flex flex-column items-center justify-center"
                            ]
                            [ mainFlower
                            , worldCompleteText model.textState
                            ]
                        , flowerSpriteLayer model.shared.window
                        ]
                  )
                , ( "meadow"
                  , div [ class "w-100 absolute z-1 top-0 left-0" ]
                        [ SunflowerMeadow.animated model.shared.window SunflowerMeadow.Visible ]
                  )
                ]

        _ ->
            span [] []


flowerSpriteLayer : Window -> Html msg
flowerSpriteLayer window =
    flowerSprites window
        [ Sprite 0 0 1 Color.sunflowerYellow
        , Sprite -3 100 1.2 Color.petalOrange
        , Sprite -5 20 1.5 Color.sunflowerYellow
        , Sprite -2 95 1.6 Color.petalOrange
        , Sprite -5 140 1 Color.sunflowerYellow
        , Sprite -2 105 1.4 Color.petalOrange
        , Sprite -3 110 0.8 Color.sunflowerYellow
        , Sprite -7 100 1.2 Color.petalOrange
        , Sprite -8 130 0.8 Color.sunflowerYellow
        , Sprite -6 100 1.4 Color.petalOrange
        , Sprite -3 30 1 Color.sunflowerYellow
        , Sprite -2 130 1.1 Color.sunflowerYellow
        , Sprite -4 85 1.6 Color.petalOrange
        , Sprite -1 110 0.8 Color.sunflowerYellow
        , Sprite -8 20 2 Color.sunflowerYellow
        , Sprite -3 100 1.2 Color.petalOrange
        , Sprite -7 0 1 Color.sunflowerYellow
        ]


flowerSprites : Window -> List Sprite -> Html msg
flowerSprites window sprites =
    div
        [ style [ height <| toFloat window.height ]
        , class "w-100 absolute z-2 top-0 left-0 flex items-center justify-center"
        ]
    <|
        List.map flowerSprite sprites


type alias Sprite =
    { delay : Int
    , yOffset : Float
    , scale : Float
    , color : Color.Color
    }


flowerSprite { delay, yOffset, scale, color } =
    div
        [ style
            [ Animation.animation "fade-in" 2000 [ Animation.delay <| abs <| delay * 300 ]
            , opacity 0
            ]
        ]
        [ div
            [ style
                [ Animation.animation "hover-big"
                    4000
                    [ Animation.ease
                    , Animation.infinite
                    , Animation.delay <| delay * 300
                    ]
                ]
            ]
            [ div
                [ style
                    [ width 10
                    , height 10
                    , marginLeft 10
                    , marginRight 10
                    , Style.backgroundColor color
                    , Style.transform [ Transform.translateY yOffset, Transform.scale scale ]
                    ]
                , class "dib br-100"
                ]
                []
            ]
        ]


mainFlower : Html msg
mainFlower =
    div [ style [ height 180, width 200 ] ] [ Sunflower.animated 1000 ]


smallFlower : Int -> Html msg
smallFlower delayMs =
    div
        [ style
            [ width 50
            , height 50
            , opacity 0
            , animation "fade-in" 1000 [ Animation.delay <| delayMs + 500 ]
            ]
        ]
        [ Sunflower.static ]


worldCompleteText : TextState -> Html msg
worldCompleteText textState =
    div
        [ style [ color Color.white, transitionAll 1000 [] ]
        , class "tc relative w-100"
        , textVisibility textState
        ]
        [ text <| textContent textState ]


textVisibility : TextState -> Attribute msg
textVisibility textState =
    case textState of
        First visible ->
            showIf visible

        Second visible ->
            showIf visible


textContent : TextState -> String
textContent textState =
    case textState of
        First _ ->
            "You saved the Sunflower!"

        Second _ ->
            "It will bloom again on our new world"


renderResourcesLayer : Model -> Html msg
renderResourcesLayer ({ shared } as model) =
    let
        levelSeed =
            Progress.currentLevelSeedType Worlds.all shared.progress |> Maybe.withDefault Sunflower
    in
    div
        [ style [ height <| toFloat shared.window.height ]
        , class "flex justify-center items-center w-100"
        ]
        [ div [ style [ marginTop -100 ] ]
            [ div [ style [ width 65, marginBottom 30 ], class "center" ]
                [ renderSeedBank model levelSeed ]
            , renderResources model
            , p
                [ style
                    [ color darkYellow
                    , marginTop 100
                    , marginBottom -40
                    , transition "opacity" 1000 []
                    ]
                , class "tc"
                , showIf model.levelSuccessVisible
                ]
                [ text "We're one step closer..." ]
            ]
        ]


renderResources : Model -> Html msg
renderResources ({ shared } as model) =
    let
        resources =
            Progress.resources Worlds.all shared.progress
                |> Maybe.withDefault []
                |> List.map (renderResource model.resourceState shared.progress)
    in
    div
        [ style [ height 50, transition "opacity" 1000 [] ]
        , resourceVisibility model.resourceState
        ]
        resources


renderSeedBank : Model -> SeedType -> Html msg
renderSeedBank model seedType =
    let
        progress =
            model.shared.progress

        fillLevel =
            Progress.percentComplete Worlds.all (Seed seedType) progress
                |> Maybe.withDefault 0
    in
    div []
        [ div
            [ style [ transition "opacity" 1000 [ Transition.delay 500 ] ]
            , resourceVisibility model.resourceState
            ]
            [ renderResourceFill model.resourceState progress (Seed seedType) ]
        , innerSeedBank model.seedBankState seedType fillLevel
        ]


innerSeedBank : SeedBankState -> SeedType -> Float -> Html msg
innerSeedBank seedBankState seedType fillLevel =
    case seedBankState of
        Visible ->
            div [ style [ transform [ translateY 0 ], transitionAll 2000 [] ] ]
                [ seedBank seedType fillLevel ]

        Leaving ->
            div
                [ style [ transform [ translateY 100 ], transitionAll 2000 [] ] ]
                [ div
                    [ style
                        [ animation "shake" 500 [ Animation.delay 1000, Animation.linear, Animation.count 6 ]
                        , transformOrigin "bottom"
                        ]
                    ]
                    [ seedBank seedType fillLevel ]
                ]

        Blooming ->
            div
                [ style [ transform [ translateY 100 ], transitionAll 2000 [] ] ]
                [ div
                    [ style [ animation "bulge-fade" 500 [] ] ]
                    [ seedBank seedType fillLevel
                    ]
                ]


resourceVisibility : ResourceState -> Attribute msg
resourceVisibility resourceState =
    showIf <| resourceState == Waiting || resourceState == Filling


renderResource : ResourceState -> Progress -> TileType -> Html msg
renderResource resourceState progress tileType =
    let
        fillLevel =
            Progress.percentComplete Worlds.all tileType progress
                |> Maybe.withDefault 0
    in
    case tileType of
        Rain ->
            div [ style [ width 40 ], class "dib ph1 mh4" ]
                [ renderResourceFill resourceState progress tileType
                , rainBank fillLevel
                ]

        Sun ->
            div [ style [ width 40 ], class "dib mh4" ]
                [ renderResourceFill resourceState progress tileType
                , sunBank fillLevel
                ]

        Seed seedType ->
            div [ style [ width 40 ], class "dib ph1 mh4" ]
                [ renderResourceFill resourceState progress tileType
                , seedBank seedType fillLevel
                ]

        _ ->
            span [] []


renderResourceFill : ResourceState -> Progress -> TileType -> Html msg
renderResourceFill resourceState progress tileType =
    let
        fill =
            renderFill resourceState tileType progress
    in
    case tileType of
        Rain ->
            div [ style [ height 50 ] ]
                [ div [ style [ width 13 ], class "center" ] [ rainBankFull ]
                , fill <| div [ class "relative" ] <| List.map (weatherDrop rainBlue) <| List.range 1 50
                ]

        Sun ->
            div [ style [ height 50 ] ]
                [ div [ style [ width 18 ], class "center" ] [ sunBankFull ]
                , fill <| div [ class "relative" ] <| List.map (weatherDrop gold) <| List.range 4 54
                ]

        Seed seedType ->
            div [ style [ height 50 ] ]
                [ div [ style [ width 12 ], class "center" ] [ renderSeed seedType ]
                , fill <| div [ class "relative", style [ transform [ translateY -10 ] ] ] <| List.map (seedDrop seedType) <| List.range 7 57
                ]

        _ ->
            span [] []


renderFill : ResourceState -> TileType -> Progress -> Html msg -> Html msg
renderFill resourceState tileType progess element =
    if resourceState == Filling && pointsFromPreviousLevel tileType progess > 0 then
        element

    else
        span [] []


pointsFromPreviousLevel : TileType -> Progress -> Int
pointsFromPreviousLevel tileType progress =
    Progress.pointsFromPreviousLevel Worlds.all tileType progress
        |> Maybe.withDefault 0


seedDrop : SeedType -> Int -> Html msg
seedDrop seedType n =
    div
        [ style [ transform [ translateX <| wave { left = -5, center = 0, right = 5 } (n - 1) ] ] ]
        [ div
            [ style
                [ width 5
                , height 8
                , opacity 0
                , animation "fade-slide-down" 150 [ Animation.delay <| n * dropDelay n, linear ]
                ]
            , class "absolute top-0 left-0 right-0 center"
            ]
            [ renderSeed seedType ]
        ]


weatherDrop : String -> Int -> Html msg
weatherDrop bgColor n =
    div
        [ style [ transform [ translateX <| wave { left = -5, center = 0, right = 5 } (n - 1) ] ] ]
        [ div
            [ style
                [ width 6
                , height 6
                , background bgColor
                , opacity 0
                , animation "fade-slide-down" 150 [ Animation.delay (n * dropDelay n), linear ]
                ]
            , class "br-100 absolute left-0 right-0 center"
            ]
            []
        ]


dropDelay : Int -> Int
dropDelay n =
    if modBy 3 n == 0 then
        30

    else if modBy 3 n == 1 then
        60

    else
        90
