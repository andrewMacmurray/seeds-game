module Exit exposing
    ( Handler
    , Status
    , WithPayload
    , continue
    , exit
    , exitWithPayload
    , handle
    )


type alias Status state =
    WithPayload () state


type WithPayload payload state
    = Continue state
    | Exit payload state


type alias Handler payload model msg subModel subMsg =
    { state : WithPayload payload ( subModel, Cmd subMsg )
    , onContinue : ( subModel, Cmd subMsg ) -> ( model, Cmd msg )
    , onExit : payload -> ( model, Cmd msg )
    }


continue : model -> List (Cmd msg) -> WithPayload payload ( model, Cmd msg )
continue model cmds =
    Continue
        ( model
        , Cmd.batch cmds
        )


exit : model -> List (Cmd msg) -> WithPayload () ( model, Cmd msg )
exit model cmds =
    Exit ()
        ( model
        , Cmd.batch cmds
        )


exitWithPayload : payload -> model -> List (Cmd msg) -> WithPayload payload ( model, Cmd msg )
exitWithPayload payload model cmds =
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
