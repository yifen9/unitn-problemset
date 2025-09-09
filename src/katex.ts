import "katex/dist/katex.min.css";
import renderMathInElement from "katex/contrib/auto-render/auto-render.js";

const opts = {
	delimiters: [
		{ left: "$$", right: "$$", display: true },
		{ left: "$", right: "$", display: false },
	],
	throwOnError: false,
};

export function setupKatex(root: HTMLElement) {
	const render = () => renderMathInElement(root, opts as any);
	const obs = new MutationObserver(render);
	obs.observe(root, { childList: true, subtree: true, characterData: true });
	render();
}
