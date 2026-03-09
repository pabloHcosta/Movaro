"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.MigrationPlanEntity = void 0;
class MigrationPlanEntity {
    originCountry;
    destinationCountry;
    goal;
    timeline;
    steps;
    constructor(originCountry, destinationCountry, goal, timeline, steps) {
        this.originCountry = originCountry;
        this.destinationCountry = destinationCountry;
        this.goal = goal;
        this.timeline = timeline;
        this.steps = steps;
    }
}
exports.MigrationPlanEntity = MigrationPlanEntity;
//# sourceMappingURL=migration-plan.entity.js.map