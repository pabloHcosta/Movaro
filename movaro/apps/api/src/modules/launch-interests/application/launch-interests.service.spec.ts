import { ServiceUnavailableException } from '@nestjs/common';

import { SupabaseAdminService } from '../../../common/supabase/supabase-admin.service';
import { LaunchInterestsService } from './launch-interests.service';

describe('LaunchInterestsService', () => {
  it('normalizes and upserts an interested email', async () => {
    const upsert = jest.fn().mockResolvedValue({ error: null });
    const from = jest.fn().mockReturnValue({ upsert });
    const supabase = {
      isConfigured: true,
      admin: { from },
    } as unknown as SupabaseAdminService;
    const service = new LaunchInterestsService(supabase);

    await expect(
      service.register({ email: ' Pablo@Example.com ', locale: 'pt' }),
    ).resolves.toEqual({ accepted: true });
    expect(from).toHaveBeenCalledWith('launch_interests');
    expect(upsert).toHaveBeenCalledWith(
      expect.objectContaining({
        email: 'pablo@example.com',
        locale: 'pt',
        source: 'landing_page',
        status: 'interested',
      }),
      { onConflict: 'email' },
    );
  });

  it('does not claim success when storage is unavailable', async () => {
    const supabase = {
      isConfigured: false,
    } as unknown as SupabaseAdminService;
    const service = new LaunchInterestsService(supabase);

    await expect(
      service.register({ email: 'pablo@example.com', locale: 'pt' }),
    ).rejects.toBeInstanceOf(ServiceUnavailableException);
  });
});
