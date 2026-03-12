import { Module } from '@nestjs/common';

import { BcbExchangeRateService } from '../../integrations/exchange/bcb-exchange-rate.service';
import { BcraExchangeRateService } from '../../integrations/exchange/bcra-exchange-rate.service';
import { ExchangeRatesService } from './application/services/exchange-rates.service';
import { ReferenceController } from './presentation/reference.controller';

@Module({
  controllers: [ReferenceController],
  providers: [
    BcbExchangeRateService,
    BcraExchangeRateService,
    ExchangeRatesService,
  ],
})
export class ReferenceModule {}
