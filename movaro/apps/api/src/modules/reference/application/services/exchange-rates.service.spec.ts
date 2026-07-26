import { describe, expect, it, jest } from '@jest/globals';
import { BcbExchangeRateService } from '../../../../integrations/exchange/bcb-exchange-rate.service';
import { BcraExchangeRateService } from '../../../../integrations/exchange/bcra-exchange-rate.service';
import { ExchangeRatesService } from './exchange-rates.service';

describe('ExchangeRatesService', () => {
  it('builds internally consistent rates using official BCB and BCRA data', async () => {
    const bcb = {
      getUsdToBrl: jest.fn().mockResolvedValue({
        usdToBrl: 5,
        referenceDate: todayDayFirst(),
      }),
    } as unknown as BcbExchangeRateService;
    const bcra = {
      getRegionalRates: jest.fn().mockResolvedValue({
        brlToArs: 300,
        brlToEur: 0.17,
        brlToClp: 185,
        brlToUyu: 8,
        brlToCop: 820,
        brlToPen: 0.72,
        brlToPyg: 1500,
        brlToBob: 1.35,
        usdReferenceToArs: 1500,
        referenceDate: todayIso(),
      }),
    } as unknown as BcraExchangeRateService;

    const snapshot = await new ExchangeRatesService(
      bcb,
      bcra,
    ).getCurrentRates();

    expect(snapshot.usdToBrl).toBe(5);
    expect(snapshot.brlToArs).toBe(300);
    expect(snapshot.usdToArs).toBe(1500);
    expect(snapshot.brlToClp).toBe(185);
    expect(snapshot.source).toBe('official');
    expect(snapshot.isIndicative).toBe(true);
    expect(snapshot.sources).toHaveLength(2);
    expect(snapshot.sources.join(' ')).not.toContain('CurrencyAPI');
  });

  it('rejects official sources that disagree on the implied cross-rate', async () => {
    const bcb = {
      getUsdToBrl: jest.fn().mockResolvedValue({
        usdToBrl: 5,
        referenceDate: todayDayFirst(),
      }),
    } as unknown as BcbExchangeRateService;
    const bcra = {
      getRegionalRates: jest.fn().mockResolvedValue({
        brlToArs: 300,
        brlToEur: 0.17,
        brlToClp: 185,
        brlToUyu: 8,
        brlToCop: 820,
        brlToPen: 0.72,
        brlToPyg: 1500,
        brlToBob: 1.35,
        usdReferenceToArs: 2100,
        referenceDate: todayIso(),
      }),
    } as unknown as BcraExchangeRateService;

    await expect(
      new ExchangeRatesService(bcb, bcra).getCurrentRates(),
    ).rejects.toThrow('diverge');
  });
});

function todayIso(): string {
  return new Date().toISOString().slice(0, 10);
}

function todayDayFirst(): string {
  const [year, month, day] = todayIso().split('-');
  return `${day}/${month}/${year}`;
}
