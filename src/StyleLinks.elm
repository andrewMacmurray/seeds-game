module StyleLinks exposing (..)

import Types exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)


styleSheetNode : String -> Html Msg
styleSheetNode url =
    node "link" [ rel "stylesheet", href url ] []


tachyons : Html Msg
tachyons =
    styleSheetNode "https://unpkg.com/tachyons@4.6.1/css/tachyons.min.css"


mainStyle : Html Msg
mainStyle =
    styleSheetNode "/style.css"
