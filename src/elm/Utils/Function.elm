module Utils.Function exposing (apply)


apply : a -> (a -> b) -> b
apply =
    (|>)
