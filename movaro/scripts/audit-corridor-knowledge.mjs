import { readFile } from "node:fs/promises";
import { fileURLToPath } from "node:url";
import { dirname, resolve } from "node:path";

const root = resolve(dirname(fileURLToPath(import.meta.url)), "..");
const path = resolve(root, "packages/content/argentina_brazil_knowledge.json");
const catalog = JSON.parse(await readFile(path, "utf8"));
const errors = [];
const requiredTopics = [
  "residence",
  "documents",
  "health",
  "medicines",
  "pets",
  "tax",
  "school",
  "emergency",
  "consumer",
  "customs",
  "utilities",
  "protection",
  "long_term",
];
const ids = new Set();
const topics = new Set();
const reviewedAt = new Date(`${catalog.reviewedAt}T00:00:00Z`);

if (catalog.schemaVersion !== 1) errors.push("schemaVersion must be 1");
if (!/^20\d{2}\.\d{2}\.\d{2}$/.test(catalog.catalogVersion ?? "")) {
  errors.push("catalogVersion must use YYYY.MM.DD");
}
if (Number.isNaN(reviewedAt.getTime())) errors.push("reviewedAt is invalid");

for (const entry of catalog.entries ?? []) {
  if (ids.has(entry.id)) errors.push(`duplicate id: ${entry.id}`);
  ids.add(entry.id);
  topics.add(entry.topic);
  if (!entry.authority || !entry.title)
    errors.push(`${entry.id}: missing attribution`);
  if (!String(entry.url).startsWith("https://"))
    errors.push(`${entry.id}: URL must use HTTPS`);
  const verified = new Date(`${entry.verifiedAt}T00:00:00Z`);
  if (Number.isNaN(verified.getTime()))
    errors.push(`${entry.id}: invalid verifiedAt`);
  const maxDays = entry.critical
    ? catalog.reviewPolicy.criticalReviewDays
    : catalog.reviewPolicy.standardReviewDays;
  const ageDays = (reviewedAt - verified) / 86_400_000;
  if (ageDays > maxDays)
    errors.push(`${entry.id}: source review is stale (${ageDays} days)`);
}

for (const topic of requiredTopics) {
  if (!topics.has(topic)) errors.push(`missing required topic: ${topic}`);
}

const claimsFiles = [
  "apps/app/lib/features/migration_questionnaire/application/services/argentina_brazil_guide_datasource.dart",
  "apps/api/src/modules/chat/data/argentina-brazil-guide.datasource.ts",
];

const quickHelpCatalog = await readFile(
  resolve(root, "apps/api/src/modules/chat/data/quick-help-trust.catalog.ts"),
  "utf8",
);
const journeyKnowledge = (
  await Promise.all(
    [
      "apps/app/lib/features/migration_questionnaire/application/services/argentina_brazil_guide_datasource.dart",
      "apps/app/lib/features/migration_questionnaire/application/services/preparation_resource_links.dart",
      "apps/app/lib/features/info/presentation/pages/guide_toolkit_page.dart",
    ].map((relative) => readFile(resolve(root, relative), "utf8")),
  )
).join("\n");

for (const entry of catalog.entries ?? []) {
  if (entry.surfaces?.includes("help")) {
    if (!quickHelpCatalog.includes(`id: '${entry.id}'`)) {
      errors.push(
        `${entry.id}: canonical source ID is missing from Quick Help`,
      );
    }
    if (!quickHelpCatalog.includes(`url: '${entry.url}'`)) {
      errors.push(`${entry.id}: Quick Help URL differs from canonical source`);
    }
  }
  if (
    entry.surfaces?.includes("journey") &&
    !journeyKnowledge.includes(entry.url)
  ) {
    errors.push(`${entry.id}: journey URL differs from canonical source`);
  }
}
const forbiddenClaims = [
  /janela legal (?:de|dos) 90 dias/i,
  /precisa sair do brasil ap[oó]s 90 dias/i,
  /argentinos? s[oó] (?:podem|pode) permanecer 90 dias/i,
];
for (const relative of claimsFiles) {
  const body = await readFile(resolve(root, relative), "utf8");
  for (const claim of forbiddenClaims) {
    if (claim.test(body))
      errors.push(`${relative}: forbidden universal claim ${claim}`);
  }
}

if (errors.length) {
  console.error(`Knowledge audit failed with ${errors.length} issue(s):`);
  for (const error of errors) console.error(`- ${error}`);
  process.exitCode = 1;
} else {
  console.log(
    `Knowledge audit passed: ${catalog.entries.length} sources, ` +
      `${topics.size} topics, catalog ${catalog.catalogVersion}.`,
  );
}
