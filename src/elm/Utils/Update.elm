module Utils.Update exposing
    ( andCmd
    , andCmds
    , context
    , updateModel
    , updateWith
    , withContext
    )

-- Update


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



-- Context


context : { a | context : context } -> context
context =
    .context


withContext : (context -> context) -> { a | context : context } -> { a | context : context }
withContext f model =
    { model | context = f model.context }
