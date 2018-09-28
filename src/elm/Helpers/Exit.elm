module Helpers.Exit exposing
    ( ExitMsg(..)
    , continue
    , exit
    , exitWith
    , loadScene
    , mapScene
    , onExit
    , onExitDo
    )

import Types exposing (HasScene, Scene, SceneState(..))


type ExitMsg a
    = Exit
    | Continue
    | ExitWith a


continue : model -> List (Cmd msg) -> ( model, Cmd msg, ExitMsg a )
continue model cmds =
    ( model, Cmd.batch cmds, Continue )


exit : model -> List (Cmd msg) -> ( model, Cmd msg, ExitMsg a )
exit model cmds =
    ( model, Cmd.batch cmds, Exit )


exitWith : a -> model -> List (Cmd msg) -> ( model, Cmd msg, ExitMsg a )
exitWith a model cmds =
    ( model, Cmd.batch cmds, ExitWith a )


onExit : (model -> model) -> List (Cmd msg) -> ( model, Cmd msg, ExitMsg a ) -> ( model, Cmd msg )
onExit modelF cmds ( model, cmd, exitMsg ) =
    case exitMsg of
        Exit ->
            ( modelF model, Cmd.batch <| cmd :: cmds )

        _ ->
            ( model, cmd )


onExitDo : List (Cmd msg) -> ( model, Cmd msg, ExitMsg a ) -> ( model, Cmd msg )
onExitDo cmds ( model, cmd, exitMsg ) =
    case exitMsg of
        Exit ->
            ( model, Cmd.batch <| cmd :: cmds )

        _ ->
            ( model, cmd )


mapScene :
    HasScene mainModel
    -> (subModel -> Scene)
    -> (subMsg -> mainMsg)
    -> ( subModel, Cmd subMsg, exitMsg )
    -> ( HasScene mainModel, Cmd mainMsg, exitMsg )
mapScene mainModel sceneF msgF ( subModel, subMsg, exitMsg ) =
    ( (\mm -> { mm | scene = Loaded <| sceneF subModel }) mainModel
    , Cmd.map msgF subMsg
    , exitMsg
    )


loadScene :
    (subModel -> Scene)
    -> (subMsg -> mainMsg)
    -> HasScene mainModel
    -> ( subModel, Cmd subMsg )
    -> ( HasScene mainModel, Cmd mainMsg )
loadScene scene sceneMsg mainModel ( subModel, subMsg ) =
    ( { mainModel | scene = Loaded <| scene subModel }
    , Cmd.map sceneMsg subMsg
    )
