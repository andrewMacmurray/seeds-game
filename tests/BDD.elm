module BDD exposing (expect, it, toBe)

import Expect exposing (Expectation)
import Test exposing (Test, test)


it : String -> Expectation -> Test
it description expectation =
    test description <| always expectation


toBe : a -> a -> Expectation
toBe =
    Expect.equal


expect : a -> (a -> a -> Expectation) -> a -> Expectation
expect subject matcher expectedValue =
    matcher expectedValue subject
