module Scene.Garden exposing
    ( Model
    , Msg
    , getContext
    , init
    , menuOptions
    , update
    , updateContext
    , view
    )

import Browser.Dom as Dom
import Config.Level as Level exposing (WorldConfig)
import Config.World as Worlds
import Context exposing (Context)
import Css.Animation as Animation
import Css.Color as Color exposing (Color)
import Css.Style exposing (..)
import Css.Transition as Transition
import Exit exposing (continue, exit)
import Html exposing (Html, button, div, p, span, text)
import Html.Attributes exposing (class, id)
import Html.Events exposing (onClick)
import Html.Keyed as Keyed
import Level.Progress as Progress exposing (Progress)
import Scene.Summary.Chrysanthemum as Chrysanthemum
import Scene.Summary.Cornflower as Cornflower
import Scene.Summary.Sunflower as Sunflower
import Seed exposing (Seed(..))
import Svg exposing (Svg)
import Task exposing (Task)
import Utils.Delay exposing (after)
import View.Flower as Flower
import View.Icon.Cross exposing (cross)
import View.Icon.Sprite.Bee as Bee
import View.Icon.Sprite.Butterfly as Butterfly
import View.Menu as Menu
import View.Seed as Seed
import View.Seed.Mono exposing (greyedOutSeed)
import Window exposing (Window)



-- Model


type alias Model =
    { context : Context
    , selectedFlower : Seed
    , flowerVisibility : FlowerVisibility
    }


type Msg
    = ScrollToCurrentCompletedWorld
    | WorldScrolledToView (Result Dom.Error ())
    | SelectFlower Seed
    | ShowFlower
    | HideFlower
    | ClearFlower
    | ExitToHub


type FlowerVisibility
    = Hidden
    | Entering
    | Leaving
    | Visible



-- Context


getContext : Model -> Context
getContext model =
    model.context


updateContext : (Context -> Context) -> Model -> Model
updateContext f model =
    { model | context = f model.context }


menuOptions : List (Menu.Option Msg)
menuOptions =
    [ Menu.option ExitToHub "Levels"
    ]



-- Init


init : Context -> ( Model, Cmd Msg )
init context =
    ( initialState context, after 500 ScrollToCurrentCompletedWorld )


initialState : Context -> Model
initialState context =
    { context = context
    , selectedFlower = Sunflower
    , flowerVisibility = Hidden
    }



-- Update


update : Msg -> Model -> Exit.Status ( Model, Cmd Msg )
update msg model =
    case msg of
        ScrollToCurrentCompletedWorld ->
            continue model [ scrollToCurrentCompletedWorld model.context.progress ]

        WorldScrolledToView _ ->
            continue model []

        SelectFlower seed ->
            continue { model | selectedFlower = seed, flowerVisibility = Entering } [ after 100 ShowFlower ]

        ShowFlower ->
            continue { model | flowerVisibility = Visible } []

        HideFlower ->
            continue { model | flowerVisibility = Leaving } [ after 1000 ClearFlower ]

        ClearFlower ->
            continue { model | flowerVisibility = Hidden } []

        ExitToHub ->
            exit model


scrollToCurrentCompletedWorld : Progress -> Cmd Msg
scrollToCurrentCompletedWorld progress =
    progress
        |> (currentCompletedWorldSeedType >> Seed.name)
        |> Dom.getElement
        |> Task.andThen scrollWorldToView
        |> Task.attempt WorldScrolledToView


scrollWorldToView : Dom.Element -> Task Dom.Error ()
scrollWorldToView { element, viewport } =
    let
        yOffset =
            element.y - viewport.height / 2 + element.height / 2
    in
    Dom.setViewportOf "flowers" 0 yOffset


currentCompletedWorldSeedType : Progress -> Seed
currentCompletedWorldSeedType progress =
    Worlds.list
        |> List.filter (\( _, keys ) -> worldComplete progress keys)
        |> List.reverse
        |> List.head
        |> Maybe.map (Tuple.first >> .seed)
        |> Maybe.withDefault Sunflower


worldComplete : Progress -> List Level.Id -> Bool
worldComplete progress levelKeys =
    levelKeys
        |> List.reverse
        |> List.head
        |> Maybe.map (\l -> Level.completed (Progress.reachedLevel progress) l)
        |> Maybe.withDefault False



-- View


view : Model -> Html Msg
view model =
    div [ class "w-100 z-1" ]
        [ initialOverlay model.context.window
        , div [ class "z-9 absolute top-0" ] [ renderSelectedFlower model ]
        , div
            [ id "flowers"
            , style [ height <| toFloat model.context.window.height ]
            , class "w-100 fixed overflow-y-scroll momentum-scroll z-2"
            ]
            [ div
                [ style [ marginTop 50, marginBottom 125 ]
                , class "flex flex-column items-center overflow-hidden"
                ]
                (allFlowers model.context.progress)
            ]
        , backToLevelsButton
        ]


initialOverlay : Window -> Html msg
initialOverlay window =
    div
        [ style
            [ background Color.lightYellow
            , height <| toFloat window.height
            , Animation.animation "fade-out" 1500 [ Animation.linear, Animation.delay 3000 ]
            ]
        , class "w-100 ttu tracked-ultra f3 z-7 fixed flex items-center justify-center touch-disabled"
        ]
        [ p
            [ style
                [ color Color.darkYellow
                , opacity 0
                , marginBottom 80
                , Animation.animation "fade-in" 1000 [ Animation.linear, Animation.delay 500 ]
                ]
            ]
            [ text "Garden" ]
        ]


backToLevelsButton : Html Msg
backToLevelsButton =
    div [ style [ bottom 40 ], class "fixed tc left-0 right-0 z-5 center" ]
        [ button
            [ style
                [ color Color.white
                , backgroundColor Color.darkBrown
                , paddingHorizontal 20
                , paddingVertical 10
                , borderNone
                ]
            , onClick ExitToHub
            , class "pointer br4 f7 outline-0 tracked-mega"
            ]
            [ text "BACK TO LEVELS" ]
        ]


allFlowers : Progress -> List (Html Msg)
allFlowers progress =
    Worlds.list
        |> List.reverse
        |> List.map (worldFlowers progress)


worldFlowers : Progress -> ( WorldConfig, List Level.Id ) -> Html Msg
worldFlowers progress ( { seed }, levelKeys ) =
    if worldComplete progress levelKeys then
        div
            [ id <| Seed.name seed
            , style
                [ marginTop 50
                , marginBottom 50
                ]
            , class "relative pointer"
            , onClick <| SelectFlower seed
            ]
            [ flowers seed
            , seeds seed
            , flowerName seed
            ]

    else
        div
            [ id <| Seed.name seed
            , style [ marginTop 75, marginBottom 75 ]
            ]
            [ unfinishedWorldSeeds
            , p
                [ style [ color Color.lightGray ]
                , class "f6 tc"
                ]
                [ text "..." ]
            ]


unfinishedWorldSeeds : Html msg
unfinishedWorldSeeds =
    div [ class "flex items-end justify-center" ]
        [ sized 20 greyedOutSeed
        , sized 30 greyedOutSeed
        , sized 20 greyedOutSeed
        ]


flowerName : Seed -> Html msg
flowerName seed =
    p [ style [ color Color.darkYellow ], class "tc ttu tracked-ultra" ]
        [ text <| Seed.name seed ]


seeds : Seed -> Html msg
seeds seed =
    div [ style [ marginTop -20, marginBottom 30 ], class "flex items-end justify-center" ]
        [ renderSeed 20 seed
        , renderSeed 30 seed
        , renderSeed 20 seed
        ]


renderSeed : Float -> Seed -> Html msg
renderSeed size =
    sized size << Seed.view


flowers : Seed -> Html msg
flowers seed =
    let
        spacing =
            flowerSpacing seed
    in
    div [ class "flex items-end justify-center relative" ]
        [ div [ style [ marginRight spacing.offsetX ] ] [ flower spacing.small seed ]
        , div [ style [ marginBottom spacing.offsetY ], class "relative" ] [ flower spacing.large seed ]
        , div [ style [ marginLeft spacing.offsetX ], class "relative" ] [ flower spacing.small seed ]
        , sprites seed
        ]


flower : Float -> Seed -> Html msg
flower size =
    sized size << Flower.view


sized : Float -> Html msg -> Html msg
sized size element =
    div [ style [ width size, height size ] ] [ element ]


sprites : Seed -> Html msg
sprites seed =
    case seed of
        Sunflower ->
            div [ class "absolute", style [ top 0, left 0 ] ]
                [ div [ style [ left 70, top 100, right 0 ], class "absolute" ] [ Butterfly.resting 0 ]
                , div [ style [ left 120, top 30, right 0 ], class "absolute" ] [ Butterfly.resting 0 ]
                , div [ style [ left 150, top 120, right 0, width 30, height 30 ], class "absolute" ] [ Butterfly.resting 0.5 ]
                ]

        Chrysanthemum ->
            div [ class "absolute", style [ top -160, left 0 ] ]
                [ Bee.animate
                    [ ( 0, div [ style [ left 30, top 100, right 0, opacity 0 ], class "absolute" ] [ Bee.bee ] )
                    , ( 0.5, div [ style [ left 0, top 80, right 0, opacity 0 ], class "absolute" ] [ Bee.bee ] )
                    , ( 0.7, div [ style [ left 60, top 60, right 0, opacity 0 ], class "absolute" ] [ Bee.bee ] )
                    , ( 1.3, div [ style [ left -70, top 125, right 0, opacity 0 ], class "absolute" ] [ Bee.bee ] )
                    , ( 1.6, div [ style [ left 130, top 135, right 0, opacity 0 ], class "absolute" ] [ Bee.bee ] )
                    ]
                ]

        _ ->
            span [] []



-- Selected Flower


type alias SelectedFlower msg =
    { hidden : Svg msg
    , visible : Svg msg
    , background : Color
    , description : String
    }


renderSelectedFlower : Model -> Html Msg
renderSelectedFlower model =
    let
        window =
            model.context.window

        flowerLayer =
            getFlowerLayer model.selectedFlower window

        visibility =
            model.flowerVisibility
    in
    case visibility of
        Entering ->
            Keyed.node "div"
                []
                [ ( "flowers", flowerLayer.hidden )
                , ( "backdrop", renderFlowerBackdrop window flowerLayer visibility )
                ]

        Visible ->
            Keyed.node "div"
                [ style
                    [ windowDimensions window
                    ]
                , class "relative flex items-center justify-center"
                ]
                [ ( "clear"
                  , div
                        [ onClick HideFlower
                        , style [ width 20, height 20, opacity 0, Animation.animation "fade-in" 500 [ Animation.delay 500 ] ]
                        , class "absolute top-1 right-1 z-7 pointer"
                        ]
                        [ cross ]
                  )
                , ( "flowers", flowerLayer.visible )
                , ( "text", renderFlowerLayerText flowerLayer )
                , ( "backdrop", renderFlowerBackdrop window flowerLayer visibility )
                ]

        Leaving ->
            Keyed.node "div"
                [ style [ Animation.animation "fade-out" 800 [ Animation.linear ] ]
                , class "touch-disabled"
                ]
                [ ( "flowers", flowerLayer.visible )
                , ( "backdrop", renderFlowerBackdrop window flowerLayer visibility )
                ]

        Hidden ->
            span [] []


renderFlowerLayerText : SelectedFlower msg -> Html msg
renderFlowerLayerText flowerLayer =
    p
        [ style
            [ color Color.white
            , lineHeight 2
            , marginTop 150
            , maxWidth 350
            , paddingHorizontal 10
            , opacity 0
            , Animation.animation "fade-in" 1000 [ Animation.delay 1500 ]
            ]
        , class "f6 tracked absolute z-7"
        ]
        [ text flowerLayer.description ]


renderFlowerBackdrop : Window -> SelectedFlower msg -> FlowerVisibility -> Html msg
renderFlowerBackdrop window flowerLayer visibility =
    case visibility of
        Entering ->
            div
                [ style
                    [ windowDimensions window
                    , opacity 0
                    , Transition.transition "opacity" 1000 [ Transition.linear, Transition.delay 500 ]
                    , backgroundColor flowerLayer.background
                    ]
                ]
                []

        _ ->
            div
                [ style
                    [ backgroundColor flowerLayer.background
                    , windowDimensions window
                    , opacity 1
                    , Transition.transition "opacity" 1000 [ Transition.linear, Transition.delay 500 ]
                    ]
                ]
                []


getFlowerLayer : Seed -> Window -> SelectedFlower msg
getFlowerLayer seed window =
    let
        description =
            flowerDescription seed
    in
    case seed of
        Sunflower ->
            { hidden = Sunflower.hidden window
            , visible = Sunflower.visible window
            , background = Sunflower.background
            , description = description
            }

        Chrysanthemum ->
            { hidden = Chrysanthemum.hidden window
            , visible = Chrysanthemum.visible window
            , background = Chrysanthemum.background
            , description = description
            }

        Cornflower ->
            { hidden = Cornflower.hidden window
            , visible = Cornflower.visible window
            , background = Cornflower.background
            , description = description
            }

        _ ->
            { hidden = Sunflower.hidden window
            , visible = Sunflower.visible window
            , background = Sunflower.background
            , description = description
            }



-- Config


type alias FlowerSpacing =
    { large : Float
    , small : Float
    , offsetX : Float
    , offsetY : Float
    }


flowerSpacing : Seed -> FlowerSpacing
flowerSpacing seed =
    case seed of
        Sunflower ->
            { large = 150
            , small = 80
            , offsetX = -30
            , offsetY = 20
            }

        Chrysanthemum ->
            { large = 120
            , small = 80
            , offsetX = 0
            , offsetY = 30
            }

        Cornflower ->
            { large = 170
            , small = 100
            , offsetX = -45
            , offsetY = 20
            }

        _ ->
            { large = 150
            , small = 80
            , offsetX = 30
            , offsetY = 20
            }


flowerDescription : Seed -> String
flowerDescription seed =
    case seed of
        Sunflower ->
            "Sunflowers are native to North America but bloom across the world. During growth their bright yellow flowers turn to face the sun. Their seeds are an important food source for both humans and animals."

        Chrysanthemum ->
            "Chrysanthemums are native to Asia and Northeastern Europe, with the largest variety in China. They bloom early in Autumn, in many different colours and shapes. The Ancient Chinese used Chrysanthemum roots in pain relief medicine."

        Cornflower ->
            "Cornflowers are a wildflower native to Europe. In the past their bright blue heads could be seen amongst fields of corn. They are now endangered in their natural habitat from Agricultural intensification."

        _ ->
            ""
