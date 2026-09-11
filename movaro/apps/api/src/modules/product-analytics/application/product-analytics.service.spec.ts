import { SupabaseAdminService } from '../../../common/supabase/supabase-admin.service';
import { ProductAnalyticsService } from './product-analytics.service';

describe('ProductAnalyticsService recommendation observability', () => {
  it('stores only bounded aggregate recommendation diagnostics', async () => {
    const upsert = jest.fn().mockResolvedValue({ error: null });
    const from = jest.fn().mockReturnValue({ upsert });
    const supabase = {
      isConfigured: true,
      admin: { from },
    } as unknown as SupabaseAdminService;
    const service = new ProductAnalyticsService(supabase);

    const result = await service.ingest({
      installationToken: 'a'.repeat(48),
      appEnvironment: 'production',
      events: [
        {
          eventId: 'refinement-event-0000001',
          eventName: 'refinementEvaluated',
          occurredAt: '2026-07-29T01:00:00.000Z',
          methodologyVersion: 'city-recommendation-v2.3.0',
          stabilityBand: 'robust',
          refinementStatus: 'ask',
          refinementQuestionId: 'work_arrangement',
          refinementGainBand: 'high',
          refinementScenariosEvaluated: 8,
        },
      ],
    });

    expect(result.accepted).toBe(true);
    expect(from).toHaveBeenCalledWith('product_flow_events');
    expect(upsert).toHaveBeenCalledWith(
      [
        expect.objectContaining({
          event_name: 'refinementEvaluated',
          methodology_version: 'city-recommendation-v2.3.0',
          stability_band: 'robust',
          refinement_status: 'ask',
          refinement_question_id: 'work_arrangement',
          refinement_gain_band: 'high',
          refinement_scenarios_evaluated: 8,
        }),
      ],
      { onConflict: 'event_id', ignoreDuplicates: true },
    );
    const storedRow = upsert.mock.calls[0][0][0] as Record<string, unknown>;
    expect(storedRow).not.toHaveProperty('city_id');
    expect(storedRow).not.toHaveProperty('recommendation_id');
    expect(storedRow).not.toHaveProperty('answers');
  });

  it('stores bounded pilot evidence without task or profile data', async () => {
    const upsert = jest.fn().mockResolvedValue({ error: null });
    const from = jest.fn().mockReturnValue({ upsert });
    const supabase = {
      isConfigured: true,
      admin: { from },
    } as unknown as SupabaseAdminService;
    const service = new ProductAnalyticsService(supabase);

    await service.ingest({
      installationToken: 'b'.repeat(48),
      appEnvironment: 'production',
      events: [
        {
          eventId: 'pilot-check-in-0000001',
          eventName: 'pilotCheckInSubmitted',
          occurredAt: '2026-09-11T12:00:00.000Z',
          validationClarityBand: 'clear',
          validationProgressBand: 'blocked',
          validationValueBand: 'moderate',
          validationPhaseBand: 'work',
        },
      ],
    });

    const storedRow = upsert.mock.calls[0][0][0] as Record<string, unknown>;
    expect(storedRow).toEqual(
      expect.objectContaining({
        event_name: 'pilotCheckInSubmitted',
        validation_clarity_band: 'clear',
        validation_progress_band: 'blocked',
        validation_value_band: 'moderate',
        validation_phase_band: 'work',
      }),
    );
    expect(storedRow).not.toHaveProperty('task_id');
    expect(storedRow).not.toHaveProperty('city_id');
    expect(storedRow).not.toHaveProperty('answers');
  });
});
