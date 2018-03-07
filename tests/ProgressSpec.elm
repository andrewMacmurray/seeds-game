module ProgressSpec exposing (..)

import Data.Hub.Progress exposing (incrementProgress)
import Expect
import Test exposing (..)


suite : Test
suite =
    describe "The progress module"
        [ test "it increments level progress when currentLevel is greater than currentProgress" <|
            \_ ->
                let
                    actual =
                        incrementProgress (Just ( 1, 2 )) ( 1, 1 )

                    expected =
                        ( 1, 2 )
                in
                    Expect.equal actual expected
        , test "it returns existing current progress if currentLevel is less than currentProgress" <|
            \_ ->
                let
                    actual =
                        incrementProgress (Just ( 1, 2 )) ( 1, 3 )

                    expected =
                        ( 1, 3 )
                in
                    Expect.equal actual expected
        , test "it sets the progress to the next world after completing previous world's last level" <|
            \_ ->
                let
                    actual =
                        incrementProgress (Just ( 1, 5 )) ( 1, 5 )

                    expected =
                        ( 1, 3 )
                in
                    Expect.equal actual expected
        ]
