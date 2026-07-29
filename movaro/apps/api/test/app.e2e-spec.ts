import { INestApplication, VersioningType } from '@nestjs/common';
import { Test } from '@nestjs/testing';
import {
  FastifyAdapter,
  NestFastifyApplication,
} from '@nestjs/platform-fastify';
import request from 'supertest';

import { AppModule } from '../src/app.module';
import {
  API_VERSION,
  APP_GLOBAL_PREFIX,
} from '../src/common/constants/app.constants';

describe('Movaro API (e2e)', () => {
  let app: INestApplication;

  beforeAll(async () => {
    const moduleRef = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();

    app = moduleRef.createNestApplication<NestFastifyApplication>(
      new FastifyAdapter(),
    );
    app.setGlobalPrefix(APP_GLOBAL_PREFIX);
    app.enableVersioning({
      type: VersioningType.URI,
      defaultVersion: API_VERSION,
    });
    await app.init();
    await app.getHttpAdapter().getInstance().ready();
  });

  afterAll(async () => {
    if (app) {
      await app.close();
    }
  });

  it('exposes the versioned health contract', async () => {
    const response = await request(app.getHttpServer())
      .get(`/${APP_GLOBAL_PREFIX}/v${API_VERSION}/health`)
      .expect(200);

    expect(response.body).toEqual({
      success: true,
      data: expect.objectContaining({
        status: 'ok',
        timestamp: expect.any(String),
      }),
    });
    expect(Number.isNaN(Date.parse(response.body.data.timestamp))).toBe(false);
  });

  it('does not expose an unversioned health route', async () => {
    await request(app.getHttpServer())
      .get(`/${APP_GLOBAL_PREFIX}/health`)
      .expect(404);
  });
});
