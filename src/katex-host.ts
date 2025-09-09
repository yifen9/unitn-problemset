import "katex/dist/katex.min.css";
import renderMathInElement from "katex/contrib/auto-render/auto-render.js";
import MarkdownIt from "markdown-it";

const md = new MarkdownIt({ html: false, linkify: true, typographer: true });

class KatexHost extends HTMLElement {
	static get observedAttributes() {
		return ["data-content", "data-mode"];
	}
	#root: ShadowRoot;
	#container: HTMLDivElement;

	constructor() {
		super();
		this.#root = this.attachShadow({ mode: "open" });
		const style = document.createElement("style");
		style.textContent = `:host{font-size:inherit} :host([data-block]){display:block}`;
		this.#container = document.createElement("div");
		this.#root.append(style, this.#container);
	}

	connectedCallback() {
		this.#render();
	}
	attributeChangedCallback() {
		this.#render();
	}

	#render() {
		const s = this.getAttribute("data-content") || "";
		const mode = (this.getAttribute("data-mode") || "inline").toLowerCase();
		const html = mode === "block" ? md.render(s) : md.renderInline(s);
		this.#container.innerHTML = html;
		renderMathInElement(this.#container, {
			delimiters: [
				{ left: "$$", right: "$$", display: true },
				{ left: "$", right: "$", display: false },
			],
			throwOnError: false,
			output: "mathml",
		} as any);
	}
}

customElements.define("katex-host", KatexHost);
