# Community & Trust — spec v1 (F5 / F6)

Honest scope note: o app **já tem** sinais de comunidade/confiança (city `community`
score, `communityTips` "dica de quem já fez", `survivalPhrases`, fontes +
metodologia, lembretes de prazo). O que **falta** e como abordar sem fabricar.

## Já entregue nesta rodada (alta integridade, sem inventar dados)
- **Página "Confiança e apoio"** (`trust_and_support_page.dart`, acessível em Ajustes):
  - **Por que confiar** (F6): fontes oficiais (IBGE), metodologia, "não é aconselhamento jurídico".
  - **Apoio oficial e gratuito** (F5): rede de apoio a migrantes (gov.br), consulados
    da Argentina, Polícia Federal, direito à matrícula escolar — todos links **oficiais**.
  - **Serviços que você pode precisar** (F6): categorias (tradução juramentada,
    despachante/advogado, seguro-fiança) com **como achar de forma segura** e um
    slot honesto "parcerias verificadas em breve" — **sem listagens inventadas**.

## F6 — Diretório de serviços / monetização (precisa de insumo seu)
Modelo recomendado (lead-gen, alinhado ao ICP econômico):
- Categorias: despachante/advogado migratório, tradução juramentada, seguro-fiança,
  remessas, plano de saúde, cursos de português.
- **Requisito**: parceiros **reais e verificados** (credencial: OAB p/ advogado,
  tradutor público da Junta Comercial, CNPJ ativo). O Movaro **não deve** listar
  empresa não verificada — é o ethos de "fontes oficiais".
- Monetização: lead-gen/afiliados por categoria; destaque pago **rotulado** como anúncio.
- Próximo passo concreto: você fornece/aprova 1–2 parceiros por categoria → eu plugo
  no scaffold já criado (a UI e os slots existem).

## F5 — Comunidade real (subsistema maior; faseado)
Comunidade aberta = responsabilidade de **moderação** (spam, golpes, dados pessoais,
desinformação jurídica). Faseamento recomendado:

- **Fase 0 (agora, custo zero)**: a página de apoio + `communityTips` curadas no app.
- **Fase 1 (leve)**: canal oficial **Telegram/WhatsApp** moderado pelo time + FAQ da
  comunidade respondido pelo assistente (reusa o endpoint `/chat` que já existe).
  Sem armazenar conteúdo gerado por usuário → baixa carga de moderação.
- **Fase 2 (backend)**: feed/Q&A por cidade no **Supabase** (já configurado), com:
  - auth (já há fluxo), posts/respostas, **denúncia + remoção**, rate limit.
  - moderação: fila de denúncias, palavras bloqueadas, e termos de uso.
  - é a "V3" do roadmap original — exige decisão de produto + esforço de backend/moderação.

Recomendação: **não** abrir comunidade aberta antes da Fase 1. O maior ganho de
confiança/retenção no curto prazo vem de (a) parceiros verificados (F6) e (b) os
lembretes/checklist que já existem (F7).
