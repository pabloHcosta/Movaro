# Posicionamento jurídico — assistente, não consultor (v1)

> ⚠️ **Rascunho para revisão de um advogado.** Não é parecer jurídico. O objetivo
> é alinhar produto + texto-base; um advogado deve validar antes de publicar.

## Princípio
Movaro é um **assistente** que organiza informação e **aponta para fontes
oficiais**. Não é consultor jurídico, migratório nem financeiro, e **não dá
aconselhamento personalizado**. A autoridade é sempre a fonte oficial
(Polícia Federal, Receita Federal, gov.br, bancos, imobiliárias).

### Regras de produto (para não virar consultoria)
1. Toda informação procedimental **aponta para a fonte oficial** e pede "confirme aqui".
2. Linguagem de assistente: "normalmente / segundo [fonte] / muitos fazem assim" —
   nunca "você deve / é garantido / é assim".
3. Nada de **veredito** jurídico/financeiro. Custos = **comparação de referência**.
4. Disclaimer visível nas superfícies sensíveis (assistente, guia, viabilidade, plano).
5. Sem coletar dado pessoal sensível para "avaliar caso".

## Disclaimer in-app (implementado — `PracticalInfoDisclaimer`)
- **PT:** "Informação geral para te orientar — não é aconselhamento jurídico nem financeiro. Confirme sempre nas fontes oficiais."
- **ES:** "Información general para orientarte — no es asesoría legal ni financiera. Confirmá siempre en las fuentes oficiales."
- **EN:** "General information to orient you — not legal or financial advice. Always confirm with official sources."

Superfícies onde aparece hoje: **viabilidade** (detalhe da cidade), **assistente determinístico**,
**guia prático**. Recomendado adicionar também no **resultado do plano** e no **copiloto**.

## Esboço de Termos de Uso / Aviso Legal (rascunho p/ advogado)
1. **Natureza do serviço.** O Movaro fornece informação geral e organização de
   tarefas para apoiar quem planeja mudar de país. **Não presta serviços de
   consultoria jurídica, migratória, contábil ou financeira**, nem substitui um
   profissional habilitado ou os órgãos oficiais.
2. **Sem aconselhamento.** Conteúdos (cidades, custos, documentos, frases,
   respostas do assistente) são **referência geral**, podem estar
   **desatualizados ou incompletos**, e **não constituem recomendação
   personalizada**. Decisões são de responsabilidade do usuário.
3. **Fontes oficiais prevalecem.** Em qualquer divergência, valem as informações
   e exigências dos órgãos oficiais (PF, Receita, gov.br, etc.).
4. **Dados estimados.** Scores e custos são **heurísticas/estimativas derivadas**
   de dados públicos, não indicadores oficiais únicos.
5. **Limitação de responsabilidade.** Na máxima extensão permitida em lei, o
   Movaro não se responsabiliza por perdas decorrentes do uso da informação;
   o usuário deve confirmar tudo nas fontes oficiais.
6. **Assistente sem IA por padrão.** As respostas são determinísticas e curadas.
   Quando não existe resposta revisada, o produto deve dizer isso e apontar uma
   guia ou fonte oficial, sem improvisar.
7. **Privacidade e localização.** A localização é opcional e solicitada no
   contexto da função. Após a detecção, o app persiste localmente apenas a
   cidade confirmada e um ponto municipal aproximado, não o ponto GPS bruto.
   O usuário pode apagar esse dado em Ajustes.
8. **Metadados de evidência.** Conteúdo sensível expõe tipo de fonte, URL,
   data da última verificação e nota de escopo.
9. **Jurisdição / contato.** (A definir com o advogado.)

## A fazer com apoio jurídico
- Validar/ajustar o texto acima e a política de privacidade.
- Confirmar a redação dos disclaimers in-app.
- Definir jurisdição, contato e aceite de termos (se/where exibir).
