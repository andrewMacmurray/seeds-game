module Utils.Update exposing
    ( andCmd
    , andCmds
    , updateModel
    , updateWith
    )


updateWith : (subMsg -> msg) -> (subModel -> model) -> ( subModel, Cmd subMsg ) -> ( model, Cmd msg )
updateWith msgF modelF ( subModel, subCmd ) =
    ( modelF subModel
    , Cmd.map msgF subCmd
    )


updateModel : (model -> model) -> ( model, Cmd msg ) -> ( model, Cmd msg )
updateModel =
    Tuple.mapFirst


andCmd : (model -> Cmd msg) -> model -> ( model, Cmd msg )
andCmd toCmd =
    andCmds [ toCmd ]


andCmds : List (model -> Cmd msg) -> model -> ( model, Cmd msg )
andCmds toCmds model =
    ( model
    , Cmd.batch (List.map (\f -> f model) toCmds)
    )
