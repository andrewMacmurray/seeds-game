module Helpers.OutMsg exposing (..)

-- Convenience functions for adding a Maybe OutMsg to (Model, Cmd Msg)
-- Used to communicate with parent component -- dont' abuse these!


returnWithOutMsg : (b -> d) -> (a -> msg) -> ( b, Cmd a, outMsg ) -> ( d, Cmd msg, outMsg )
returnWithOutMsg modelF msgF ( model, cmd, outMsg ) =
    ( modelF model, Cmd.map msgF cmd, outMsg )


(!!) : model -> List (Cmd msg) -> ( model, Cmd msg, Maybe outMsg )
(!!) model cmds =
    ( model, Cmd.batch cmds, Nothing )


(!!!) : model -> ( List (Cmd msg), outMsg ) -> ( model, Cmd msg, Maybe outMsg )
(!!!) model ( cmds, outMsg ) =
    ( model, Cmd.batch cmds, Just outMsg )
