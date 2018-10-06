module Views.Intro.DyingLandscape exposing (dyingLandscape)

import Data.Visibility exposing (..)
import Css.Style as Style exposing (Style, opacity, svgStyle, svgStyles)
import Css.Timing exposing (..)
import Css.Transform exposing (translateY)
import Css.Transition exposing (transitionStyle)
import Scenes.Intro.Types exposing (..)
import Svg exposing (Attribute, Svg)
import Svg.Attributes exposing (..)


dyingLandscape : Environment -> Visibility -> Svg msg
dyingLandscape env vis =
    Svg.svg [ viewBox "0 -30 1023 448", class "absolute z-1 bottom-0", preserveAspectRatio "none" ]
        [ Svg.g [ fill "none", fillRule "evenodd" ]
            [ Svg.g [ layerOffsetStyle 448 0 vis ]
                [ hill1 env
                , hill3 env
                , firrTree 300 env
                ]
            , Svg.g [ layerOffsetStyle 330 500 vis ]
                [ pine 800
                    env
                    ( "M588.2 344.1h6.7v33.8h-6.7z"
                    , "M591.6 303.3s14.8 20.4 14.8 32.9c0 8.2-6.6 14.8-14.8 14.8v-47.6z"
                    , "M576.8 336.2c0-12.2 13.9-31.6 14.7-32.8V351c-8.1 0-14.7-6.6-14.7-14.8z"
                    )
                , pine 1200
                    env
                    ( "M865.2 183.1h6.7v33.8h-6.7z"
                    , "M868.6 142.3s14.8 20.4 14.8 32.9c0 8.2-6.6 14.8-14.8 14.8v-47.6z"
                    , "M853.8 175.2c0-12.2 13.9-31.6 14.7-32.8V190c-8.1 0-14.7-6.6-14.7-14.8z"
                    )
                , pine 300
                    env
                    ( "M901.2 165.1h6.7v33.8h-6.7z"
                    , "M904.6 124.3s14.8 20.4 14.8 32.9c0 8.2-6.6 14.8-14.8 14.8v-47.6z"
                    , "M889.8 157.2c0-12.2 13.9-31.6 14.7-32.8V172c-8.1 0-14.7-6.6-14.7-14.8z"
                    )
                , hill4 env
                , hill2 env
                , circleTree 600 env
                ]
            , Svg.g [ layerOffsetStyle 200 1000 vis ]
                [ hill6 env
                , hill5 env
                ]
            ]
        ]


layerOffsetStyle : Float -> Float -> Visibility -> Attribute msg
layerOffsetStyle offset delay vis =
    case vis of
        Entering ->
            svgStyles
                [ transitionStyle
                    { duration = 3500
                    , property = "transform"
                    , timing = EaseOut
                    , delay = Just delay
                    }
                , Style.transform [ translateY 0 ]
                ]

        Hidden ->
            svgStyles
                [ transitionStyle
                    { duration = 1500
                    , property = "transform"
                    , timing = CubicBezier 0.8 -0.2 0.7 1.3
                    , delay = Just delay
                    }
                , Style.transform [ translateY offset ]
                ]

        Visible ->
            style "opacity: 1"

        Leaving ->
            svgStyles
                [ transitionStyle
                    { duration = 400
                    , property = "opacity"
                    , timing = Linear
                    , delay = Just delay
                    }
                , Style.opacity 0
                ]


hill1 : Environment -> Svg msg
hill1 =
    renderHill "M0 7l1188.8 699.5H0z" ( "#3D6132", "#898755" ) 0


hill2 : Environment -> Svg msg
hill2 =
    renderHill "M0 155l900.1 545.2H0z" ( "#518642", "#866942" ) 300


hill3 : Environment -> Svg msg
hill3 =
    renderHill "M1049.5-15L-209.9 702.8h1259.4z" ( "#4A6E40", "#7D7E7D" ) 600


hill4 : Environment -> Svg msg
hill4 =
    renderHill "M1052.7 105L28.5 701.6h1024.2z" ( "#5A9749", "#978A49" ) 900


hill5 : Environment -> Svg msg
hill5 =
    renderHill "M0 323l631.2 382.3H0z" ( "#87AF7B", "#484848" ) 1200


hill6 : Environment -> Svg msg
hill6 =
    renderHill "M1023.6 273L285 703.2h738.6z" ( "#87AF7B", "#372c1f" ) 1500


renderHill : String -> ( String, String ) -> Float -> Environment -> Svg msg
renderHill path ( aliveC, deadC ) delay env =
    let
        hill color =
            Svg.path [ d path, fill color, svgStyle <| transitionFill delay ] []
    in
    case env of
        Alive ->
            hill aliveC

        Dead ->
            hill deadC


type TeardropTree
    = Single
    | Multiple


firrTree : Float -> Environment -> Svg msg
firrTree delay env =
    let
        treeTop delayOffset =
            teardrop (delay + delayOffset) Single env
    in
    Svg.g []
        [ Svg.path [ d "M118.1 197.8h6.8v60.7h-6.8z", fill "#453321" ] []
        , Svg.path [ d "M96.7 179.2l4.8-4.8L125 198l-4.8 4.8z", fill "#453321" ] []
        , Svg.path [ d "M146.5 179.2l-4.9-4.8L118 198l4.8 4.8z", fill "#453321" ] []
        , treeTop 0
            ( "M121.5 164s9.7 13.5 9.7 21.7c0 5.4-4.3 9.7-9.7 9.7v-31.3z"
            , "M111.8 185.7c0-8 9.1-20.8 9.7-21.6v31.3a9.7 9.7 0 0 1-9.7-9.7z"
            )
        , treeTop 150
            ( "M106.7 157.9s9.7 13.4 9.7 21.6c0 5.4-4.4 9.7-9.7 9.7V158z"
            , "M97 179.5c0-8 9.1-20.8 9.7-21.6v31.3a9.7 9.7 0 0 1-9.7-9.7z"
            )
        , treeTop 300
            ( "M135.3 157.9s9.7 13.4 9.7 21.6c0 5.4-4.3 9.7-9.7 9.7V158z"
            , "M125.7 179.5c0-8 9-20.8 9.6-21.6v31.3a9.7 9.7 0 0 1-9.6-9.7z"
            )
        , treeTop 450
            ( "M94.4 150.7s9.7 13.4 9.7 21.6c0 5.4-4.3 9.7-9.7 9.7v-31.3z"
            , "M84.7 172.3c0-8 9.1-20.8 9.7-21.6V182a9.7 9.7 0 0 1-9.7-9.7z"
            )
        , treeTop 550
            ( "M121.5 146s9.7 13.4 9.7 21.6c0 5.4-4.3 9.8-9.7 9.8V146z"
            , "M111.8 167.6c0-8 9.1-20.7 9.7-21.5v31.3a9.7 9.7 0 0 1-9.7-9.8z"
            )
        , treeTop 650
            ( "M148.6 150.7s9.7 13.4 9.7 21.6c0 5.4-4.3 9.7-9.7 9.7v-31.3z"
            , "M139 172.3c0-8 9-20.8 9.6-21.6V182a9.7 9.7 0 0 1-9.6-9.7z"
            )
        ]


pine : Float -> Environment -> ( String, String, String ) -> Svg msg
pine delay env ( trunk, p1, p2 ) =
    Svg.g []
        [ Svg.path [ d trunk, fill "#6D4D2D" ] []
        , teardrop delay Single env ( p1, p2 )
        ]


transitionFill : Float -> Style
transitionFill delay =
    transitionStyle
        { property = "fill"
        , duration = 500
        , timing = Linear
        , delay = Just delay
        }


teardrop : Float -> TeardropTree -> Environment -> ( String, String ) -> Svg msg
teardrop delay treeType environment ( path1, path2 ) =
    let
        ( l, r ) =
            if environment == Alive && treeType == Single then
                singleTeardropTreeColors

            else if environment == Alive && treeType == Multiple then
                multipleTeardropTreeColors

            else
                deadTreeColors
    in
    Svg.g [ fillRule "nonzero" ]
        [ Svg.path [ d path1, fill l, svgStyle <| transitionFill delay ] []
        , Svg.path [ d path2, fill r, svgStyle <| transitionFill delay ] []
        ]


circleTree : Float -> Environment -> Svg msg
circleTree delay env =
    let
        ( l, r ) =
            case env of
                Alive ->
                    circleTreeColors

                Dead ->
                    deadTreeColors

        transitionStyle delayOffset =
            svgStyle <| transitionFill (delay + delayOffset)
    in
    Svg.g []
        [ Svg.path [ d "M266.3 337.4h6.2v35.5h-6.2z", fill "#6D4D2D" ] []
        , Svg.path [ d "M247.6 320.2l3.3-3.4 21.4 20.6-3.4 3.4z", fill "#6D4D2D" ] []
        , Svg.path [ d "M305.3 306.3L302 303l-36 34.5 3.4 3.4z", fill "#6D4D2D" ] []
        , Svg.path [ d "M253.6 283.6l3.4-3.5 35.8 34.6-3.3 3.5z", fill "#6D4D2D" ] []
        , Svg.path [ d "M303 284h-.5a12.5 12.5 0 1 0 .5 25v-25z", transitionStyle 0, fill l ] []
        , Svg.path [ d "M302 284h.5a12.5 12.5 0 1 1-.5 25v-25z", transitionStyle 0, fill r ] []
        , Svg.path [ d "M257 259h-.5a12.5 12.5 0 1 0 .5 25v-25z", transitionStyle 300, fill l ] []
        , Svg.path [ d "M256 259h.5a12.5 12.5 0 1 1-.5 25v-25z", transitionStyle 300, fill r ] []
        , Svg.path [ d "M251 297h-.5a12.5 12.5 0 1 0 .5 25v-25z", transitionStyle 600, fill l ] []
        , Svg.path [ d "M250 297h.5a12.5 12.5 0 1 1-.5 25v-25z", transitionStyle 600, fill r ] []
        ]


circleTreeColors : ( String, String )
circleTreeColors =
    ( "#32B559", "#4CE483" )


multipleTeardropTreeColors : ( String, String )
multipleTeardropTreeColors =
    ( "#95EDB3", "#24AC4B" )


singleTeardropTreeColors : ( String, String )
singleTeardropTreeColors =
    ( "#24AC4B", "#95EDB3" )


deadTreeColors : ( String, String )
deadTreeColors =
    ( "#C09E73", "#FFCD93" )
