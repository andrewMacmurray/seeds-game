module InfoWindow exposing
    ( InfoWindow
    , State(..)
    , content
    , hidden
    , leaving
    , state
    , visible
    )

-- Info Window


type InfoWindow content
    = WithContent State content
    | Empty


type State
    = Visible
    | Leaving
    | Hidden



-- Construct


visible : content -> InfoWindow content
visible =
    WithContent Visible


leaving : InfoWindow content -> InfoWindow content
leaving infoWindow =
    case infoWindow of
        WithContent _ content_ ->
            WithContent Leaving content_

        Empty ->
            Empty


hidden : InfoWindow content
hidden =
    Empty



-- Query


content : InfoWindow content -> Maybe content
content infoWindow =
    case infoWindow of
        WithContent _ c ->
            Just c

        Empty ->
            Nothing


state : InfoWindow content -> State
state infoWindow =
    case infoWindow of
        WithContent state_ _ ->
            state_

        Empty ->
            Hidden
