# Movaro — Guia de respostas rápidas v1

> Atualização arquitetural de 22 de agosto de 2026: a superfície passou a se
> chamar **Ajuda** e é autocontida. Ela compartilha catálogo, afirmações e
> fontes revisadas com a jornada, mas não importa cidade, progresso ou estado
> do plano e não abre guia, toolkit ou outra feature. Tema, sugestão e pergunta
> sempre terminam em uma resposta dentro da própria Ajuda. Links de fonte
> oficial continuam disponíveis como evidência explícita.

## Decisão de produto

Renomear a área principal `Ferramentas` para `Guia`.

- **Plano**: jornada pessoal, ordenada, persistente e com progresso.
- **Guia**: respostas, conteúdo e recursos avulsos que podem ser usados sem criar,
  alterar ou abrir um plano.
- **Ferramenta prática**: um tipo de recurso dentro do Guia, como estimador,
  busca de voos ou verificador de proposta.

O Guia deve responder à pergunta “o que preciso entender ou resolver agora?”. O
Plano deve responder “qual é a sequência da minha mudança?”.

Essa separação é uma regra de domínio, e não apenas uma mudança de texto. Abrir
uma resposta ou ferramenta nunca pode modificar o plano nem levar o usuário ao
copiloto silenciosamente. Quando houver relação útil, a tela pode oferecer uma
ação secundária explícita, como `Ver etapa relacionada` ou `Adicionar ao meu
plano`.

## Problema confirmado na implementação atual

Hoje a tela promete “Resolver agora” e afirma que não mistura pesquisa com
execução, mas `_openGuideTask` abre o `migrationPlanCopilot` sempre que há uma
cidade confirmada. Custos, voos, moradia, trabalho e documentos usam esse
mecanismo. O resultado é uma mudança de contexto inesperada justamente para o
usuário que já possui plano.

Também há três superfícies parcialmente sobrepostas:

1. `ToolsHubPage`, com cards de recursos;
2. `AssistantPage`, com conversa e guias;
3. `DocumentationGuidePage`, com busca, temas e respostas rápidas.

O conteúdo e a infraestrutura já existem, mas a arquitetura de informação não
expõe um ponto de entrada único para consulta rápida.

## Proposta de experiência

### Navegação principal

`Início · Descobrir · Plano · Guia · Mais`

`Guia` é preferível a:

- `Ferramentas`, porque boa parte da oferta é conhecimento, não utilitário;
- `Dúvidas`, porque descreve o problema, não o valor entregue;
- `Ajuda`, porque costuma ser interpretado como suporte técnico;
- `Resolver`, porque parece uma ação imediata, enquanto uma tab representa uma
  seção persistente do aplicativo.

O título da página pode ser mais orientado à tarefa: `O que você precisa
resolver?`.

### Home do Guia

Ordem recomendada:

1. **Pergunta/busca em destaque**
   - label visível: `O que você precisa resolver?`;
   - exemplo curto: `Escola, documentos, aluguel, trabalho...`;
   - aceita linguagem natural e termos de busca;
   - mantém contexto editável em chips: `Argentina → Brasil`, idioma e cidade,
     quando relevante.
2. **Dúvidas frequentes**
   - 4 a 6 perguntas completas, ajustadas ao corredor;
   - reconhecimento antes de memorização ou formulação perfeita.
3. **Explorar por tema**
   - Documentos, Moradia, Trabalho, Educação, Saúde, Dinheiro, Transporte e
     Família;
   - os nomes devem refletir a linguagem do usuário, não a estrutura interna do
     plano.
4. **Ferramentas práticas**
   - Verificar proposta, Estimar custos, Buscar voos e outros utilitários reais;
   - visualmente separados das respostas editoriais.
5. **Recentes e salvos**, apenas depois que houver uso suficiente para agregar
   valor.

Não começar a página com dois cards promocionais grandes. A pergunta principal
deve aparecer antes da dobra e receber o maior peso visual.

### Resultado rápido

Uma resposta deve abrir em uma superfície própria do Guia, sem checklist e sem
indicadores de progresso:

1. **Resposta direta**, em 2 a 4 frases;
2. **O que fazer agora**, com no máximo 3 ações;
3. **O que depende do seu contexto**, mostrando país/cidade usados;
4. **Fonte oficial e data de revisão**, como dados estruturados e clicáveis;
5. **Limites e alertas**, especialmente para temas jurídicos, médicos e fiscais;
6. **Isso ajudou?**, com feedback simples;
7. **Ações relacionadas**, como abrir uma ferramenta ou ver a etapa do plano.

`Ver etapa do plano` deve ser secundária. `Adicionar ao meu plano` precisa de
confirmação e deve explicar o efeito antes de persistir qualquer mudança.

### Exemplos de comportamento

| Intenção | Destino correto | Relação opcional com o plano |
| --- | --- | --- |
| “Como matriculo meu filho?” | Resposta Educação → matrícula escolar | Ver etapa de família |
| “Posso estudar em universidade pública?” | Resposta Educação → ensino superior | Nenhuma por padrão |
| “Quais garantias podem pedir no aluguel?” | Resposta Moradia → garantias | Ver etapa de moradia |
| “Quero buscar passagem” | Ferramenta autônoma de voos | Usar cidade do plano como valor editável |
| “Essa vaga parece golpe?” | Verificador de proposta | Nenhuma |
| “O que faço depois?” | Resposta contextual curta | Abrir próximo passo do plano, mediante ação |

## Princípios psicológicos e de conteúdo

- **Reconhecimento antes de recordação**: sugestões e temas reduzem a obrigação
  de o usuário saber o termo correto.
- **Continuidade de contexto**: uma consulta não pode transportar o usuário para
  uma jornada longa sem aviso.
- **Autonomia**: personalização usa o plano como contexto, não como prisão.
- **Progressive disclosure**: resposta primeiro; detalhes, fontes e exceções
  depois. Informações críticas, porém, não ficam escondidas.
- **Redução de carga cognitiva**: uma ação principal por tela, blocos curtos,
  linguagem literal e títulos orientados à tarefa.
- **Calibração de confiança**: mostrar origem, data e limites da informação; não
  expor um percentual interno de confiança que o usuário não sabe interpretar.
- **Falha segura**: quando não houver conteúdo revisado, dizer isso claramente e
  oferecer tema, fonte oficial ou ajuda humana, sem improvisar.

Esses princípios seguem a orientação cognitiva do W3C de tornar tarefas
importantes fáceis de encontrar, usar conteúdo curto e compreensível, manter
ajuda consistente e explicar escolhas. A orientação de IA do NIST e do Google
PAIR reforça validade, transparência, limites conhecidos e explicações que
ajudem o usuário a calibrar confiança.

## Acessibilidade mínima para lançamento

- conformidade alvo WCAG 2.2 AA;
- label programático e visível no campo de pergunta; hint curto separado;
- ordem de foco igual à ordem lógica e foco nunca encoberto pela barra inferior;
- navegação por teclado e leitor de tela em todos os cards e resultados;
- anunciar quantidade de resultados e conclusão da resposta sem ler a animação
  caractere por caractere;
- alvos de toque de pelo menos 48×48 dp, superando o mínimo WCAG de 24 CSS px;
- contraste de texto de pelo menos 4.5:1 e de componentes/foco de pelo menos
  3:1;
- suporte a escala de texto de 200% sem truncar tabs, perguntas ou CTAs;
- ícone nunca como único portador de significado;
- estados de carregamento, vazio, offline e erro com texto e ação de recuperação;
- respeitar redução de movimento e remover atraso artificial da resposta;
- manter a posição e identificação do Guia consistentes em todas as telas.

Referências principais: [WCAG
2.2](https://www.w3.org/TR/WCAG22/), [acessibilidade cognitiva do
W3C](https://www.w3.org/WAI/cognitive/), [conteúdo claro e
compreensível](https://www.w3.org/WAI/WCAG2/supplemental/objectives/o3-clear-content/),
[ajuda fácil de
encontrar](https://www.w3.org/WAI/WCAG2/supplemental/patterns/o7p05-findable-support/)
e [tab bars da
Apple](https://developer.apple.com/design/human-interface-guidelines/tab-bars).

## Arquitetura técnica recomendada

### Separar conteúdo de tarefa

Não reutilizar `GuideItem` do plano como modelo primário do Guia. Criar um
contrato de conhecimento independente e ligar os dois por referência opcional:

```text
QuickGuideEntry
  id / slug / corridorKey / locale
  topic / questionVariants / keywords
  directAnswer / actionBlocks / caveats
  contextRequirements
  sources[] { title, url, publisher, checkedAt }
  reviewedAt / expiresAt / riskLevel / coverage
  relatedToolId?
  relatedPlanItemIds[]
```

Uma etapa pode apontar para várias respostas, e uma resposta pode apontar para
zero ou várias etapas. Nenhum dos lados deve precisar abrir o outro para
funcionar.

### API estruturada

Evoluir a resposta atual, que chega como uma string, para um payload de UI:

```text
POST /v1/guide/resolve
GET  /v1/guide/home
GET  /v1/guide/entries/:slug
```

Resposta de `resolve`:

```json
{
  "entryId": "education-school-enrollment",
  "answer": "...",
  "actions": [],
  "caveats": [],
  "sources": [],
  "context": { "origin": "argentina", "destination": "brasil" },
  "coverage": "reviewed",
  "reviewedAt": "2026-08-18",
  "relatedToolId": null,
  "relatedPlanItemIds": ["..."]
}
```

`confidence` continua útil internamente para roteamento e observabilidade, mas
não deve ser a explicação apresentada ao usuário.

### Motor de resposta

Ordem segura:

1. normalizar idioma, corredor, cidade e intenção;
2. localizar entrada revisada por ID/aliases/busca textual;
3. recuperar conteúdo e fontes compatíveis com o contexto;
4. usar IA, se desejado, apenas para entender/parafrasear a pergunta dentro do
   material recuperado;
5. bloquear geração livre em temas de alto risco;
6. retornar `partial` ou `not_covered` quando faltar cobertura;
7. registrar versão do conteúdo usado para auditoria.

A base atual já tem bons fundamentos: respostas determinísticas locais, catálogo
por corredor, resolvers, limiar interno de confiança, fallback seguro e conteúdo
remoto. O principal trabalho é estruturar a saída e desacoplar o destino de UI.
O comentário do controller que ainda menciona fallback para Gemini deve ser
alinhado ao comportamento real, que hoje retorna fallback determinístico.

Referências de confiança: [NIST AI
RMF](https://airc.nist.gov/airmf-resources/airmf/), [NIST AI RMF
Core](https://airc.nist.gov/airmf-resources/airmf/5-sec-core/) e [Google PAIR —
Explainability + Trust](https://pair.withgoogle.com/chapter/explainability-trust/).

## Privacidade

- não exigir login para consultar conteúdo público;
- reutilizar contexto já informado, sem pedir os mesmos dados novamente;
- permitir remover cidade/origem da consulta;
- não enviar texto cru de perguntas para analytics por padrão;
- para melhoria de busca, registrar intenção/tópico anonimizado ou fazer coleta
  explícita com consentimento e redaction de dados pessoais;
- histórico de conversa deve continuar efêmero até existir uma proposta clara de
  valor e controle de exclusão.

## Métricas

### Métrica principal

**Taxa de resolução rápida**: porcentagem das sessões do Guia em que o usuário
encontra uma resposta útil ou inicia a ferramenta desejada sem cair no Plano e
sem reformular repetidamente.

### Eventos novos

- `guideOpened`
- `guideQuerySubmitted` — somente tópico/intenção, nunca texto cru
- `guideAnswerShown`
- `guideAnswerHelpful`
- `guideAnswerNotHelpful`
- `guideQueryReformulated`
- `guideNoResult`
- `guideSourceOpened`
- `guideToolOpened`
- `guideRelatedPlanOpened`
- `guideItemAddedToPlan`

### Indicadores e guardrails

- tempo até primeira resposta útil;
- taxa de primeira consulta bem-sucedida;
- taxa de zero resultado e reformulação;
- utilidade declarada da resposta;
- conclusão por ferramenta;
- **taxa de vazamento para o Plano** sem intenção explícita — alvo zero;
- respostas vencidas ou sem fonte;
- incidentes em conteúdo de alto risco;
- latência p50/p95, sucesso offline e falhas de acessibilidade.

## Entrega por fases

### Fase 0 — corrigir a promessa

- impedir `_openGuideTask` de abrir o copiloto automaticamente;
- manter todos os cards em superfícies independentes;
- preservar cidade do plano apenas como contexto editável;
- renomear label e título para `Guia`.

### Fase 1 — unificar a experiência

- transformar `ToolsHubPage` no novo Guia search-first;
- incorporar busca e respostas rápidas já existentes no
  `DocumentationGuidePage`;
- manter “Ferramentas práticas” como seção distinta;
- fazer o assistente abrir resultados do Guia, não respostas soltas em texto
  quando houver uma entrada revisada.

### Fase 2 — contrato estruturado

- criar `QuickGuideEntry` e endpoints de Guia;
- migrar fontes, revisão e alertas para campos estruturados;
- adicionar estados `reviewed`, `partial`, `not_covered` e `stale`;
- criar testes de contrato e auditoria de links/freshness.

### Fase 3 — ferramentas autônomas

- extrair custos, voos, moradia e trabalho que ainda dependem de widgets ou
  tarefas do plano;
- receber contexto por parâmetro, sem dependência de `generatedPlan`;
- oferecer vínculo opcional ao plano depois da conclusão.

### Fase 4 — aprender e expandir

- testar o nome `Guia` com usuários em português e espanhol;
- analisar termos sem resultado com coleta segura;
- priorizar novas respostas por demanda real;
- usar IA para entendimento linguístico apenas após avaliações de precisão,
  segurança e cobertura.

## Critérios de pronto da v1

1. Um usuário sem plano responde dúvidas de escola, documentos, moradia,
   trabalho, saúde e custos.
2. Um usuário com plano recebe a mesma experiência e não é redirecionado.
3. Toda resposta informa contexto, fonte e data de revisão.
4. Toda ferramenta funciona sem `MigrationPlan` obrigatório.
5. O plano só abre após uma ação explicitamente rotulada.
6. Busca, resposta, fontes e ferramentas passam por leitor de tela, teclado,
   escala de texto e contraste.
7. Há fallback seguro para conteúdo ausente, vencido ou de alto risco.
8. Métricas distinguem consulta, ferramenta e relação opcional com o plano.

## Pesquisa de validação antes do rollout

Fazer 5 a 8 testes moderados por idioma principal com dois grupos: pessoas que
ainda estão explorando e pessoas que já escolheram uma cidade. Tarefas:

1. descobrir como matricular um filho;
2. entender universidade pública;
3. verificar garantias de aluguel;
4. buscar voo sem criar plano;
5. encontrar a fonte oficial;
6. decidir se deseja ou não levar algo ao plano.

Observar: primeiro clique, expectativa ao tocar em `Guia`, entendimento da
diferença Plano/Guia, capacidade de voltar, confiança na resposta e percepção do
efeito de `Adicionar ao meu plano`.
