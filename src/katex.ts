import 'katex/dist/katex.min.css';
import renderMathInElement from 'katex/contrib/auto-render/auto-render.js';

const opts = {
  delimiters: [
    { left: '$$', right: '$$', display: true },
    { left: '$',  right: '$',  display: false },
  ],
  throwOnError: false,
};

let _lastRoot: HTMLElement | null = null;
let _scheduled = false;

function renderOnce(root: HTMLElement) {
  const scopes = root.querySelectorAll<HTMLElement>('.math-scope');
  if (scopes.length === 0) {
    renderMathInElement(root, opts as any);
  } else {
    for (const el of scopes) {
      renderMathInElement(el, opts as any);
    }
  }
}

function scheduleRender() {
  if (_scheduled || !_lastRoot) return;
  _scheduled = true;
  requestAnimationFrame(() => {
    _scheduled = false;
    renderOnce(_lastRoot!);
  });
}

export function forceKatexRender() {
  if (_lastRoot) renderOnce(_lastRoot);
}

export function setupKatex(root: HTMLElement) {
  _lastRoot = root;
  const obs = new MutationObserver(() => scheduleRender());
  obs.observe(root, { childList: true, subtree: true, characterData: true, attributes: true });
  renderOnce(root);
}
