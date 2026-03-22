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

      const arsToBrl = rates.arsToBrl.toFixed(4);
      const brlToArs = rates.brlToArs.toFixed(2);
      const usdToBrl = rates.usdToBrl.toFixed(2);

      const summary = this.buildSummary(
        { arsToBrl, brlToArs, usdToBrl },
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
    rates: { arsToBrl: string; brlToArs: string; usdToBrl: string },
    locale: string,
  ): string {
    if (locale === 'es') {
      return (
        `📊 **Tipo de cambio actual (fuente oficial):**\n` +
        `• 1 ARS = ${rates.arsToBrl} BRL\n` +
        `• 1 BRL = ${rates.brlToArs} ARS\n` +
        `• 1 USD = ${rates.usdToBrl} BRL\n\n` +
        `**Costos de vida estimados en Brasil (referencia para argentinos):**\n` +
        `• Alquiler 1 dorm. en ciudad mediana: R$ 1.000–1.800/mes\n` +
        `• Alquiler 1 dorm. en São Paulo / Florianópolis: R$ 2.000–3.500/mes\n` +
        `• Comida (supermercado mensual, 1 persona): R$ 600–900\n` +
        `• Transporte público mensual: R$ 150–250\n` +
        `• Internet + servicios básicos: R$ 200–350/mes\n\n` +
        `⚠️ Los valores son estimaciones. El tipo de cambio ARS/BRL fluctúa — ` +
        `verificar siempre antes de tomar decisiones financieras.`
      );
    }

    if (locale === 'en') {
      return (
        `📊 **Current exchange rates (official source):**\n` +
        `• 1 ARS = ${rates.arsToBrl} BRL\n` +
        `• 1 BRL = ${rates.brlToArs} ARS\n` +
        `• 1 USD = ${rates.usdToBrl} BRL\n\n` +
        `**Estimated cost of living in Brazil:**\n` +
        `• 1-bedroom apartment in mid-size city: R$ 1,000–1,800/month\n` +
        `• 1-bedroom in São Paulo / Florianópolis: R$ 2,000–3,500/month\n` +
        `• Groceries (1 person/month): R$ 600–900\n` +
        `• Monthly public transport: R$ 150–250\n` +
        `• Internet + utilities: R$ 200–350/month\n\n` +
        `⚠️ These are estimates. The ARS/BRL rate fluctuates — always verify ` +
        `before making financial decisions.`
      );
    }

    // pt (default)
    return (
      `📊 **Câmbio atual (fonte oficial):**\n` +
      `• 1 ARS = ${rates.arsToBrl} BRL\n` +
      `• 1 BRL = ${rates.brlToArs} ARS\n` +
      `• 1 USD = ${rates.usdToBrl} BRL\n\n` +
      `**Custos estimados de vida no Brasil:**\n` +
      `• Aluguel 1 quarto em cidade média: R$ 1.000–1.800/mês\n` +
      `• Aluguel 1 quarto em São Paulo / Florianópolis: R$ 2.000–3.500/mês\n` +
      `• Alimentação (supermercado mensal, 1 pessoa): R$ 600–900\n` +
      `• Transporte público mensal: R$ 150–250\n` +
      `• Internet + contas básicas: R$ 200–350/mês\n\n` +
      `⚠️ Esses valores são estimativas. O câmbio ARS/BRL oscila — ` +
      `verifique sempre antes de tomar decisões financeiras.`
    );
  }

  private staticSummary(locale: string): string {
    if (locale === 'es') {
      return (
        `Los costos de vida en Brasil varían según la ciudad. En general:\n` +
        `• Alquiler 1 dorm.: R$ 1.000–3.500/mes según la ciudad\n` +
        `• Comida mensual (1 persona): R$ 600–900\n` +
        `• Transporte mensual: R$ 150–250\n\n` +
        `No pude obtener el tipo de cambio actual. ` +
        `Verificá en el Banco Central de Argentina (BCRA) o BCB para el cambio ARS/BRL.`
      );
    }
    if (locale === 'en') {
      return (
        `Cost of living in Brazil varies by city. General estimates:\n` +
        `• 1-bedroom rent: R$ 1,000–3,500/month depending on city\n` +
        `• Monthly groceries (1 person): R$ 600–900\n` +
        `• Monthly transport: R$ 150–250\n\n` +
        `Could not fetch current exchange rates. ` +
        `Check BCRA or BCB for the current ARS/BRL rate.`
      );
    }
    return (
      `Os custos de vida no Brasil variam por cidade. Estimativas gerais:\n` +
      `• Aluguel 1 quarto: R$ 1.000–3.500/mês dependendo da cidade\n` +
      `• Alimentação mensal (1 pessoa): R$ 600–900\n` +
      `• Transporte mensal: R$ 150–250\n\n` +
      `Não consegui buscar o câmbio atual. ` +
      `Verifique no Banco Central (BCB) ou BCRA para o câmbio ARS/BRL.`
    );
  }
}
