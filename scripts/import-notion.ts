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
const CONTENT_COURSES_DIR = path.join(IN_ROOT, "courses");
const buildDate = new Date().toISOString().slice(0, 10);

type RichText = { plain_text: string };
type TitleProp = { title?: RichText[] };
type RTProp = { rich_text?: RichText[] };
type DateProp = { date?: { start?: string } };
type SelectProp = { select?: { name?: string } | null };
type MultiSelectProp = { multi_select?: Array<{ name?: unknown }> };
type RelationProp = { relation?: Array<{ id?: string }> };
type Properties = Record<string, unknown>;

type PageObject = { id: string; properties: Properties };

type CourseRow = { pageId: string; id: string; title: string; date: string };
type ProblemRow = {
	pageId: string;
	coursePageId: string;
	id: string;
	title: string;
	date: string;
	type: "single" | "multi";
	answer: string[];
	questionText: string;
	explanationText: string;
	choicesText: string;
	detailsText?: string;
};

type DataSourcesQueryArgs = {
	data_source_id: string;
	start_cursor?: string;
	[k: string]: unknown;
};
type DataSourcesQueryResp = {
	results: unknown[];
	has_more: boolean;
	next_cursor?: string | null;
};
type DbRetrieveResp = { data_sources?: Array<{ id: string }> };

type NotionWithDS = {
	dataSources: {
		query(args: DataSourcesQueryArgs): Promise<DataSourcesQueryResp>;
	};
	databases: {
		retrieve(args: { database_id: string }): Promise<DbRetrieveResp>;
	};
};
const notionDS = notion as unknown as NotionWithDS;

const joinRT = (arr?: RichText[]) =>
	(arr ?? []).map((x) => x.plain_text).join("");

const getProp = (p: PageObject, key: string): unknown =>
	(p.properties as Properties)[key];

const pickTitle = (p: PageObject, key = "Name") => {
	const v = getProp(p, key) as TitleProp | undefined;
	return joinRT(v?.title) || "";
};
const pickRT = (p: PageObject, key: string) => {
	const v = getProp(p, key) as RTProp | undefined;
	return joinRT(v?.rich_text) || "";
};
const pickDate = (p: PageObject, key = "Date") => {
	const v = getProp(p, key) as DateProp | undefined;
	const s = v?.date?.start;
	return typeof s === "string" && s.length >= 10 ? s.slice(0, 10) : buildDate;
};
const pickSelectLower = (p: PageObject, key = "Type") => {
	const v = getProp(p, key) as SelectProp | undefined;
	const s = String(v?.select?.name ?? "").toLowerCase();
	return s === "multi" ? "multi" : "single";
};
const pickMultiSelectNames = (p: PageObject, key = "Answer") => {
	const v = getProp(p, key) as MultiSelectProp | undefined;
	const arr = v?.multi_select ?? [];
	return arr
		.map((x) => String((x as { name?: unknown }).name ?? ""))
		.filter(Boolean);
};
const pickRelationFirstId = (p: PageObject, key = "Course") => {
	const v = getProp(p, key) as RelationProp | undefined;
	const first = (v?.relation ?? [])[0]?.id;
	return first ? String(first) : "";
};

const dsIdCache = new Map<string, string>();
async function toDataSourceId(maybeDbOrDsId: string): Promise<string> {
	const cached = dsIdCache.get(maybeDbOrDsId);
	if (cached) return cached;
	try {
		const db = await notionDS.databases.retrieve({
			database_id: maybeDbOrDsId,
		});
		const ds = db.data_sources?.[0]?.id;
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
		const resp = await notionDS.dataSources.query({
			data_source_id,
			start_cursor,
			...body,
		});
		results.push(...resp.results);
		if (!resp.has_more || !resp.next_cursor) break;
		start_cursor = resp.next_cursor ?? undefined;
	}
	return results;
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

function coerceChoicesFromUnknown(
	v: unknown,
): Array<{ id: string; text_md: string }> {
	if (!Array.isArray(v)) return [];
	const out: Array<{ id: string; text_md: string }> = [];
	for (const it of v) {
		if (it && typeof it === "object" && !Array.isArray(it)) {
			const o = it as Record<string, unknown>;
			const idVal = o["id"];
			const t1 = o["text_md"];
			const t2 = o["text"];
			const id = typeof idVal === "string" ? idVal : "";
			const text_md =
				typeof t1 === "string" ? t1 : typeof t2 === "string" ? t2 : "";
			if (id && text_md) out.push({ id, text_md });
		}
	}
	return out;
}

function coerceStringArray(v: unknown): string[] {
	return Array.isArray(v) ? v.map((x) => String(x)) : [];
}

function normalizeDetailsToFM(raw: string) {
	const t = (raw ?? "").replace(/\r\n/g, "\n").trim();
	if (!t) return t;

	const lines = t.split("\n");

	const ensureWrapped = (xs: string[]) => {
		const hasStart = xs[0]?.trim() === "---";
		let endIdx = -1;
		if (!hasStart) xs.unshift("---");
		for (let i = 1; i < xs.length; i++) {
			if (xs[i].trim() === "---") {
				endIdx = i;
				break;
			}
		}
		if (endIdx === -1) {
			xs.splice(1, 0, "---");
			endIdx = 1;
		}
		return { xs, headStart: 0, headEnd: endIdx };
	};

	const { xs, headStart, headEnd } = ensureWrapped(lines);

	const isTopKey = (ln: string) => /^[A-Za-z_][\w-]*\s*:/.test(ln);

	const reindentBlockFor = (key: string) => {
		for (let i = headStart + 1; i < headEnd; i++) {
			const ln = xs[i];
			if (new RegExp(`^${key}\\s*:\\s*$`).test(ln)) {
				let j = i + 1;
				while (j < headEnd) {
					const rawLine = xs[j];
					if (!rawLine.trim()) break;
					if (isTopKey(rawLine)) break;

					const s = rawLine.replace(/^\s+/, "");
					if (/^-\s+/.test(s)) {
						xs[j] = "  " + s;
					} else {
						xs[j] = "    " + s;
					}
					j++;
				}
				break;
			}
		}
	};

	reindentBlockFor("choices");
	reindentBlockFor("answer");

	return xs.join("\n");
}

async function readCourses(): Promise<CourseRow[]> {
	const pages = await queryAll(COURSES_DB_ID, {});
	return (pages as PageObject[]).map((pg) => {
		const id = pickRT(pg, "CourseId") || pickRT(pg, "ID") || pg.id.slice(0, 8);
		const title = pickTitle(pg, "Title") || pickTitle(pg, "Name") || id;
		const date = pickDate(pg, "Date");
		return { pageId: pg.id, id, title, date };
	});
}

async function readProblemsFor(coursePageId: string): Promise<ProblemRow[]> {
	const pages = await queryAll(PROBLEMS_DB_ID, {
		filter: { property: "Course", relation: { contains: coursePageId } },
		sorts: [{ property: "ProblemId", direction: "ascending" }],
	});
	return (pages as PageObject[]).map((pg) => {
		const id = pickRT(pg, "ProblemId") || pickRT(pg, "ID") || pg.id.slice(0, 8);
		const title = pickTitle(pg, "Title") || pickTitle(pg, "Name") || id;
		const date = pickDate(pg, "Date");
		const type = pickSelectLower(pg, "Type");
		const answer = pickMultiSelectNames(pg, "Answer");
		const questionText = pickRT(pg, "Question");
		const explanationText = pickRT(pg, "Explanation") || pickRT(pg, "Solution");
		const choicesText = pickRT(pg, "Choices");
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
			questionText,
			explanationText,
			choicesText,
			detailsText,
		};
	});
}

function toProblemMarkdown(p: ProblemRow) {
	if (p.detailsText?.trim()) {
		const t = normalizeDetailsToFM(p.detailsText);
		const parsed = matter(t);

		let baseObj: Record<string, unknown> = {};
		if (
			parsed.data &&
			typeof parsed.data === "object" &&
			!Array.isArray(parsed.data)
		) {
			baseObj = parsed.data as Record<string, unknown>;
		}

		const baseChoicesRaw = (baseObj as Record<string, unknown>).choices;
		const baseAnswerRaw = (baseObj as Record<string, unknown>).answer;

		const choicesCand = coerceChoicesFromUnknown(baseChoicesRaw);
		const choices =
			choicesCand.length > 0 ? choicesCand : parseChoices(p.choicesText);

		const answer =
			coerceStringArray(baseAnswerRaw).length > 0
				? coerceStringArray(baseAnswerRaw)
				: p.answer;

		const forced = {
			...baseObj,
			id: p.id,
			title: p.title,
			date: p.date,
			type: p.type,
			choices,
			answer,
		};

		const body = (parsed.content || "").trim();
		return `${matter.stringify(body, forced)}\n`;
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
		(p.questionText || "").trim(),
		p.explanationText ? `\n\n---\n\n${p.explanationText.trim()}` : "",
	].join("");
	return `${fm}\n${body}\n`;
}

async function ensureDirClean(dir: string) {
	await rm(dir, { recursive: true, force: true });
	await mkdir(dir, { recursive: true });
}

async function main() {
	await ensureDirClean(CONTENT_COURSES_DIR);

	const courses = await readCourses();
	for (const c of courses) {
		const courseDir = path.join(IN_ROOT, "courses", c.id);
		const problemsDir = path.join(courseDir, "problems");
		await mkdir(courseDir, { recursive: true });
		await ensureDirClean(problemsDir);

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
