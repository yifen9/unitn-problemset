import { mkdir, readFile, rm, writeFile } from "node:fs/promises";
import path from "node:path";
import fg from "fast-glob";
import matter from "gray-matter";

type Course = { id: string; title: string; date: string; count: number };
type ProblemSummary = { id: string; title: string; date: string; path: string };
type ProblemDetail = {
	id: string;
	title: string;
	date: string;
	type: "single" | "multi";
	question_md: string;
	choices: { id: string; text_md: string }[];
	answer: string[];
	explanation_md: string;
};

const IN_ROOT = "content";
const OUT_ROOT = "public/data";
const buildDate = new Date().toISOString().slice(0, 10);

const norm = (s: unknown, d = ""): string => (typeof s === "string" ? s : d);
const toArray = (v: unknown): string[] =>
	Array.isArray(v) ? v.map(String) : typeof v === "string" ? [v] : [];
const asType = (v: unknown): "single" | "multi" =>
	String(v ?? "single").toLowerCase() === "multi" ? "multi" : "single";

async function ensureDir(p: string) {
	await mkdir(p, { recursive: true });
}

function splitQuestionAndExplanation(body: string): { q: string; e: string } {
	const sep = /\n-{3,}\n/;
	const parts = body.split(sep);
	if (parts.length >= 2) {
		return { q: parts[0].trim(), e: parts.slice(1).join("\n---\n").trim() };
	}
	const solHead = /\n##\s*(Solution|Explanation)\s*\n/i;
	const m = solHead.exec(`\n${body}`);
	if (m) {
		const idx = m.index - 1;
		return {
			q: body.slice(0, idx).trim(),
			e: body.slice(idx).replace(solHead, "").trim(),
		};
	}
	return { q: body.trim(), e: "" };
}

async function readCourseMeta(courseDir: string) {
	const courseMd = path.join(courseDir, "course.md");
	const raw = await readFile(courseMd, "utf8");
	const fm = matter(raw);
	const id = norm(
		(fm.data as Record<string, unknown>).id,
		path.basename(courseDir),
	);
	const title = norm((fm.data as Record<string, unknown>).title, id);
	const date = norm((fm.data as Record<string, unknown>).date, buildDate);
	return { id, title, date };
}

function coerceChoices(v: unknown): { id: string; text_md: string }[] {
	if (!Array.isArray(v)) return [];
	return v
		.map((x) => {
			if (x && typeof x === "object") {
				const obj = x as Record<string, unknown>;
				const id = norm(obj.id);
				const text_md = norm(obj.text_md, norm(obj.text, ""));
				if (id && text_md) return { id, text_md };
			}
			return null;
		})
		.filter((x): x is { id: string; text_md: string } => x !== null);
}

async function buildCourse(courseDir: string) {
	const meta = await readCourseMeta(courseDir);
	const problemsDir = path.join(courseDir, "problems");
	const files = await fg("*.md", { cwd: problemsDir, onlyFiles: true });
	const outCourseDir = path.join(OUT_ROOT, "courses", meta.id);
	const outProblemsDir = path.join(outCourseDir, "problems");

	await rm(outProblemsDir, { recursive: true, force: true });
	await ensureDir(outProblemsDir);

	const summaries: ProblemSummary[] = [];
	for (const file of files) {
		const abs = path.join(problemsDir, file);
		const raw = await readFile(abs, "utf8");
		const fm = matter(raw);
		const data = fm.data as Record<string, unknown>;

		const id = norm(data.id, path.parse(file).name);
		const title = norm(data.title, id);
		const date = norm(data.date, buildDate);
		const type = asType(data.type);
		const { q, e } = splitQuestionAndExplanation(fm.content);
		const choices = coerceChoices(data.choices);
		const answer = toArray(data.answer);

		const detail: ProblemDetail = {
			id,
			title,
			date,
			type,
			question_md: q,
			choices,
			answer,
			explanation_md: e,
		};

		const outPath = path.join(outProblemsDir, `${id}.json`);
		await writeFile(outPath, JSON.stringify(detail, null, 2), "utf8");

		summaries.push({ id, title, date, path: `${id}.json` });
	}

	summaries.sort((a, b) =>
		a.date === b.date ? a.id.localeCompare(b.id) : a.date.localeCompare(b.date),
	);

	const problemsIndex = {
		courseId: meta.id,
		build: buildDate,
		count: summaries.length,
		problems: summaries,
	};
	await writeFile(
		path.join(outProblemsDir, "index.json"),
		JSON.stringify(problemsIndex, null, 2),
		"utf8",
	);

	return {
		id: meta.id,
		title: meta.title,
		date: meta.date,
		count: summaries.length,
	};
}

async function main() {
	const courseDirs = await fg("courses/*", {
		cwd: IN_ROOT,
		onlyDirectories: true,
		deep: 1,
	});
	await rm(path.join(OUT_ROOT, "courses"), { recursive: true, force: true });
	const courses: Course[] = [];
	for (const rel of courseDirs) {
		const dir = path.join(IN_ROOT, rel);
		const course = await buildCourse(dir);
		courses.push(course);
	}
	courses.sort((a, b) => a.title.localeCompare(b.title));
	const index = { build: buildDate, courses };
	const outRoot = path.join(OUT_ROOT, "courses");
	await ensureDir(outRoot);
	await writeFile(
		path.join(outRoot, "index.json"),
		JSON.stringify(index, null, 2),
		"utf8",
	);
}

main().catch((err) => {
	console.error(err);
	process.exit(1);
});
