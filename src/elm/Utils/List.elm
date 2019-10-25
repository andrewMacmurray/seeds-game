module Utils.List exposing
    ( groupWhile
    , splitAt
    , unique
    )


unique : List a -> List a
unique =
    let
        accum a b =
            if List.member a b then
                b

            else
                a :: b
    in
    List.foldr accum []


splitAt : Int -> List a -> ( List a, List a )
splitAt n xs =
    ( List.take n xs
    , List.drop n xs
    )


groupWhile : (a -> a -> Bool) -> List a -> List (List a)
groupWhile eq xs_ =
    case xs_ of
        [] ->
            []

        x :: xs ->
            let
                ( ys, zs ) =
                    span (eq x) xs
            in
            (x :: ys) :: groupWhile eq zs


span : (a -> Bool) -> List a -> ( List a, List a )
span p xs =
    ( takeWhile p xs
    , dropWhile p xs
    )


takeWhile : (a -> Bool) -> List a -> List a
takeWhile predicate =
    let
        takeWhileMemo memo list =
            case list of
                [] ->
                    List.reverse memo

                x :: xs ->
                    if predicate x then
                        takeWhileMemo (x :: memo) xs

                    else
                        List.reverse memo
    in
    takeWhileMemo []


dropWhile : (a -> Bool) -> List a -> List a
dropWhile predicate list =
    case list of
        [] ->
            []

        x :: xs ->
            if predicate x then
                dropWhile predicate xs

            else
                list
