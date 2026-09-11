# Parecer de produto e avaliação técnica do Movaro

Data: 10/09/2026. Estágio informado pelo fundador: desenvolvimento, sem usuários externos.

Base da avaliação: checkout `bb92181c`, incluindo as alterações locais existentes durante a análise. Os documentos de estratégia foram tratados como intenção; a implementação observada foi usada para verificar entrega. As mudanças descritas abaixo foram implementadas depois do diagnóstico inicial.

Implementação iniciada após o parecer: a busca de origem agora prioriza correspondência exata e oferece uma entrada agregada para Buenos Aires/CABA; datas futuras deixam de ser classificadas como atuais na recomendação; falhas de IBGE/SIDRA usam snapshots locais explicitamente rotulados; e todos os cenários do orçamento aplicam a composição familiar, mostram suas premissas e aceitam valores reais persistidos pelo usuário. As configurações também permitem criar um backup portátil e restaurar jornada, plano, rascunho e progresso em outro aparelho, com formato versionado, validação prévia e rollback em falhas de gravação. A etapa de mercado de trabalho passou a avaliar área, experiência, português, regulamentação profissional, vagas verificadas e compatibilidade entre renda esperada e custo essencial. A busca de aluguel fixo passou a avaliar imóveis comparados, peso da moradia na renda, desembolso inicial, comprovação, garantia, contingência temporária e obtenção efetiva do contrato e das chaves. Os dois diagnósticos geram obstáculos e ações persistidos no plano. A instrumentação do piloto agora pergunta, de forma opcional e consentida, se o usuário entendeu a próxima ação, realizou algo fora do aplicativo e percebeu ajuda concreta; envia apenas categorias fechadas e limita a frequência por fase e após recusa. Os demais itens permanecem recomendações.

**Parecer: o Movaro tem uma proposta coerente e uma base funcional suficientemente desenvolvida para preparar um piloto acompanhado. Entrega organização e orientação contextual; a qualidade das decisões financeiras, a continuidade da execução e a adequação comercial ainda precisam de validação. Expandir o escopo agora tende a produzir menos aprendizado que colocar a jornada principal nas mãos de usuários reais.**

## 1. O problema que o produto deve resolver

A proposta mais defensável é: “Ajudar argentinos a avaliar uma mudança para o Brasil e executar a preparação e a chegada, sabendo o próximo passo, as dependências e o que precisam confirmar.”

Há três problemas distintos: escolher uma cidade viável; preparar documentos, recursos e moradia; conseguir continuar quando uma etapa trava. A implementação cobre os três em graus diferentes. A unidade de valor não deveria ser o número de telas, cidades ou respostas: deveria ser uma decisão melhor ou um impedimento resolvido.

O produto pode ter valor mesmo sem intermediar aluguel, conseguir emprego ou protocolar residência. Porém, precisa explicar onde sua orientação termina e o usuário passa a depender de uma instituição ou prestador. “Etapa marcada como concluída” também não equivale automaticamente a resultado externo obtido.

## 2. A dor de mercado é plausível; o público prioritário permanece uma hipótese

Serviços públicos separados, requisitos documentais e organizações que oferecem apoio a trabalho e documentação sustentam a existência de problemas práticos. A [Polícia Federal distingue rotas de residência](https://www.gov.br/pf/pt-br/assuntos/imigracao/autorizacao-residencia/formularios), e a [Missão Paz mantém um programa de trabalho e orientação documental](https://missaonspaz.org/programa-trabalho/). Isso não demonstra, por si só, demanda pelo Movaro ou disposição para pagar.

O documento [ICP](icp-v1.md) prioriza o migrante econômico e afirma que ele concentra volume e urgência. Essa prioridade pode ser útil para testar, mas sua fundamentação precisa ser corrigida:

- CPF não mede mudança de residência. A [Receita permite inscrição inclusive a estrangeiros não residentes](https://servicos.receita.fazenda.gov.br/servicos/cpf/cpfestrangeiro/).
- Entradas na fronteira não equivalem a pessoas que se estabeleceram no Brasil. O [OBMigra separa movimentação fronteiriça, registros de residência e trabalho formal](https://www.gov.br/mj/pt-br/assuntos/seus-direitos/migracoes/portal-de-imigracao-laboral/obmigra-1/relatorios-obmigra/dados-consolidados/2024/obmigra-dados-consolidados-2024).
- A afirmação de argentinos como segunda nacionalidade em 2024 diverge dos [dados consolidados do OBMigra](https://portaldeimigracao.mj.gov.br/images/DADOS_CONSOLIDADOS_2024_25.pdf), que apontam venezuelanos, bolivianos e argentinos nessa ordem para regularização.

Não foi validado o número de aproximadamente 40 mil CPFs em 2025 nem a decomposição dos 93 mil ingressos citados no ICP. Não usar esses números para estimar mercado pagante antes de recuperar fonte, definição, período e denominador.

Recomendação: manter Argentina → Brasil e testar um recorte inicial mais observável: pessoas com intenção de mudar nos próximos seis meses, buscando trabalho e avaliando um pequeno conjunto de cidades. Esse é um recorte de experimento, não uma conclusão sobre o maior segmento. Comparar seus resultados com uma pequena amostra de pessoas com renda remota.

## 3. O que está sendo entregue

“Presente” significa encontrado no código e, quando indicado, observado na interface; não significa eficácia comprovada com usuários.

| Necessidade | Entrega atual | Avaliação |
|---|---|---|
| Entender por onde começar | Entrada sem cadastro, questionário curto, exploração e ajuda | Boa base para reduzir esforço inicial; falta medir compreensão e abandono |
| Escolher cidade | Recomendação por perfil, comparação, restrições, evidências, cobertura e estabilidade | Útil para formar uma lista de opções; não comprova viabilidade individual |
| Organizar preparação | Guia contextual, dependências e estados de tarefa | Uma das partes mais fortes da proposta; já ultrapassa um checklist estático |
| Preparar documentação | Checklist e decisões condicionais, inclusive rota bilateral argentina | Presente; falta validar entendimento e aplicação em casos reais |
| Estimar dinheiro necessário | Pré-orçamento e cenários de instalação/30/90 dias | Presente, mas depende de hipóteses e multiplicadores; precisa de calibração |
| Procurar trabalho | Lente por setor, sinais municipais e orientação | Parcial: setor forte não equivale a vaga adequada, salário acessível ou empregabilidade pessoal |
| Viabilizar moradia | Orientação, buscas externas, análise de riscos e diagnóstico persistido das condições de acesso | O fluxo agora diferencia busca, proposta em análise e contrato com chaves; eficácia e aprovação real ainda precisam de validação |
| Acompanhar chegada | Conteúdo e tarefas de primeira semana, mês e trimestre | Presente; resultado externo e ajuda diante de bloqueios precisam ser avaliados |
| Retomar a jornada | Persistência local, snapshots associados a sessão Supabase e backup portátil explícito | A troca de aparelho passa a ser possível por exportação/restauração manual; ainda falta validar a compreensão e conveniência do fluxo com usuários |

Evidências principais: `apps/app/lib/features/migration_questionnaire/application/services/migration_guide_registry.dart:33`; `entry_regularization_decision_engine.dart:33`; `landing_budget_estimator.dart:60`; `arrival_execution_builder.dart:34`; `apps/app/lib/features/cities/application/services/city_work_area_lens.dart:43`; `apps/app/lib/features/migration_questionnaire/presentation/pages/migration_plan_copilot_page.dart:8986` e `:9046`.

Parte da estratégia antiga lista orçamento, documentos e chegada como trabalho futuro. Essas funções já existem. O trabalho seguinte é aprofundar e testar a entrega, evitando construir novamente o que já foi feito.

## 4. O que está bom

**Entrada sem obrigar cadastro.** A navegação local permitiu entrar, escolher origem manualmente e responder ao questionário. Isso permite experimentar valor antes de assumir compromisso com o produto.

**Uma jornada que mantém contexto.** Cidade confirmada, perfil e progresso influenciam a preparação. O usuário não precisa recompor todas as decisões a cada assunto.

**Personalização útil.** Filhos, composição familiar, necessidades práticas e situação migratória são mais relevantes que apenas perguntar preferências de estilo de vida. A rota bilateral já está presente no motor de entrada/regularização e corresponde a uma [via publicada pela PF](https://www.gov.br/pf/pt-br/assuntos/imigracao/autorizacao-residencia/acordo-de-residencia-brasil-e-argentina). Isso não constitui auditoria jurídica integral do conteúdo.

**Preocupação com confiança.** Evidências, origem dos dados, cobertura, estabilidade e avisos de atualização aparecem na arquitetura de recomendação. Existe uma decisão explícita de não gerar um ranking alternativo offline com outra metodologia.

**Base de testes real.** Há testes de decisões migratórias, documentos, orçamento, persistência, fontes, navegação e falhas de rede. Não se trata apenas de uma interface demonstrativa.

**Telemetria com limites de privacidade.** O código prevê consentimento e evita enviar respostas, valores financeiros e referência específica da tarefa ao endpoint agregado. A ausência de usuários externos significa que essa instrumentação ainda precisa ser comprovada em operação.

## 5. Ajustes prioritários

### A. Transformar estimativa financeira em decisão compreensível — prioridade alta

O orçamento de execução pode multiplicar uma base individual por composição familiar. Sem snapshot, deriva valores de scores ou usa base fixa; o fator familiar tem teto de 3,6. Os snapshots disponíveis usam aluguel de um quarto. Isso pode ajudar na exploração, mas não substitui orçamento do imóvel e da família concreta.

Evidências: `landing_budget_estimator.dart:178` e `:207`; `apps/api/src/modules/cities/application/services/city-budget-snapshot.service.ts:34`. O pré-orçamento também utiliza hipóteses fixas e, por desenho, não persiste seus dados no plano: `apps/app/lib/features/explore/application/services/pre_plan_budget_estimator.dart:99`.

**Ajuste:** mostrar e permitir editar os principais componentes, distinguir custo recorrente de desembolso inicial, indicar fonte/data e dar visibilidade à reserva para período sem renda. Evitar que a comparação entre simuladores pareça uma contradição: explicar escopo e oferecer reaproveitamento explícito dos dados úteis.

**Aceite:** o participante consegue explicar quanto precisa para chegar, quanto gastaria por mês, quais valores são hipóteses e o que muda se ficar mais tempo sem emprego. Famílias maiores não ficam silenciosamente limitadas a um multiplicador máximo.

### B. Melhorar confiabilidade do catálogo e da recomendação — prioridade alta

O catálogo da API é montado em `Promise.all`; cada merge depende de serviços IBGE. Uma rejeição pode impedir o catálogo completo. Há cache em memória, mas o caminho de montagem não apresenta recuperação por cidade. No cliente, GETs têm cache/snapshot para `NetworkException`; erros de API permanecem visíveis, e recomendações POST não têm fallback.

Evidências: `apps/api/src/modules/cities/application/services/cities-catalog.service.ts:161`; `city-merge.service.ts:40`; `apps/app/lib/features/cities/data/datasources/cities_remote_data_source.dart:22`.

**Ajuste:** servir catálogo previamente validado, atualizar de forma controlada, isolar falhas de provedores/cidades e oferecer retomada clara da recomendação sem perder respostas. A opção de cidade manual pode preservar utilidade quando o ranking não puder ser calculado.

**Aceite:** simular indisponibilidade de um provedor e HTTP 5xx; catálogo utilizável, informação de atualização correta e respostas preservadas. Esse risco foi identificado no código; não foi medido como incidente de produção.

### C. Fazer atualidade dos dados participar da política de decisão — prioridade alta

O ranking calcula freshness separadamente do score. Na função de freshness da API, uma data futura gera idade negativa e pode ser classificada como recente. A documentação de governança afirma que datas futuras são inválidas, portanto há inconsistência específica.

Evidência: `apps/api/src/modules/cities/application/services/city-recommendation.service.ts:640` e `:1013`; [governança](source-freshness-governance-v1.md).

**Ajuste:** invalidar datas futuras; definir tratamento de dado ausente/vencido por dimensão. Não aplicar penalidade automática indiscriminada: um indicador oficial histórico e um preço de aluguel precisam de políticas diferentes. A data de revisão da fonte também deve ser distinguida do período de referência do dado.

**Aceite:** nenhum timestamp futuro recebe selo de atualidade; a recomendação deixa claro quando uma prioridade importante está sustentada por dados limitados. Ter links válidos não deve ser tratado como confirmação de conteúdo atualizado.

### D. Corrigir relevância da busca de origem — prioridade média, baixo esforço provável

Na interface local, “Buenos Aires” mostrou primeiro “Buenos Aires Chico”; “Rosario” apareceu depois de localidades como “Rosario de Lerma”. O buscador prioriza prefixos, mas não correspondência exata; depois ordena pelo nome de exibição. O resultado introduz atrito antes do valor principal.

Evidência: `apps/app/lib/features/location/argentina_locality_catalog.dart:40`. Observação em Flutter Web de desenvolvimento.

**Ajuste:** priorizar nome exato, depois aliases e prefixos; tratar CABA/Buenos Aires explicitamente e distinguir cidade de província. Preservar opção manual e não tornar geolocalização obrigatória.

**Aceite:** Rosario exata em primeiro; capital argentina facilmente encontrável por nomes usuais; seleção sem pedir permissão de localização.

### E. Validar a recuperação portátil e definir a evolução de identidade — prioridade alta

Há persistência e sincronização, mas a restauração automática retorna sem agir quando já existem dados locais; a sessão pode ser anônima. O bootstrap ainda injeta autenticação simulada, cujo login é bloqueado fora de desenvolvimento. Isso não demonstra recuperação por identidade em novo aparelho. Como caminho explícito, o produto agora exporta e restaura um backup portátil com jornada, plano, rascunho, progresso e orçamento informado.

Evidências: `migration_state_sync_service.dart:78`, `:169`; `apps/app/lib/app/bootstrap/bootstrap.dart:66`; `apps/app/lib/features/auth/data/datasources/fake_auth_data_source.dart:24`.

**Ajuste:** no piloto, comunicar e testar a recuperação manual por backup. Se a promessa futura exigir sincronização automática entre aparelhos, implementar vínculo de identidade, recuperação e política de conflitos antes de anunciar essa capacidade.

**Aceite:** fechar/reabrir preserva progresso; participantes conseguem transferir o backup entre aparelhos e entendem que o arquivo contém dados privados. Nunca insinuar que um snapshot anônimo garante recuperação universal.

### F. Aproximar orientação de emprego e moradia dos obstáculos reais — prioridade alta de produto

A lente de emprego filtra `topIndustries` e ordena scores municipais. É uma orientação inicial útil, mas insuficiente para responder “consigo emprego na minha área e alugar com a renda que provavelmente terei?”.

A etapa de mercado de trabalho agora registra sinais pessoais, exige comparação de vagas reais e produz ações para lacunas de idioma, experiência, reconhecimento profissional ou renda. A etapa de aluguel fixo registra condições de propostas reais e aponta lacunas de comprovação, garantia, caixa inicial, peso mensal e contingência. A tarefa de moradia só pode ser concluída quando o usuário informa contrato assinado e chaves recebidas. Os resultados declaram explicitamente os limites: não garantem contratação, aprovação, disponibilidade ou segurança contratual.

**Ajuste:** validar os diagnósticos de trabalho e moradia no piloto, medindo se cada ação ajuda o participante a sair do bloqueio. Não é necessário construir um marketplace: uma lista curta e revisada de caminhos locais, testada com participantes, já pode produzir aprendizado.

**Aceite:** distinguir “cidade com setor relevante” de “oportunidade confirmada”; registrar se o usuário conseguiu avançar após seguir a orientação e por que não conseguiu quando falhou.

### G. Reduzir risco de manutenção nas telas centrais — prioridade média

A organização geral separa módulos e serviços, mas a página de copilot tem cerca de 13,7 mil linhas, e a home cerca de 3 mil. Isso aumenta a superfície de regressões e dificulta revisar regras, estados e traduções em mudanças frequentes.

**Ajuste:** extrair fluxos por responsabilidade ao corrigir e validar a jornada. Evitar uma reescrita ampla antes do piloto. Adicionar testes de contrato e integração onde a atual cobertura não alcança o comportamento real entre camadas.

## 6. Diferenciação e negócio

Informação isolada tem substitutos: [ACNUR Help publica orientação documental](https://help.unhcr.org/brazil/documentos/); [Missão Paz oferece apoio ao migrante](https://missaonspaz.org/); [InterNations oferece comunidade e guias para expatriados](https://www.internations.org/brazil-expats). Os públicos e serviços não são idênticos, e essa comparação não é um levantamento exaustivo de concorrentes.

A diferenciação possível do Movaro está em unir contexto, sequência, comparação e retomada. Ela fica mais forte quando a ferramenta demonstra que evitou uma decisão ruim ou ajudou alguém a sair de um bloqueio. Mais páginas de informação, sozinhas, são uma defesa competitiva fraca.

A monetização por indicação de serviços, sugerida no ICP, continua hipótese. Antes de investir nela, validar oferta de parceiros, conversão, custo de atendimento e conflitos de interesse. Uma recomendação de cidade não deve favorecer quem paga comissão. Serviços patrocinados precisam de identificação explícita e alternativas quando existirem.

Também não presumir que assinatura mensal seja adequada: mudança de país é um processo com começo, meio e fim. Pacote por jornada, atendimento opcional ou distribuição por organizações são hipóteses possíveis, a comparar depois de observar uso e obter sinais reais de disposição para pagar.

## 7. Plano para validar eficiência

**Primeiro ciclo: corrigir atritos e testar compreensão.** Escolher 3–5 cidades do corredor, revisar os dados decisivos e convidar 8–12 participantes do público pretendido. Esses tamanhos são sugestões práticas para pesquisa qualitativa, sem pretensão de representatividade estatística.

Executar três cenários: pessoa sozinha buscando trabalho e com pouca reserva; pessoa com filhos e necessidades de escola/moradia; pessoa com renda remota e cidade previamente escolhida. Observar tarefas com linguagem real, especialmente em espanhol: selecionar origem, obter lista de cidades, entender limites, confirmar cidade, identificar próxima ação e retomar o plano.

**Segundo ciclo: piloto acompanhado de 2–4 semanas.** Trabalhar com 15–25 pessoas em preparação real e documentar bloqueios e resultados, com consentimento. Comparar uma tarefa delimitada com o processo atual do participante, sem expô-lo a decisões irreversíveis para experimentar o produto.

Métricas propostas:

- Tempo até identificar corretamente a próxima ação e seus pré-requisitos.
- Proporção que explica por que a cidade foi sugerida e o que ainda precisa confirmar.
- Primeira ação relevante realizada fora do aplicativo, diferenciada de clicar no link ou marcar tarefa.
- Bloqueios encontrados, resolvidos e tempo de resolução.
- Retomada do plano e preservação do contexto após interrupção.
- Diferença entre orçamento estimado e referências/gastos observados por categoria.
- Minutos de atendimento humano necessários por participante.

O app já possui eventos como `taskBlocked`, `taskCompleted` e `officialLinkReturned` em `guide_flow_metrics_store.dart:7`. Isso é uma base, não a prova do resultado. Complementar os dados agregados com entrevistas consentidas; não remover proteções de privacidade para obter métricas mais detalhadas.

**Implementado para o piloto:** após uma tarefa prática, participantes que autorizaram métricas podem responder a um check-in curto sobre clareza da próxima ação, progresso realizado fora do Movaro e ajuda percebida. A mesma fase não pergunta novamente depois do envio; uma recusa interrompe novas ofertas por sete dias. O backend aceita apenas as categorias delimitadas `clear/partial/unclear`, `completed/blocked/notStarted`, `high/moderate/low` e a fase ampla da jornada. Identificador da tarefa, cidade, texto livre, documentos, respostas de perfil e valores não são enviados. Eventos de exibição e recusa permitem calcular viés de resposta.

Essa instrumentação torna o piloto mensurável, mas não valida o mercado sozinha. Recrutamento, observação, entrevistas, registro do processo anterior do participante e testes de disposição para pagar continuam atividades de pesquisa com pessoas reais.

Como critérios iniciais propostos, buscar ao menos 80% identificando a próxima ação sem intervenção do moderador e nenhuma interpretação crítica errada de requisito ou orçamento. São metas de piloto, não benchmarks de mercado. Ajustá-las após a primeira rodada e registrar denominadores. Retenção D7/D30 deve ser interpretada por estágio da mudança; concluir a jornada também pode ser sucesso.

## 8. Verificação e limites

- API: build e auditorias de conhecimento/contrato concluídos com sucesso; 15 suítes unitárias, 182 testes aprovados.
- E2E da API: 2 testes aprovados. Cobrem apenas contratos de health, portanto não comprovam a jornada integrada.
- Flutter: 252 testes aprovados e 1 falhou em `apps/app/test/splash_loading_view_test.dart:19`, por esperar o texto “Seu próximo passo começa com clareza.”. O sintoma é divergência de texto esperado, não evidência de falha na migração ou na instrumentação do piloto.
- `flutter analyze --no-pub`: um warning no exemplo do pacote local de calendário por include de lint não encontrado; comando terminou com status 1.
- Navegação local: intro, home, origem manual e quatro perguntas percorridas em Flutter Web; geração acionada. Não foi validado o resultado final integrado com API configurada, nem um percurso completo de execução em dispositivos móveis.
- Não houve teste de carga, auditoria de segurança completa, validação jurídica integral, acesso a métricas de produção ou entrevistas externas. O navegador local iniciou em inglês; isso não permite concluir que usuários argentinos receberão idioma errado.
- Há alterações de desenvolvimento não commitadas no checkout; os resultados descrevem o estado observado e podem mudar com edições posteriores.

## 9. Decisão recomendada

Preparar um piloto acompanhado com escopo contido. Priorizar precisão financeira, resiliência, entendimento da próxima ação e continuidade. Corrigir busca de origem e inconsistências de qualidade antes do recrutamento. Tratar recuperação entre dispositivos conforme a promessa escolhida.

Adiar expansão de países, comunidade própria ampla, marketplace e novas ferramentas periféricas até observar o que impede usuários reais de avançar. O Movaro já tem funcionalidades suficientes para testar sua hipótese central. O próximo investimento deve produzir evidência de utilidade e localizar os pontos em que a orientação deixa de ajudar.
