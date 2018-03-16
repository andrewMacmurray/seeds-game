module Helpers.OutMsg exposing (..)

-- Convenience functions for adding a Maybe OutMsg to (Model, Cmd Msg)
-- Used to communicate with parent component -- don't abuse these!


returnWithOutMsg : (b -> d) -> (a -> msg) -> ( b, Cmd a, outMsg ) -> ( d, Cmd msg, outMsg )
returnWithOutMsg modelF msgF ( model, cmd, outMsg ) =
    ( modelF model, Cmd.map msgF cmd, outMsg )


noOutMsg : model -> List (Cmd msg) -> ( model, Cmd msg, Maybe outMsg )
noOutMsg model cmds =
    ( model, Cmd.batch cmds, Nothing )


withOutMsg : model -> List (Cmd msg) -> outMsg -> ( model, Cmd msg, Maybe outMsg )
withOutMsg model cmds outMsg =
    ( model, Cmd.batch cmds, Just outMsg )
