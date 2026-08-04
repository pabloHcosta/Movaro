# Auditoria técnica e redesign da tela de detalhes da cidade — V3

Data: 2026-08-04  
Escopo: 12 capturas de Florianópolis, implementação Flutter, contratos locais, seeds e serviços da API.

## Conclusão executiva

A tela continha informação suficiente, mas não uma ordem de decisão eficiente. O problema dominante era estrutural: hero e uma faixa de até 18 atalhos ficavam fora do scroll de conteúdo. Em um telefone, isso consumia de forma permanente grande parte da viewport, cortava o hero durante a rolagem e transformava cada bloco num miniartigo de peso visual semelhante.

A arquitetura correta para este produto responde, nesta ordem:

1. Vale continuar considerando esta cidade?
2. Consigo chegar e me manter nela?
3. Como tende a ser a vida cotidiana?
4. Ela vence minhas alternativas em quê?
5. Quais fontes e limitações sustentam a resposta?

O redesign implementado reorganiza a navegação global em cinco áreas: `Panorama`, `Custo e chegada`, `Vida prática`, `Comparar` e `Evidências`. O hero agora sai da tela com o scroll, a navegação por área permanece visível, compartilhar foi movido para o hero e o primeiro card mostra somente veredito, próximo passo e a principal ressalva.

## Análise das 12 capturas

| Tela | Conteúdo | Diagnóstico | Decisão de redesign |
|---|---|---|---|
| 1 | Hero, acesso rápido e decisão | O hero é atraente, mas alto. O card repete veredito, justificativas, bullets e alerta antes de o usuário chegar a um número objetivo. | Hero reduzido e rolável; veredito condensado em uma conclusão, um próximo passo e uma ressalva. |
| 2 | Resumo e quatro critérios | Três cards em colunas truncam texto em espanhol (`Compatible con tu...`, `Por encima de tus op...`). | Em telefones, os indicadores passam a empilhar e não usam reticências como substituto de conteúdo. |
| 3 | Custo mensal e relação com salário | Há boa intenção analítica, mas os valores se repetem em cards seguintes. O disclaimer legal ocupa mais espaço que a ação. | Um valor principal primeiro; decomposição e metodologia depois. Disclaimer deve ser curto e abrir detalhe. |
| 4 | Reserva, pressão inicial e primeiro foco | Estrutura útil, mas `Entender mejor` se repete em cada célula sem indicar o destino. | Tratar o bloco como uma única decisão de chegada, com detalhes por métrica e rótulos específicos. |
| 5 | Narrativa e clima | Dois parágrafos narrativos e outro alerta retomam informação já dita. | Liderar cada card com uma frase factual; manter explicação longa sob demanda. |
| 6 | Afinidade e bairros | `92/100` aparece duas vezes; a API concatena `92score`; textos de opinião em português vazam na interface espanhola. | Remover duplicata, formatar unidades e chamar explicitamente de `Índice Movaro`, não fato social observado. |
| 7 | Lista de bairros e fortalezas | `Sede · Sede · Florianopolis` e `Córrego Grande · Córrego Grande...` expõem a estrutura bruta do OSM. | Deduplicar nome/bairro/região sem diferenciar maiúsculas e minúsculas. |
| 8 | Fortalezas e comparação | A cópia fala que o dado “vem da API”, linguagem interna sem valor para o usuário. | Trocar por instrução orientada à tarefa: comparar cidades pelos mesmos critérios. |
| 9 | Sazonalidade | `~3 milhões` e `população ×2` parecem oficiais pelo peso visual, mas o seed declara `sourceType: curated`, `não oficial` e não possui URL. | Exibir no próprio bloco `Estimativa Movaro · não é dado oficial`. Não usar essa estimativa como fato sem fonte rastreável. |
| 10 | Voo, mapa e opinião | O mapa é evidência secundária e está corretamente mais abaixo, mas a página ainda exige scroll excessivo para chegar a ele. | Agrupar mapa, voo, sazonalidade e opinião em `Evidências`. |
| 11 | Indicadores e realidade financeira | É a visualização mais densa e objetiva, mas chega tarde e mistura dado oficial, derivado e interno sob o mesmo tratamento. | Manter no deep dive, sempre com tipo da fonte, período e metodologia junto da métrica. |
| 12 | Contexto e melhor época para voar | População e código IBGE são fatos; afinidade e suporte ao espanhol são heurísticas. A tela os apresenta com barras equivalentes. | Separar `Dados oficiais` de `Índices Movaro`; nunca usar a mesma semântica visual para ambos. |

## Auditoria de dados

### Dados verificáveis e adequados

- População `587.486` e código IBGE `4205407`: conferem com a estimativa IBGE 2025 e com a página oficial do município.
- IDHM `0,847`: dado histórico de 2010; é válido se o ano permanecer sempre visível.
- Temperatura e vento: payload de Open-Meteo; devem mostrar estado de atualização e falhar sem inventar valor.
- Segurança: o backend usa homicídios por 100 mil do Atlas da Violência/Ipea e produz um score derivado. O score não é classificação oficial e não cobre crime patrimonial nem variação por bairro.

### Dados reais, mas derivados ou voláteis

- Custo, aluguel, salário e transporte vêm de snapshot do Livingcost convertido por câmbio. O snapshot local é de `2026-03-11`; a fonte externa é mutável e em junho de 2026 já apresentava outros valores. A UI não deve chamá-los de preço atual sem atualizar ou mostrar claramente a data.
- `R$ 4.350–5.100/mês` é uma composição do produto, não um orçamento universal. Perfil, bairro, temporada, tipo de contrato e câmbio alteram o resultado.
- Cobertura salarial de `80%` é uma razão entre duas estimativas; deve ser descrita como referência, não diagnóstico financeiro.

### Dados curados ou internos que pareciam fatos

- Afinidade argentina `92`, suporte ao espanhol `90`, mercado de trabalho e scores Movaro são seeds/heurísticas internas.
- `~3 milhões de turistas`, `×2`, meses de pico e multiplicação de aluguel são cenários curados no repositório, sem URL de origem.
- Textos como “popular entre argentinos” e “adaptação mais fácil” são interpretações do modelo; não foram sustentados por pesquisa amostral exposta ao usuário.
- A versão anterior calculava a prioridade `warm_climate` usando o score de economia. Isso era semanticamente incorreto e foi removido: sem métrica de clima compatível, essa prioridade não participa do veredito local.

## Hierarquia de informação implementada

### Panorama

- veredito curto
- principal ressalva
- resumo comparável
- critérios essenciais
- ação de escolher ou comparar

### Custo e chegada

- custo mensal de referência
- relação com renda
- reserva inicial
- pressão de chegada
- custo/impacto do voo

### Vida prática

- rotina
- clima
- índice de adaptação
- bairros de entrada

### Comparar

- fortalezas relativas
- comparação com as alternativas do plano

### Evidências

- sazonalidade
- mapa
- opinião externa
- análise detalhada
- voos
- fontes e metodologia

## Base técnica e normativa

- Apple HIG recomenda hierarquia clara entre controles/navegação e conteúdo, além de tornar a continuidade do scroll perceptível.
- WCAG 2.2 exige alvo mínimo de 24×24 CSS px (AA) e recomenda 44×44 para alvos importantes; a faixa anterior tinha altura total de 40 dp. O redesign usa 48 dp.
- WCAG 2.2 Reflow determina leitura sem rolagem em duas dimensões a 320 px. A navegação horizontal permanece um controle, mas o conteúdo e os indicadores refluem sem truncar em telefones.
- A heurística `Recognition rather than recall` do Nielsen Norman Group sustenta manter cinco áreas reconhecíveis durante a rolagem em vez de obrigar o usuário a lembrar uma lista inicial de 18 destinos.
- O GOV.UK Design System recomenda títulos front-loaded, hierarquia consistente e cautela com accordions; esconder conteúdo não substitui simplificação nem bons headings.

Referências:

- https://developer.apple.com/design/human-interface-guidelines
- https://developer.apple.com/design/human-interface-guidelines/scroll-views
- https://www.w3.org/WAI/WCAG22/Understanding/target-size-minimum.html
- https://www.w3.org/WAI/WCAG22/Understanding/reflow.html
- https://media.nngroup.com/media/articles/attachments/Heuristic_6_A4_compressed.pdf
- https://design-system.service.gov.uk/styles/headings/
- https://design-system.service.gov.uk/components/accordion/
- https://www.ibge.gov.br/cidades-e-estados/sc/florianopolis.html
- https://livingcost.org/cost/brazil/florianopolis

## Critérios de sucesso a medir

O expert review não substitui teste com usuários. Instrumentar e validar:

- tempo mediano até o usuário responder se continuaria considerando a cidade
- taxa de abertura de `Custo e chegada` e `Evidências`
- taxa de comparação antes de escolher cidade
- entendimento correto da diferença entre dado oficial, derivado e Índice Movaro
- conclusão da ação principal sem retornar ao topo
- teste de Dynamic Type/escala 200%, VoiceOver/TalkBack, contraste e viewport de 320 dp

