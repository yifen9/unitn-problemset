import "./styles/app.css";
import { Elm } from './Main.elm';
import { setupKatex, forceKatexRender } from './katex';
import './katex-host';

const root = document.getElementById('app')!;
const app = Elm.Main.init({ node: root });

setupKatex(root);
app.ports?.katexRender?.subscribe(() => {
  requestAnimationFrame(() => forceKatexRender());
});
