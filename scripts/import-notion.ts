import { mkdir, rm, writeFile } from "node:fs/promises";
import path from "node:path";
import { Client } from "@notionhq/client";
import matter from "gray-matter";

const NOTION_TOKEN = process.env.NOTION_TOKEN ?? "";
const COURSES_DB_ID = process.env.NOTION_COURSES_DB_ID ?? "";
const PROBLEMS_DB_ID = process.env.NOTION_PROBLEMS_DB_ID ?? "";
if (!NOTION_TOKEN || !COURSES_DB_ID || !PROBLEMS_DB_ID) {
	console.error(
		"Missing NOTION_TOKEN / NOTION_COURSES_DB_ID / NOTION_PROBLEMS_DB_ID",
	);
	process.exit(1);
}

const notion = new Client({ auth: NOTION_TOKEN });

const IN_ROOT = "content";
const buildDate = new Date().toISOString().slice(0, 10);

const joinRT = (arr: Array<{ plain_text: string }> | undefined) =>
	(arr ?? []).map((x) => x.plain_text).join("");

type PageObject = { id: string; properties: Record<string, unknown> };

type CourseRow = { pageId: string; id: string; title: string; date: string };

type ProblemRow = {
	pageId: string;
	coursePageId: string;
	id: string;
	title: string;
	date: string;
	type: "single" | "multi";
	answer: string[];
	choicesText: string;
	questionText: string;
	explanationText: string;
	detailsText: string;
};

function pickTitle(p: PageObject, key = "Name") {
	const v =
		(p.properties?.[key] as { title?: Array<{ plain_text: string }> }) ?? {};
	return joinRT(v.title) || "";
}
function pickRT(p: PageObject, key: string) {
	const v =
		(p.properties?.[key] as { rich_text?: Array<{ plain_text: string }> }) ??
		{};
	return joinRT(v.rich_text) || "";
}
function pickDate(p: PageObject, key = "Date") {
	const v = (p.properties?.[key] as { date?: { start?: string } }) ?? {};
	const s = v.date?.start;
	return typeof s === "string" && s.length >= 10 ? s.slice(0, 10) : buildDate;
}
function pickSelectLower(p: PageObject, key = "Type") {
	const v = (p.properties?.[key] as { select?: { name?: string } }) ?? {};
	const s = String(v.select?.name ?? "").toLowerCase();
	return s === "multi" ? "multi" : "single";
}
function pickMultiSelectNames(p: PageObject, key = "Answer") {
	const v =
		(p.properties?.[key] as { multi_select?: Array<{ name?: unknown }> }) ?? {};
	const arr = v.multi_select ?? [];
	return Array.isArray(arr) ? arr.map((x) => String((x as any).name)) : [];
}
function pickRelationFirstId(p: PageObject, key = "Course") {
	const v =
		(p.properties?.[key] as { relation?: Array<{ id?: string }> }) ?? {};
	const arr = v.relation ?? [];
	if (Array.isArray(arr) && arr[0]?.id) return String(arr[0].id);
	return "";
}

function parseChoices(s: string) {
	const lines = s
		.split(/\r?\n/)
		.map((x) => x.trim())
		.filter(Boolean);
	return lines
		.map((ln) => {
			const m =
				/^([A-Za-z0-9]+)[.:)-]\s*(.+)$/.exec(ln) ||
				/^([A-Za-z0-9]+)\s+(.+)$/.exec(ln);
			if (!m) return null;
			return { id: m[1].toUpperCase(), text_md: m[2] };
		})
		.filter(
			(x): x is { id: string; text_md: string } => !!x && !!x.id && !!x.text_md,
		);
}

const dsIdCache = new Map<string, string>();
async function toDataSourceId(maybeDbOrDsId: string) {
	if (dsIdCache.has(maybeDbOrDsId)) return dsIdCache.get(maybeDbOrDsId)!;
	try {
		const db = await notion.databases.retrieve({
			database_id: maybeDbOrDsId as any,
		});
		const ds = (db as any).data_sources?.[0]?.id;
		if (ds) {
			dsIdCache.set(maybeDbOrDsId, ds);
			return ds;
		}
	} catch {}
	return maybeDbOrDsId;
}

async function queryAll(
	dbOrDsId: string,
	body: Record<string, unknown>,
): Promise<unknown[]> {
	const data_source_id = await toDataSourceId(dbOrDsId);
	const results: unknown[] = [];
	let start_cursor: string | undefined;
	for (;;) {
		const resp = await notion.dataSources.query({
			data_source_id,
			start_cursor,
			...body,
		} as any);
		results.push(...(resp as any).results);
		if (!(resp as any).has_more || !(resp as any).next_cursor) break;
		start_cursor = (resp as any).next_cursor as string | undefined;
	}
	return results;
}

async function readCourses(): Promise<CourseRow[]> {
	const pages = await queryAll(COURSES_DB_ID, {});
	return (pages as PageObject[]).map((pg) => {
		const id = pickRT(pg, "CourseId") || pickRT(pg, "ID") || pg.id.slice(0, 8);
		const title = pickTitle(pg, "Name") || id;
		const date = pickDate(pg, "Date");
		return { pageId: pg.id, id, title, date };
	});
}

async function readProblemsFor(coursePageId: string): Promise<ProblemRow[]> {
	const pages = await queryAll(PROBLEMS_DB_ID, {
		filter: { property: "Course", relation: { contains: coursePageId } },
	});
	return (pages as PageObject[]).map((pg) => {
		const id = pickRT(pg, "ProblemId") || pickRT(pg, "ID") || pg.id.slice(0, 8);
		const title = pickTitle(pg, "Name") || id;
		const date = pickDate(pg, "Date");
		const type = pickSelectLower(pg, "Type");
		const answer = pickMultiSelectNames(pg, "Answer");
		const choicesText = pickRT(pg, "Choices");
		const questionText = pickRT(pg, "Question");
		const explanationText = pickRT(pg, "Explanation") || pickRT(pg, "Solution");
		const detailsText = pickRT(pg, "Details");
		const courseRel = pickRelationFirstId(pg, "Course");
		return {
			pageId: pg.id,
			coursePageId: courseRel,
			id,
			title,
			date,
			type,
			answer,
			choicesText,
			questionText,
			explanationText,
			detailsText,
		};
	});
}

function toProblemMarkdown(p: ProblemRow) {
	if (p.detailsText && p.detailsText.trim().length > 0) {
		const parsed = matter(p.detailsText.trim());
		const forced = {
			...parsed.data,
			id: p.id,
			title: p.title,
			date: p.date,
			type: p.type,
		};
		return matter.stringify(parsed.content.trim(), forced) + "\n";
	}
	const fm = [
		"---",
		`id: "${p.id}"`,
		`title: "${p.title.replace(/"/g, '\\"')}"`,
		`date: "${p.date}"`,
		`type: "${p.type}"`,
		"choices:",
		...parseChoices(p.choicesText).map(
			(c) => `  - { id: "${c.id}", text_md: ${JSON.stringify(c.text_md)} }`,
		),
		`answer: ${JSON.stringify(p.answer)}`,
		"---",
	].join("\n");
	const body = [
		p.questionText.trim(),
		p.explanationText ? `\n\n---\n\n${p.explanationText.trim()}` : "",
	].join("");
	return `${fm}\n${body}\n`;
}

async function ensureDirClean(dir: string) {
	await rm(dir, { recursive: true, force: true });
	await mkdir(dir, { recursive: true });
}

async function main() {
	const courses = await readCourses();
	for (const c of courses) {
		const courseDir = path.join(IN_ROOT, "courses", c.id);
		const problemsDir = path.join(courseDir, "problems");
		await ensureDirClean(problemsDir);
		await mkdir(courseDir, { recursive: true });
		const courseMd = [
			"---",
			`id: "${c.id}"`,
			`title: "${c.title.replace(/"/g, '\\"')}"`,
			`date: "${c.date}"`,
			"---",
			"",
		].join("\n");
		await writeFile(path.join(courseDir, "course.md"), courseMd, "utf8");

		const problems = await readProblemsFor(c.pageId);
		for (const p of problems) {
			const md = toProblemMarkdown(p);
			await writeFile(path.join(problemsDir, `${p.id}.md`), md, "utf8");
		}
	}
}

main().catch((e) => {
	console.error(e);
	process.exit(1);
});
