export * from './collector-submission.model';
import { UnitSubmissionModel, ICollectorSubmissionDoc } from './collector-submission.model';

// Backward compatibility aliases
export type ITempUnitSubmissionDoc = ICollectorSubmissionDoc;
export const TempUnitSubmissionModel = UnitSubmissionModel;
