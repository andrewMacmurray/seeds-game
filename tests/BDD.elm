module BDD exposing (expect, it, toEqual)

import Expect exposing (Expectation)
import Test exposing (Test, test)


expect : a -> (a -> a -> Expectation) -> a -> Expectation
expect subject matcher expectedValue =
    matcher expectedValue subject


it : String -> Expectation -> Test
it description expectation =
    test description <| always expectation


toEqual : a -> a -> Expectation
toEqual =
    Expect.equal
