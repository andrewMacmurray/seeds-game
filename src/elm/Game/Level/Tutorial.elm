module Game.Level.Tutorial exposing
    ( Highlight(..)
    , Steps
    , Tutorial(..)
    , autoStep
    , hideStep
    , highlightMultiple
    , horizontalTiles
    , isAutoStep
    , isInProgress
    , nextStep
    , noHighlight
    , none
    , remainingMoves
    , seedBank
    , showStep
    , step
    , stepConfig
    , tutorial
    , verticalTiles
    )

import Game.Board.Coord exposing (Coord)


type Tutorial
    = InProgress Steps
    | Complete


type alias Steps =
    { current : Step
    , remaining : List Step
    , visible : Bool
    }


type Step
    = AutoHide Step_
    | WaitForUserAction Step_


type alias Step_ =
    { text : String
    , highlight : Highlight
    }


type Highlight
    = HorizontalTiles TilesHighlight
    | VerticalTiles TilesHighlight
    | Multiple (List Highlight)
    | RemainingMoves
    | SeedBank
    | NoHighlight


type alias TilesHighlight =
    { from : Coord
    , length : Int
    }



-- Steps


tutorial : Step -> List Step -> Tutorial
tutorial step_ steps_ =
    InProgress
        { current = step_
        , remaining = steps_
        , visible = False
        }


step : String -> Highlight -> Step
step text_ =
    WaitForUserAction << Step_ text_


autoStep : String -> Highlight -> Step
autoStep text_ =
    AutoHide << Step_ text_


stepConfig : Step -> Step_
stepConfig step_ =
    case step_ of
        AutoHide config ->
            config

        WaitForUserAction config ->
            config


showStep : Tutorial -> Tutorial
showStep tutorial_ =
    case tutorial_ of
        InProgress config ->
            InProgress { config | visible = True }

        Complete ->
            Complete


hideStep : Tutorial -> Tutorial
hideStep tutorial_ =
    case tutorial_ of
        InProgress config ->
            InProgress { config | visible = False }

        Complete ->
            Complete


nextStep : Tutorial -> Tutorial
nextStep tutorial_ =
    case tutorial_ of
        InProgress config ->
            toNextStep config

        Complete ->
            Complete


toNextStep : Steps -> Tutorial
toNextStep config =
    case List.head config.remaining of
        Just step_ ->
            InProgress
                { config
                    | current = step_
                    , remaining = List.drop 1 config.remaining
                    , visible = True
                }

        Nothing ->
            Complete


isInProgress : Tutorial -> Bool
isInProgress tutorial_ =
    case tutorial_ of
        InProgress _ ->
            True

        Complete ->
            False


isAutoStep : Tutorial -> Bool
isAutoStep tutorial_ =
    case tutorial_ of
        InProgress config ->
            case config.current of
                AutoHide _ ->
                    True

                WaitForUserAction _ ->
                    False

        Complete ->
            False


none : Tutorial
none =
    Complete



-- Highlight


horizontalTiles : TilesHighlight -> Highlight
horizontalTiles =
    HorizontalTiles


verticalTiles : TilesHighlight -> Highlight
verticalTiles =
    VerticalTiles


remainingMoves : Highlight
remainingMoves =
    RemainingMoves


seedBank : Highlight
seedBank =
    SeedBank


noHighlight : Highlight
noHighlight =
    NoHighlight


highlightMultiple : List Highlight -> Highlight
highlightMultiple =
    Multiple
