import { BcraExchangeRateService } from './bcra-exchange-rate.service';

describe('BcraExchangeRateService', () => {
  afterEach(() => {
    jest.restoreAllMocks();
  });

  it('derives regional BRL rates from one official BCRA quotation table', async () => {
    jest.spyOn(global, 'fetch').mockResolvedValue({
      ok: true,
      json: async () => ({
        results: {
          fecha: '2026-07-24',
          detalle: [
            { codigoMoneda: 'BRL', tipoCotizacion: 300 },
            { codigoMoneda: 'EUR', tipoCotizacion: 1800 },
            { codigoMoneda: 'CLP', tipoCotizacion: 1.5 },
            { codigoMoneda: 'UYU', tipoCotizacion: 36 },
            { codigoMoneda: 'COP', tipoCotizacion: 0.36 },
            { codigoMoneda: 'PEN', tipoCotizacion: 420 },
            { codigoMoneda: 'PYG', tipoCotizacion: 0.2 },
            { codigoMoneda: 'BOB', tipoCotizacion: 210 },
            { codigoMoneda: 'REF', tipoCotizacion: 1500 },
          ],
        },
      }),
    } as Response);

    const service = new BcraExchangeRateService({
      outboundRequestTimeoutMs: 1000,
    } as never);
    const rates = await service.getRegionalRates();

    expect(rates.referenceDate).toBe('2026-07-24');
    expect(rates.brlToArs).toBe(300);
    expect(rates.brlToClp).toBe(200);
    expect(rates.brlToUyu).toBeCloseTo(8.333);
    expect(rates.brlToPyg).toBe(1500);
    expect(rates.usdReferenceToArs).toBe(1500);
  });

  it('rejects an incomplete quotation table instead of inventing a rate', async () => {
    jest.spyOn(global, 'fetch').mockResolvedValue({
      ok: true,
      json: async () => ({
        results: {
          fecha: '2026-07-24',
          detalhe: [{ codigoMoneda: 'BRL', tipoCotizacion: 300 }],
        },
      }),
    } as Response);

    const service = new BcraExchangeRateService({
      outboundRequestTimeoutMs: 1000,
    } as never);

    await expect(service.getRegionalRates()).rejects.toThrow();
  });
});
