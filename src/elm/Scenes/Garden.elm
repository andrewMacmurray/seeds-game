module Scenes.Garden exposing
    ( Model
    , Msg
    , getContext
    , init
    , update
    , updateContext
    , view
    )

import Context exposing (Context)
import Exit exposing (exit)
import Html exposing (Html, div, text)
import Html.Attributes exposing (class)



-- Model


type alias Model =
    { context : Context }


type Msg
    = ExitToHub



-- Context


getContext : Model -> Context
getContext model =
    model.context


updateContext : (Context -> Context) -> Model -> Model
updateContext f model =
    { model | context = f model.context }



-- Init


init : Context -> ( Model, Cmd Msg )
init context =
    ( initialState context, Cmd.none )


initialState : Context -> Model
initialState context =
    { context = context }



-- Update


update : Msg -> Model -> Exit.Status ( Model, Cmd Msg )
update msg model =
    case msg of
        ExitToHub ->
            exit model



-- View


view : Model -> Html Msg
view model =
    div [ class "w-100 z-1 fixed" ]
        [ text "Garden" ]
