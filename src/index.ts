import "pepjs";
import "@webcomponents/webcomponentsjs/custom-elements-es5-adapter.js";
import "@webcomponents/webcomponentsjs/webcomponents-loader";
import "./ts/animation";
import * as Cheats from "./ts/cheats";
import * as App from "./ts/app";

Cheats.activate();
App.init();
