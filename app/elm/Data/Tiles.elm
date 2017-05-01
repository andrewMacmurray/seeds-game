module Data.Tiles exposing (..)

import Model exposing (..)


evenTiles : Int -> Tile
evenTiles n =
    if n > 90 then
        Seed
    else if n > 30 then
        SeedPod
    else if n > 20 then
        Rain
    else
        Sun


tileColorMap : Tile -> String
tileColorMap tile =
    case tile of
        Rain ->
            "bg-light-blue"

        Sun ->
            "bg-gold"

        SeedPod ->
            "bg-seed-pod"

        Seed ->
            "bg-seed"

        Blank ->
            ""


tilePaddingMap : Tile -> String
tilePaddingMap tile =
    case tile of
        Rain ->
            "9px"

        Sun ->
            "9px"

        SeedPod ->
            "13px"

        Seed ->
            "17px"

        Blank ->
            ""
