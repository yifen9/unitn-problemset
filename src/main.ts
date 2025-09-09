import "./styles/app.css";
import "./katex-host";
import { Elm } from "./Main.elm";

Elm.Main.init({ node: document.getElementById("app")! });
