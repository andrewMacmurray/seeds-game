module Return exposing
    ( Return
    , map
    , pipe
    )


type alias Return msg model =
    ( model, Cmd msg )


map : (subMsg -> msg) -> (subModel -> model) -> Return subMsg subModel -> Return msg model
map msgF modelF ( subModel, subCmd ) =
    ( modelF subModel
    , Cmd.map msgF subCmd
    )


pipe : model -> List (model -> Return msg model) -> Return msg model
pipe model =
    List.foldl andThen ( model, Cmd.none )


andThen : (model -> Return msg model) -> Return msg model -> Return msg model
andThen update ( model1, cmd1 ) =
    let
        ( model2, cmd2 ) =
            update model1
    in
    ( model2
    , Cmd.batch [ cmd1, cmd2 ]
    )
