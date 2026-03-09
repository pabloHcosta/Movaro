"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.getEnvFilePaths = getEnvFilePaths;
const environment_enum_1 = require("./environment.enum");
function getEnvFilePaths() {
    const nodeEnv = process.env.NODE_ENV ?? environment_enum_1.AppEnvironment.Development;
    return [`.env.${nodeEnv}.local`, `.env.local`, `.env.${nodeEnv}`, '.env'];
}
//# sourceMappingURL=env-file-paths.js.map