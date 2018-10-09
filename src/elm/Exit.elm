module Exit exposing
    ( Handler
    , Status
    , With
    , continue
    , exit
    , exitWith
    , handle
    )


type alias Status state =
    With () state


type With payload state
    = Continue state
    | Exit payload state


type alias Handler payload model msg subModel subMsg =
    { state : With payload ( subModel, Cmd subMsg )
    , onContinue : ( subModel, Cmd subMsg ) -> ( model, Cmd msg )
    , onExit : payload -> ( model, Cmd msg )
    }


continue : model -> List (Cmd msg) -> With payload ( model, Cmd msg )
continue model cmds =
    Continue
        ( model
        , Cmd.batch cmds
        )


exit : model -> List (Cmd msg) -> With () ( model, Cmd msg )
exit model cmds =
    Exit ()
        ( model
        , Cmd.batch cmds
        )


exitWith : payload -> model -> List (Cmd msg) -> With payload ( model, Cmd msg )
exitWith payload model cmds =
    Exit payload
        ( model
        , Cmd.batch cmds
        )


handle : Handler payload model msg subModel subMsg -> ( model, Cmd msg )
handle { state, onContinue, onExit } =
    case state of
        Continue s ->
            onContinue s

        Exit payload _ ->
            onExit payload
