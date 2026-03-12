import { Controller, Get } from '@nestjs/common';

import { ExchangeRatesService } from '../application/services/exchange-rates.service';

@Controller({
  path: 'reference',
  version: '1',
})
export class ReferenceController {
  constructor(private readonly exchangeRatesService: ExchangeRatesService) {}

  @Get('exchange-rates/current')
  getCurrentExchangeRates() {
    return this.exchangeRatesService.getCurrentRates();
  }
}
