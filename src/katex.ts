import 'katex/dist/katex.min.css';
import renderMathInElement from 'katex/contrib/auto-render/auto-render.js';

const opts = {
  delimiters: [
    { left: '$$', right: '$$', display: true },
    { left: '$',  right: '$',  display: false },
  ],
  throwOnError: false,
};

export function setupKatex(root: HTMLElement) {
  const renderAll = () => {
    const scopes = root.querySelectorAll<HTMLElement>('.math-scope');
    if (scopes.length === 0) {
      renderMathInElement(root, opts as any);
    } else {
      scopes.forEach(el => renderMathInElement(el, opts as any));
    }
  };
  const obs = new MutationObserver(renderAll);
  obs.observe(root, { childList: true, subtree: true, characterData: true, attributes: true });
  renderAll();
}
