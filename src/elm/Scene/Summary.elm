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
import Element.Animation as Animation
import Element.Background as Background
import Element.Icon.RainBank as RainBank
import Element.Icon.SeedBank as SeedBank
import Element.Icon.SunBank as SunBank
import Element.Layout as Layout
import Element.Palette as Palette
import Element.Scale as Scale
import Element.Seed as Seed
import Element.Text as Text
import Element.Transition as Transition
import Element.Weather as Weather
import Exit exposing (continue, exitWith)
import Game.Board.Tile as Tile exposing (Tile)
import Game.Config.World as Worlds
import Game.Level.Progress as Progress exposing (Progress)
import Html exposing (Html)
import Scene.Summary.Chrysanthemum as Chrysanthemum
import Scene.Summary.Cornflower as Cornflower
import Scene.Summary.Sunflower as Sunflower
import Seed exposing (Seed)
import Simple.Animation as Animation exposing (Animation)
import Simple.Animation.Property as P
import Utils.Animated as Animated
import Utils.Delay as Delay exposing (trigger)
import Utils.Element as Element
import Utils.Sine as Sine
import Window exposing (Window)



-- Model


type alias Model =
    { context : Context
    , worldText : WorldText
    , levelTextVisible : TextVisible
    , sequence : Sequence
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


type Sequence
    = Visible
    | ResourcesFilling
    | SeedShaking
    | FlowersBlooming
    | FadingOut


type WorldText
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
    , Delay.after 1500 IncrementProgress
      --, Cmd.none
    )


initialState : Context -> Model
initialState context =
    { context = context
    , worldText = First False
    , sequence = Visible
    , levelTextVisible = False
    }



-- Update


update : Msg -> Model -> Exit.With Destination ( Model, Cmd Msg )
update msg model =
    case msg of
        IncrementProgress ->
            continue (incrementProgress model) [ trigger CacheProgress ]

        CacheProgress ->
            continue model
                [ Progress.save model.context.progress
                , successSequence model
                ]

        ShowLevelSuccess ->
            continue { model | levelTextVisible = True } []

        BeginSeedBankTransformation ->
            continue { model | sequence = SeedShaking } []

        BloomWorldFlower ->
            continue { model | sequence = FlowersBlooming } []

        ShowFirstText ->
            continue { model | worldText = First True } []

        HideFirstText ->
            continue { model | worldText = First False } []

        ShowSecondText ->
            continue { model | worldText = Second True } []

        HiddenSecondText ->
            continue { model | worldText = Second False } []

        FadeOut ->
            continue { model | sequence = FadingOut } []

        ExitToHub ->
            exitWith ToHub model

        ExitToGarden ->
            exitWith ToGarden model


successSequence : Model -> Cmd Msg
successSequence { context } =
    if Progress.currentWorldComplete Worlds.all context.progress then
        Delay.sequence
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
        Delay.sequence
            [ ( 2000, ShowLevelSuccess )

            --, ( 2500, ExitToHub )
            ]


incrementProgress : Model -> Model
incrementProgress model =
    { model
        | sequence = ResourcesFilling
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
        , inFront (worldSummary model)
        , Transition.background 3000
        ]
        (resourceSummary model)



-- View Model


type alias ViewModel =
    { window : Window
    , sequence : Sequence
    , levelTextVisible : Bool
    , worldSummary : WorldSummary
    , resourcesVisible : Bool
    , mainResource : Resource
    , otherResources : List Resource
    }


type alias Resource =
    { icon : Icon
    , isFilling : Bool
    , fill : Percent
    }


type Icon
    = Rain
    | Sun
    | Seed Seed


type WorldSummary
    = WorldSummaryHidden
    | WorldSummaryVisible Seed


type alias Percent =
    Float


toViewModel : Model -> ViewModel
toViewModel model =
    { window = model.context.window
    , levelTextVisible = model.levelTextVisible
    , resourcesVisible = otherResourcesVisible model
    , worldSummary = toWorldSummary model
    , sequence = model.sequence
    , mainResource = toMainResource model
    , otherResources = toOtherResources model
    }


isFilling : Model -> Tile -> Bool
isFilling model tile =
    isFilling_ model && pointsGainedFor model tile > 0


otherResourcesVisible : Model -> Bool
otherResourcesVisible model =
    case model.sequence of
        Visible ->
            True

        ResourcesFilling ->
            True

        _ ->
            False


toWorldSummary : Model -> WorldSummary
toWorldSummary model =
    case model.sequence of
        FlowersBlooming ->
            WorldSummaryVisible (currentSeedType model)

        FadingOut ->
            WorldSummaryVisible (currentSeedType model)

        _ ->
            WorldSummaryHidden


pointsGainedFor : Model -> Tile -> Int
pointsGainedFor model tile =
    Progress.pointsFromPreviousLevel Worlds.all tile (getProgress model)


isFilling_ : Model -> Bool
isFilling_ model =
    case model.sequence of
        ResourcesFilling ->
            True

        _ ->
            False


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
    , isFilling = isFilling model tile
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
    case model.sequence of
        SeedShaking ->
            Palette.lightGold

        FlowersBlooming ->
            flowerBackground (currentSeedType model)

        FadingOut ->
            flowerBackground (currentSeedType model)

        _ ->
            Palette.background2_


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



-- Resource Summary


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



-- Main Resource


mainResource : ViewModel -> Element msg
mainResource model =
    mainResourceAnimation model
        [ centerX
        , Element.originPercent 50 75
        ]
        (viewResource
            { size = 100
            , dropperVisible = model.resourcesVisible
            , order = 0
            }
            model.mainResource
        )


mainResourceAnimation : ViewModel -> List (Attribute msg) -> Element msg -> Element msg
mainResourceAnimation model =
    case model.sequence of
        SeedShaking ->
            Animated.el leaveAndShake

        FlowersBlooming ->
            Animated.el expandFade

        _ ->
            el


leaveAndShake : Animation
leaveAndShake =
    Animation.steps
        { startAt = [ P.y 0 ]
        , options = []
        }
        (Animation.step 1000 [ P.y leavingOffset ] :: shakeSteps)


shakeSteps : List Animation.Step
shakeSteps =
    List.map shakeStep (List.range 0 60)


shakeStep : Int -> Animation.Step
shakeStep i =
    Animation.step 50
        [ P.y leavingOffset
        , P.x (shakeOffset i)
        ]


shakeOffset : Int -> number
shakeOffset i =
    if modBy 2 i == 0 then
        1

    else
        -1


expandFade : Animation
expandFade =
    Animation.fromTo
        { duration = 500
        , options = []
        }
        [ P.opacity 1, P.scale 1, P.y leavingOffset ]
        [ P.opacity 0, P.scale 5, P.y leavingOffset ]


leavingOffset : number
leavingOffset =
    75



-- Level End Text


levelEndText : ViewModel -> Element msg
levelEndText model =
    Text.text
        [ centerX
        , Transition.alpha 1000
        , Element.visibleIf model.levelTextVisible
        ]
        "We're one step closer..."



-- Other Resources


otherResources : ViewModel -> Element msg
otherResources model =
    row
        [ spacing Scale.large
        , Transition.alpha 1500
        , Element.visibleIf model.resourcesVisible
        , centerX
        ]
        (List.indexedMap otherResource model.otherResources)


otherResource : Int -> Resource -> Element msg
otherResource index =
    viewResource
        { size = 50
        , dropperVisible = True
        , order = index + 1
        }



-- Resource


type alias ResourceOptions =
    { size : Int
    , dropperVisible : Bool
    , order : Int
    }


viewResource : ResourceOptions -> Resource -> Element msg
viewResource options resource =
    column
        [ spacing Scale.large
        , behindContent (resourceDrops options resource)
        ]
        [ resourceDropper options resource
        , resourceBank options resource
        ]


resourceBank : ResourceOptions -> Resource -> Element msg
resourceBank options resource =
    Element.square options.size [ centerX ] (resourceBank_ options resource)


resourceDropper : ResourceOptions -> Resource -> Element msg
resourceDropper options resource =
    Element.square 20
        [ centerX
        , Transition.alpha 1000
        , Element.visibleIf options.dropperVisible
        ]
        (fullResource resource.icon)


fillDelay : ResourceOptions -> Int
fillDelay options =
    options.order * 75


resourceDrops : ResourceOptions -> Resource -> Element msg
resourceDrops options resource =
    List.range 0 50
        |> List.map (drop options resource)
        |> toDrops


drop : ResourceOptions -> Resource -> Int -> Element msg
drop options resource dropNumber =
    el
        [ offsetDrop dropNumber
        , Element.visibleIf resource.isFilling
        ]
        (Animated.el
            (fallDown resource options dropNumber)
            [ centerX ]
            (drop_ resource)
        )


drop_ : Resource -> Element msg
drop_ resource =
    case resource.icon of
        Sun ->
            Weather.sun
                { size = Weather.small
                , shade = Weather.bright
                }

        Rain ->
            Weather.rain Weather.small

        Seed seed ->
            Seed.view (Seed.size 10) seed


offsetDrop : Int -> Attr decorative msg
offsetDrop order =
    Sine.wave
        { left = moveLeft 2
        , center = moveLeft 0
        , right = moveRight 2
        }
        (order - 1)


toDrops : List (Element msg) -> Element msg
toDrops drops =
    column (List.map (behindContent << el [ centerX ]) drops ++ [ centerX ]) []


fallDown : Resource -> ResourceOptions -> Int -> Animation
fallDown resource options dropNumber =
    if resource.isFilling then
        fallDown_ options dropNumber

    else
        Animation.none


fallDown_ : ResourceOptions -> Int -> Animation
fallDown_ options dropNumber =
    Animation.frames
        { duration = 150
        , startAt = [ P.opacity 0, P.y 0 ]
        , options =
            [ Animation.linear
            , Animation.delay (fallDelay options dropNumber)
            ]
        }
        [ Animation.frame 10 [ P.y 5, P.opacity 1 ]
        , Animation.frame 50 [ P.y 25, P.opacity 1 ]
        , Animation.frame 100 [ P.y 50, P.opacity 0 ]
        ]


fallDelay : ResourceOptions -> Int -> Animation.Millis
fallDelay options dropNumber =
    fillDelay options + dropNumber * dropDelay dropNumber


dropDelay : Int -> Int
dropDelay n =
    if modBy 3 n == 0 then
        30

    else if modBy 3 n == 1 then
        60

    else
        90


resourceBank_ : ResourceOptions -> Resource -> Element msg
resourceBank_ options resource =
    case resource.icon of
        Sun ->
            SunBank.icon
                { percent = resource.fill
                , delay = fillDelay options
                }

        Rain ->
            RainBank.icon
                { percent = resource.fill
                , delay = fillDelay options
                }

        Seed seed ->
            SeedBank.icon
                { percent = resource.fill
                , delay = fillDelay options
                , seed = seed
                }


fullResource : Icon -> Element msg
fullResource icon =
    case icon of
        Sun ->
            html SunBank.full

        Rain ->
            html RainBank.full

        Seed seed ->
            Seed.view Seed.fill seed



-- World Summary


worldSummary : Model -> Element msg
worldSummary =
    toViewModel >> worldSummary_


worldSummary_ : ViewModel -> Element msg
worldSummary_ model =
    case model.worldSummary of
        WorldSummaryVisible seed ->
            viewWorldSummary seed model

        WorldSummaryHidden ->
            none


viewWorldSummary : Seed -> ViewModel -> Element msg
viewWorldSummary seed model =
    case seed of
        Seed.Chrysanthemum ->
            el
                [ width fill
                , height fill
                , inFront Chrysanthemum.flowers
                ]
                (html (Chrysanthemum.hills model.window))

        _ ->
            none



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
