module Utils.Style exposing (..)

import Formatting exposing (..)


classes : List String -> String
classes =
    String.join " "


styles : List (List ( String, String )) -> List ( String, String )
styles =
    List.concat


px : number -> String
px =
    print px_


px_ : Format r (number -> r)
px_ =
    number <> s "px"


transform_ : Format r a -> Format r a
transform_ formatter =
    s "transform: " <> formatter <> s ";"


translateY : number -> String
translateY =
    print translateY_


translateY_ : Format r (number -> r)
translateY_ =
    s "translateY(" <> px_ <> s ")"


translate : number -> number -> String
translate =
    print translate_


translate_ : Format r (number -> number -> r)
translate_ =
    s "translate(" <> px_ <> s ", " <> px_ <> s ")"


scale : number -> String
scale =
    print scale_


scale_ : Format r (number -> r)
scale_ =
    s "scale(" <> number <> s ")"
