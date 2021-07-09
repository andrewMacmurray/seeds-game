module Utils.Cycle exposing
    ( Four
    , Three
    , four
    , three
    )

-- Three


type alias Three a =
    { one : a
    , two : a
    , three : a
    }


three : Three a -> Int -> a
three options i =
    case modBy 3 i of
        0 ->
            options.one

        1 ->
            options.two

        _ ->
            options.three



-- Four


type alias Four a =
    { one : a
    , two : a
    , three : a
    , four : a
    }


four : Four a -> Int -> a
four options i =
    case modBy 4 i of
        0 ->
            options.one

        1 ->
            options.two

        2 ->
            options.three

        _ ->
            options.four
