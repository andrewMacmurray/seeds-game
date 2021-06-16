module Scene.Summary exposing
    ( Destination(..)
    , Model
    , Msg
    , init
    , update
    , view
    )

import Context exposing (Context)
import Element exposing (..)
import Element.Background as Background
import Element.Icon.RainBank as RainBank
import Element.Icon.SeedBank as SeedBank
import Element.Icon.SunBank as SunBank
import Element.Layout as Layout
import Element.Palette as Palette
import Element.Scale as Scale
import Element.Text as Text
import Element.Transition as Transition
import Exit exposing (continue, exitWith)
import Game.Board.Tile as Tile exposing (Tile)
import Game.Config.World as Worlds
import Game.Level.Progress as Progress exposing (Progress)
import Html exposing (Html)
import Ports exposing (cacheProgress)
import Scene.Summary.Chrysanthemum as Chrysanthemum
import Scene.Summary.Cornflower as Cornflower
import Scene.Summary.Sunflower as Sunflower
import Seed exposing (Seed)
import Utils.Delay exposing (after, sequence, trigger)
import Utils.Element as Element



-- Model


type alias Model =
    { context : Context
    , text : Text
    , worldSeed : WorldSeed
    , resourceBank : ResourceBank
    , messageVisible : Bool
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


type WorldSeed
    = Visible
    | Leaving
    | Blooming


type ResourceBank
    = Waiting
    | Filling
    | Hidden


type Text
    = First TextVisible
    | Second TextVisible


type alias TextVisible =
    Bool


type Destination
    = ToHub
    | ToGarden



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
    , worldSeed = Visible
    , resourceBank = Waiting
    , messageVisible = False
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
                [ cacheProgress (Progress.toCache model.context.progress)
                , handleSuccessMessage model
                ]

        ShowLevelSuccess ->
            continue { model | messageVisible = True } []

        BeginSeedBankTransformation ->
            continue
                { model
                    | worldSeed = Leaving
                    , resourceBank = Hidden
                }
                []

        BloomWorldFlower ->
            continue { model | worldSeed = Blooming } []

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

            --, ( 2500, ExitToHub )
            ]


incrementProgress : Model -> Model
incrementProgress model =
    { model
        | resourceBank = Filling
        , context = incrementProgress_ model.context
    }


incrementProgress_ : Context -> Context
incrementProgress_ =
    Context.incrementProgress Worlds.all >> Context.nextMessage



-- View


view : Model -> Html msg
view model =
    Layout.fadeIn
        [ Background.color (background model)
        , Transition.background 3000
        ]
        (resourceSummary model)



-- View Model


toViewModel : Model -> ViewModel
toViewModel model =
    { worldSeed = model.worldSeed
    , textVisible = model.messageVisible
    , mainResource = toMainResource model
    , otherResources = toOtherResources model
    }


toMainResource : Model -> Resource
toMainResource model =
    toResource_ model
        (Tile.Seed (currentSeedType model))
        (Seed (currentSeedType model))


getProgress : Model -> Progress
getProgress =
    .context >> .progress


toOtherResources : Model -> List Resource
toOtherResources model =
    getProgress model
        |> Progress.resources Worlds.all
        |> List.filterMap (toResource model)


toResource : Model -> Tile -> Maybe Resource
toResource model tile =
    case tile of
        Tile.Sun ->
            Just (toResource_ model tile Sun)

        Tile.Rain ->
            Just (toResource_ model tile Rain)

        Tile.Seed seed ->
            Just (toResource_ model tile (Seed seed))

        _ ->
            Nothing


toResource_ : Model -> Tile -> Icon -> Resource
toResource_ model tile icon =
    { icon = icon
    , fill = percentFor tile (getProgress model)
    }


percentFor : Tile -> Progress -> Percent
percentFor tile =
    Progress.percentComplete Worlds.all tile >> Maybe.withDefault 0


currentSeedType : Model -> Seed
currentSeedType =
    .context
        >> .progress
        >> Progress.currentLevelSeedType Worlds.all
        >> Maybe.withDefault Seed.Sunflower


background : Model -> Color
background model =
    case model.worldSeed of
        Visible ->
            Palette.background2_

        Leaving ->
            Palette.lightGold

        Blooming ->
            flowerBackground (currentSeedType model)


flowerBackground : Seed -> Color
flowerBackground seed =
    case seed of
        Seed.Sunflower ->
            Sunflower.background

        Seed.Chrysanthemum ->
            Chrysanthemum.background

        Seed.Cornflower ->
            Cornflower.background

        _ ->
            Sunflower.background



--    let
--        seed =
--            currentSeedType model.context.progress
--    in
--    div
--        [ style
--            [ height (toFloat model.context.window.height)
--            , backgroundColor seed model.worldSeed
--            , transition "background" 3000 [ Transition.linear ]
--            , animation "fade-in" 1000 [ Animation.linear ]
--            ]
--        , class "fixed z-5 w-100 top-0 left-0"
--        ]
--        [ renderFlowerLayer seed model.context.window model.worldSeed
--        , worldCompleteText seed model
--        , renderResourcesLayer model
--        , renderFadeOut model
--        ]
--
--
--renderFlowerLayer : Seed -> Window -> WorldSeed -> Html msg
--renderFlowerLayer seed window seedBankState =
--    let
--        ( flowersHidden, flowersVisible ) =
--            getFlowerLayer seed window
--    in
--    case seedBankState of
--        Leaving ->
--            flowersHidden
--
--        Blooming ->
--            flowersVisible
--
--        _ ->
--            span [] []
--
--
--getFlowerLayer : Seed -> Window -> ( Svg msg, Svg msg )
--getFlowerLayer seed window =
--    case seed of
--        Sunflower ->
--            ( Sunflower.hidden window
--            , Sunflower.visible window
--            )
--
--        Chrysanthemum ->
--            ( Chrysanthemum.hidden window
--            , Chrysanthemum.visible window
--            )
--
--        Cornflower ->
--            ( Cornflower.hidden window
--            , Cornflower.visible window
--            )
--
--        _ ->
--            ( Sunflower.hidden window
--            , Sunflower.visible window
--            )
--
--
--
--
---- Fadeout
--
--
--renderFadeOut : Model -> Html msg
--renderFadeOut model =
--    if model.fadeOut then
--        fadeOverlay model.context.window
--
--    else
--        span [] []
--
--
--fadeOverlay : Window -> Html msg
--fadeOverlay window =
--    div
--        [ style
--            [ height (toFloat window.height)
--            , opacity 0
--            , Animation.animation "fade-in" 2000 [ Animation.linear ]
--            , Style.backgroundColor Color.lightYellow
--            ]
--        , class "fixed top-0 w-100 z-7"
--        ]
--        []
--
--
--
---- Complete Text
--
--
--worldCompleteText : Seed -> Model -> Html msg
--worldCompleteText seed model =
--    div
--        [ style
--            [ color Color.white
--            , transitionAll 1000 []
--            , top (toFloat model.context.window.height / 2 + 80)
--            , textVisibility model.text
--            ]
--        , class "tc absolute tracked w-100 z-5"
--        ]
--        [ text (textContent seed model.text) ]
--
--
--textVisibility : Text -> Style
--textVisibility text =
--    case text of
--        First visible ->
--            showIf visible
--
--        Second visible ->
--            showIf visible
--
--
--textContent : Seed -> Text -> String
--textContent seed text =
--    case text of
--        First _ ->
--            "You saved the " ++ Seed.name seed ++ "!"
--
--        Second _ ->
--            "It will bloom again on our new world"
--
--
--
-- Resources


type alias ViewModel =
    { worldSeed : WorldSeed
    , textVisible : Bool
    , mainResource : Resource
    , otherResources : List Resource
    }


type alias Resource =
    { icon : Icon
    , fill : Percent
    }


type Icon
    = Rain
    | Sun
    | Seed Seed


type alias Percent =
    Float


resourceSummary : Model -> Element msg
resourceSummary =
    toViewModel >> resourceSummary_


resourceSummary_ : ViewModel -> Element msg
resourceSummary_ model =
    column
        [ centerX
        , centerY
        , spacing Scale.large
        ]
        [ mainResource model
        , otherResources model
        , levelEndText model
        ]


mainResource : ViewModel -> Element msg
mainResource model =
    el [ centerX ]
        (viewResource
            { size = 100
            }
            model.mainResource
        )


levelEndText : ViewModel -> Element msg
levelEndText model =
    Text.text
        [ centerX
        , Transition.alpha 1000
        , Element.visibleIf model.textVisible
        ]
        "We're one step closer..."


otherResources : ViewModel -> Element msg
otherResources model =
    row
        [ spacing Scale.large
        , centerX
        ]
        (List.map
            (viewResource
                { size = 50
                }
            )
            model.otherResources
        )


type alias ResourceOptions =
    { size : Int
    }


viewResource : ResourceOptions -> Resource -> Element msg
viewResource options resource =
    Element.square options.size [ centerX ] (viewResource_ resource)


viewResource_ : Resource -> Element msg
viewResource_ resource =
    case resource.icon of
        Sun ->
            SunBank.icon resource.fill

        Rain ->
            RainBank.icon resource.fill

        Seed seed ->
            SeedBank.icon seed resource.fill



--innerSeedBank : WorldSeed -> Seed -> Float -> Html msg
--innerSeedBank seedBankState seed fillLevel =
--    case seedBankState of
--        Visible ->
--            div [ style [ transform [ translateY 0 ], transitionAll 2000 [] ] ]
--                [ SeedBank.icon seed fillLevel ]
--
--        Leaving ->
--            div
--                [ style [ transform [ translateY 100 ], transitionAll 2000 [] ] ]
--                [ div
--                    [ style
--                        [ animation "shake" 500 [ Animation.delay 1000, Animation.linear, Animation.count 6 ]
--                        , transformOrigin "bottom"
--                        ]
--                    ]
--                    [ SeedBank.icon seed fillLevel ]
--                ]
--
--        Blooming ->
--            div
--                [ style [ transform [ translateY 100 ], transitionAll 2000 [] ] ]
--                [ div
--                    [ style [ animation "bulge-fade" 500 [] ] ]
--                    [ SeedBank.icon seed fillLevel
--                    ]
--                ]
--
--
--resourceVisibility : ResourceBank -> Style
--resourceVisibility resourceState =
--    showIf (resourceState == Waiting || resourceState == Filling)
--
--
--renderResource : ResourceBank -> Progress -> Tile -> Html msg
--renderResource resourceState progress tileType =
--    let
--        fillLevel =
--            Progress.percentComplete Worlds.all tileType progress
--                |> Maybe.withDefault 0
--    in
--    case tileType of
--        Rain ->
--            div [ style [ width 40 ], class "dib ph1 mh4" ]
--                [ renderResourceFill resourceState progress tileType
--                , RainBank.icon fillLevel
--                ]
--
--        Sun ->
--            div [ style [ width 40 ], class "dib mh4" ]
--                [ renderResourceFill resourceState progress tileType
--                , SunBank.icon fillLevel
--                ]
--
--        Seed seed ->
--            div [ style [ width 40 ], class "dib ph1 mh4" ]
--                [ renderResourceFill resourceState progress tileType
--                , SeedBank.icon seed fillLevel
--                ]
--
--        _ ->
--            span [] []
--
--
--renderResourceFill : ResourceBank -> Progress -> Tile -> Html msg
--renderResourceFill resourceState progress tileType =
--    let
--        fill =
--            renderFill resourceState tileType progress
--    in
--    case tileType of
--        Rain ->
--            div [ style [ height 50 ] ]
--                [ div [ style [ width 13 ], class "center" ] [ RainBank.full ]
--                , fill (div [ class "relative" ] <| List.map (weatherDrop Color.rainBlue) <| List.range 1 50)
--                ]
--
--        Sun ->
--            div [ style [ height 50 ] ]
--                [ div [ style [ width 18 ], class "center" ] [ SunBank.full ]
--                , fill (div [ class "relative" ] <| List.map (weatherDrop Color.gold) <| List.range 4 54)
--                ]
--
--        Seed seed ->
--            div [ style [ height 50 ] ]
--                [ div [ style [ width 12 ], class "center" ] [ Seed.view seed ]
--                , fill (div [ class "relative", style [ transform [ translateY -10 ] ] ] <| List.map (seedDrop seed) <| List.range 7 57)
--                ]
--
--        _ ->
--            span [] []
--
--
--renderFill : ResourceBank -> Tile -> Progress -> Html msg -> Html msg
--renderFill resourceState tileType progess element =
--    if resourceState == Filling && pointsFromPreviousLevel tileType progess > 0 then
--        element
--
--    else
--        span [] []
--
--
--pointsFromPreviousLevel : Tile -> Progress -> Int
--pointsFromPreviousLevel tileType progress =
--    Progress.pointsFromPreviousLevel Worlds.all tileType progress
--        |> Maybe.withDefault 0
--
--
--seedDrop : Seed -> Int -> Html msg
--seedDrop seed n =
--    div
--        [ style
--            [ transform
--                [ translateX
--                    (Sine.wave
--                        { left = -5
--                        , center = 0
--                        , right = 5
--                        }
--                        (n - 1)
--                    )
--                ]
--            ]
--        ]
--        [ div
--            [ style
--                [ width 5
--                , height 8
--                , opacity 0
--                , animation "fade-slide-down" 150 [ Animation.delay (n * dropDelay n), linear ]
--                ]
--            , class "absolute top-0 left-0 right-0 center"
--            ]
--            [ Seed.view seed ]
--        ]
--
--
--weatherDrop : String -> Int -> Html msg
--weatherDrop bgColor n =
--    div
--        [ style [ transform [ translateX <| Sine.wave { left = -5, center = 0, right = 5 } (n - 1) ] ] ]
--        [ div
--            [ style
--                [ width 6
--                , height 6
--                , background bgColor
--                , opacity 0
--                , animation "fade-slide-down" 150 [ Animation.delay (n * dropDelay n), linear ]
--                ]
--            , class "br-100 absolute left-0 right-0 center"
--            ]
--            []
--        ]
--
--
--dropDelay : Int -> Int
--dropDelay n =
--    if modBy 3 n == 0 then
--        30
--
--    else if modBy 3 n == 1 then
--        60
--
--    else
--        90
