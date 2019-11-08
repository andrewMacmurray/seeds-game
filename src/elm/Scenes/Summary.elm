module Scenes.Summary exposing
    ( Destination(..)
    , Model
    , Msg
    , getContext
    , init
    , update
    , updateContext
    , view
    )

import Board.Tile exposing (Tile(..))
import Config.World as Worlds
import Context exposing (Context)
import Css.Animation as Animation exposing (animation, linear)
import Css.Color as Color exposing (Color)
import Css.Style as Style exposing (..)
import Css.Transform exposing (translateX, translateY)
import Css.Transition as Transition exposing (transition, transitionAll)
import Exit exposing (continue, exitWith)
import Html exposing (..)
import Html.Attributes exposing (class)
import Level.Progress as Progress exposing (Progress)
import Ports exposing (cacheProgress)
import Scenes.Summary.Chrysanthemum as Chrysanthemum
import Scenes.Summary.Cornflower as Cornflower
import Scenes.Summary.Sunflower as Sunflower
import Seed exposing (Seed(..))
import Sine
import Svg exposing (Svg)
import Utils.Delay exposing (after, sequence, trigger)
import Views.Icon.RainBank exposing (..)
import Views.Icon.SeedBank exposing (seedBank)
import Views.Icon.SunBank exposing (sunBank, sunBankFull)
import Views.Seed as Seed
import Window exposing (Window)



-- Model


type alias Model =
    { context : Context
    , text : TextState
    , seedBankState : SeedBankState
    , resourceState : ResourceState
    , levelSuccessMessageVisible : Bool
    , fadeOut : Bool
    }


type Msg
    = IncrementProgress
    | CacheProgress
    | ShowLevelSuccess
    | BeginSeedBankTransformation
    | BloomWorldFlower
    | ShowFirstText
    | HideFirstText
    | ShowSecondText
    | HiddenSecondText
    | FadeOut
    | ExitToHub
    | ExitToGarden


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


type Destination
    = ToHub
    | ToGarden



-- Context


getContext : Model -> Context
getContext model =
    model.context


updateContext : (Context -> Context) -> Model -> Model
updateContext f model =
    { model | context = f model.context }



-- Init


init : Context -> ( Model, Cmd Msg )
init context =
    ( initialState context
    , after 1500 IncrementProgress
    )


initialState : Context -> Model
initialState context =
    { context = context
    , text = First False
    , seedBankState = Visible
    , resourceState = Waiting
    , levelSuccessMessageVisible = False
    , fadeOut = False
    }



-- Update


update : Msg -> Model -> Exit.With Destination ( Model, Cmd Msg )
update msg model =
    case msg of
        IncrementProgress ->
            continue (incrementProgress model) [ trigger CacheProgress ]

        CacheProgress ->
            continue model
                [ cacheProgress <| Progress.toCache model.context.progress
                , handleSuccessMessage model
                ]

        ShowLevelSuccess ->
            continue { model | levelSuccessMessageVisible = True } []

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
            continue { model | text = First True } []

        HideFirstText ->
            continue { model | text = First False } []

        ShowSecondText ->
            continue { model | text = Second True } []

        HiddenSecondText ->
            continue { model | text = Second False } []

        FadeOut ->
            continue { model | fadeOut = True } []

        ExitToHub ->
            exitWith ToHub model

        ExitToGarden ->
            exitWith ToGarden model


handleSuccessMessage : Model -> Cmd Msg
handleSuccessMessage { context } =
    if Progress.currentWorldComplete Worlds.all context.progress then
        sequence
            [ ( 3000, BeginSeedBankTransformation )
            , ( 4000, BloomWorldFlower )
            , ( 2000, ShowFirstText )
            , ( 3000, HideFirstText )
            , ( 1000, ShowSecondText )
            , ( 3000, HiddenSecondText )
            , ( 2000, FadeOut )
            , ( 2000, ExitToGarden )
            ]

    else
        sequence
            [ ( 2000, ShowLevelSuccess )
            , ( 2500, ExitToHub )
            ]


incrementProgress : Model -> Model
incrementProgress model =
    { model
        | resourceState = Filling
        , context =
            model.context
                |> Context.incrementProgress Worlds.all
                |> Context.incrementMessageIndex
    }



-- View


view : Model -> Html msg
view model =
    let
        seed =
            currentSeedType model.context.progress
    in
    div
        [ style
            [ height <| toFloat model.context.window.height
            , backgroundColor seed model.seedBankState
            , transition "background" 3000 [ Transition.linear ]
            , animation "fade-in" 1000 [ Animation.linear ]
            ]
        , class "fixed z-5 w-100 top-0 left-0"
        ]
        [ renderFlowerLayer seed model.context.window model.seedBankState
        , worldCompleteText seed model
        , renderResourcesLayer model
        , renderFadeOut model
        ]


currentSeedType : Progress -> Seed
currentSeedType progress =
    progress
        |> Progress.currentLevelSeedType Worlds.all
        |> Maybe.withDefault Sunflower


backgroundColor : Seed -> SeedBankState -> Style
backgroundColor seed seedBankState =
    case seedBankState of
        Visible ->
            background Color.washedYellow

        Leaving ->
            background Color.lightGold

        Blooming ->
            background <| getBackgroundFor seed


renderFlowerLayer : Seed -> Window -> SeedBankState -> Html msg
renderFlowerLayer seed window seedBankState =
    let
        ( flowersHidden, flowersVisible ) =
            getFlowerLayer seed window
    in
    case seedBankState of
        Leaving ->
            flowersHidden

        Blooming ->
            flowersVisible

        _ ->
            span [] []


getFlowerLayer : Seed -> Window -> ( Svg msg, Svg msg )
getFlowerLayer seed window =
    case seed of
        Sunflower ->
            ( Sunflower.hidden window
            , Sunflower.visible window
            )

        Chrysanthemum ->
            ( Chrysanthemum.hidden window
            , Chrysanthemum.visible window
            )

        Cornflower ->
            ( Cornflower.hidden window
            , Cornflower.visible window
            )

        _ ->
            ( Sunflower.hidden window
            , Sunflower.visible window
            )


getBackgroundFor : Seed -> Color
getBackgroundFor seed =
    case seed of
        Sunflower ->
            Sunflower.background

        Chrysanthemum ->
            Chrysanthemum.background

        Cornflower ->
            Cornflower.background

        _ ->
            Sunflower.background



-- Fadeout


renderFadeOut : Model -> Html msg
renderFadeOut model =
    if model.fadeOut then
        fadeOverlay model.context.window

    else
        span [] []


fadeOverlay : Window -> Html msg
fadeOverlay window =
    div
        [ style
            [ height <| toFloat window.height
            , opacity 0
            , Animation.animation "fade-in" 2000 [ Animation.linear ]
            , Style.backgroundColor Color.lightYellow
            ]
        , class "fixed top-0 w-100 z-7"
        ]
        []



-- Complete Text


worldCompleteText : Seed -> Model -> Html msg
worldCompleteText seed model =
    div
        [ style
            [ color Color.white
            , transitionAll 1000 []
            , top <| toFloat model.context.window.height / 2 + 80
            , textVisibility model.text
            ]
        , class "tc absolute tracked w-100 z-5"
        ]
        [ text <| textContent seed model.text ]


textVisibility : TextState -> Style
textVisibility text =
    case text of
        First visible ->
            showIf visible

        Second visible ->
            showIf visible


textContent : Seed -> TextState -> String
textContent seed text =
    case text of
        First _ ->
            "You saved the " ++ Seed.name seed ++ "!"

        Second _ ->
            "It will bloom again on our new world"



-- Resources


renderResourcesLayer : Model -> Html msg
renderResourcesLayer ({ context } as model) =
    let
        levelSeed =
            Progress.currentLevelSeedType Worlds.all context.progress |> Maybe.withDefault Sunflower
    in
    div
        [ style [ height <| toFloat context.window.height ]
        , class "flex justify-center items-center w-100"
        ]
        [ div [ style [ marginTop -100 ] ]
            [ div [ style [ width 65, marginBottom 30 ], class "center" ]
                [ viewBank model levelSeed ]
            , renderResources model
            , p
                [ style
                    [ color Color.darkYellow
                    , marginTop 100
                    , marginBottom -40
                    , transition "opacity" 1000 []
                    , showIf model.levelSuccessMessageVisible
                    ]
                , class "tc"
                ]
                [ text "We're one step closer..." ]
            ]
        ]


renderResources : Model -> Html msg
renderResources ({ context } as model) =
    let
        resources =
            Progress.resources Worlds.all context.progress
                |> Maybe.withDefault []
                |> List.map (renderResource model.resourceState context.progress)
    in
    div
        [ style
            [ height 50
            , resourceVisibility model.resourceState
            , transition "opacity" 1000 []
            ]
        ]
        resources


viewBank : Model -> Seed -> Html msg
viewBank model seed =
    let
        progress =
            model.context.progress

        fillLevel =
            Progress.percentComplete Worlds.all (Seed seed) progress
                |> Maybe.withDefault 0
    in
    div []
        [ div
            [ style
                [ transition "opacity" 1000 [ Transition.delay 500 ]
                , resourceVisibility model.resourceState
                ]
            ]
            [ renderResourceFill model.resourceState progress (Seed seed) ]
        , innerSeedBank model.seedBankState seed fillLevel
        ]


innerSeedBank : SeedBankState -> Seed -> Float -> Html msg
innerSeedBank seedBankState seed fillLevel =
    case seedBankState of
        Visible ->
            div [ style [ transform [ translateY 0 ], transitionAll 2000 [] ] ]
                [ seedBank seed fillLevel ]

        Leaving ->
            div
                [ style [ transform [ translateY 100 ], transitionAll 2000 [] ] ]
                [ div
                    [ style
                        [ animation "shake" 500 [ Animation.delay 1000, Animation.linear, Animation.count 6 ]
                        , transformOrigin "bottom"
                        ]
                    ]
                    [ seedBank seed fillLevel ]
                ]

        Blooming ->
            div
                [ style [ transform [ translateY 100 ], transitionAll 2000 [] ] ]
                [ div
                    [ style [ animation "bulge-fade" 500 [] ] ]
                    [ seedBank seed fillLevel
                    ]
                ]


resourceVisibility : ResourceState -> Style
resourceVisibility resourceState =
    showIf <| resourceState == Waiting || resourceState == Filling


renderResource : ResourceState -> Progress -> Tile -> Html msg
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

        Seed seed ->
            div [ style [ width 40 ], class "dib ph1 mh4" ]
                [ renderResourceFill resourceState progress tileType
                , seedBank seed fillLevel
                ]

        _ ->
            span [] []


renderResourceFill : ResourceState -> Progress -> Tile -> Html msg
renderResourceFill resourceState progress tileType =
    let
        fill =
            renderFill resourceState tileType progress
    in
    case tileType of
        Rain ->
            div [ style [ height 50 ] ]
                [ div [ style [ width 13 ], class "center" ] [ rainBankFull ]
                , fill <| div [ class "relative" ] <| List.map (weatherDrop Color.rainBlue) <| List.range 1 50
                ]

        Sun ->
            div [ style [ height 50 ] ]
                [ div [ style [ width 18 ], class "center" ] [ sunBankFull ]
                , fill <| div [ class "relative" ] <| List.map (weatherDrop Color.gold) <| List.range 4 54
                ]

        Seed seed ->
            div [ style [ height 50 ] ]
                [ div [ style [ width 12 ], class "center" ] [ Seed.view seed ]
                , fill <| div [ class "relative", style [ transform [ translateY -10 ] ] ] <| List.map (seedDrop seed) <| List.range 7 57
                ]

        _ ->
            span [] []


renderFill : ResourceState -> Tile -> Progress -> Html msg -> Html msg
renderFill resourceState tileType progess element =
    if resourceState == Filling && pointsFromPreviousLevel tileType progess > 0 then
        element

    else
        span [] []


pointsFromPreviousLevel : Tile -> Progress -> Int
pointsFromPreviousLevel tileType progress =
    Progress.pointsFromPreviousLevel Worlds.all tileType progress
        |> Maybe.withDefault 0


seedDrop : Seed -> Int -> Html msg
seedDrop seed n =
    div
        [ style [ transform [ translateX <| Sine.wave { left = -5, center = 0, right = 5 } (n - 1) ] ] ]
        [ div
            [ style
                [ width 5
                , height 8
                , opacity 0
                , animation "fade-slide-down" 150 [ Animation.delay <| n * dropDelay n, linear ]
                ]
            , class "absolute top-0 left-0 right-0 center"
            ]
            [ Seed.view seed ]
        ]


weatherDrop : String -> Int -> Html msg
weatherDrop bgColor n =
    div
        [ style [ transform [ translateX <| Sine.wave { left = -5, center = 0, right = 5 } (n - 1) ] ] ]
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
