import { ServiceUnavailableException } from '@nestjs/common';

import { SupabaseAdminService } from '../../../common/supabase/supabase-admin.service';
import { SiteAnalyticsService } from './site-analytics.service';

const intent = {
  sessionId: '018f22d4-d8a4-7ee1-8d77-f47b82122774',
  locale: 'es' as const,
  intentCategory: 'cityFit' as const,
  moveStage: 'withinSixMonths' as const,
};

describe('SiteAnalyticsService intent capture', () => {
  it('rejects the signal when storage is unavailable', async () => {
    const supabase = { isConfigured: false } as SupabaseAdminService;
    const service = new SiteAnalyticsService(supabase);

    await expect(service.recordIntent(intent)).rejects.toBeInstanceOf(
      ServiceUnavailableException,
    );
  });

  it('stores bounded categories and marks an existing session converted', async () => {
    const intentUpsert = jest.fn().mockResolvedValue({ error: null });
    const sessionEq = jest.fn().mockResolvedValue({ error: null });
    const sessionUpdate = jest.fn().mockReturnValue({ eq: sessionEq });
    const from = jest.fn((table: string) =>
      table === 'landing_page_intent_signals'
        ? { upsert: intentUpsert }
        : { update: sessionUpdate },
    );
    const supabase = {
      isConfigured: true,
      admin: { from },
    } as unknown as SupabaseAdminService;
    const service = new SiteAnalyticsService(supabase);

    await expect(service.recordIntent(intent)).resolves.toEqual({ accepted: true });
    expect(intentUpsert).toHaveBeenCalledWith(
      expect.objectContaining({
        session_id: intent.sessionId,
        locale: 'es',
        intent_category: 'cityFit',
        move_stage: 'withinSixMonths',
      }),
      { onConflict: 'session_id' },
    );
    expect(sessionUpdate).toHaveBeenCalledWith(
      expect.objectContaining({ converted: true }),
    );
    expect(sessionEq).toHaveBeenCalledWith('session_id', intent.sessionId);
  });

  it('does not claim success when the signal could not be stored', async () => {
    const supabase = {
      isConfigured: true,
      admin: {
        from: jest.fn().mockReturnValue({
          upsert: jest.fn().mockResolvedValue({ error: { message: 'offline' } }),
        }),
      },
    } as unknown as SupabaseAdminService;
    const service = new SiteAnalyticsService(supabase);

    await expect(service.recordIntent(intent)).rejects.toBeInstanceOf(
      ServiceUnavailableException,
    );
  });
});
