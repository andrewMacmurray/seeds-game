module Data.InfoWindow
    exposing
        ( InfoWindow(..)
        , toHiding
        )


type InfoWindow a
    = Visible a
    | Hiding a
    | Hidden


toHiding : InfoWindow a -> InfoWindow a
toHiding info =
    case info of
        Visible a ->
            Hiding a

        info ->
            info
