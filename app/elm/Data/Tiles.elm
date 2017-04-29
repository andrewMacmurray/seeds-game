module Data.Tiles exposing (..)

import Model exposing (..)


evenTiles : Int -> Tile
evenTiles n =
    if n > 80 then
        Seed
    else if n > 20 then
        SeedPod
    else if n > 10 then
        Rain
    else
        Sun


tileToCssClass : Tile -> String
tileToCssClass tile =
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
            "15px"

        Blank ->
            ""
