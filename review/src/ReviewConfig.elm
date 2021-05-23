module ReviewConfig exposing (config)

{-| Do not rename the ReviewConfig module or the config function, because
`elm-review` will look for these.

To add packages that contain rules, add them to this review project using

    `elm install author/packagename`

when inside the directory containing this file.

-}

import NoExposingEverything
import NoUnused.CustomTypeConstructorArgs
import NoUnused.CustomTypeConstructors
import NoUnused.Dependencies
import NoUnused.Exports
import NoUnused.Modules
import NoUnused.Parameters
import NoUnused.Patterns
import NoUnused.Variables
import Review.Rule as Rule exposing (Rule)
import Simplify


config : List Rule
config =
    [ NoUnused.CustomTypeConstructors.rule []
    , NoUnused.CustomTypeConstructorArgs.rule
    , NoUnused.Dependencies.rule
    , exportsRule
    , modulesRule
    , NoUnused.Parameters.rule
    , NoUnused.Patterns.rule
    , NoUnused.Variables.rule
    , noExposingRule
    , Simplify.rule Simplify.defaults
    ]


exportsRule : Rule
exportsRule =
    NoUnused.Exports.rule
        |> Rule.ignoreErrorsForFiles [ paletteFile, debugFile ]


modulesRule : Rule
modulesRule =
    NoUnused.Modules.rule
        |> Rule.ignoreErrorsForFiles [ debugFile ]


noExposingRule =
    NoExposingEverything.rule
        |> Rule.ignoreErrorsForFiles [ paletteFile ]


debugFile : String
debugFile =
    "src/elm/Utils/Debug.elm"


paletteFile : String
paletteFile =
    "src/elm/Element/Palette.elm"
