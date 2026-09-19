import { IsIn, IsUUID } from 'class-validator';

export class RecordSiteIntentDto {
  @IsUUID()
  sessionId!: string;

  @IsIn(['pt', 'es', 'en'])
  locale!: 'pt' | 'es' | 'en';

  @IsIn(['cityFit', 'costsAndHousing', 'documentsAndSteps', 'stillExploring'])
  intentCategory!:
    | 'cityFit'
    | 'costsAndHousing'
    | 'documentsAndSteps'
    | 'stillExploring';

  @IsIn(['exploring', 'withinSixMonths', 'organizingMove'])
  moveStage!: 'exploring' | 'withinSixMonths' | 'organizingMove';
}
