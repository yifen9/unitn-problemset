import "./styles/app.css";
import { setupKatex } from "./katex";
import { Elm } from "./Main.elm";

const root = document.getElementById("app");
if (root) {
	Elm.Main.init({ node: root });
	setupKatex(root);
}
