module Utils.Update exposing
    ( updateModel
    , updateWith
    , withCmds
    )


updateWith : (subMsg -> msg) -> (subModel -> model) -> ( subModel, Cmd subMsg ) -> ( model, Cmd msg )
updateWith msgF modelF ( subModel, subCmd ) =
    ( modelF subModel
    , Cmd.map msgF subCmd
    )


updateModel : (model -> model) -> ( model, Cmd msg ) -> ( model, Cmd msg )
updateModel =
    Tuple.mapFirst


withCmds : List (Cmd msg) -> ( model, Cmd msg ) -> ( model, Cmd msg )
withCmds cmds ( model, cmd ) =
    ( model, Cmd.batch (cmd :: cmds) )
