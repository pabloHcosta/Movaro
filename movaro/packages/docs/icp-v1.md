# Movaro ICP (Ideal Customer Profile) — v1

> Decisão P0 (estratégia). Define ranking, copy, onboarding, monetização e
> marketing. **Não tentar servir "todo mundo".**

## Decisão

- **Primário (A): migrante econômico do Sul.**
- **Secundário (B): lifestyle / remoto / aposentado.**

A é onde estão **volume e urgência**; B é real, porém menor e melhor monetizado
depois (upsell premium).

## Evidência (por que A)

- Emissão de CPF para argentinos: ~8 mil/ano (2016–2021) → **~40 mil em 2025**.
- **194,3 mil novos migrantes** no Brasil em 2024; argentinos = **2ª** nacionalidade.
- Pedidos de residência de argentinos **+162% (2019→2022)**; **~93 mil** entrando
  pelo RS só em dez/2024 (**+102%** vs. 2023).
- Fluxo puxado por crise (ex.: Misiones/erva-mate) rumo a **RS, SC, PR** e
  interior, atrás de **renda** — não de praia.

## Perfis

### A — Migrante econômico (PRIMÁRIO)
- **Quem**: classe média/trabalhadora; muitas vezes "chega com pouco".
- **Para onde**: Sul (RS/SC/PR), interior e metrópoles de emprego.
- **Job-to-be-done**: "Onde tem trabalho na minha área, cabe no meu bolso e é
  perto da Argentina? Como me viro nos primeiros 90 dias?"
- **Dores**: renda/custo, português para emprego, CPF↔endereço↔conta↔aluguel,
  CTPS, antecedentes, residência Mercosul, aluguel sem fiador.

### B — Lifestyle / remoto (SECUNDÁRIO)
- **Quem**: nômade/remoto/aposentado com mais folga financeira.
- **Para onde**: cidades-praia / qualidade de vida.
- **Job-to-be-done**: "Qual a melhor cidade pra minha nova vida?"

## Implicações no produto (o que muda)

| Área | Direção A-primário |
|---|---|
| **Ranking de cidades** | Peso default em **emprego + custo/aluguel + proximidade**. Âncoras "familiares" do shortlist = **polos de trabalho** (Sul/interior/metrópole), não praia. Praia só quando o usuário sinaliza praia/nature/remoto. |
| **Catálogo** | Manter o cinturão de emprego (Chapecó, Caxias, Joinville, Campinas, BH…) em destaque ao lado das metrópoles. |
| **Onboarding/copy** | Tom prático e acolhedor: "chegue com o pé direito, mesmo começando com pouco". |
| **Checklist** | Ênfase em CTPS, conta digital grátis, antecedentes, aluguel sem fiador, residência Mercosul. |
| **Monetização** | Lead-gen de volume: vagas, despachante, remessas, tradução juramentada. Premium/concierge fica para B (secundário). |
| **Marketing** | "Dá pra viver em Chapecó com salário X?", vagas por cidade, quebras de custo — espelhando o conteúdo que já viraliza. |

## Já implementado nesta direção
- Catálogo expandido com 8 polos de emprego (P2).
- Motor de recomendação: âncoras separadas por ICP (trabalho vs. lifestyle) e
  default "balanceado" com lean leve para custo/emprego/proximidade
  (`migration_plan_generator.dart`).

## Próximos passos sugeridos (alinhados ao ICP)
1. Copy de home/onboarding orientada a A.
2. "Lente de emprego" na exploração (filtro/realce de mercado de trabalho por área).
3. Marketing/conteúdo no estilo "vale a pena? / quebra de custo / vagas por cidade".
