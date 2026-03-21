/** Coverage level for the requested corridor. */
export type CoverageLevel = 'full' | 'partial' | 'unsupported';

/**
 * Structured context block ready to be injected into the AI system prompt.
 *
 * `appDataBlock` is a formatted text string containing city data and guide
 * phase items relevant to the user's current state. It is inserted between the
 * static system prompt and the conversation history.
 */
export class ChatContextEntity {
  constructor(
    /** Formatted text injected as APP DATA in the system prompt. */
    public readonly appDataBlock: string,
    /** Coverage level for this corridor — controls assistant behaviour. */
    public readonly coverageLevel: CoverageLevel,
    /** Human-readable corridor label (e.g. "Argentina → Brasil"). */
    public readonly supportedCorridor: string,
  ) {}
}
