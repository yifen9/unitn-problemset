import 'katex/dist/katex.min.css';
import renderMathInElement from 'katex/contrib/auto-render/auto-render.js';

class KatexHost extends HTMLElement {
  static get observedAttributes() { return ['data-content']; }
  #root: ShadowRoot;
  #container: HTMLDivElement;

  constructor() {
    super();
    this.#root = this.attachShadow({ mode: 'open' });
    this.#container = document.createElement('div');
    this.#root.appendChild(this.#container);
  }

  connectedCallback() { this.#render(); }
  attributeChangedCallback() { this.#render(); }

  #render() {
    const s = this.getAttribute('data-content') || '';
    this.#container.textContent = s;
    renderMathInElement(this.#container, {
      delimiters: [
        { left: '$$', right: '$$', display: true },
        { left: '$',  right: '$',  display: false },
      ],
      throwOnError: false,
      output: 'mathml',
    } as any);
  }
}

customElements.define('katex-host', KatexHost);
