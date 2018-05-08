module Data.InfoWindow
    exposing
        ( InfoWindow
        , hidden
        , isHidden
        , isLeaving
        , isVisible
        , leave
        , map
        , show
        , val
        )

import Data.Visibility exposing (..)


type InfoWindow a
    = Full Visibility a
    | Empty Visibility


show : a -> InfoWindow a
show a =
    Full Visible a


leave : InfoWindow a -> InfoWindow a
leave info =
    case info of
        Full _ a ->
            Full Leaving a

        _ ->
            info


hidden : InfoWindow a
hidden =
    Empty Hidden


val : InfoWindow a -> Maybe a
val info =
    case info of
        Full _ a ->
            Just a

        _ ->
            Nothing


map : (a -> a) -> InfoWindow a -> InfoWindow a
map f info =
    case info of
        Full v a ->
            Full v <| f a

        info ->
            info


isVisible : InfoWindow a -> Bool
isVisible info =
    case info of
        Full Visible _ ->
            True

        _ ->
            False


isLeaving : InfoWindow a -> Bool
isLeaving info =
    case info of
        Full Leaving _ ->
            True

        _ ->
            False


isHidden : InfoWindow a -> Bool
isHidden info =
    case info of
        Empty Hidden ->
            True

        _ ->
            False
