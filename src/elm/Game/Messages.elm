module Game.Messages exposing (pickFrom)

import Dict exposing (Dict)
import Utils.Dict as Dict



-- Random Message


type alias Context context =
    { context | successMessageIndex : Int }


type alias Messages =
    Dict Int Message


type alias Message =
    String



-- Pick


pickFrom : Message -> List Message -> Context context -> Message
pickFrom first rest context =
    toMessages first rest
        |> Dict.get (nextIndex first rest context)
        |> Maybe.withDefault first


nextIndex : Message -> List Message -> Context context -> Int
nextIndex first rest context =
    modBy (totalMessages first rest) context.successMessageIndex


totalMessages : Message -> List Message -> Int
totalMessages first =
    toMessages first >> Dict.size


toMessages : Message -> List Message -> Messages
toMessages first rest =
    Dict.indexedFrom 0 (first :: rest)
