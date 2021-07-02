module Scene.Summary exposing
    ( Destination(..)
    , Model
    , Msg
    , init
    , update
    , view
    )

import Context exposing (Context)
import Delay
import Element exposing (..)
import Element.Animation as Animation
import Element.Animations as Animations
import Element.Background as Background
import Element.Flower as Flower
import Element.Font as Font
import Element.Icon.RainBank as RainBank
import Element.Icon.SeedBank as SeedBank
import Element.Icon.SunBank as SunBank
import Element.Layout as Layout
import Element.Palette as Palette
import Element.Scale as Scale
import Element.Seed as Seed
import Element.Text as Text
import Element.Weather as Weather
import Exit exposing (continue, exitWith)
import Game.Board.Tile as Tile exposing (Tile)
import Game.Config.World as Worlds
import Game.Level.Progress as Progress exposing (Progress)
import Game.Messages as Messages
import Html exposing (Html)
import Scene.Summary.Chrysanthemum as Chrysanthemum
import Scene.Summary.Cornflower as Cornflower
import Scene.Summary.Sunflower as Sunflower
import Seed exposing (Seed)
import Simple.Animation as Animation exposing (Animation)
import Simple.Animation.Property as P
import Utils.Animated as Animated
import Utils.Element as Element
import Utils.Sine as Sine
import Utils.Transition as Transition
import Utils.Update as Update
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
            continue (incrementProgress model) [ Update.trigger CacheProgress ]

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
            , ( 3000, ShowFirstText )
            , ( 3000, HideFirstText )
            , ( 1000, ShowSecondText )
            , ( 3000, HiddenSecondText )
            , ( 2000, FadeOut )
            , ( 2500, ExitToGarden )
            ]

    else
        Delay.sequence
            [ ( 2000, ShowLevelSuccess )
            , ( 2500, ExitToHub )
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


view : Model -> Layout.Scene msg
view model =
    Layout.fadeIn
        [ Background.color (background model)
        , inFront (worldSummary model)
        , inFront (fadeOverlay model)
        , Transition.background 3000
        ]
        (resourceSummary model)



-- View Model


type alias ViewModel =
    { window : Window
    , sequence : Sequence
    , levelTextVisible : TextVisible
    , worldTextVisible : TextVisible
    , worldTextColor : Color
    , text : String
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
    , worldTextVisible = worldTextVisible model
    , worldTextColor = worldTextColor model
    , resourcesVisible = otherResourcesVisible model
    , text = successText model
    , worldSummary = toWorldSummary model
    , sequence = model.sequence
    , mainResource = toMainResource model
    , otherResources = toOtherResources model
    }


worldTextVisible : Model -> TextVisible
worldTextVisible model =
    case model.worldText of
        First visible ->
            visible

        Second visible ->
            visible


successText : Model -> String
successText model =
    case toWorldSummary model of
        WorldSummaryHidden ->
            levelSuccessText model.context

        WorldSummaryVisible seed ->
            worldSuccessText seed model


levelSuccessText : Context -> String
levelSuccessText =
    Messages.pickFrom "We're one step closer..."
        [ "More seeds for our new home..."
        , "A triumph for our seeds!"
        , "You're saving the world, seed by seed!"
        ]


worldSuccessText : Seed -> Model -> String
worldSuccessText seed model =
    case model.worldText of
        First _ ->
            "You saved the " ++ Seed.name seed ++ "!"

        Second _ ->
            "It will bloom again on our new world"


worldTextColor : Model -> Color
worldTextColor =
    currentSeedType >> Flower.textColor


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
flowerBackground =
    Flower.background



-- Fade Overlay


fadeOverlay : Model -> Element msg
fadeOverlay model =
    case model.sequence of
        FadingOut ->
            fadeOverlay_

        _ ->
            none


fadeOverlay_ : Element msg
fadeOverlay_ =
    Animated.el (Animations.fadeIn 1800 [ Animation.linear ])
        [ width fill
        , height fill
        , Background.color Palette.background1_
        ]
        none



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
    el [ centerX ]
        (viewResource
            { size = 100
            , dropperVisible = model.resourcesVisible
            , order = 0
            , animation = mainResourceAnimation model
            }
            model.mainResource
        )


mainResourceAnimation : ViewModel -> Maybe Animation
mainResourceAnimation model =
    case model.sequence of
        SeedShaking ->
            Just leaveAndShake

        FlowersBlooming ->
            Just expandFade

        _ ->
            Nothing


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
        { duration = 800
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
        model.text



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
        , animation = Nothing
        }



-- Resource


type alias ResourceOptions =
    { size : Int
    , dropperVisible : Bool
    , order : Int
    , animation : Maybe Animation
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
    Animated.maybe options.animation
        [ centerX
        , centerY
        , Element.originPercent 50 60
        ]
        (Element.square options.size
            [ centerX, centerY ]
            (resourceBank_ options resource)
        )


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
    column (centerX :: List.map toDrop drops) []


toDrop : Element msg -> Attribute msg
toDrop =
    behindContent << el [ centerX ]


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
            SeedBank.full seed



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
        Seed.Sunflower ->
            viewWorldSummary_
                { flowers = Sunflower.flowers
                , hills = Sunflower.hills model.window
                , model = model
                }

        Seed.Chrysanthemum ->
            viewWorldSummary_
                { flowers = Chrysanthemum.flowers
                , hills = Chrysanthemum.hills model.window
                , model = model
                }

        Seed.Cornflower ->
            viewWorldSummary_
                { flowers = Cornflower.flowers
                , hills = Cornflower.hills model.window
                , model = model
                }

        _ ->
            none


type alias WorldSummary_ msg =
    { flowers : Element msg
    , model : ViewModel
    , hills : Html msg
    }


viewWorldSummary_ : WorldSummary_ msg -> Element msg
viewWorldSummary_ options =
    el
        [ width fill
        , height fill
        , inFront (flowersWithText options.flowers options.model)
        ]
        (html options.hills)


flowersWithText : Element msg -> ViewModel -> Element msg
flowersWithText flowers model =
    column
        [ centerY
        , centerX
        , width fill
        , moveUp Scale.large
        , spacing Scale.medium
        ]
        [ flowers
        , worldText model
        ]


worldText : ViewModel -> Element msg
worldText model =
    paragraph [ Font.center, spacing Scale.medium ]
        [ Text.text
            [ Element.visibleIf model.worldTextVisible
            , Transition.alpha 1000
            , Text.color model.worldTextColor
            , Text.f4
            , Text.bold
            , centerX
            ]
            model.text
        ]
