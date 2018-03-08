module Helpers.OutMsg exposing (..)

-- Convenience functions for adding a Maybe OutMsg to (Model, Cmd Msg)
-- Used to communicate with parent component -- dont' abuse these!


(!!) : model -> List (Cmd msg) -> ( model, Cmd msg, Maybe outMsg )
(!!) model cmds =
    ( model, Cmd.batch cmds, Nothing )


(!!!) : model -> ( List (Cmd msg), outMsg ) -> ( model, Cmd msg, Maybe outMsg )
(!!!) model ( cmds, outMsg ) =
    ( model, Cmd.batch cmds, Just outMsg )
