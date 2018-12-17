module Scenes.Garden exposing
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
import Context exposing (Context)
import Css.Animation as Animation
import Css.Color as Color exposing (rgb)
import Css.Style as Style exposing (..)
import Css.Transition as Transition
import Data.Board.Tile exposing (seedName)
import Data.Board.Types exposing (SeedType(..))
import Data.Levels as Levels exposing (WorldConfig)
import Data.Progress as Progress exposing (Progress)
import Data.Window exposing (Window)
import Exit exposing (continue, exit)
import Helpers.Delay exposing (after)
import Html exposing (Html, button, div, label, p, span, text)
import Html.Attributes exposing (class, id)
import Html.Events exposing (onClick)
import Html.Keyed as Keyed
import Scenes.Summary.Chrysanthemum as Chrysanthemum
import Scenes.Summary.Cornflower as Cornflower
import Scenes.Summary.Sunflower as Sunflower
import Task exposing (Task)
import Views.Flowers.All exposing (renderFlower)
import Views.Icons.Cross exposing (cross)
import Views.Menu as Menu
import Views.Seed.All exposing (renderSeed)
import Views.Seed.Mono exposing (greyedOutSeed)
import Worlds



-- Model


type alias Model =
    { context : Context
    , selectedFlower : SeedType
    , flowerVisibility : FlowerVisibility
    }


type Msg
    = ScrollToCurrentCompletedWorld
    | DomNoOp (Result Dom.Error ())
    | SelectFlower SeedType
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

        DomNoOp _ ->
            continue model []

        SelectFlower seedType ->
            continue { model | selectedFlower = seedType, flowerVisibility = Entering } [ after 100 ShowFlower ]

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
        |> (currentCompletedWorldSeedType >> seedName)
        |> Dom.getElement
        |> Task.andThen scrollWorldToView
        |> Task.attempt DomNoOp


scrollWorldToView : Dom.Element -> Task Dom.Error ()
scrollWorldToView { element, viewport } =
    let
        yOffset =
            element.y - viewport.height / 2 + element.height / 2
    in
    Dom.setViewportOf "flowers" 0 yOffset


currentCompletedWorldSeedType : Progress -> SeedType
currentCompletedWorldSeedType progress =
    Worlds.list
        |> List.filter (\( _, keys ) -> worldComplete progress keys)
        |> List.reverse
        |> List.head
        |> Maybe.map (Tuple.first >> .seedType)
        |> Maybe.withDefault Sunflower


worldComplete : Progress -> List Levels.Key -> Bool
worldComplete progress levelKeys =
    levelKeys
        |> List.reverse
        |> List.head
        |> Maybe.map (\l -> Levels.completed (Progress.reachedLevel progress) l)
        |> Maybe.withDefault False



-- View


view : Model -> Html Msg
view model =
    div [ class "w-100 z-1" ]
        [ initialOverlay model.context.window
        , div [ class "z-7 absolute top-0" ] [ renderSelectedFlower model ]
        , div
            [ id "flowers"
            , style [ height <| toFloat model.context.window.height ]
            , class "w-100 fixed overflow-y-scroll momentum-scroll z-2"
            ]
            [ div [ style [ marginTop 50, marginBottom 125 ], class "flex flex-column items-center" ] <| allFlowers model.context.progress
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
                , backgroundColor <| rgb 251 214 74
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


worldFlowers : Progress -> ( WorldConfig, List Levels.Key ) -> Html Msg
worldFlowers progress ( { seedType }, levelKeys ) =
    if worldComplete progress levelKeys then
        div
            [ id <| seedName seedType
            , style
                [ marginTop 50
                , marginBottom 50
                ]
            , class "relative pointer"
            , onClick <| SelectFlower seedType
            ]
            [ flowers seedType
            , seeds seedType
            , flowerName seedType
            ]

    else
        div
            [ id <| seedName seedType
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


flowerName : SeedType -> Html msg
flowerName seedType =
    p [ style [ color Color.darkYellow ], class "tc ttu tracked-ultra" ]
        [ text <| seedName seedType ]


seeds : SeedType -> Html msg
seeds seedType =
    div [ style [ marginTop -20, marginBottom 30 ], class "flex items-end justify-center" ]
        [ seed 20 seedType
        , seed 30 seedType
        , seed 20 seedType
        ]


seed : Float -> SeedType -> Html msg
seed size seedType =
    sized size <| renderSeed seedType


flowers : SeedType -> Html msg
flowers seedType =
    let
        spacing =
            flowerSpacing seedType
    in
    div [ class "flex items-end justify-center relative" ]
        [ div [ style [ marginRight spacing.offsetX ] ] [ flower spacing.small seedType ]
        , div [ style [ marginBottom spacing.offsetY ], class "relative" ] [ flower spacing.large seedType ]
        , div [ style [ marginLeft spacing.offsetX ], class "relative" ] [ flower spacing.small seedType ]
        ]


flower : Float -> SeedType -> Html msg
flower size seedType =
    sized size <| renderFlower seedType


sized : Float -> Html msg -> Html msg
sized size element =
    div [ style [ width size, height size ] ] [ element ]


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


getFlowerLayer seedType window =
    let
        description =
            flowerDescription seedType
    in
    case seedType of
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


flowerSpacing : SeedType -> FlowerSpacing
flowerSpacing seedType =
    case seedType of
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


flowerDescription : SeedType -> String
flowerDescription seedType =
    case seedType of
        Sunflower ->
            "Sunflowers are native to North America but bloom across the world. During growth their bright yellow flowers turn to face the sun. Their seeds are an important food source for both humans and animals."

        Chrysanthemum ->
            "Chrysanthemums are native to Aisa and northeastern Europe, with the largest variety in China. They bloom early in Autumn, in many different colours and shapes. The Ancient Chinese used Chrysanthemum roots in pain relief medicine."

        Cornflower ->
            "Cornflowers are a wildflower native to Europe. In the past their bright blue heads could be seen amongst fields of corn. They are now endangered in their natural habitat from Agricultural intensification."

        _ ->
            ""
