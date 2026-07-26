import { Injectable, Logger } from '@nestjs/common';

import { ExchangeRatesService } from '../../../../reference/application/services/exchange-rates.service';

export interface CostResolverResult {
  confidence: number;
  summary: string;
}

@Injectable()
export class CostResolverService {
  private readonly logger = new Logger(CostResolverService.name);

  constructor(private readonly exchangeRatesService: ExchangeRatesService) {}

  async resolve(locale: string = 'pt'): Promise<CostResolverResult> {
    try {
      const rates = await this.exchangeRatesService.getCurrentRates();

      const thousandArsToBrl = (rates.arsToBrl * 1000).toFixed(0);
      const brlToArs = rates.brlToArs.toFixed(0);
      const usdToBrl = rates.usdToBrl.toFixed(2);

      const summary = this.buildSummary(
        {
          thousandArsToBrl,
          brlToArs,
          usdToBrl,
          referenceDate: rates.referenceDate,
        },
        locale,
      );

      return { confidence: 0.88, summary };
    } catch (err) {
      this.logger.warn(`Cost resolver: exchange rate fetch failed — ${err}`);
      return {
        confidence: 0.5,
        summary: this.staticSummary(locale),
      };
    }
  }

  private buildSummary(
    rates: {
      thousandArsToBrl: string;
      brlToArs: string;
      usdToBrl: string;
      referenceDate: string;
    },
    locale: string,
  ): string {
    if (locale === 'es') {
      return (
        `📊 **Cambio indicativo (${rates.referenceDate}, BCB + BCRA):**\n` +
        `• R$ 1 ≈ AR$ ${rates.brlToArs}\n` +
        `• AR$ 1.000 ≈ R$ ${rates.thousandArsToBrl}\n` +
        `• US$ 1 ≈ R$ ${rates.usdToBrl}\n\n` +
        `El costo real depende de la ciudad, la zona, la vivienda y tu estilo de vida. ` +
        `Usá la franja económica y la franja con más comodidad de la ciudad elegida; ` +
        `si el presupuesto queda ajustado, compará una zona más económica o una ciudad alternativa.\n\n` +
        `⚠️ Son referencias para planificar, no una cotización bancaria ni una promesa de costo.`
      );
    }

    if (locale === 'en') {
      return (
        `📊 **Indicative exchange (${rates.referenceDate}, BCB + BCRA):**\n` +
        `• R$1 ≈ AR$${rates.brlToArs}\n` +
        `• AR$1,000 ≈ R$${rates.thousandArsToBrl}\n` +
        `• US$1 ≈ R$${rates.usdToBrl}\n\n` +
        `Actual cost depends on the city, area, housing and lifestyle. Use the chosen ` +
        `city's economical and more-comfortable ranges; if the budget is tight, compare ` +
        `a lower-cost area or an alternative city.\n\n` +
        `⚠️ These are planning references, not a bank quote or a cost guarantee.`
      );
    }

    // pt (default)
    return (
      `📊 **Câmbio indicativo (${rates.referenceDate}, BCB + BCRA):**\n` +
      `• R$ 1 ≈ AR$ ${rates.brlToArs}\n` +
      `• AR$ 1.000 ≈ R$ ${rates.thousandArsToBrl}\n` +
      `• US$ 1 ≈ R$ ${rates.usdToBrl}\n\n` +
      `O custo real depende da cidade, da zona, da moradia e do estilo de vida. ` +
      `Use as faixas econômica e mais confortável da cidade escolhida; se o orçamento ` +
      `ficar apertado, compare uma zona mais econômica ou uma cidade alternativa.\n\n` +
      `⚠️ São referências de planejamento, não cotação bancária nem promessa de custo.`
    );
  }

  private staticSummary(locale: string): string {
    if (locale === 'es') {
      return (
        `Los costos varían según la ciudad, la zona y el estilo de vida. ` +
        `Consultá las franjas de la ciudad en Movaro para comparar una opción económica ` +
        `con otra más cómoda.\n\nNo pude validar el cambio ahora; los valores permanecen ` +
        `en reales hasta obtener una referencia oficial del BCB y BCRA.`
      );
    }
    if (locale === 'en') {
      return (
        `Costs vary by city, area and lifestyle. Use Movaro's city ranges to compare ` +
        `an economical option with a more comfortable one.\n\nI could not validate the ` +
        `exchange rate now; amounts remain in BRL until an official BCB and BCRA ` +
        `reference is available.`
      );
    }
    return (
      `Os custos variam por cidade, zona e estilo de vida. Use as faixas da cidade ` +
      `no Movaro para comparar uma opção econômica com outra mais confortável.\n\n` +
      `Não consegui validar o câmbio agora; os valores permanecem em reais até haver ` +
      `uma referência oficial do BCB e do BCRA.`
    );
  }
}
