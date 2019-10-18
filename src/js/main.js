import "pepjs"
import { Elm } from '../elm/Main.elm'
import { Embed } from './embed'
import * as Cheats from "./cheats.js"

Cheats.activate();

Embed(Elm.Main);
