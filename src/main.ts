import "./styles/app.css";
import { Elm } from "./Main.elm";

const node = document.getElementById("app");
if (!(node instanceof HTMLElement)) throw new Error("#app not found");
Elm.Main.init({ node });
