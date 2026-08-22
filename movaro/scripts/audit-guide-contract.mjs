import { readFile } from "node:fs/promises";

const appCatalogFile = new URL(
  "../apps/app/lib/features/migration_questionnaire/application/services/argentina_brazil_guide_datasource.dart",
  import.meta.url,
);
const apiCatalogFile = new URL(
  "../apps/api/src/modules/chat/data/argentina-brazil-guide.datasource.ts",
  import.meta.url,
);
const apiLocalizationFile = new URL(
  "../apps/api/src/modules/chat/application/services/resolvers/corridor-guidance-profiles.ts",
  import.meta.url,
);
const quickHelpPageFile = new URL(
  "../apps/app/lib/features/info/presentation/pages/quick_guide_answer_page.dart",
  import.meta.url,
);
const quickHelpServiceFile = new URL(
  "../apps/api/src/modules/chat/application/services/quick-guide.service.ts",
  import.meta.url,
);
const quickHelpHubFile = new URL(
  "../apps/app/lib/features/home/presentation/pages/tools_hub_page.dart",
  import.meta.url,
);

const [
  appCatalog,
  apiCatalog,
  apiLocalization,
  quickHelpPage,
  quickHelpService,
  quickHelpHub,
] = await Promise.all([
  readFile(appCatalogFile, "utf8"),
  readFile(apiCatalogFile, "utf8"),
  readFile(apiLocalizationFile, "utf8"),
  readFile(quickHelpPageFile, "utf8"),
  readFile(quickHelpServiceFile, "utf8"),
  readFile(quickHelpHubFile, "utf8"),
]);

const appIds = [
  ...appCatalog.matchAll(/GuideActionItem\(\s*id:\s*'([^']+)'/g),
].map((match) => match[1]);
const apiIds = [...apiCatalog.matchAll(/^\s*id:\s*'([^']+)'/gm)].map(
  (match) => match[1],
);

const duplicateValues = (values) => [
  ...new Set(values.filter((value, index) => values.indexOf(value) !== index)),
];
const errors = [];
const appIdSet = new Set(appIds);

const duplicateAppIds = duplicateValues(appIds);
const duplicateApiIds = duplicateValues(apiIds);
if (duplicateAppIds.length > 0) {
  errors.push(`Duplicate app guide IDs: ${duplicateAppIds.join(", ")}`);
}
if (duplicateApiIds.length > 0) {
  errors.push(`Duplicate API guide IDs: ${duplicateApiIds.join(", ")}`);
}

const missingInApp = apiIds.filter((id) => !appIdSet.has(id));
if (missingInApp.length > 0) {
  errors.push(
    `API guide IDs without an app catalog item: ${missingInApp.join(", ")}`,
  );
}

const nonCanonicalApiIds = apiIds.filter(
  (id) => !/^item_\d+_\d+_[a-z0-9_]+$/.test(id),
);
if (nonCanonicalApiIds.length > 0) {
  errors.push(`Non-canonical API guide IDs: ${nonCanonicalApiIds.join(", ")}`);
}

const requiredJourneyIds = [
  "item_0_2_document_folder",
  "item_0_2_antecedentes",
  "item_0_3_budget",
  "item_1_0_entry_proof",
  "item_1_2_housing_temporary",
  "item_2_1_cpf",
  "item_2_2_residencia",
  "item_3_4_work_rights",
  "item_3_4_formal_work_ready",
  "item_4_2_saude",
  "item_4_5_registro_rnm",
];
for (const id of requiredJourneyIds) {
  if (!appIdSet.has(id) || !apiIds.includes(id)) {
    errors.push(`Required cross-platform journey ID is missing: ${id}`);
  }
}

const apiItemBlocks = apiCatalog.match(/\{\s*id:[\s\S]*?\n\s*\},/g) ?? [];
for (const block of apiItemBlocks) {
  const id = block.match(/id:\s*'([^']+)'/)?.[1] ?? "unknown";
  for (const field of ["phase", "title", "summary"]) {
    if (!new RegExp(`${field}:\\s*['"]`).test(block)) {
      errors.push(`API item ${id} is missing required field ${field}`);
    }
  }
}

if (
  !/export type GuidanceLocale = 'pt' \| 'es' \| 'en';/.test(apiLocalization)
) {
  errors.push("Corridor guidance must keep the pt, es and en locale contract.");
}

for (const forbidden of [
  ["generatedPlan", "must not import plan state"],
  ["_openAction", "must not navigate to another feature"],
  ["AppRoutes.guideToolkit", "must not open a toolkit"],
  ["AppRoutes.documentationTopic", "must not open the journey guide"],
]) {
  if (quickHelpPage.includes(forbidden[0])) {
    errors.push(`Quick Help ${forbidden[1]} (${forbidden[0]}).`);
  }
}
if (!/actions:\s*\[\]/.test(quickHelpService)) {
  errors.push("Quick Help API must return no cross-feature actions.");
}
for (const forbidden of [
  "generatedPlan",
  "_openToolkit",
  "_openTopic",
  "AppRoutes.guideToolkit",
  "AppRoutes.documentationTopic",
  "AppRoutes.proposalSafetyCheck",
  "AppRoutes.flightSearch",
]) {
  if (quickHelpHub.includes(forbidden)) {
    errors.push(`Quick Help hub must not couple to ${forbidden}.`);
  }
}

if (errors.length > 0) {
  console.error(
    ["Guide contract audit failed:", ...errors.map((e) => `- ${e}`)].join("\n"),
  );
  process.exitCode = 1;
} else {
  console.log(
    `Guide contract audit passed: ${apiIds.length} API items map to ${appIds.length} app items; pt/es/en locale contract present.`,
  );
}
