module Utils.Update exposing
    ( andThenWithCmds
    , updateModel
    , updateWith
    , withCmd
    )


updateWith : (subMsg -> msg) -> (subModel -> model) -> ( subModel, Cmd subMsg ) -> ( model, Cmd msg )
updateWith msgF modelF ( subModel, subCmd ) =
    ( modelF subModel
    , Cmd.map msgF subCmd
    )


updateModel : (model -> model) -> ( model, Cmd msg ) -> ( model, Cmd msg )
updateModel =
    Tuple.mapFirst


withCmd : Cmd msg -> ( model, Cmd msg ) -> ( model, Cmd msg )
withCmd cmd2 ( model, cmd ) =
    ( model, Cmd.batch [ cmd, cmd2 ] )


andThenWithCmds : List (model -> Cmd msg) -> model -> ( model, Cmd msg )
andThenWithCmds toCmds model =
    ( model
    , Cmd.batch <| List.map (\f -> f model) toCmds
    )
