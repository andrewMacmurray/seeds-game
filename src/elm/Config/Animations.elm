module Config.Animations exposing (internalAnimations)

import Css.Keyframes exposing (..)
import Html exposing (Html)


internalAnimations : Html msg
internalAnimations =
    embed
        [ { name = "fade-slide-down"
          , frames =
                let
                    toY =
                        30 / 100
                in
                map2 ( translateY, opacity )
                    [ ( 0, ( 0, 1 ) )
                    , ( 60, ( toY * 60, 1 ) )
                    , ( 100, ( toY * 100, 0 ) )
                    ]
          }
        , { name = "slide-down-scale-out"
          , frames =
                map3 ( translateY, scale, opacity )
                    [ ( 0, ( 0, 1, 1 ) )
                    , ( 50, ( 40, 1, 1 ) )
                    , ( 60, ( 40, 1.1, 1 ) )
                    , ( 100, ( 40, 0, 0 ) )
                    ]
          }
        , { name = "exit-down"
          , frames =
                map2 ( translateY, opacity )
                    [ ( 0, ( 0, 1 ) )
                    , ( 100, ( 300, 0 ) )
                    ]
          }
        , { name = "hover"
          , frames =
                map translateY
                    [ ( 0, 0 )
                    , ( 50, -5 )
                    , ( 100, 0 )
                    ]
          }
        , { name = "bulge-fade"
          , frames =
                map2 ( scale, opacity )
                    [ ( 0, ( 1, 1 ) )
                    , ( 100, ( 2.5, 0 ) )
                    ]
          }
        , { name = "bulge"
          , frames =
                map scale
                    [ ( 0, 0.5 )
                    , ( 50, 1.3 )
                    , ( 100, 1 )
                    ]
          }
        , { name = "bulge-elastic"
          , frames =
                map2 ( scale, opacity )
                    [ ( 0, ( 0, 0 ) )
                    , ( 50, ( 1.3, 0.4 ) )
                    , ( 75, ( 0.9, 0.7 ) )
                    , ( 100, ( 1, 1 ) )
                    ]
          }
        , { name = "bulge-elastic-big"
          , frames =
                map2 ( scale, opacity )
                    [ ( 0, ( 0.3, 0 ) )
                    , ( 20, ( 1.3, 1 ) )
                    , ( 40, ( 0.8, 1 ) )
                    , ( 60, ( 1.1, 1 ) )
                    , ( 80, ( 0.9, 1 ) )
                    , ( 100, ( 1, 1 ) )
                    ]
          }
        , { name = "bulge-small"
          , frames =
                map2 ( scale, opacity )
                    [ ( 0, ( 0, 0.5 ) )
                    , ( 50, ( 1, 1.1 ) )
                    , ( 100, ( 1, 1 ) )
                    ]
          }
        , { name = "fade-in"
          , frames =
                map opacity
                    [ ( 0, 0 )
                    , ( 100, 1 )
                    ]
          }
        , { name = "fade-out"
          , frames =
                map opacity
                    [ ( 0, 1 )
                    , ( 100, 0 )
                    ]
          }
        , { name = "heartbeat"
          , frames =
                map scale
                    [ ( 0, 1 )
                    , ( 50, 1.15 )
                    , ( 100, 1 )
                    ]
          }
        , { name = "heart-break-left"
          , frames =
                map2 ( translateX, rotateZ )
                    [ ( 0, ( 0, 0 ) )
                    , ( 100, ( -3, -2 ) )
                    ]
          }
        , { name = "heart-break-right"
          , frames =
                map2 ( translateX, rotateZ )
                    [ ( 0, ( 0, 0 ) )
                    , ( 100, ( 3, 2 ) )
                    ]
          }
        ]
