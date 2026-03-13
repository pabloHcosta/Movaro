// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get homeTitle => 'Movaro';

  @override
  String get homeEnvironmentLabel => 'Ambiente atual';

  @override
  String environmentValue(String environment) {
    return '$environment';
  }

  @override
  String get splashLoadingLabel => 'Organizando sua experiência';

  @override
  String get splashHeroTitle => 'Planejamento de migração com mais clareza.';

  @override
  String get splashHeroBody =>
      'Carregando cidades, custos e contexto prático para montar sua rota inicial.';

  @override
  String get splashInitializingLabel => 'Inicializando experiência';

  @override
  String get loadingCountriesLabel => 'Carregando países';

  @override
  String get loadingCitiesCatalogLabel => 'Carregando catálogo de cidades';

  @override
  String get journeySetupPageTitle => 'Escolha seu trajeto';

  @override
  String get journeySetupHeroTitle =>
      'Comece definindo de onde você sai e para onde quer ir';

  @override
  String get journeySetupHeroBody =>
      'O Movaro vai usar essa escolha para montar a experiência certa para você. Hoje, o beta está liberado para Argentina -> Brasil, mas a estrutura já está pronta para crescer.';

  @override
  String get journeyOriginTitle => 'País de origem';

  @override
  String get journeyOriginBody =>
      'Escolha o país de onde você está saindo. Isso ajuda a contextualizar idioma, burocracia e adaptação.';

  @override
  String get journeyDestinationTitle => 'País de destino';

  @override
  String get journeyDestinationBody =>
      'Escolha o país que você quer avaliar. A home e o plano passam a refletir esse destino.';

  @override
  String get journeySummaryTitle => 'Seu trajeto atual';

  @override
  String journeySummaryValue(String origin, String destination) {
    return '$origin -> $destination';
  }

  @override
  String get journeySummaryPlaceholder =>
      'Selecione origem e destino para continuar.';

  @override
  String get journeyAvailabilityNote =>
      'Hoje, só o trajeto Argentina -> Brasil está disponível para uso completo. Os demais países já aparecem para sinalizar a direção global do produto.';

  @override
  String get journeyContinueAction => 'Continuar com este trajeto';

  @override
  String get journeyAvailableNowLabel => 'Disponível agora';

  @override
  String get journeyComingSoonLabel => 'Em breve';

  @override
  String get journeyChangeAction => 'Trocar trajeto';

  @override
  String get publicHomeHeadline => 'Planeje sua mudança com mais clareza';

  @override
  String get publicHomeDescription =>
      'Entenda suas opções em poucos passos antes de decidir o que salvar.';

  @override
  String get publicHomeScopeBadge => 'Hoje: Argentina -> Brasil';

  @override
  String get publicHomeFocusedDescription =>
      'Hoje, o Movaro foi desenhado para quem está avaliando a mudança da Argentina para o Brasil. Em vez de mostrar tudo de uma vez, ele ajuda você a escolher o melhor primeiro passo.';

  @override
  String publicHomeSelectedJourneyDescription(
    String origin,
    String destination,
  ) {
    return 'O Movaro vai organizar sua experiência para a jornada $origin -> $destination. Você começa com o essencial e aprofunda só quando fizer sentido.';
  }

  @override
  String get publicHomePrimaryQuestionTitle => 'Comece pela decisão principal';

  @override
  String get publicHomePrimaryQuestionBody =>
      'Primeiro, descubra se você precisa de um plano guiado, de comparação entre cidades ou apenas de um panorama rápido do produto.';

  @override
  String get publicHomeTrustFastTitle => 'Entrada rápida';

  @override
  String get publicHomeTrustFastBody =>
      'Você consegue começar sem formulário longo nem bloqueio inicial.';

  @override
  String get publicHomeTrustGuestTitle => 'Sem login agora';

  @override
  String get publicHomeTrustGuestBody =>
      'Explore como visitante e entre só quando fizer sentido salvar algo.';

  @override
  String get publicHomeTrustFocusTitle => 'Escopo claro';

  @override
  String get publicHomeTrustFocusBody =>
      'Este beta está focado no corredor Argentina -> Brasil.';

  @override
  String publicHomeTrustSelectedBody(String origin, String destination) {
    return 'Sua navegação agora está contextualizada para $origin -> $destination, sem antecipar conteúdo irrelevante antes da escolha.';
  }

  @override
  String get publicHomeFirstStepTitle => 'Escolha seu primeiro passo';

  @override
  String get publicHomeFirstStepBody =>
      'A home agora serve para orientar a entrada. O aprofundamento vem depois, dentro do caminho que você escolher.';

  @override
  String get publicHomeSecondaryTitle => 'A documentação entra depois';

  @override
  String get publicHomeSecondaryBody =>
      'O guia prático do Brasil continua disponível, mas como apoio. Ele faz mais sentido depois que você já entendeu se quer gerar um plano ou comparar cidades.';

  @override
  String get publicHomeSecondaryGenericBody =>
      'Quando um novo destino estiver disponível, a documentação e os detalhes locais aparecem como apoio contextual, não como ruído logo na primeira dobra.';

  @override
  String get publicHomeExploreAction => 'Explorar mais';

  @override
  String get publicHomeQuestionnaireAction => 'Gerar meu plano';

  @override
  String get publicHomeLoginAction => 'Entrar quando eu precisar salvar';

  @override
  String get publicHomeGuestSectionTitle =>
      'Você pode começar no modo visitante';

  @override
  String get publicHomeGuestSectionBody =>
      'Você pode explorar tudo isso sem entrar. O login aparece só quando fizer sentido salvar algo seu.';

  @override
  String get publicHomeBetaSectionBody =>
      'Este beta já abre o que está pronto: exploração, documentação prática e seu plano inicial.';

  @override
  String get publicHomeHowItWorksAction => 'Ver como funciona';

  @override
  String get publicHomeCitiesTitle => 'Descobrir cidades';

  @override
  String get publicHomeCitiesBody =>
      'Veja sugestões por custo, trabalho e popularidade entre argentinos.';

  @override
  String get publicHomeCitiesAction => 'Ver cidades';

  @override
  String get publicHomeQuestionsTitle => 'Guia prático';

  @override
  String get publicHomeQuestionsBody =>
      'Entre no guia para entender documentos, saúde, moradia e custos iniciais sem pesquisa solta.';

  @override
  String get publicHomeQuestionsAction => 'Tirar dúvidas';

  @override
  String get publicHomePlanTitle => 'Gerar meu plano';

  @override
  String get publicHomePlanBody =>
      'Responda poucas perguntas e receba um plano inicial com sugestões mais claras.';

  @override
  String get publicHomeStoriesTitle => 'Ler experiências reais';

  @override
  String get publicHomeStoriesBody =>
      'Entenda o que outras pessoas estão buscando antes de decidir seu próximo passo.';

  @override
  String get publicHomeStoriesAction => 'Explorar histórias';

  @override
  String get decisionSupportTitle =>
      'Comece pela pergunta que mais importa para você';

  @override
  String get decisionSupportBody =>
      'Quem pensa em morar fora geralmente quer respostas rápidas sobre idioma, custo, burocracia e trabalho. O Movaro precisa deixar isso claro logo de cara.';

  @override
  String get decisionSupportLanguageTitle =>
      'Vou conseguir viver no dia a dia sem português no início?';

  @override
  String get decisionSupportLanguageBody =>
      'Use o sinal de adaptação ao idioma para encontrar lugares que parecem mais fáceis para quem ainda depende do espanhol.';

  @override
  String get decisionSupportCostTitle => 'O custo diário vai pesar demais?';

  @override
  String get decisionSupportCostBody =>
      'Compare cidades por custo e aluguel antes de se aprofundar em um destino.';

  @override
  String get decisionSupportPaperworkTitle =>
      'Quais seriam os primeiros passos de documentação?';

  @override
  String get decisionSupportPaperworkBody =>
      'O plano guiado transforma essa dúvida em uma checklist curta, em vez de uma pesquisa longa e confusa.';

  @override
  String get decisionSupportWorkTitle =>
      'Por onde faz mais sentido começar se eu preciso de trabalho ou estrutura?';

  @override
  String get decisionSupportWorkBody =>
      'O questionário e o ranking ajudam a reduzir a busca para cidades com melhor encaixe inicial.';

  @override
  String get commonNeedsTitle => 'Se você ainda não sabe por onde começar';

  @override
  String get commonNeedsBody =>
      'Estes são os atalhos mais úteis para quem chega com uma dúvida difusa e quer reduzir a ansiedade antes de decidir.';

  @override
  String get commonNeedCompareCostTitle =>
      'Quero comparar custo e aluguel primeiro';

  @override
  String get commonNeedCompareCostBody =>
      'Vá direto para cidades e use os sinais de custo, aluguel, idioma e trabalho como leitura inicial.';

  @override
  String get commonNeedDocumentsTitle =>
      'Preciso entender os documentos antes de tudo';

  @override
  String get commonNeedDocumentsBody =>
      'A documentação resume CPF, registro, permanência, trabalho e banco com fonte oficial e linguagem simples.';

  @override
  String get commonNeedDirectionTitle =>
      'Ainda não sei qual caminho faz sentido';

  @override
  String get commonNeedDirectionBody =>
      'O plano guiado reduz a dúvida a uma cidade inicial e a uma ordem curta de primeiros passos.';

  @override
  String get commonNeedExploreAllTitle => 'Quero ver tudo sem me prender';

  @override
  String get commonNeedExploreAllBody =>
      'A área Explorar reúne cidades, documentação e outros caminhos em um só lugar.';

  @override
  String get explorePageTitle => 'Explorar';

  @override
  String get explorePublicFeaturesTitle => 'Exploração pública';

  @override
  String get explorePublicFeaturesDescription =>
      'Descubra cidades e países disponíveis para qualquer usuário visitante.';

  @override
  String get exploreDocumentationTitle => 'Vida prática no Brasil';

  @override
  String get exploreDocumentationDescription =>
      'Entenda documentos, saúde, habilitação, trabalho e conta bancária em linguagem simples.';

  @override
  String get exploreDocumentationAction => 'Ver documentação';

  @override
  String get exploreCitiesAction => 'Ver cidades';

  @override
  String get exploreCountriesAction => 'Ver países';

  @override
  String get exploreCommunityTitle => 'Conteúdo da comunidade';

  @override
  String get exploreCommunityDescription =>
      'O conteúdo da comunidade é público, mas postar exige autenticação.';

  @override
  String get exploreCreatePostAction => 'Criar post';

  @override
  String get exploreIntroTitle => 'Como usar o Movaro';

  @override
  String get exploreIntroDescription =>
      'Antes de sair navegando, veja em menos de um minuto o que o Movaro ajuda a resolver e o que já está disponível neste beta.';

  @override
  String get exploreIntroAction => 'Abrir introdução';

  @override
  String get exploreChecklistTitle => 'Seu plano inicial';

  @override
  String get exploreChecklistDescription =>
      'Responda a um fluxo curto e receba um plano inicial sem transformar a experiência em um formulário longo.';

  @override
  String get exploreQuestionnaireAction => 'Iniciar questionário';

  @override
  String get exploreTrailsEyebrow => 'Três caminhos claros';

  @override
  String get exploreTrailsTitle =>
      'Escolha o tipo de ajuda de que você precisa agora';

  @override
  String get exploreTrailsBody =>
      'Em vez de mostrar tudo de uma vez, o app agora separa a experiência em três trilhas: decidir a cidade, entender a burocracia prática e preparar a mudança.';

  @override
  String get exploreTrailCitiesTitle => 'Decidir a cidade';

  @override
  String get exploreTrailCitiesBody =>
      'Compare cidades, veja litoral, custo, trabalho, idioma e moradia para entender qual contexto combina mais com você.';

  @override
  String get exploreTrailDocsTitle => 'Entender a burocracia prática';

  @override
  String get exploreTrailDocsBody =>
      'Veja aluguel, SUS, CPF, trabalho, dirigir e custos iniciais em blocos mais claros e menos espalhados.';

  @override
  String get exploreTrailPrepTitle => 'Preparar a mudança';

  @override
  String get exploreTrailPrepBodyStart =>
      'Quando você ainda não confirmou uma cidade, comece pelo plano inicial para organizar a decisão.';

  @override
  String get exploreTrailPrepBodyReady =>
      'Como você já confirmou uma cidade, aqui o foco passa a ser checklist, documentos, moradia e chegada.';

  @override
  String get exploreSavePlanAction => 'Salvar plano';

  @override
  String get documentationPageTitle => 'Documentação e vida prática';

  @override
  String get documentationHeroEyebrow => 'Guia prático';

  @override
  String get documentationHeroTitle =>
      'Entenda melhor como organizar a vida prática no Brasil';

  @override
  String get documentationHeroDescription =>
      'Escreva uma dúvida ou escolha um tema. O Movaro ajuda você a encontrar a orientação e o guia certo sobre documentos, saúde, trabalho, moradia, mobilidade e custos iniciais.';

  @override
  String get documentationHeroStepOneTitle => 'Escreva uma dúvida';

  @override
  String get documentationHeroStepOneBody =>
      'Você pode buscar em português, espanhol ou inglês.';

  @override
  String get documentationHeroStepTwoTitle => 'Escolha um tema';

  @override
  String get documentationHeroStepTwoBody =>
      'Filtre por documentos, saúde, trabalho, moradia, mobilidade e custos.';

  @override
  String get documentationHeroStepThreeTitle => 'Abra o guia certo';

  @override
  String get documentationHeroStepThreeBody =>
      'Entre em uma resposta rápida ou no bloco completo quando precisar de mais contexto.';

  @override
  String get documentationSearchLabel => 'O que você precisa entender?';

  @override
  String get documentationSearchHint =>
      'Ex.: posso trabalhar com visto de visita? / CPF / bank / salud / custos';

  @override
  String get documentationSearchSupport =>
      'Você pode pesquisar em português, espanhol ou inglês.';

  @override
  String get documentationSearchPanelTitle =>
      'Comece pela busca ou por um tema';

  @override
  String get documentationSearchPanelBody =>
      'Escreva sua dúvida ou toque em um tema para chegar mais rápido ao bloco certo.';

  @override
  String get documentationGuideHideNextTime => 'Não mostrar novamente';

  @override
  String get documentationGuideStepsLabel => '3 passos';

  @override
  String get documentationGuideDismissAction => 'Agora não';

  @override
  String get documentationGuidePrimaryAction => 'Entendi';

  @override
  String documentationSearchResultsCount(int count) {
    return '$count itens encontrados';
  }

  @override
  String get documentationSearchResultsHint =>
      'Toque em um item para abrir o tema ou ir direto para os resultados filtrados.';

  @override
  String get documentationFilterAll => 'Tudo';

  @override
  String get documentationQuickRoutesTitle => 'Entradas por tema';

  @override
  String get documentationQuickRoutesBody =>
      'Deslize e entre direto no bloco certo se você já souber qual tema quer resolver.';

  @override
  String get documentationQuickChoicesTitle => 'Escolhas rápidas';

  @override
  String get documentationQuickChoicesBody =>
      'Filtre por tema ou use perguntas prontas para chegar mais rápido ao bloco certo.';

  @override
  String get documentationResultsTitle => 'Resultados do guia';

  @override
  String get documentationResultsBody =>
      'Comece por uma resposta rápida ou abra o tema completo para aprofundar.';

  @override
  String get documentationResultsFilteredBody =>
      'A busca cruza respostas rápidas e blocos completos para encurtar o caminho até a informação certa.';

  @override
  String get documentationViewMatchesAction => 'Ver';

  @override
  String get documentationNoResultsTitle => 'Nada apareceu com esse termo';

  @override
  String get documentationNoResultsBody =>
      'Tente CPF, registro, work, visa, saúde, aluguel ou custos.';

  @override
  String get documentationQuickStepCpf => 'CPF';

  @override
  String get documentationQuickStepRegistration => 'Registro';

  @override
  String get documentationQuickStepStay => 'Permanência';

  @override
  String get documentationQuickStepWorkBank => 'Trabalho e banco';

  @override
  String get documentationQuickStepCitizenship => 'Naturalização';

  @override
  String get documentationQuickStepHealth => 'Saúde';

  @override
  String get documentationQuickStepDriving => 'Habilitação';

  @override
  String get documentationQuickStepWork => 'Trabalho';

  @override
  String get documentationQuickStepRetirement => 'Previdência';

  @override
  String get documentationOfficialSourceLabel => 'Fonte oficial';

  @override
  String get documentationPathsTitle => 'Comece pela sua dúvida principal';

  @override
  String get documentationPathsBody =>
      'Em vez de ler tudo, escolha a área que mais pesa agora. O restante fica como apoio quando você precisar aprofundar.';

  @override
  String get documentationHousingArrivalSectionTitle => 'Moradia e chegada';

  @override
  String get documentationHousingArrivalSectionBody =>
      'Veja aluguel, custo de entrada, garantia, soft landing e como evitar os primeiros erros.';

  @override
  String get documentationNavigatorTitle => 'Onde encontrar cada assunto';

  @override
  String get documentationNavigatorBody =>
      'Use estes blocos para encontrar mais rápido aluguel, SUS, trabalho, direção e custos sem precisar ler a página inteira de uma vez.';

  @override
  String get documentationNavigatorHousing => 'Moradia e aluguel';

  @override
  String get documentationNavigatorHealth => 'SUS e saúde';

  @override
  String get documentationNavigatorWork => 'Trabalho e renda';

  @override
  String get documentationNavigatorDriving => 'Dirigir no Brasil';

  @override
  String get documentationNavigatorCosts => 'Custos iniciais';

  @override
  String get documentationNavigatorDocuments => 'Documentos básicos';

  @override
  String get documentationPathDocumentsTitle => 'Documentos e permanência';

  @override
  String get documentationPathDocumentsBody =>
      'CPF, registro, prazo de permanência e o que destrava primeiro a vida prática.';

  @override
  String get documentationPathHealthTitle => 'Saúde no dia a dia';

  @override
  String get documentationPathHealthBody =>
      'Entenda quando faz sentido usar SUS, posto de saúde, hospital ou plano privado.';

  @override
  String get documentationPathDrivingTitle => 'Dirigir e se locomover';

  @override
  String get documentationPathDrivingBody =>
      'Veja se sua carteira estrangeira ajuda no início e quando você precisa consultar o Detran.';

  @override
  String get documentationPathWorkTitle => 'Trabalho e contribuição';

  @override
  String get documentationPathWorkBody =>
      'Entenda carteira assinada, PJ e como isso se relaciona com a previdência.';

  @override
  String get documentationPathCostsTitle => 'Custos iniciais';

  @override
  String get documentationPathCostsBody =>
      'Leia custos aproximados em reais, pesos e dólar sem confundir referência com preço final.';

  @override
  String get documentationOpenTopicAction => 'Abrir tema';

  @override
  String get documentationQuickAnswersTitle =>
      'Respostas rápidas para as dúvidas mais comuns';

  @override
  String get documentationQuickAnswersBody =>
      'Antes de abrir cada card, comece por estas respostas curtas. Se alguma delas já resolver sua dúvida, você ganha tempo.';

  @override
  String get documentationAnswerWorkQuestion =>
      'Posso trabalhar só com visto de visita?';

  @override
  String get documentationAnswerWorkAnswer =>
      'Não. Para trabalho formal, você precisa de situação migratória compatível e registro regular.';

  @override
  String get documentationAnswerTravelDocQuestion =>
      'Para viajar da Argentina ao Brasil eu preciso de passaporte?';

  @override
  String get documentationAnswerTravelDocAnswer =>
      'Não necessariamente. Para argentinos, a viagem ao Brasil pode ser feita com DNI físico válido, em bom estado e com foto que permita identificar o titular. Comprovante de documento em trâmite não basta.';

  @override
  String get documentationAnswerCpfQuestion =>
      'Só o CPF resolve banco e contrato?';

  @override
  String get documentationAnswerCpfAnswer =>
      'Não. O CPF ajuda bastante, mas normalmente não substitui um documento migratório regular.';

  @override
  String get documentationAnswerRegistrationQuestion =>
      'O registro migratório fica pronto na hora?';

  @override
  String get documentationAnswerRegistrationAnswer =>
      'Não. O protocolo já importa enquanto a CRNM é confeccionada, então o processo não depende de um cartão imediato.';

  @override
  String get documentationAnswerStayQuestion =>
      'Ficar mais tempo como visitante é o mesmo que morar de forma regular?';

  @override
  String get documentationAnswerStayAnswer =>
      'Não. Para quem vai viver no Brasil, a residência regular costuma ser o caminho certo.';

  @override
  String get documentationAnswerSusQuestion => 'Estrangeiro pode usar o SUS?';

  @override
  String get documentationAnswerSusAnswer =>
      'Sim. O SUS é universal no Brasil, e o próprio Ministério da Saúde reafirma o acesso para pessoas estrangeiras.';

  @override
  String get documentationAnswerSusCardQuestion =>
      'Preciso esperar o Cartão SUS ou o CPF para buscar atendimento?';

  @override
  String get documentationAnswerSusCardAnswer =>
      'Não necessariamente. O cadastro ajuda no acompanhamento, mas o acesso inicial, e principalmente em urgências, não deveria depender de você já ter tudo pronto.';

  @override
  String get documentationAnswerForeignLicenseQuestion =>
      'Posso dirigir com minha carteira estrangeira no começo?';

  @override
  String get documentationAnswerForeignLicenseAnswer =>
      'Em regra, sim, por período limitado, com documento válido e observando as exigências do acordo aplicável. Depois disso, vale confirmar com o Detran do estado.';

  @override
  String get documentationAnswerBrazilianLicenseQuestion =>
      'Depois eu consigo tirar a habilitação brasileira?';

  @override
  String get documentationAnswerBrazilianLicenseAnswer =>
      'Sim, se você estiver regular no país e cumprir os requisitos do Detran. O processo e as taxas mudam de estado para estado.';

  @override
  String get documentationAnswerWorkCardQuestion =>
      'Carteira assinada ainda existe? Como funciona?';

  @override
  String get documentationAnswerWorkCardAnswer =>
      'Sim. No trabalho formal pela CLT, o vínculo fica registrado e a Carteira de Trabalho Digital concentra o histórico laboral.';

  @override
  String get documentationAnswerPjQuestion =>
      'Trabalhar como PJ é igual ao monotributo?';

  @override
  String get documentationAnswerPjAnswer =>
      'Pode lembrar essa lógica de trabalho por conta própria e CNPJ, mas não é a mesma estrutura. No Brasil, as regras fiscais, previdenciárias e contratuais mudam conforme o enquadramento.';

  @override
  String get documentationAnswerMarketQuestion =>
      'Dá para construir renda no mercado de trabalho brasileiro?';

  @override
  String get documentationAnswerMarketAnswer =>
      'Sim, mas a expectativa prática é de renda viável e crescimento gradual, não de salários excepcionalmente altos logo na chegada. O Brasil tem mercado grande e diversificado, mas o ganho muda bastante conforme cidade, setor, idioma e sua forma de regularização para trabalhar.';

  @override
  String get documentationAnswerSafetyQuestion =>
      'Segurança no Brasil é igual em todo lugar?';

  @override
  String get documentationAnswerSafetyAnswer =>
      'Não. A segurança varia muito por estado, cidade, bairro e rotina diária. O mais seguro é comparar a área concreta onde você pretende morar e circular, e não tratar o país inteiro como um bloco único.';

  @override
  String get documentationAnswerInssQuestion =>
      'A previdência pública no Brasil é o INSS?';

  @override
  String get documentationAnswerInssAnswer =>
      'Sim. O INSS é a principal porta da previdência pública para benefícios como aposentadoria, desde que haja contribuição e cumprimento dos requisitos.';

  @override
  String get documentationAnswerRetirementQuestion =>
      'A aposentadoria depende só da idade?';

  @override
  String get documentationAnswerRetirementAnswer =>
      'Não. A idade mínima pesa, mas o tempo de contribuição e as regras de transição também importam.';

  @override
  String get documentationHealthSectionTitle => 'Saúde pública x saúde privada';

  @override
  String get documentationHealthSectionBody =>
      'O mais importante aqui é entender a função de cada caminho. Saúde pública não é um plano barato, e saúde privada não substitui, por si só, uma boa leitura de cobertura.';

  @override
  String get documentationWorkSectionTitle =>
      'Como trabalho e previdência se conectam';

  @override
  String get documentationWorkSectionBody =>
      'Aqui vale diferenciar o modelo de trabalho do modo de contribuir. Carteira assinada, trabalho por CNPJ e contribuição ao INSS não significam exatamente a mesma coisa.';

  @override
  String get documentationDrivingSectionTitle =>
      'Como pensar na habilitação sem complicar';

  @override
  String get documentationDrivingSectionBody =>
      'O fluxo mais seguro é separar três perguntas: posso dirigir agora, o que preciso validar no estado e quando vale iniciar a habilitação brasileira.';

  @override
  String get documentationDeepDiveTitle => 'Se você precisar ir um nível além';

  @override
  String get documentationDeepDiveBody =>
      'Aqui ficam os cards completos com fonte oficial. Eles continuam curtos, mas servem para quando a resposta rápida não bastar.';

  @override
  String get documentationCostsTitle =>
      'Custos aproximados que ajudam a orientar';

  @override
  String get documentationCostsBody =>
      'Quando existe valor nacional ou uma referência oficial útil, o app mostra a conversão aproximada para ajudar na sua leitura inicial.';

  @override
  String documentationCostsUpdatedAt(String value) {
    return 'Câmbio aproximado atualizado em $value';
  }

  @override
  String get documentationCostsUnavailable =>
      'Não foi possível atualizar a cotação agora. Os valores em reais continuam como referência.';

  @override
  String get documentationCostsDisclaimer =>
      'Use isto como orientação inicial. Os custos variam por estado, convênio, idade, cobertura e regras locais.';

  @override
  String get documentationCostFreeValue => 'Grátis';

  @override
  String get documentationCostVariableValue => 'Variável';

  @override
  String get documentationCostCpfTitle => 'Pedido oficial de CPF';

  @override
  String get documentationCostCpfSupporting =>
      'O pedido oficial é gratuito; o app trata isso como custo zero.';

  @override
  String get documentationCostSusCardTitle => 'Cartão SUS e cadastro inicial';

  @override
  String get documentationCostSusCardSupporting =>
      'A emissão e o cadastro público não costumam exigir pagamento direto.';

  @override
  String get documentationCostPublicCareTitle => 'Atendimento inicial no SUS';

  @override
  String get documentationCostPublicCareSupporting =>
      'UBS, posto de saúde e portas públicas de entrada não funcionam como consulta particular paga.';

  @override
  String get documentationCostDrivingTitle => 'Primeira habilitação';

  @override
  String get documentationCostDrivingValue => 'Exemplo oficial';

  @override
  String get documentationCostDrivingSupporting =>
      'Referência recente do Detran-ES: R\$ 533,34. Seu estado e sua autoescola podem cobrar valores diferentes.';

  @override
  String get documentationCostPrivateHealthTitle => 'Plano de saúde privado';

  @override
  String get documentationCostPrivateHealthSupporting =>
      'Não existe um preço único nacional. Idade, cobertura, rede e carência mudam bastante o valor final.';

  @override
  String get documentationCpfTitle => 'CPF';

  @override
  String get documentationCpfSummary =>
      'O primeiro documento prático para abrir caminho em banco, contrato e cadastros.';

  @override
  String get documentationCpfBulletOne =>
      'Estrangeiros podem solicitar CPF; no Brasil, o pedido pode ser feito online ou em entidade conveniada.';

  @override
  String get documentationCpfBulletTwo =>
      'O serviço oficial informa prazo estimado de até 30 dias corridos.';

  @override
  String get documentationCpfBulletThree =>
      'O CPF não substitui documento migratório, mas costuma destravar boa parte da vida prática.';

  @override
  String get documentationTravelDocsTitle =>
      'Documento para viajar da Argentina ao Brasil';

  @override
  String get documentationTravelDocsSummary =>
      'Para turismo e entrada inicial, o passaporte não é a única opção. O ponto central é viajar com documento físico válido e reconhecido no corredor Mercosul.';

  @override
  String get documentationTravelDocsBulletOne =>
      'Argentinos podem viajar ao Brasil com Documento Nacional de Identidade (DNI) ou passaporte.';

  @override
  String get documentationTravelDocsBulletTwo =>
      'O documento apresentado deve estar em bom estado de conservação e permitir identificar claramente o titular pela foto.';

  @override
  String get documentationTravelDocsBulletThree =>
      'Constância de trâmite, documentos deteriorados e documentos antigos não aceitos pelas regras migratórias podem impedir o embarque ou a saída do país.';

  @override
  String get documentationRegistrationTitle => 'Registro migratório e CRNM';

  @override
  String get documentationRegistrationSummary =>
      'Depois da entrada regular, o registro na Polícia Federal costuma ser a etapa mais importante.';

  @override
  String get documentationRegistrationBulletOne =>
      'Quem entra com visto temporário deve fazer o registro em até 90 dias após a entrada no Brasil.';

  @override
  String get documentationRegistrationBulletTwo =>
      'Se a autorização de residência foi concedida já no Brasil, o registro deve ser feito em até 30 dias.';

  @override
  String get documentationRegistrationBulletThree =>
      'A CRNM pode levar perto de 30 dias úteis para ser confeccionada; o serviço oficial admite prazo total maior, e o protocolo preserva direitos.';

  @override
  String get documentationStayTitle => 'Quanto tempo posso ficar';

  @override
  String get documentationStaySummary =>
      'Para argentinos, o caminho mais prático costuma ser regularizar a residência, e não depender da permanência como visitante.';

  @override
  String get documentationStayBulletOne =>
      'O visto de visita não foi pensado para morar no Brasil nem para trabalho remunerado.';

  @override
  String get documentationStayBulletTwo =>
      'A residência pelo Acordo do Mercosul pode ser concedida por 2 anos.';

  @override
  String get documentationStayBulletThree =>
      'Antes do fim desse prazo, você pode pedir a conversão para residência por prazo indeterminado, se cumprir os requisitos.';

  @override
  String get documentationWorkBankTitle => 'Trabalho e conta bancária';

  @override
  String get documentationWorkBankSummary =>
      'Trabalhar e abrir conta dependem mais da sua regularização do que de um único documento milagroso.';

  @override
  String get documentationWorkBankBulletOne =>
      'O visto de visita não autoriza atividade remunerada no Brasil.';

  @override
  String get documentationWorkBankBulletTwo =>
      'Para trabalhar formalmente, você precisa de situação migratória compatível e registro regular.';

  @override
  String get documentationWorkBankBulletThree =>
      'O banco pode pedir documentos adicionais; o CPF ajuda, mas um documento migratório regular costuma fazer diferença no cadastro.';

  @override
  String get documentationCitizenshipTitle => 'Naturalização';

  @override
  String get documentationCitizenshipSummary =>
      'A nacionalidade brasileira não vem só por tempo de CPF ou de estadia; ela depende de residência regular e de regras próprias.';

  @override
  String get documentationCitizenshipBulletOne =>
      'A naturalização ordinária, em regra, exige residência por prazo indeterminado no Brasil.';

  @override
  String get documentationCitizenshipBulletTwo =>
      'A regra geral exige 4 anos de residência antes do pedido, além de outros requisitos legais.';

  @override
  String get documentationCitizenshipBulletThree =>
      'Existem hipóteses oficiais de redução desse prazo, então vale checar a regra exata antes de planejar seu caminho.';

  @override
  String get documentationHealthPublicTitle =>
      'SUS, posto de saúde e acesso público';

  @override
  String get documentationHealthPublicSummary =>
      'Saúde pública no Brasil não é um plano com entrada paga. A lógica é de acesso universal, com portas diferentes para cada tipo de necessidade.';

  @override
  String get documentationHealthPublicBulletOne =>
      'O SUS atende de forma universal, inclusive pessoas estrangeiras em território brasileiro.';

  @override
  String get documentationHealthPublicBulletTwo =>
      'A UBS, ou posto de saúde, costuma ser a porta de entrada para rotina, acompanhamento, vacinação e cuidado básico.';

  @override
  String get documentationHealthPublicBulletThree =>
      'Urgência e emergência seguem outra lógica de acesso; não espere ter tudo resolvido no cadastro antes de buscar ajuda.';

  @override
  String get documentationHealthFlowTitle =>
      'Como encontrar o atendimento certo';

  @override
  String get documentationHealthFlowSummary =>
      'Nem toda dúvida de saúde começa em hospital. Vale saber quando procurar UBS, UPA, hospital ou aplicativo oficial.';

  @override
  String get documentationHealthFlowBulletOne =>
      'Use UBS ou posto de saúde para rotina, encaminhamento, receitas e acompanhamento.';

  @override
  String get documentationHealthFlowBulletTwo =>
      'Use UPA ou hospital quando o caso for urgente, agudo ou não puder esperar pela agenda básica.';

  @override
  String get documentationHealthFlowBulletThree =>
      'Meu SUS Digital e a secretaria local ajudam a localizar unidades, exames e informações de acompanhamento.';

  @override
  String get documentationHealthPrivateTitle => 'Saúde privada';

  @override
  String get documentationHealthPrivateSummary =>
      'O plano privado pode acelerar rede e conveniência, mas entra como custo recorrente e exige comparar cobertura com cuidado.';

  @override
  String get documentationHealthPrivateBulletOne =>
      'Plano de saúde privado é pago e regulado pela ANS.';

  @override
  String get documentationHealthPrivateBulletTwo =>
      'Preço, rede credenciada, abrangência e carência mudam conforme contrato, idade e operadora.';

  @override
  String get documentationHealthPrivateBulletThree =>
      'Antes de contratar, compare rede, cobertura e regras no material oficial da ANS, não só o preço.';

  @override
  String get documentationWorkCltTitle => 'Carteira assinada';

  @override
  String get documentationWorkCltSummary =>
      'No trabalho formal, o vínculo empregatício segue a CLT e o registro aparece na Carteira de Trabalho Digital.';

  @override
  String get documentationWorkCltBulletOne =>
      'Carteira assinada é a forma mais reconhecível de trabalho formal no Brasil.';

  @override
  String get documentationWorkCltBulletTwo =>
      'O histórico laboral pode ser acompanhado pela Carteira de Trabalho Digital.';

  @override
  String get documentationWorkCltBulletThree =>
      'Nesse modelo, a relação com a contribuição previdenciária costuma ser mais integrada à folha de pagamento.';

  @override
  String get documentationWorkPjTitle =>
      'PJ, CNPJ e trabalho por conta própria';

  @override
  String get documentationWorkPjSummary =>
      'Trabalhar como PJ ou por CNPJ muda a lógica do vínculo. Isso pode lembrar o monotributo na comparação cultural, mas não é a mesma estrutura jurídica.';

  @override
  String get documentationWorkPjBulletOne =>
      'PJ não é carteira assinada; o vínculo é empresarial ou autônomo, não empregatício.';

  @override
  String get documentationWorkPjBulletTwo =>
      'Abrir CNPJ e contribuir para a previdência são assuntos conectados, mas não automáticos em todos os casos.';

  @override
  String get documentationWorkPjBulletThree =>
      'Antes de aceitar esse formato, vale entender como vão funcionar imposto, contrato e contribuição previdenciária.';

  @override
  String get documentationWorkMarketTitle =>
      'Mercado de trabalho e expectativa de renda';

  @override
  String get documentationWorkMarketSummary =>
      'O Brasil oferece escala e muitos formatos de trabalho, mas o planejamento migratório mais realista parte de renda moderada e progressão gradual, não de salários fora da curva na primeira fase.';

  @override
  String get documentationWorkMarketBulletOne =>
      'No trimestre móvel encerrado em outubro de 2025, o IBGE registrou desocupação de 5,4%, rendimento médio habitual de R\$ 3.528 e recorde de 39,2 milhões de empregados com carteira no setor privado.';

  @override
  String get documentationWorkMarketBulletTwo =>
      'Esse conjunto mostra um mercado grande e ativo, com espaço em serviços, comércio, logística, saúde, educação, tecnologia e redes locais de negócio.';

  @override
  String get documentationWorkMarketBulletThree =>
      'Para quem chega do exterior, a leitura mais segura é planejar com renda realista, reserva financeira e diferença salarial de cidade para cidade.';

  @override
  String get documentationRetirementTitle =>
      'Previdência pública e aposentadoria';

  @override
  String get documentationRetirementSummary =>
      'No Brasil, a aposentadoria pública gira em torno do INSS, com idade mínima, tempo de contribuição e regras de transição que mudam a leitura de cada caso.';

  @override
  String get documentationRetirementBulletOne =>
      'A regra geral atual usa idade mínima de 62 anos para mulheres e 65 para homens na aposentadoria por idade.';

  @override
  String get documentationRetirementBulletTwo =>
      'O tempo de contribuição continua relevante, especialmente nas regras de transição e na análise de elegibilidade.';

  @override
  String get documentationRetirementBulletThree =>
      'Para quem chega do exterior, o mais seguro é entender cedo como será sua forma de contribuição no Brasil.';

  @override
  String get documentationSafetyTitle =>
      'Segurança: leia por cidade e por bairro';

  @override
  String get documentationSafetySummary =>
      'Segurança no Brasil não é uniforme. A decisão útil não é se o país é \'seguro\' em abstrato, mas como a cidade, o bairro, o trajeto e o horário combinam com a sua rotina.';

  @override
  String get documentationSafetyBulletOne =>
      'O Anuário Brasileiro de Segurança Pública 2025 compila dados oficiais de secretarias e polícias e é uma das leituras mais amplas do tema no país.';

  @override
  String get documentationSafetyBulletTwo =>
      'Os números variam bastante entre estados e tipos de crime, então média nacional sozinha não basta para escolher onde morar.';

  @override
  String get documentationSafetyBulletThree =>
      'Antes de alugar ou aceitar trabalho, compare contexto do bairro, mobilidade noturna, trajetos e a rotina prática que você realmente terá.';

  @override
  String get documentationDrivingTitle => 'Primeira habilitação no Brasil';

  @override
  String get documentationDrivingSummary =>
      'Se você vai morar no Brasil, a habilitação brasileira depende do Detran do estado e de um processo local com etapas obrigatórias.';

  @override
  String get documentationDrivingBulletOne =>
      'O processo costuma incluir exames médico e psicológico, aulas, prova teórica e prova prática.';

  @override
  String get documentationDrivingBulletTwo =>
      'Pessoas estrangeiras regularizadas podem entrar no processo se cumprirem as exigências de identificação e residência do estado.';

  @override
  String get documentationDrivingBulletThree =>
      'Taxas e custo final mudam conforme o Detran e a autoescola, então use o valor exibido apenas como referência de orientação.';

  @override
  String get documentationForeignLicenseTitle =>
      'Carteira estrangeira e direção no começo';

  @override
  String get documentationForeignLicenseSummary =>
      'Ter habilitação estrangeira válida pode ajudar no início, mas não substitui para sempre a necessidade de confirmar a regra brasileira.';

  @override
  String get documentationForeignLicenseBulletOne =>
      'A possibilidade de dirigir com carteira estrangeira depende de validade, identificação e regra aplicável ao seu caso.';

  @override
  String get documentationForeignLicenseBulletTwo =>
      'O período inicial de uso não significa equivalência automática para toda a permanência no Brasil.';

  @override
  String get documentationForeignLicenseBulletThree =>
      'Se você vai fixar residência, confirme cedo com o Detran do estado se haverá registro, troca ou novo processo completo.';

  @override
  String get citiesPageTitle => 'Cidades';

  @override
  String get countriesPageTitle => 'Países';

  @override
  String get publicAccessLabel => 'Acesso público';

  @override
  String get loginPageTitle => 'Entrar';

  @override
  String get loginHeadline => 'Entre só quando fizer sentido para você';

  @override
  String get loginDescription =>
      'O Movaro deixa a exploração aberta. O login aparece apenas quando você quer salvar algo pessoal.';

  @override
  String get loginGoogleAction => 'Continuar com Google';

  @override
  String get loginAppleAction => 'Continuar com Apple';

  @override
  String get loginDevOnlyHint =>
      'Estes botões usam FakeAuthDataSource apenas em desenvolvimento.';

  @override
  String get loginLaterAction => 'Agora não';

  @override
  String loginActionRequired(String action) {
    return 'Para $action, precisamos vincular esta ação a você.';
  }

  @override
  String get pendingActionSavePlan => 'salvar seu plano';

  @override
  String get pendingActionPostCommunity => 'publicar na comunidade';

  @override
  String get pendingActionSaveCity => 'salvar esta cidade';

  @override
  String get onboardingPageTitle => 'Seu contexto';

  @override
  String get onboardingHeadline => 'Vamos entender seu momento';

  @override
  String get onboardingDescription =>
      'Isso ajuda a tornar sua experiência mais útil sem pedir informações demais.';

  @override
  String get onboardingOriginLabel => 'De onde você vem?';

  @override
  String get onboardingDestinationLabel => 'Para onde quer ir?';

  @override
  String get onboardingContinueAction => 'Continuar';

  @override
  String get authenticatedHomeTitle => 'Seu espaço';

  @override
  String authenticatedWelcome(String name) {
    return 'Olá, $name';
  }

  @override
  String get authenticatedHomeDescription =>
      'Aqui você retoma o que estava fazendo e encontra seus atalhos principais.';

  @override
  String get authenticatedPlanSectionTitle => 'Seu plano';

  @override
  String get authenticatedShortcutsTitle => 'Atalhos úteis';

  @override
  String get authenticatedCitiesShortcut => 'Ver cidades';

  @override
  String get authenticatedSearchShortcut => 'Buscar cidade';

  @override
  String get signOutAction => 'Sair';

  @override
  String onboardingSummary(String origin, String destination) {
    return 'Origem: $origin  Destino: $destination';
  }

  @override
  String savedPlansCount(int count) {
    return 'Planos salvos: $count';
  }

  @override
  String get startNewPlanAction => 'Montar novo plano';

  @override
  String get questionnairePageTitle => 'Seu plano inicial';

  @override
  String get questionnaireLoadingLabel => 'Preparando suas perguntas';

  @override
  String get questionnaireSupportText =>
      'Leva menos de um minuto. Uma pergunta por vez.';

  @override
  String questionProgress(int current, int total) {
    return 'Pergunta $current de $total';
  }

  @override
  String get backAction => 'Voltar';

  @override
  String get nextAction => 'Continuar';

  @override
  String get generatePlanAction => 'Ver meu plano';

  @override
  String get migrationPlanPageTitle => 'Seu plano inicial';

  @override
  String get migrationPlanSummaryTitle => 'O que você contou para a gente';

  @override
  String get planRecommendedCityTitle => 'Cidade sugerida para começar';

  @override
  String planRecommendedCityDescription(String city, String stateCode) {
    return 'Com base nas suas respostas, o Movaro sugere que você olhe primeiro para $city, $stateCode.';
  }

  @override
  String get planRecommendedCityAction => 'Ver esta cidade';

  @override
  String planSummaryOrigin(String value) {
    return 'Origem: $value';
  }

  @override
  String planSummaryDestination(String value) {
    return 'Destino: $value';
  }

  @override
  String planSummaryGoal(String value) {
    return 'Objetivo: $value';
  }

  @override
  String planSummaryTimeline(String value) {
    return 'Momento da mudança: $value';
  }

  @override
  String get migrationPlanStepsTitle => 'Primeiros passos sugeridos';

  @override
  String get planNextActionsTitle => 'O que costuma vir logo depois';

  @override
  String get planNextActionsBody =>
      'Se o resultado ajudou, o próximo passo normalmente é confirmar documentos, comparar a cidade sugerida com outras opções ou refazer o plano com outra prioridade.';

  @override
  String get planNextActionDocumentsTitle =>
      'Confirmar documentos antes de agir';

  @override
  String get planNextActionDocumentsBody =>
      'Use o guia prático para checar CPF, registro, permanência, trabalho e banco sem cair em pesquisa dispersa.';

  @override
  String get planNextActionCitiesTitle =>
      'Comparar outras cidades antes de decidir';

  @override
  String get planNextActionCitiesBody =>
      'Veja se a cidade sugerida continua fazendo sentido quando comparada com custo, idioma, segurança e trabalho.';

  @override
  String get planNextActionRetakeTitle =>
      'Refazer o plano com outra prioridade';

  @override
  String get planNextActionRetakeBody =>
      'Se sua prioridade mudou, vale responder de novo e ver se a ordem dos passos também muda.';

  @override
  String get readinessSectionTitle => 'Checklist prático para a próxima fase';

  @override
  String get readinessStageNow => 'Comece agora';

  @override
  String get readinessStageSoon => 'Prepare em seguida';

  @override
  String get readinessStageLanding => 'Antes de chegar';

  @override
  String get readinessSummaryResearching =>
      'Como você ainda está explorando, o melhor passo agora é reduzir a incerteza antes de abrir frentes demais.';

  @override
  String get readinessSummaryTwelveMonths =>
      'Você ainda tem tempo para preparar bem a mudança, então use esta checklist para reduzir atritos com antecedência.';

  @override
  String get readinessSummarySixMonths =>
      'Seis meses já são tempo suficiente para sair do improviso e estruturar documentos, dinheiro e cidade.';

  @override
  String get readinessSummaryAsap =>
      'Como o plano está próximo, a prioridade agora é organizar o essencial e evitar erros evitáveis.';

  @override
  String get readinessItemMigrationPathTitle =>
      'Confirme primeiro a rota migratória';

  @override
  String get readinessItemMigrationPathBody =>
      'Antes de banco, moradia ou trabalho, valide qual caminho de residência faz mais sentido para a sua entrada no Brasil.';

  @override
  String get readinessItemDocumentsTitle =>
      'Monte o pacote documental essencial';

  @override
  String get readinessItemDocumentsBody =>
      'Separe passaporte, antecedentes, necessidade de apostila e documentos que ainda podem exigir tradução.';

  @override
  String get readinessItemBudgetTitle => 'Teste o orçamento de aterrissagem';

  @override
  String get readinessItemBudgetBody =>
      'Projete o que os primeiros 30 a 90 dias vão exigir, e não só o custo mensal depois que tudo estabilizar.';

  @override
  String get readinessItemCityTitle => 'Transforme a cidade em um filtro real';

  @override
  String get readinessItemCityBody =>
      'Use sua seleção atual de cidades para reduzir a incerteza sobre moradia, transporte e rotina antes de entrar no nível de bairro.';

  @override
  String readinessItemCityBodyWithCity(String city) {
    return 'Use $city como primeiro filtro e compare com alternativas antes de decidir no nível de bairro.';
  }

  @override
  String get readinessItemLanguageTitle =>
      'Prepare sua primeira camada de idioma';

  @override
  String get readinessItemLanguageBody =>
      'Foque no português que reduz atrito no cotidiano: moradia, transporte, banco e serviços.';

  @override
  String get readinessItemLanguageWorkBody =>
      'Foque no português que impacta entrevista, rotina de trabalho, negociação e pedidos básicos de serviço.';

  @override
  String get readinessItemLanguageStudyBody =>
      'Foque no português necessário para aulas, matrícula, rotina diária e comunicação institucional.';

  @override
  String get readinessGoalWorkTitle =>
      'Mapeie a empregabilidade antes de chegar';

  @override
  String get readinessGoalWorkBody =>
      'Revise que tipo de trabalho você pode buscar no início, quais documentos travam o processo e como a cidade muda suas chances.';

  @override
  String get readinessGoalRemoteTitle => 'Estabilize a base do trabalho remoto';

  @override
  String get readinessGoalRemoteBody =>
      'Cheque internet, fluxo bancário, custo diário e a estrutura mínima local antes de depender da renda remota.';

  @override
  String get readinessGoalStudyTitle => 'Valide a rota de estudo';

  @override
  String get readinessGoalStudyBody =>
      'Revise admissão, custo de rotina, timing de estudante e o que precisa estar regular antes de usar o estudo como base.';

  @override
  String get readinessGoalEntrepreneurTitle =>
      'Planeje a entrada para empreender';

  @override
  String get readinessGoalEntrepreneurBody =>
      'Mapeie a camada prática inicial: documentos locais, banco, cidade e estrutura mínima para operar com mais segurança.';

  @override
  String get readinessGoalRetireTitle => 'Proteja rotina e previsibilidade';

  @override
  String get readinessGoalRetireBody =>
      'Priorize acesso à saúde, rotina de bairro, custo recorrente e os documentos que protegem uma chegada tranquila.';

  @override
  String get readinessGoalQualityTitle =>
      'Converta qualidade de vida em critério';

  @override
  String get readinessGoalQualityBody =>
      'Transforme estilo de vida em filtros reais: segurança, rotina, adaptação ao idioma e custo de permanência.';

  @override
  String get readinessItemCpfBankTitle =>
      'Prepare o CPF e a primeira base bancária';

  @override
  String get readinessItemCpfBankBody =>
      'CPF e situação regular influenciam banco, contrato e boa parte da estrutura prática da chegada.';

  @override
  String get readinessItemHousingTitle =>
      'Reduza o atrito da moradia antes da busca';

  @override
  String get readinessItemHousingBody =>
      'Revise garantia, reserva financeira, prioridade de bairro e comprovações que podem ser exigidas antes de falar com proprietários.';

  @override
  String get readinessItemArrivalTitle =>
      'Monte um plano de chegada de 30 dias';

  @override
  String get readinessItemArrivalBody =>
      'Liste o que precisa funcionar no primeiro mês: conectividade, saúde, transporte, pagamentos e acompanhamento documental.';

  @override
  String readinessProgressLabel(int done, int total) {
    return '$done de $total itens concluídos';
  }

  @override
  String planStepMeta(String category, int days) {
    return 'Categoria: $category  Dias estimados: $days';
  }

  @override
  String get planStepOpenDetailsAction => 'Abrir detalhes';

  @override
  String get planStepOpenVisaEyebrow => 'Residência e visto';

  @override
  String get planStepOpenVisaSummary =>
      'Antes de decidir banco, trabalho ou contrato, vale confirmar qual é a sua base migratória correta para entrar e permanecer de forma regular.';

  @override
  String get planStepOpenVisaPointOne =>
      'Para argentinos, a residência pelo Acordo do Mercosul costuma ser um dos caminhos mais diretos.';

  @override
  String get planStepOpenVisaPointTwo =>
      'O visto de visita não foi feito para morar no Brasil nem para atividade remunerada.';

  @override
  String get planStepOpenVisaPointThree =>
      'Se a sua intenção já é viver no Brasil, vale resolver isso antes de assumir aluguel ou trabalho.';

  @override
  String get planStepOpenCpfEyebrow => 'Documento fiscal';

  @override
  String get planStepOpenCpfSummary =>
      'O CPF ajuda a destravar banco, contrato, cadastro e parte da vida prática logo no começo.';

  @override
  String get planStepOpenCpfPointOne =>
      'O pedido pode ser iniciado online, conforme a orientação oficial.';

  @override
  String get planStepOpenCpfPointTwo =>
      'O prazo informado oficialmente pode chegar a até 30 dias corridos.';

  @override
  String get planStepOpenCpfPointThree =>
      'O CPF ajuda bastante, mas não substitui documento migratório regular.';

  @override
  String get planStepOpenBankEyebrow => 'Conta inicial';

  @override
  String get planStepOpenBankSummary =>
      'Abrir conta depende mais da sua regularização e dos documentos apresentados do que de um banco específico.';

  @override
  String get planStepOpenBankPointOne =>
      'Existem bancos tradicionais e digitais, mas os documentos exigidos podem variar.';

  @override
  String get planStepOpenBankPointTwo =>
      'O CPF costuma ajudar, mas CRNM, protocolo ou outro documento regular podem fazer diferença na aprovação.';

  @override
  String get planStepOpenBankPointThree =>
      'Comece comparando conta digital para uma rotina simples e banco tradicional se você precisa de atendimento físico.';

  @override
  String get planStepOpenHousingEyebrow => 'Moradia e bairros';

  @override
  String get planStepOpenHousingSummary =>
      'Antes de fechar moradia, vale comparar bairros com melhor rotina, acesso e custo.';

  @override
  String planStepOpenHousingSummaryCity(String city) {
    return 'Para $city, compare bairros com melhor rotina, acesso e custo antes de fechar um contrato de moradia.';
  }

  @override
  String get planStepOpenHousingPointOne =>
      'Priorize bairros com boa conexão com o que você precisa no dia a dia: trabalho, transporte e serviços.';

  @override
  String get planStepOpenHousingPointTwo =>
      'Use a leitura de custo da cidade como ponto de partida, mas confirme aluguel e contrato antes de decidir.';

  @override
  String get planStepOpenHousingPointThree =>
      'A análise por bairro ainda precisa de uma base dedicada; por enquanto, use a cidade recomendada como filtro inicial.';

  @override
  String get planStepOpenGeneralEyebrow => 'Checklist guiada';

  @override
  String get planStepOpenGeneralSummary =>
      'Este passo funciona melhor como uma validação prática dentro da sua chegada ao Brasil.';

  @override
  String get planStepOpenGeneralPointOne =>
      'Resolva o essencial primeiro para não abrir frentes demais ao mesmo tempo.';

  @override
  String get planStepOpenGeneralPointTwo =>
      'Quando a etapa depender de documento oficial, confirme a exigência mais recente antes de protocolar.';

  @override
  String get planStepOpenGeneralPointThree =>
      'Use o plano como ordem sugerida, não como uma regra fixa para todos os casos.';

  @override
  String get planStepOpenTagMercosur => 'Mercosul';

  @override
  String get planStepOpenTagVisitor => 'Visita não autoriza trabalho';

  @override
  String get planStepOpenTagOnline => 'Pedido online';

  @override
  String get planStepOpenTagReceitaFederal => 'Receita Federal';

  @override
  String get planStepOpenTagTraditionalBanks => 'Bancos tradicionais';

  @override
  String get planStepOpenTagDigitalBanks => 'Bancos digitais';

  @override
  String get planStepOpenTagNeighborhoods => 'Bairros';

  @override
  String get planStepOpenTagRent => 'Aluguel';

  @override
  String get planStepOpenTagChecklist => 'Passo a passo';

  @override
  String get savePlanAction => 'Salvar plano';

  @override
  String get savePlanPageTitle => 'Salvar plano';

  @override
  String get savePlanSuccessTitle => 'Plano salvo por enquanto';

  @override
  String savePlanSuccessBody(int count) {
    return 'Planos salvos temporariamente nesta sessão: $count';
  }

  @override
  String get goToProfileAction => 'Ir para meu espaço';

  @override
  String get citiesExploreTitle => 'Cidades';

  @override
  String get citiesExploreHeadline => 'Descubra cidades com mais contexto';

  @override
  String get citiesExploreDescription =>
      'Veja sugestões por intenção e entenda por que cada cidade aparece aqui.';

  @override
  String get citiesExploreSearchFirstDescription =>
      'Pesquise uma cidade ou use os chips para filtrar o catálogo quando fizer sentido. A lista não abre carregada: os resultados aparecem só quando você buscar ou selecionar um recorte.';

  @override
  String get citiesGuideEyebrow => 'Guia rápido';

  @override
  String get citiesGuideTitle => 'Como usar a descoberta de cidades';

  @override
  String get citiesGuideBody =>
      'Aqui você pode buscar por nome, filtrar o catálogo por recortes rápidos ou abrir o mapa para escolher pela localização.';

  @override
  String get citiesGuideStepOneTitle => 'Busque uma cidade';

  @override
  String get citiesGuideStepOneBody =>
      'Digite o nome e toque no resultado mais próximo para abrir o detalhe.';

  @override
  String get citiesGuideStepTwoTitle => 'Use um recorte rápido';

  @override
  String get citiesGuideStepTwoBody =>
      'Os chips ajudam a reduzir a lista por popularidade, custo, trabalho, idioma e outros sinais.';

  @override
  String get citiesGuideStepThreeTitle => 'Escolha no mapa';

  @override
  String get citiesGuideStepThreeBody =>
      'Abra o mapa, toque em uma cidade e siga para o detalhe quando quiser decidir pela localização.';

  @override
  String get citiesGuideHideNextTime => 'Não mostrar novamente';

  @override
  String get citiesGuideStepsLabel => '3 passos';

  @override
  String get citiesGuideDismissAction => 'Agora não';

  @override
  String get citiesGuidePrimaryAction => 'Entendi';

  @override
  String get citiesExploreSearchIdleTitle =>
      'Pesquise uma cidade ou escolha um filtro';

  @override
  String get citiesExploreSearchIdleDescription =>
      'Digite o nome da cidade para autocomplete imediato ou deslize os chips para explorar por popularidade, praia, trabalho, idioma e chegada.';

  @override
  String get citiesLoadingLabel => 'Carregando cidades';

  @override
  String get citiesMethodologyNote =>
      'Rankings baseados em dados públicos e na metodologia do Movaro.';

  @override
  String get citiesExplorePopularTitle => 'Mais escolhidas por argentinos';

  @override
  String get citiesExploreLanguageTitle =>
      'Mais fáceis para quem ainda depende do espanhol';

  @override
  String get citiesExploreEconomicalTitle =>
      'Boas opções para quem prioriza custo';

  @override
  String get citiesExploreWorkTitle => 'Boas opções para quem busca trabalho';

  @override
  String get citiesExploreHousingEasyTitle =>
      'Melhores para uma chegada mais leve';

  @override
  String get citiesExploreHousingPressureTitle =>
      'Exigem mais caixa na entrada';

  @override
  String get citiesExploreSoftLandingTitle =>
      'Boas para chegar com menos atrito';

  @override
  String get citiesExploreFamilyStabilityTitle =>
      'Boas para chegar com mais previsibilidade';

  @override
  String get citiesExploreIncomeStartTitle => 'Boas para chegar buscando renda';

  @override
  String get citiesExploreCoastalTitle =>
      'Boas para quem quer viver perto da praia';

  @override
  String get citiesExploreCoastalSoftLandingTitle =>
      'Praia com chegada mais leve';

  @override
  String get citiesExploreCoastalBalancedTitle =>
      'Praia com melhor equilíbrio de rotina';

  @override
  String get citiesHighlightPopularLabel =>
      'Entre as cidades analisadas pelo Movaro';

  @override
  String get citiesHighlightLanguageLabel =>
      'Boa opção se a adaptação ao idioma importa para você';

  @override
  String get citiesHighlightEconomicalLabel =>
      'Boa opção para quem prioriza custo';

  @override
  String get citiesHighlightWorkLabel =>
      'Boa para quem busca mais oportunidades de trabalho';

  @override
  String get citiesHighlightHousingEasyLabel => 'Boa para soft landing';

  @override
  String get citiesHighlightHousingPressureLabel => 'Pressão de moradia alta';

  @override
  String get citiesHighlightSoftLandingLabel =>
      'Boa para um pouso inicial com menos fricção';

  @override
  String get citiesHighlightFamilyStabilityLabel =>
      'Boa para equilibrar segurança, moradia e rotina';

  @override
  String get citiesHighlightIncomeStartLabel =>
      'Boa para quem precisa ativar renda mais cedo';

  @override
  String get citiesHighlightCoastalLabel => 'Boa para rotina de litoral';

  @override
  String get citiesHighlightMetropolisLabel =>
      'Boa para quem quer um ritmo mais urbano';

  @override
  String get citiesHighlightInlandLabel =>
      'Boa para quem busca uma rotina mais calma';

  @override
  String get citiesHighlightBorderLabel =>
      'Boa para quem quer a leitura de uma cidade de fronteira';

  @override
  String get citiesHighlightCoastalSoftLandingLabel =>
      'Praia com melhor soft landing';

  @override
  String get citiesHighlightCoastalBalancedLabel =>
      'Praia com melhor equilíbrio entre rotina e custo';

  @override
  String get citiesExploreEmptyTitle => 'Ainda estamos ampliando este catálogo';

  @override
  String get citiesExploreEmptyDescription =>
      'As sugestões de cidades vão aparecer aqui conforme a base do Movaro crescer.';

  @override
  String get citiesSearchTitle => 'Buscar cidades';

  @override
  String get citiesSearchHeadline => 'Encontre uma cidade no catálogo inicial';

  @override
  String get citiesSearchDescription =>
      'Busque por nome ou explore a lista atual do Movaro.';

  @override
  String get citiesSearchHint => 'Buscar cidade';

  @override
  String get citiesSearchFieldLabel => 'Nome da cidade';

  @override
  String get citiesSearchHelper =>
      'Digite para buscar cidades por nome e tocar no autocomplete.';

  @override
  String get citiesQuickChoicesTitle => 'Escolhas rápidas';

  @override
  String get citiesQuickChoicesBody =>
      'Use um recorte para reduzir a lista mais rápido ou vá pelo mapa se você preferir localização.';

  @override
  String citiesSearchResultsCount(int count) {
    return '$count cidades encontradas';
  }

  @override
  String get citiesSearchResultsHint =>
      'Toque em uma cidade para abrir direto o detalhe.';

  @override
  String get citiesMapOpenAction => 'Escolher no mapa';

  @override
  String get citiesMapCalloutBody =>
      'Prefere decidir pela localização? Entre no mapa e compare as cidades pelo ponto onde você quer começar.';

  @override
  String get citiesMapCalloutStepOne => 'Abrir mapa';

  @override
  String get citiesMapCalloutStepTwo => 'Tocar na cidade';

  @override
  String get citiesMapCalloutStepThree => 'Abrir detalhe';

  @override
  String get citiesMapSheetTitle => 'Escolha uma cidade no mapa';

  @override
  String get citiesMapSheetBody =>
      'Abra o mapa do Brasil, toque em um ponto e selecione a cidade pela posição.';

  @override
  String get citiesMapOpenCityAction => 'Abrir cidade';

  @override
  String get citiesQuickFilterAll => 'Visão geral';

  @override
  String get citiesQuickFilterPopular => 'Mais populares';

  @override
  String get citiesQuickFilterLowCost => 'Melhor custo';

  @override
  String get citiesQuickFilterWork => 'Mais trabalho';

  @override
  String get citiesQuickFilterLanguage => 'Idioma mais fácil';

  @override
  String get citiesQuickFilterHousingEasy => 'Chegada leve';

  @override
  String get citiesQuickFilterHousingPressure => 'Mais caixa';

  @override
  String get citiesQuickFilterSoftLanding => 'Menos atrito';

  @override
  String get citiesQuickFilterFamilyStability => 'Mais previsível';

  @override
  String get citiesQuickFilterIncomeStart => 'Renda rápida';

  @override
  String get citiesQuickFilterCoastal => 'Praia';

  @override
  String get citiesSearchingLabel => 'Buscando cidades';

  @override
  String get citiesCatalogLoadingLabel => 'Carregando catálogo';

  @override
  String get citiesFilterClear => 'Limpar';

  @override
  String get citiesResultsTitle => 'Resultados';

  @override
  String citiesResultsBody(int count) {
    return '$count cidades combinam com esta busca ou filtro.';
  }

  @override
  String get citiesResultsMoreHint => 'Role para carregar mais cidades';

  @override
  String get citiesSearchEmptyTitle => 'Nenhuma cidade encontrada';

  @override
  String get citiesSearchEmptyDescription =>
      'Tente outro nome ou explore o catálogo inicial do Movaro.';

  @override
  String get citiesSearchFirstEmptyDescription =>
      'Tente outro nome ou troque o filtro para ampliar os resultados.';

  @override
  String get citiesCatalogEmptyTitle => 'Catálogo ainda vazio';

  @override
  String get citiesCatalogEmptyDescription =>
      'As cidades do catálogo do Movaro vão aparecer aqui.';

  @override
  String get cityDetailTitleFallback => 'Cidade';

  @override
  String get cityDetailLoadingLabel => 'Carregando detalhes da cidade';

  @override
  String get cityDetailEmptyTitle => 'Cidade indisponível';

  @override
  String get cityDetailEmptyDescription =>
      'Não encontramos os detalhes dessa cidade neste momento.';

  @override
  String get cityDetailContextNote =>
      'Use estes indicadores como ponto de partida, não como verdade absoluta.';

  @override
  String get cityDetailDecisionSnapshotTitle => 'Resumo para decidir';

  @override
  String cityDetailDecisionSnapshotSubtitle(Object bestFor) {
    return 'O Movaro vê esta cidade como uma boa opção se você prioriza $bestFor.';
  }

  @override
  String cityDetailDecisionSnapshotPlanSubtitle(Object bestFor) {
    return 'Para o seu plano, esta cidade aparece forte se você estiver priorizando $bestFor.';
  }

  @override
  String cityDetailDecisionSnapshotRecommendedSubtitle(Object bestFor) {
    return 'Esta cidade está na frente no seu plano se o foco atual for $bestFor.';
  }

  @override
  String get cityDetailWatchoutTitle => 'O principal ponto para validar';

  @override
  String get cityDetailPlanLeadingChip => 'Lidera no seu plano';

  @override
  String get cityDetailPlanMatchChip => 'Combina com seu plano';

  @override
  String cityDetailUpdatedLabel(Object date) {
    return 'Atualizado em $date';
  }

  @override
  String get cityDetailAffordabilityTitle => 'Custo e moradia';

  @override
  String get cityDetailSettleInTitle => 'Adaptação e comunidade';

  @override
  String get cityDetailCommunityTitle => 'Rede de apoio';

  @override
  String get cityDetailContextTitle => 'Contexto da cidade';

  @override
  String get cityLifestyleCoastalLabel => 'Estilo de vida litorâneo';

  @override
  String get cityLifestyleMetropolisLabel => 'Ritmo de metrópole';

  @override
  String get cityLifestyleBorderLabel => 'Cidade de fronteira';

  @override
  String get cityLifestyleInlandLabel => 'Rotina de interior';

  @override
  String get cityDetailMapTitle => 'Onde a cidade fica';

  @override
  String get cityDetailMapDescription =>
      'Veja a localização da cidade no mapa antes de comparar contexto, distância e região.';

  @override
  String get cityDetailSnapshotTitle => 'Visão rápida';

  @override
  String get cityDetailSnapshotPositiveTag => 'Ponto forte';

  @override
  String get cityDetailSnapshotWatchoutTag => 'Atenção';

  @override
  String get cityDetailSnapshotContextTag => 'Contexto';

  @override
  String get cityDetailMetricsSummary =>
      'Abra só se quiser ver todos os indicadores e o recorte completo.';

  @override
  String get cityDetailPopulationLabel => 'População';

  @override
  String get cityDetailCostLabel => 'Custo';

  @override
  String get cityDetailRentLabel => 'Aluguel';

  @override
  String get cityDetailSafetyLabel => 'Segurança';

  @override
  String get cityDetailPopularityLabel => 'Popularidade entre argentinos';

  @override
  String get cityDetailLanguageLabel => 'Adaptação ao idioma';

  @override
  String get cityDetailWorkLabel => 'Mercado de trabalho';

  @override
  String get cityDetailIdhmLabel => 'IDHM';

  @override
  String get cityDetailIdhmOfficialNote =>
      'dado oficial do Atlas do Desenvolvimento Humano';

  @override
  String get cityDetailUnemploymentLabel => 'Taxa de desemprego';

  @override
  String get cityDetailIndustriesTitle => 'Setores fortes';

  @override
  String get cityDetailReasonsTitle => 'Por que o Movaro recomenda';

  @override
  String get cityDetailSourcesTitle => 'Fontes dos dados';

  @override
  String cityDetailSourcesSummary(int count) {
    return '$count fontes disponíveis. Expanda apenas se quiser validar a origem dos dados.';
  }

  @override
  String get cityDetailSourceOfficialBadge => 'Fonte oficial';

  @override
  String get cityDetailSourceCuratedBadge => 'Fonte curada';

  @override
  String get cityDetailSourceProviderLabel => 'Origem';

  @override
  String get cityDetailSourceUrlLabel => 'Referência';

  @override
  String get cityDetailPublicOpinionTitle =>
      'O que visitantes costumam comentar';

  @override
  String cityDetailPublicOpinionSubtitle(Object provider) {
    return 'Leitura de temas recorrentes em avaliações públicas do $provider. Não representa a opinião de toda a cidade.';
  }

  @override
  String cityDetailPublicOpinionRating(Object rating) {
    return 'Nota $rating';
  }

  @override
  String cityDetailPublicOpinionSample(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count avaliações',
      one: '1 avaliação',
      zero: 'Sem avaliações',
    );
    return '$_temp0';
  }

  @override
  String get cityDetailPublicOpinionFallbackSummary =>
      'Esses tópicos mostram temas que aparecem com frequência nas avaliações públicas encontradas para a localidade.';

  @override
  String get cityDetailPublicOpinionPositiveTitle => 'O que mais elogiam';

  @override
  String get cityDetailPublicOpinionCriticalTitle => 'O que mais criticam';

  @override
  String cityDetailPublicOpinionNote(Object date) {
    return 'Resumo automático consultado em $date. Use como sinal de percepção recorrente, não como consenso absoluto.';
  }

  @override
  String get citySourceTerritorialTitle => 'Identidade territorial';

  @override
  String get citySourceTerritorialDescription =>
      'Nome oficial, estado, código IBGE e região municipal.';

  @override
  String get citySourcePopulationTitle => 'População';

  @override
  String get citySourcePopulationDescription =>
      'Referência oficial de população do município.';

  @override
  String get citySourceHumanDevelopmentTitle => 'Desenvolvimento humano';

  @override
  String get citySourceHumanDevelopmentDescription =>
      'IDHM municipal oficial com referência no Censo 2010.';

  @override
  String get citySourceCuratedMetricsTitle => 'Métricas curadas do produto';

  @override
  String get citySourceCuratedMetricsDescription =>
      'Hoje, vêm do dataset curado do Movaro. As substituições oficiais prioritárias são Atlas da Violência (segurança), Novo Caged (emprego), FipeZAP (aluguel) e IBGE PIB dos Municípios (atividade econômica).';

  @override
  String get citySourceRankingTitle => 'Metodologia de score';

  @override
  String get citySourceRankingDescription =>
      'Scores do Movaro calculados com base em dados públicos e dataset curado.';

  @override
  String get citySourcePublicReviewsTitle => 'Percepção pública da localidade';

  @override
  String get citySourcePublicReviewsDescription =>
      'Temas recorrentes extraídos de avaliações públicas do Google sobre a localidade. Não representa a opinião de toda a cidade.';

  @override
  String get cityDetailSaveAction => 'Salvar cidade';

  @override
  String get cityDetailSavedAction => 'Cidade salva';

  @override
  String get cityDetailSavedFeedback =>
      'Cidade salva temporariamente neste dispositivo.';

  @override
  String get cityDetailFavoriteAction => 'Adicionar aos favoritos';

  @override
  String get cityDetailFavoriteRemoveAction => 'Remover dos favoritos';

  @override
  String get cityDetailFavoriteNote =>
      'Você pode manter até 3 cidades favoritas para voltar a elas rapidamente na home.';

  @override
  String cityDetailFavoriteAddedFeedback(Object city) {
    return '$city foi adicionada aos favoritos.';
  }

  @override
  String cityDetailFavoriteRemovedFeedback(Object city) {
    return '$city foi removida dos favoritos.';
  }

  @override
  String cityDetailFavoriteLimitFeedback(Object count) {
    return 'Você pode escolher no máximo $count cidades favoritas.';
  }

  @override
  String get cityDetailDiscoverTitle => 'Conheça melhor a cidade';

  @override
  String cityDetailDiscoverBody(Object city, Object state) {
    return 'Se quiser ver fotos, buscas e contexto geral de $city ($state), abra a visão do Google sem sair do app.';
  }

  @override
  String get cityDetailDiscoverAction => 'Conhecer a cidade';

  @override
  String get cityDetailDeepDiveTitle => 'Análise detalhada';

  @override
  String get cityDetailDeepDiveSummary =>
      'Abra esta área se quiser ver todos os indicadores, contexto e leitura mais profunda da cidade.';

  @override
  String get cityDetailCompareAction => 'Comparar outras cidades';

  @override
  String get cityDetailPlanAction => 'Montar meu plano';

  @override
  String get cityDetailFooterNote =>
      'Os indicadores ajudam na exploração inicial e não substituem análise individual.';

  @override
  String get publicHomeFavoritesTitle => 'Suas cidades favoritas';

  @override
  String get publicHomeFavoritesBody =>
      'Guarde até 3 cidades para voltar rápido aos detalhes quando quiser comparar melhor.';

  @override
  String get publicHomeFavoritesJumpAction => 'Ver cidades favoritas';

  @override
  String get publicHomeFavoriteCardHint =>
      'Abra os detalhes para comparar de novo custo, trabalho e encaixe de chegada.';

  @override
  String get mainNavHome => 'Home';

  @override
  String get mainNavFavorites => 'Favoritas';

  @override
  String get mainNavCopilot => 'Guia';

  @override
  String get mainNavFavoritesDisabled =>
      'Adicione pelo menos 1 cidade aos favoritos para liberar esta aba.';

  @override
  String get mainNavCopilotDisabled =>
      'Confirme uma cidade no seu plano para liberar o guia da mudança.';

  @override
  String get favoritesEmptyTitle => 'Nenhuma cidade favorita ainda';

  @override
  String get favoritesEmptyBody =>
      'Quando você favoritar cidades, elas ficam reunidas aqui para acompanhar detalhes, clima e comparação mais rápido.';

  @override
  String get favoritesEmptyHint =>
      'Explore cidades, salve as mais promissoras e volte aqui quando quiser retomar.';

  @override
  String get favoritesExploreAction => 'Explorar cidades';

  @override
  String get favoritesGuideEyebrow => 'Guia rápido';

  @override
  String get favoritesGuideTitle => 'Como usar Favoritas';

  @override
  String get favoritesGuideBody =>
      'Aqui você guarda até 3 cidades para retomar depois sem refazer busca. Use esta área para comparar melhor, reabrir detalhes e decidir com mais calma.';

  @override
  String get favoritesGuideStepOneTitle => 'Salve as cidades mais promissoras';

  @override
  String get favoritesGuideStepOneBody =>
      'Use o coração nos cards ou no detalhe para manter as cidades que fazem sentido para você.';

  @override
  String get favoritesGuideStepTwoTitle => 'Volte para comparar rápido';

  @override
  String get favoritesGuideStepTwoBody =>
      'Favoritas reúne suas escolhas em um só lugar para você não se perder entre buscas e filtros.';

  @override
  String get favoritesGuideStepThreeTitle =>
      'Abra o detalhe quando quiser decidir';

  @override
  String get favoritesGuideStepThreeBody =>
      'Toque em uma cidade para rever contexto, clima, custo e os sinais principais antes de avançar.';

  @override
  String get favoritesGuideHideNextTime => 'Não mostrar novamente';

  @override
  String get favoritesGuideStepsLabel => '3 passos';

  @override
  String get favoritesGuideDismissAction => 'Agora não';

  @override
  String get favoritesGuidePrimaryAction => 'Entendi';

  @override
  String get publicHomeJourneyResetAction => 'Escolher outra rota';

  @override
  String get publicHomeJourneyResetTitle => 'Escolher outra rota?';

  @override
  String get publicHomeJourneyResetBody =>
      'Sua rota atual já está salva neste dispositivo. Se você reiniciar agora, o Movaro vai abrir novamente a seleção para escolher outra origem ou destino.';

  @override
  String get publicHomeJourneyResetConfirm => 'Refazer rota';

  @override
  String get publicHomePlanResetTitle => 'Montar outro plano?';

  @override
  String get publicHomePlanResetBody =>
      'Seu plano atual será removido deste dispositivo para que você possa responder o questionário novamente do zero.';

  @override
  String cityWeatherSummary(Object temperature) {
    return '$temperature°C agora';
  }

  @override
  String get introPageTitle => 'Como o Movaro funciona';

  @override
  String get introHeroTitle => 'Entenda o app em menos de um minuto';

  @override
  String get introHeroDescription =>
      'O Movaro ajuda você a comparar cidades, entender burocracias práticas e montar uma primeira direção de mudança sem começar pelo excesso de informação.';

  @override
  String get introExploreTitle => 'Explore cidades com contexto';

  @override
  String get introExploreDescription =>
      'Veja custo, segurança, adaptação ao idioma e sinais locais para entender por que uma cidade aparece como boa opção.';

  @override
  String get introPlanTitle => 'Monte um plano inicial';

  @override
  String get introPlanDescription =>
      'Responda a poucas perguntas e receba uma direção prática para o seu próximo passo.';

  @override
  String get introDocumentationTitle =>
      'Consulte a documentação quando precisar';

  @override
  String get introDocumentationDescription =>
      'Use o guia para entender CPF, registro, saúde, trabalho e custos aproximados do começo da mudança.';

  @override
  String get introBetaTitle => 'O que já está disponível neste beta';

  @override
  String get introBetaDescription =>
      'Esta versão foca em clareza. Você já pode explorar cidades, comparar sinais e gerar um plano inicial antes de chegar às funções mais profundas de conta.';

  @override
  String get introBottomSupportLabel => 'Próximo passo';

  @override
  String get introPrimaryAction => 'Começar a explorar';

  @override
  String get introSkipAction => 'Pular';

  @override
  String get cityPracticalAnswersTitle =>
      'Respostas rápidas para dúvidas comuns';

  @override
  String get cityPracticalLanguageQuestion =>
      'O dia a dia ficaria mais fácil se eu ainda dependesse do espanhol?';

  @override
  String get cityPracticalCostQuestion =>
      'Essa cidade parece administrável no custo de vida cotidiano?';

  @override
  String get cityPracticalWorkQuestion =>
      'Parece uma cidade forte para começar a trabalhar?';

  @override
  String get cityPracticalSafetyQuestion =>
      'Parece mais fácil se adaptar com uma rotina mais estável?';

  @override
  String get cityPracticalLanguageEasy =>
      'Ela parece mais fácil que a média para quem chega falando espanhol, porque combina melhor adaptação linguística e familiaridade com argentinos.';

  @override
  String get cityPracticalLanguageMedium =>
      'Ela parece administrável, mas ainda ajuda chegar com uma base de português para a rotina.';

  @override
  String get cityPracticalLanguageHard =>
      'Ela deve exigir uma adaptação mais rápida ao português, porque o apoio cotidiano em espanhol parece menor.';

  @override
  String get cityPracticalCostEasy =>
      'O sinal de custo parece mais amigável para uma mudança inicial dentro do catálogo atual.';

  @override
  String get cityPracticalCostMedium =>
      'Ela parece equilibrada, mas ainda vale validar aluguel e bairros com cuidado.';

  @override
  String get cityPracticalCostHard =>
      'Ela pode pesar mais no início, então orçamento e moradia importam ainda mais aqui.';

  @override
  String get cityPracticalWorkStrong =>
      'Ela mostra sinais mais fortes de oportunidades de trabalho e estrutura econômica inicial.';

  @override
  String get cityPracticalWorkMedium =>
      'Ela pode funcionar dependendo do seu perfil, mas a escolha precisa ser mais deliberada.';

  @override
  String get cityPracticalWorkLow =>
      'Ela parece menos atraente se sua principal preocupação for encontrar trabalho rápido.';

  @override
  String get cityPracticalSafetyGood =>
      'Dentro deste catálogo inicial, ela parece mais adequada para uma rotina diária mais estável.';

  @override
  String get cityPracticalSafetyMedium =>
      'Ela parece razoável, mas o contexto local e a escolha do bairro ainda importam bastante.';

  @override
  String get cityPracticalSafetyLow =>
      'Ela merece mais cautela e validação local antes de ser tratada como uma mudança simples.';

  @override
  String get cityMetricBadgePositive => 'Leitura favorável';

  @override
  String get cityMetricBadgeNeutral => 'Exige equilíbrio';

  @override
  String get cityMetricBadgeAttention => 'Exige mais atenção';

  @override
  String get cityMetricCostLowHeadline => 'Baixo custo';

  @override
  String get cityMetricCostLowSupporting =>
      'Mais leve para o orçamento do dia a dia.';

  @override
  String get cityMetricCostMediumHeadline => 'Custo moderado';

  @override
  String get cityMetricCostMediumSupporting =>
      'Equilíbrio razoável entre rotina e infraestrutura.';

  @override
  String get cityMetricCostHighHeadline => 'Custo alto';

  @override
  String get cityMetricCostHighSupporting =>
      'Vai exigir mais cuidado com aluguel e gastos mensais.';

  @override
  String get cityMetricSafetyHighHeadline => 'Segurança alta';

  @override
  String get cityMetricSafetyHighSupporting =>
      'Leitura mais confortável para a rotina inicial.';

  @override
  String get cityMetricSafetyMediumHeadline => 'Segurança moderada';

  @override
  String get cityMetricSafetyMediumSupporting =>
      'Depende mais do bairro e do contexto local.';

  @override
  String get cityMetricSafetyLowHeadline => 'Mais cautela';

  @override
  String get cityMetricSafetyLowSupporting =>
      'Vale validar melhor a cidade antes de tratá-la como uma mudança simples.';

  @override
  String get cityMetricLanguageEasyHeadline => 'Adaptação fácil';

  @override
  String get cityMetricLanguageEasySupporting =>
      'Tende a ser mais amigável para quem chega falando espanhol.';

  @override
  String get cityMetricLanguageMediumHeadline => 'Adaptação moderada';

  @override
  String get cityMetricLanguageMediumSupporting =>
      'Uma base de português ajuda bastante na rotina.';

  @override
  String get cityMetricLanguageHardHeadline => 'Adaptação mais difícil';

  @override
  String get cityMetricLanguageHardSupporting =>
      'O idioma tende a pesar mais na integração do dia a dia.';

  @override
  String get cityMetricWorkStrongHeadline => 'Mercado forte';

  @override
  String get cityMetricWorkStrongSupporting =>
      'Cidade com leitura mais favorável para buscar oportunidades.';

  @override
  String get cityMetricWorkMediumHeadline => 'Mercado moderado';

  @override
  String get cityMetricWorkMediumSupporting =>
      'Pode funcionar bem, mas depende mais do seu perfil.';

  @override
  String get cityMetricWorkLowHeadline => 'Mercado mais limitado';

  @override
  String get cityMetricWorkLowSupporting =>
      'Exige mais estratégia se trabalho rápido for sua prioridade.';

  @override
  String get cityIdhmVeryHigh => 'Desenvolvimento muito alto';

  @override
  String get cityIdhmVeryHighSupporting =>
      'Entre os patamares municipais mais fortes no indicador oficial.';

  @override
  String get cityIdhmHigh => 'Desenvolvimento alto';

  @override
  String get cityIdhmHighSupporting =>
      'Leitura sólida de desenvolvimento humano no recorte oficial.';

  @override
  String get cityIdhmMedium => 'Desenvolvimento médio';

  @override
  String get cityIdhmMediumSupporting =>
      'Exige leitura mais contextual junto com custo e oportunidades.';

  @override
  String get cityIdhmLow => 'Desenvolvimento baixo';

  @override
  String get cityIdhmLowSupporting =>
      'Exige mais cuidado antes de assumir boa estrutura geral.';

  @override
  String get cityIdhmVeryLow => 'Desenvolvimento muito baixo';

  @override
  String get cityIdhmVeryLowSupporting =>
      'Sinaliza uma base mais frágil no indicador oficial.';

  @override
  String get citySnapshotRentLower => 'Aluguel mais leve';

  @override
  String get citySnapshotRentLowerSupporting =>
      'Tende a pesar menos no início da mudança.';

  @override
  String get citySnapshotRentModerate => 'Aluguel moderado';

  @override
  String get citySnapshotRentModerateSupporting =>
      'Exige equilíbrio entre bairro, contrato e rotina.';

  @override
  String get citySnapshotRentHigher => 'Aluguel mais alto';

  @override
  String get citySnapshotRentHigherSupporting =>
      'Vai exigir mais cuidado antes de fechar moradia.';

  @override
  String get cityHousingViabilityTileLabel => 'Entrada de moradia';

  @override
  String get cityHousingViabilityEasyHeadline => 'Entrada mais leve';

  @override
  String get cityHousingViabilityEasySupporting =>
      'Tende a permitir um pouso inicial mais simples, com menos pressão de aluguel e mais margem para ajustar bairro e rotina.';

  @override
  String get cityHousingViabilityEasyBadge => 'Boa para soft landing';

  @override
  String get cityHousingViabilityBalancedHeadline => 'Entrada equilibrada';

  @override
  String get cityHousingViabilityBalancedSupporting =>
      'Pode funcionar bem se você chegar com reserva e validar bairro, garantia e custo total antes de assumir contrato.';

  @override
  String get cityHousingViabilityBalancedBadge => 'Exige validação';

  @override
  String get cityHousingViabilityHardHeadline => 'Exige mais caixa';

  @override
  String get cityHousingViabilityHardSupporting =>
      'Aqui, aluguel e entrada tendem a pesar mais. Vale tratar moradia como um filtro sério antes de escolher a cidade.';

  @override
  String get cityHousingViabilityHardBadge => 'Pressão de moradia alta';

  @override
  String get cityMetricInsightTapHint =>
      'Toque para entender os dados por trás desta leitura.';

  @override
  String get cityMetricInsightMeaningTitle => 'O que isso quer dizer';

  @override
  String get cityMetricInsightMethodTitle => 'Como essa leitura foi montada';

  @override
  String get cityMetricInsightFactsTitle => 'Dados usados hoje';

  @override
  String get cityMetricInsightValidateTitle => 'O que validar antes de decidir';

  @override
  String get cityMetricInsightSourcesTitle => 'Base e fontes';

  @override
  String get cityMetricInsightDisclaimer =>
      'Use este card como triagem inicial. A decisão final ainda depende de bairro, preço real e checagem local.';

  @override
  String get cityMetricInsightCurrentBaseBadge => 'Base usada hoje';

  @override
  String get cityMetricInsightMappedBaseBadge => 'Referência mapeada';

  @override
  String get cityMetricInsightOpenSourceAction => 'Abrir fonte';

  @override
  String get cityMetricInsightRangeLabel => 'Faixa deste card';

  @override
  String get cityMetricInsightSpanishSupportLabel => 'Suporte ao espanhol';

  @override
  String get cityMetricInsightLanguageCurrentBaseTitle =>
      'Leitura prática de adaptação';

  @override
  String get cityMetricInsightHousingMeaning =>
      'Quando este bloco cai para alerta, significa que aluguel e custo de entrada tendem a pesar mais na mudança inicial desta cidade.';

  @override
  String get cityMetricInsightHousingMethod =>
      'Hoje o app cruza o rentScore da cidade com o score econômico geral. Quando a leitura de moradia fica abaixo de 55, o produto trata a entrada de moradia como um filtro crítico.';

  @override
  String get cityMetricInsightHousingValidate =>
      'Compare aluguel real, caução, garantia, mobília e custo do bairro antes de assumir contrato. Aqui, errar na moradia costuma custar mais.';

  @override
  String get cityMetricInsightHousingMappedSource =>
      'FipeZAP é a referência mais sólida já mapeada no projeto para recalibrar aluguel e pressão de moradia quando houver cobertura municipal.';

  @override
  String get cityMetricInsightSafetyMeaning =>
      'Este alerta não quer dizer que a cidade seja inviável. Quer dizer que bairro, rotina e validação local pesam mais antes de tratar a mudança como simples.';

  @override
  String get cityMetricInsightSafetyMethod =>
      'Hoje o card usa o safetyScore do catálogo Movaro. Abaixo de 55, a leitura sobe para cautela; entre 55 e 69, ela fica moderada; a partir de 70, fica mais favorável.';

  @override
  String get cityMetricInsightSafetyValidate =>
      'Cheque bairro por bairro, deslocamentos noturnos, rotina real de quem já mora na cidade e a diferença entre áreas turísticas e residenciais.';

  @override
  String get cityMetricInsightSafetyMappedSource =>
      'O Atlas da Violência é a referência oficial mapeada no projeto para recalibrar este grupo com base pública e metodologia aberta.';

  @override
  String get cityMetricInsightWorkMeaning =>
      'Mercado moderado não é um bloqueio. Significa que a cidade pode funcionar, mas o resultado depende mais da sua área, senioridade e forma de entrada.';

  @override
  String get cityMetricInsightWorkMethod =>
      'A nota de trabalho combina jobMarketScore, economicActivityScore e desemprego invertido. Entre 62 e 77, a leitura fica moderada; acima de 78, fica forte.';

  @override
  String get cityMetricInsightWorkValidate =>
      'Procure vagas reais na sua área, veja quais setores puxam a cidade e estime quanto tempo você teria de fôlego até a primeira renda.';

  @override
  String get cityMetricInsightWorkMappedSource =>
      'Novo Caged é a principal referência oficial mapeada para medir dinamismo do emprego formal municipal.';

  @override
  String get cityMetricInsightWorkEconomicMappedSource =>
      'PIB dos Municípios, do IBGE, é a referência oficial mapeada para calibrar o peso de atividade econômica da cidade.';

  @override
  String get cityMetricInsightLanguageMeaning =>
      'Adaptação mais difícil significa que o português tende a pesar mais na integração prática do dia a dia e que o apoio informal em espanhol parece menor.';

  @override
  String get cityMetricInsightLanguageMethod =>
      'Esta leitura usa o score de adaptação linguística com apoio do suporte ao espanhol e da familiaridade com argentinos. Abaixo de 65, o atrito tende a ser maior.';

  @override
  String get cityMetricInsightLanguageValidate =>
      'Teste a rotina sem depender do espanhol: aluguel, mercado, saúde, serviços e trabalho. Se isso travar, a adaptação real da cidade é mais dura para o seu perfil.';

  @override
  String get cityMetricInsightLanguageMappedSource =>
      'Ainda não há uma fonte oficial única para esta leitura. Hoje ela continua sendo uma heurística curada do produto para medir adaptação prática.';

  @override
  String get citySnapshotPopularityHigh => 'Muito procurada';

  @override
  String get citySnapshotPopularityHighSupporting =>
      'Já aparece com forte afinidade entre argentinos.';

  @override
  String get citySnapshotPopularityMedium => 'Popularidade moderada';

  @override
  String get citySnapshotPopularityMediumSupporting =>
      'Tem familiaridade razoável dentro do catálogo atual.';

  @override
  String get citySnapshotPopularityLow => 'Menos recorrente';

  @override
  String get citySnapshotPopularityLowSupporting =>
      'Ainda aparece menos no recorte inicial de interesse argentino.';

  @override
  String get citySnapshotUnemploymentLower => 'Desemprego mais baixo';

  @override
  String get citySnapshotUnemploymentModerate => 'Desemprego moderado';

  @override
  String get citySnapshotUnemploymentHigher => 'Desemprego mais alto';

  @override
  String get languageSelectorTooltip => 'Escolher idioma';

  @override
  String get languageOptionSpanishArgentina => 'Espanhol (Argentina)';

  @override
  String get languageOptionEnglish => 'English';

  @override
  String get languageOptionPortuguese => 'Português';

  @override
  String get commonRetryAction => 'Tentar novamente';

  @override
  String get commonBackAction => 'Voltar';

  @override
  String get protectedCommunityCreateTitle => 'Criar post';

  @override
  String get protectedCommunityCreateDescription =>
      'Esta área vai permitir criar posts quando esse fluxo da comunidade estiver habilitado.';

  @override
  String get questionOriginCountryTitle => 'De onde você vem?';

  @override
  String get questionDestinationCountryTitle => 'Para onde você quer ir?';

  @override
  String get questionGoalTitle => 'O que você quer fazer no novo país?';

  @override
  String get questionPortugueseFamiliarityTitle =>
      'Qual é a sua familiaridade com o português hoje?';

  @override
  String get questionTimelineTitle => 'Quando pretende mudar?';

  @override
  String get questionOptionArgentina => 'Argentina';

  @override
  String get questionOptionBrazil => 'Brasil';

  @override
  String get questionOptionChile => 'Chile';

  @override
  String get questionOptionUruguay => 'Uruguai';

  @override
  String get questionOptionParaguay => 'Paraguai';

  @override
  String get questionOptionUnknown => 'Ainda não sei';

  @override
  String get questionOptionWork => 'Trabalhar';

  @override
  String get questionOptionRemoteWork => 'Trabalhar remotamente';

  @override
  String get questionOptionStudy => 'Estudar';

  @override
  String get questionOptionEntrepreneur => 'Empreender';

  @override
  String get questionOptionRetire => 'Aposentar-se';

  @override
  String get questionOptionQualityOfLife => 'Qualidade de vida';

  @override
  String get questionOptionBeachLife => 'Praia e litoral';

  @override
  String get questionOptionNoPortuguese =>
      'Ainda dependo principalmente do espanhol';

  @override
  String get questionOptionBasicPortuguese =>
      'Consigo me virar com o português básico';

  @override
  String get questionOptionComfortablePortuguese =>
      'Já consigo viver em português';

  @override
  String get questionOptionResearching => 'Só estou pesquisando';

  @override
  String get questionOption12Months => 'Nos próximos 12 meses';

  @override
  String get questionOption6Months => 'Nos próximos 6 meses';

  @override
  String get questionOptionAsap => 'O mais rápido possível';

  @override
  String get recommendationReasonEconomical =>
      'Boa opção para quem prioriza custo';

  @override
  String get recommendationReasonPopularArgentina => 'Popular entre argentinos';

  @override
  String get recommendationReasonLanguageSupport =>
      'Adaptação mais fácil se você ainda depende do espanhol';

  @override
  String get recommendationReasonWorkMarket => 'Mercado de trabalho mais forte';

  @override
  String get recommendationReasonInfrastructure =>
      'Custo mais alto, mas melhor infraestrutura';

  @override
  String get recommendationReasonBalanced =>
      'Opção equilibrada dentro do catálogo inicial do Movaro';

  @override
  String get planReasonGoalWork =>
      'Destaca-se para quem está buscando mais oportunidades de trabalho.';

  @override
  String get planReasonGoalRemoteWork =>
      'Combina melhor com quem quer trabalhar remotamente e equilibrar custo com qualidade de vida.';

  @override
  String get planReasonGoalStudy =>
      'Tem boa combinação de estrutura urbana e adaptação inicial para quem quer estudar.';

  @override
  String get planReasonGoalEntrepreneur =>
      'Tem sinais mais fortes de atividade econômica para quem quer empreender.';

  @override
  String get planReasonGoalRetire =>
      'Faz mais sentido para quem quer uma rotina com mais segurança e custo mais controlado.';

  @override
  String get planReasonGoalQualityOfLife =>
      'Encaixa-se melhor em uma busca por mais qualidade de vida e adaptação gradual.';

  @override
  String get planReasonGoalBeachLife =>
      'Faz mais sentido para quem quer priorizar litoral, praia e uma rotina mais ligada ao mar.';

  @override
  String get planReasonLanguageNeedsSupport =>
      'Como você disse que ainda depende do espanhol, demos mais peso a cidades com melhor adaptação linguística.';

  @override
  String get planReasonLanguageBasic =>
      'Como você disse que se vira apenas com o português básico, a adaptação ao idioma ainda influencia a recomendação.';

  @override
  String get planReasonTimelineAsap =>
      'Ajuda em uma mudança mais rápida por combinar melhor com adaptação inicial e vida prática.';

  @override
  String get planReasonTimeline6Months =>
      'Funciona bem para um horizonte de mudança mais curto.';

  @override
  String get planReasonTimeline12Months =>
      'Oferece uma base equilibrada para quem ainda está estruturando a mudança.';

  @override
  String get planStepTitleVisaResidence =>
      'Verificar tipo de residência ou visto';

  @override
  String get planStepDescriptionVisaResidence =>
      'Mapear a base migratória adequada para a sua principal motivação de mudança.';

  @override
  String get planStepTitleCpf => 'Obter CPF';

  @override
  String get planStepDescriptionCpf =>
      'Organizar o registro fiscal necessário para serviços e transações no Brasil.';

  @override
  String get planStepTitleBankAccount => 'Abrir conta bancária';

  @override
  String get planStepDescriptionBankAccount =>
      'Preparar uma conta local para movimentação financeira inicial.';

  @override
  String get planStepTitleHousing => 'Buscar moradia';

  @override
  String get planStepDescriptionHousing =>
      'Pesquisar bairros, contratos e custos para uma instalação segura.';

  @override
  String get planStepTitleSettleDocuments => 'Regularizar a documentação local';

  @override
  String get planStepDescriptionSettleDocuments =>
      'Conferir registros adicionais, comprovantes e etapas administrativas locais.';

  @override
  String get planStepTitleMapDestinations => 'Mapear destinos possíveis';

  @override
  String get planStepDescriptionMapDestinations =>
      'Comparar opções de país com base no seu objetivo e na sua janela de mudança.';

  @override
  String get planStepTitleDecisionCriteria => 'Definir critério de decisão';

  @override
  String get planStepDescriptionDecisionCriteria =>
      'Organizar prioridades como custo, documentação e qualidade de vida.';

  @override
  String get planBeachDecisionTitle => 'Litoral na decisão';

  @override
  String get planBeachDecisionIntro =>
      'Se praia e litoral entram no seu critério, não basta olhar beleza ou turismo. O filtro real passa por moradia, ritmo da cidade e pouso inicial.';

  @override
  String get planBeachDecisionCoastalHeadline =>
      'A recomendação já aponta para o litoral';

  @override
  String planBeachDecisionCoastalBody(Object cityName) {
    return '$cityName já entra no recorte de cidade costeira. O próximo filtro é entender se a entrada na moradia e a rotina local combinam com o seu momento.';
  }

  @override
  String get planBeachDecisionNotCoastalHeadline =>
      'Seu critério de litoral pede comparação extra';

  @override
  String get planBeachDecisionNotCoastalBody =>
      'Mesmo com esse objetivo, vale comparar cidades de praia antes de fechar a decisão. Nem toda cidade forte no plano entrega a rotina costeira que você pode estar buscando.';

  @override
  String get planBeachDecisionPriorityNote =>
      'Se praia é prioridade, trate moradia e rotina local como filtro principal.';

  @override
  String get planBeachDecisionHousingHeadline =>
      'Entrada na moradia no litoral';

  @override
  String get stepCategoryDocumentation => 'Documentação';

  @override
  String get stepCategoryFinancial => 'Financeiro';

  @override
  String get stepCategoryHousing => 'Moradia';

  @override
  String get stepCategorySettlement => 'Instalação';

  @override
  String get stepCategoryResearch => 'Pesquisa';

  @override
  String get stepCategoryPlanning => 'Planejamento';

  @override
  String get industryAgribusiness => 'Agronegócio';

  @override
  String get industryCommerce => 'Comércio';

  @override
  String get industryConstruction => 'Construção';

  @override
  String get industryEnergy => 'Energia';

  @override
  String get industryFinance => 'Finanças';

  @override
  String get industryIndustry => 'Indústria';

  @override
  String get industryLogistics => 'Logística';

  @override
  String get industryPort => 'Porto';

  @override
  String get industryHealth => 'Saúde';

  @override
  String get industryServices => 'Serviços';

  @override
  String get industryTechnology => 'Tecnologia';

  @override
  String get industryTourism => 'Turismo';

  @override
  String get errorNetworkTitle => 'Parece que você está sem conexão.';

  @override
  String get errorNetworkDescription =>
      'Confira sua internet e tente novamente em instantes.';

  @override
  String get errorServerTitle => 'Algo deu errado. Tente novamente.';

  @override
  String get errorServerDescription =>
      'Não conseguimos concluir esta ação agora. Tente novamente em alguns instantes.';

  @override
  String get errorNotFoundTitle => 'Não encontramos esta informação.';

  @override
  String get errorNotFoundDescription =>
      'Este conteúdo não está disponível no momento ou ainda não faz parte desta base.';

  @override
  String get errorUnauthorizedTitle => 'Você precisa entrar para continuar.';

  @override
  String get errorUnauthorizedDescription =>
      'Algumas ações precisam estar vinculadas a você para poderem ser salvas.';

  @override
  String get errorUnknownTitle => 'Algo saiu do esperado.';

  @override
  String get errorUnknownDescription => 'Tente novamente em alguns instantes.';

  @override
  String get errorValidationTitle => 'Não foi possível concluir.';

  @override
  String get errorNetworkMovaroDescription =>
      'Não conseguimos falar com o Movaro neste momento. Tente novamente em instantes.';

  @override
  String get errorApiGenericDescription =>
      'Não foi possível concluir esta ação agora.';

  @override
  String get apiUnavailableTitle =>
      'O Movaro não conseguiu se conectar à API agora.';

  @override
  String get apiUnavailableDescription =>
      'O aplicativo abriu, mas o serviço principal está indisponível neste momento. Sem essa conexão, não dá para montar sua jornada com dados reais.';

  @override
  String get apiUnavailableSupportingText =>
      'Tente novamente em alguns instantes. Se continuar assim, vale conferir se a API está online e se o endereço configurado neste ambiente está correto.';

  @override
  String get apiUnavailableRetryAction => 'Tentar novamente';

  @override
  String get sourceProviderIbgeLocalities => 'IBGE Localidades';

  @override
  String get sourceProviderIbgeCities => 'IBGE Cidades e Estados';

  @override
  String get sourceProviderAtlasHumanDevelopment =>
      'Atlas do Desenvolvimento Humano no Brasil (PNUD, Ipea e FJP)';

  @override
  String get sourceProviderMovaroDataset => 'Dataset Curado do Movaro v1';

  @override
  String get sourceProviderMovaroRanking =>
      'Metodologia de Ranking do Movaro v1';

  @override
  String get sourceProviderGoogleMaps => 'Google Maps';

  @override
  String get sourceProviderReceitaFederalGovBr => 'Receita Federal / Gov.br';

  @override
  String get sourceProviderArgentinaMigraciones =>
      'Argentina.gob.ar / Migraciones';

  @override
  String get sourceProviderPoliciaFederal => 'Polícia Federal';

  @override
  String get sourceProviderPoliciaFederalGovBr => 'Polícia Federal / Gov.br';

  @override
  String get sourceProviderMrePoliciaFederal => 'MRE / Polícia Federal';

  @override
  String get sourceProviderMreBancoCentral => 'MRE / Banco Central';

  @override
  String get sourceProviderMinisterioJustica => 'Ministério da Justiça';

  @override
  String get sourceProviderMinisterioSaude => 'Gov.br / Ministério da Saúde';

  @override
  String get sourceProviderMeuSusDigital => 'Meu SUS Digital / Gov.br';

  @override
  String get sourceProviderAns => 'ANS';

  @override
  String get sourceProviderDetranEsMgGov => 'Detran-ES / MG.gov.br';

  @override
  String get sourceProviderSenatranMgGov => 'SENATRAN / MG.gov.br';

  @override
  String get sourceProviderMteCtps => 'MTE / Carteira de Trabalho Digital';

  @override
  String get sourceProviderPortalEmpreendedorInss =>
      'Portal do Empreendedor / INSS';

  @override
  String get sourceProviderMinisterioPrevidenciaInss =>
      'Ministério da Previdência / INSS';

  @override
  String get sourceProviderIbgePnadContinua => 'IBGE / PNAD Contínua';

  @override
  String get sourceProviderForumBrasileiroSegurancaPublica =>
      'Fórum Brasileiro de Segurança Pública';

  @override
  String get sourceProviderBancoCentralBrasil => 'Banco Central do Brasil';

  @override
  String get sourceProviderMovaro => 'Movaro';

  @override
  String get documentReadinessSectionTitle =>
      'Prontidão documental antes da mudança';

  @override
  String get documentReadinessPriorityCritical => 'Crítico agora';

  @override
  String get documentReadinessPriorityPrepare => 'Prepare com antecedência';

  @override
  String get documentReadinessPriorityArrival => 'Leve pronto para a chegada';

  @override
  String get documentReadinessSummaryResearching =>
      'Antes de comparar caminhos demais, confirme se a sua mudança depende de um pacote documental que realmente pode ser montado sem surpresas.';

  @override
  String get documentReadinessSummaryTwelveMonths =>
      'Com mais tempo, a meta é remover cedo o risco documental evitável, em vez de descobrir faltas perto da mudança.';

  @override
  String get documentReadinessSummarySixMonths =>
      'Seis meses já permitem organizar os documentos mais sensíveis agora e deixar a chegada mais leve.';

  @override
  String get documentReadinessSummaryAsap =>
      'Como a mudança está perto, foque primeiro nos documentos que podem travar residência, banco e moradia.';

  @override
  String get documentReadinessRouteTitle => 'Valide a rota legal de entrada';

  @override
  String get documentReadinessRouteBodyBrazil =>
      'Confirme se a sua mudança vai usar a residência Mercosul e o que esse caminho exige antes de montar o resto com base em suposições.';

  @override
  String get documentReadinessRouteBodyGeneric =>
      'Confirme primeiro a rota legal do destino para que o restante da checklist seja montado com base no caminho migratório correto.';

  @override
  String get documentReadinessIdentityPackTitle =>
      'Separe o pacote básico de identidade';

  @override
  String get documentReadinessIdentityPackBody =>
      'Mantenha passaporte, certidões, antecedentes e identificações pessoais em um único bloco revisado antes de abrir outras frentes.';

  @override
  String get documentReadinessApostilleTitle =>
      'Revise apostila e validade dos documentos';

  @override
  String get documentReadinessApostilleBodyBrazil =>
      'Para o Brasil, veja quais documentos argentinos precisam de apostila, qual validade prática eles têm e o que pode vencer antes da chegada.';

  @override
  String get documentReadinessRuleCheckTitle =>
      'Cheque cedo as regras documentais oficiais';

  @override
  String get documentReadinessRuleCheckBody =>
      'Mapeie quais documentos precisam ser originais, apostilados, traduzidos ou reemitidos para não depender de achismos.';

  @override
  String get documentReadinessTranslationTitle =>
      'Mapeie a tradução antes de pagar duas vezes';

  @override
  String get documentReadinessTranslationBodyBrazil =>
      'Separe o que pode ficar em espanhol do que pode exigir tradução juramentada no Brasil, especialmente para residência e prova civil.';

  @override
  String get documentReadinessTranslationBodyGeneric =>
      'Separe o que pode permanecer no idioma de origem do que pode exigir tradução certificada no país de destino.';

  @override
  String get documentReadinessHousingProofTitle =>
      'Prepare comprovantes para moradia e rotina inicial';

  @override
  String get documentReadinessHousingProofBodyBrazil =>
      'Agrupe comprovante de renda, reserva, identidade e documentos de apoio que locadores, bancos ou garantias podem pedir no Brasil.';

  @override
  String get documentReadinessProofPackTitle =>
      'Monte seu pacote prático de comprovações';

  @override
  String get documentReadinessProofPackBody =>
      'Agrupe identidade, prova de fundos, renda e os documentos que costumam destravar banco, moradia e serviços essenciais.';

  @override
  String get documentReadinessCpfTitle =>
      'Trate CPF e status regular como uma camada só';

  @override
  String get documentReadinessCpfBodyBrazil =>
      'CPF, acompanhamento da residência e primeiro comprovante local costumam destravar a vida prática. Deixe esse bloco pronto para execução rápida.';

  @override
  String get documentReadinessCopiesTitle =>
      'Mantenha backup físico e digital alinhados';

  @override
  String get documentReadinessCopiesBody =>
      'Guarde scans, originais e cópias de emergência em uma estrutura acessível no celular e fácil de usar presencialmente, se necessário.';

  @override
  String get documentReadinessArrivalFolderTitle =>
      'Prepare uma pasta de chegada, não arquivos soltos';

  @override
  String get documentReadinessArrivalFolderBodyBrazil =>
      'Monte uma pasta única com acompanhamento da residência, referências do CPF, notas de endereço e as provas que mais tendem a ser pedidas no primeiro mês.';

  @override
  String get documentReadinessArrivalFolderBodyGeneric =>
      'Monte uma pasta única com os primeiros documentos, notas de comprovação local e as evidências que você mais tende a usar nas primeiras semanas.';

  @override
  String get documentReadinessGoalWorkTitle =>
      'Proteja os documentos de empregabilidade';

  @override
  String get documentReadinessGoalWorkBodyBrazil =>
      'Revise o que pode travar trabalho cedo no Brasil: consistência de identidade, acompanhamento da residência e provas específicas da sua área.';

  @override
  String get documentReadinessGoalWorkBodyGeneric =>
      'Revise o que pode travar trabalho cedo no destino: consistência de identidade, status migratório e provas específicas da sua profissão.';

  @override
  String get documentReadinessGoalRemoteTitle =>
      'Estabilize a base documental da renda remota';

  @override
  String get documentReadinessGoalRemoteBodyBrazil =>
      'Mantenha identidade fiscal, referências bancárias e provas que sustentem contratos, transferências e uma rotina estável no Brasil.';

  @override
  String get documentReadinessGoalRemoteBodyGeneric =>
      'Mantenha identidade fiscal, referências bancárias e provas que sustentem contratos e fluxo internacional de renda no novo país.';

  @override
  String get documentReadinessGoalStudyTitle =>
      'Proteja a rota de estudo com os registros certos';

  @override
  String get documentReadinessGoalStudyBodyBrazil =>
      'Deixe admissão, históricos, identidade e papéis sensíveis a prazo alinhados antes de depender do estudo como porta de entrada.';

  @override
  String get documentReadinessGoalStudyBodyGeneric =>
      'Deixe admissão, históricos, identidade e papéis sensíveis a prazo alinhados antes de depender do estudo como base.';

  @override
  String get documentReadinessGoalEntrepreneurTitle =>
      'Prepare a camada documental para operar';

  @override
  String get documentReadinessGoalEntrepreneurBodyBrazil =>
      'Separe as provas de identidade, banco e residência que vão influenciar a segurança para começar a operar no Brasil.';

  @override
  String get documentReadinessGoalEntrepreneurBodyGeneric =>
      'Separe as provas de identidade, banco e imigração que vão influenciar a segurança para começar a operar no país de destino.';

  @override
  String get documentReadinessGoalRetireTitle =>
      'Proteja uma chegada tranquila com papéis revisados';

  @override
  String get documentReadinessGoalRetireBodyBrazil =>
      'Priorize o conjunto documental que reduz surpresas em saúde, banco e rotina recorrente quando você chegar ao Brasil.';

  @override
  String get documentReadinessGoalRetireBodyGeneric =>
      'Priorize o conjunto documental que reduz surpresas em saúde, banco e rotina recorrente quando você chegar.';

  @override
  String get documentReadinessGoalQualityTitle =>
      'Use documentos para reduzir atrito, não só para cumprir regra';

  @override
  String get documentReadinessGoalQualityBodyBrazil =>
      'Mesmo quando a prioridade é qualidade de vida, a mudança mais suave é a que chega ao Brasil com identidade, provas e pasta de chegada já organizadas.';

  @override
  String get documentReadinessGoalQualityBodyGeneric =>
      'Mesmo quando a prioridade é qualidade de vida, a mudança mais suave é a que chega com identidade, provas e pasta de chegada já organizadas.';

  @override
  String get documentReadinessRiskBlocking => 'Pode travar a mudança';

  @override
  String get documentReadinessRiskCaution => 'Evita atraso e retrabalho';

  @override
  String get documentReadinessRiskReview => 'Revisar na etapa certa';

  @override
  String get documentReadinessReviewBeforeBooking =>
      'Revise antes de comprar a passagem';

  @override
  String get documentReadinessReviewCloseToMove =>
      'Reconfirme perto da mudança';

  @override
  String get documentReadinessReviewOnArrival => 'Deixe pronto para a chegada';

  @override
  String documentReadinessSourceLabel(Object source) {
    return 'Base: $source';
  }

  @override
  String get housingDecisionSectionTitle =>
      'Moradia é uma decisão crítica antes da cidade';

  @override
  String housingDecisionSectionTitleWithCity(Object city) {
    return 'A moradia pode definir se $city funciona para você';
  }

  @override
  String get housingDecisionSectionBody =>
      'Antes de decidir a cidade, vale entender como aluguel e garantias funcionam no Brasil. O maior risco não é só o preço mensal: é chegar sem um caminho viável para contrato, bairro e instalação inicial.';

  @override
  String housingDecisionSectionBodyWithCity(Object city) {
    return 'Antes de assumir $city como a melhor opção, valide se aluguel, garantias e instalação inicial parecem viáveis para o seu momento. O risco não está só no preço: está no caminho real para fechar a moradia.';
  }

  @override
  String get housingDecisionGuaranteesTitle =>
      'Garantias podem bloquear o aluguel';

  @override
  String get housingDecisionGuaranteesBody =>
      'Fiador local ainda pesa em muitos contratos. Se isso não existir para você, compare caução, seguro-fiança, título de capitalização e exigência de comprovação de renda antes de contar com o bairro.';

  @override
  String get housingDecisionSoftLandingTitle =>
      'Um começo leve reduz erros caros';

  @override
  String get housingDecisionSoftLandingBody =>
      'Temporário, mobiliado, coliving ou contrato curto por 30 a 90 dias costumam ser um caminho mais seguro do que assumir um aluguel longo sem conhecer a rotina local.';

  @override
  String get housingDecisionProofPackTitle =>
      'Leve a pasta que destrava a conversa';

  @override
  String get housingDecisionProofPackBody =>
      'Reserve identidade, renda, reserva financeira, referências e comprovações digitais em uma única pasta. Isso não garante o contrato, mas reduz a fricção logo no primeiro contato.';

  @override
  String get housingDecisionCityReadTitle =>
      'Leia a cidade pela pressão de moradia';

  @override
  String housingDecisionCityReadTitleWithCity(Object city) {
    return 'Leia $city pela pressão de moradia';
  }

  @override
  String get housingDecisionCityReadBody =>
      'Não compare só o aluguel médio. Olhe bairro, transporte, serviços por perto, necessidade de mobília, distância do trabalho e margem de caixa para entrada e imprevistos.';

  @override
  String housingDecisionCityReadBodyWithCity(Object city) {
    return 'Em $city, compare bairros, transporte, serviços por perto, necessidade de mobília e caixa para entrada e imprevistos antes de tratar o aluguel como resolvido.';
  }

  @override
  String get housingDecisionSectionNote =>
      'Hoje, o Movaro organiza o contexto para ajudar você a decidir melhor. Contrato, garantia aceita e política de cada proprietário ou plataforma ainda precisam ser validados na fonte antes de fechar a moradia.';

  @override
  String get housingEntrySectionTitle =>
      'Estimativa de custo de entrada na moradia';

  @override
  String housingEntrySectionTitleWithCity(Object city) {
    return 'Quanto a moradia pode exigir para entrar em $city';
  }

  @override
  String get housingEntrySectionBody =>
      'Um aluguel que parece acessível no anúncio pode exigir muito mais na entrada. Use esta leitura para simular caução, seguro-fiança ou um começo temporário antes de decidir a cidade.';

  @override
  String housingEntrySectionBodyWithCity(Object city) {
    return 'Em $city, não olhe só o aluguel mensal. Use esta leitura para estimar quanto a entrada pode exigir com caução, seguro-fiança ou um começo temporário.';
  }

  @override
  String housingEntryRentLabel(Object amount) {
    return 'Aluguel mensal de referência: $amount';
  }

  @override
  String get housingEntryModeDeposit => 'Caução';

  @override
  String get housingEntryModeInsurance => 'Seguro-fiança';

  @override
  String get housingEntryModeTemporary => 'Temporário';

  @override
  String get housingEntryModeDepositBody =>
      'Leitura comum quando o contrato pede cerca de 3 meses de caução mais a primeira mensalidade.';

  @override
  String get housingEntryModeInsuranceBody =>
      'Leitura comum quando o fiador é substituído por uma taxa anual de seguro ou garantia digital.';

  @override
  String get housingEntryModeTemporaryBody =>
      'Leitura mais leve para os primeiros 30 a 90 dias, priorizando flexibilidade antes de fechar um contrato longo.';

  @override
  String get housingEntryTotalTitle => 'Quanto pode sair para entrar';

  @override
  String get housingEntryFirstMonthLabel => 'Primeiro mês';

  @override
  String get housingEntryGuaranteeLabel => 'Garantia / caução';

  @override
  String get housingEntrySetupLabel => 'Taxas e instalação';

  @override
  String get housingEntryPlatformsTitle => 'Plataformas e caminhos úteis';

  @override
  String get housingEntryPlatformsHeadline =>
      'Use o canal certo para o seu nível de risco';

  @override
  String get housingEntryPlatformsBody =>
      'A melhor plataforma depende menos do anúncio bonito e mais da burocracia que você consegue sustentar agora.';

  @override
  String get housingEntryPlatformsQuintoAndar =>
      'Digital e sem fiador, mas exige renda e documentação consistentes.';

  @override
  String get housingEntryPlatformsZap =>
      'Use filtros como aluguel sem fiador para reduzir perda de tempo na busca.';

  @override
  String get housingEntryPlatformsCredPago =>
      'Garantia digital que pode substituir o fiador em várias imobiliárias.';

  @override
  String get housingEntryPlatformsAirbnb =>
      'Ajuda a pousar por 15 a 30 dias e visitar bairros antes de assumir um contrato longo.';

  @override
  String get housingEntryDisclaimer =>
      'Esta simulação é direcional. O valor real muda por cidade, bairro, plataforma, comprovação de renda e política do proprietário. O objetivo aqui é evitar subestimar o custo de entrada.';

  @override
  String get housingSoftLandingTitle =>
      'Como argentinos costumam pousar antes do aluguel fixo';

  @override
  String get housingSoftLandingBody =>
      'Nos primeiros dias, o caminho mais comum não é ir direto para o contrato tradicional. A sequência costuma ser desembarque, moradia temporária e só depois a busca por uma base fixa com menos risco.';

  @override
  String get housingSoftLandingTemporaryTitle =>
      'Desembarque por temporada ou flat';

  @override
  String get housingSoftLandingTemporaryBody =>
      'Airbnb com desconto mensal, apart-hotel e flat ajudam a pousar sem fiador nem comprovação local. Isso compra tempo para visitar bairros e entender a cidade na prática.';

  @override
  String get housingSoftLandingDirectTitle =>
      'Busca direta com o proprietário ou grupos locais';

  @override
  String get housingSoftLandingDirectBody =>
      'Facebook Marketplace, OLX e contatos diretos costumam ser mais flexíveis do que a imobiliária tradicional. Em troca, o risco de golpe aumenta e a validação do imóvel precisa ser mais rigorosa.';

  @override
  String get housingSoftLandingGuaranteeTitle =>
      'A moeda de troca é a garantia';

  @override
  String get housingSoftLandingGuaranteeBody =>
      'Sem fiador, o argumento mais forte costuma ser caução, seguro-fiança, título de capitalização ou alguns meses pagos adiantados. O ponto não é prometer demais, é entrar com uma estrutura crível.';

  @override
  String get housingSoftLandingSurvivalTitle =>
      'Checklist de sobrevivência logo na chegada';

  @override
  String get housingSoftLandingSurvivalChip =>
      'Compre um chip brasileiro cedo. Sem número local, imobiliárias e proprietários tendem a responder menos.';

  @override
  String get housingSoftLandingSurvivalCpf =>
      'Se o CPF ainda não estiver resolvido, trate isso como prioridade. Ele pesa em plataforma, banco e conversa sobre aluguel.';

  @override
  String get housingSoftLandingSurvivalLocation =>
      'Nos primeiros dias, priorize ficar perto de mercado, farmácia, transporte e posto de saúde para reduzir custo e fricção.';

  @override
  String get housingSoftLandingSurvivalScam =>
      'Não deposite reserva sem visitar o imóvel ou ter alguém de confiança validando o local.';

  @override
  String get landingBudgetSectionTitle =>
      'Reserva sugerida para a aterrissagem';

  @override
  String landingBudgetSectionTitleWithCity(String city) {
    return 'Reserva sugerida para chegar em $city';
  }

  @override
  String get landingBudgetSummaryResearching =>
      'Use isto como referência de reserva para não desenhar a mudança olhando só o custo mensal depois que tudo estiver estabilizado.';

  @override
  String get landingBudgetSummaryTwelveMonths =>
      'Com mais tempo, a meta é formar uma reserva realista e reduzir o choque dos custos de instalação antes de a mudança chegar.';

  @override
  String get landingBudgetSummarySixMonths =>
      'Seis meses já permitem transformar a mudança em um plano com reserva, em vez de uma sequência de gastos reativos.';

  @override
  String get landingBudgetSummaryAsap =>
      'Como a mudança está perto, a reserva importa tanto quanto a cidade. Use esta estimativa para não chegar com pouco fôlego financeiro.';

  @override
  String get landingBudgetLeanTitle => 'Enxuto';

  @override
  String get landingBudgetLeanBody =>
      'Funciona como referência se você pretende chegar com gasto mais controlado, expectativa de moradia mais simples e decisões iniciais mais apertadas.';

  @override
  String get landingBudgetBalancedTitle => 'Equilibrado';

  @override
  String get landingBudgetBalancedBody =>
      'Uma leitura intermediária para quem quer reduzir o estresse sem assumir uma instalação premium desde o primeiro dia.';

  @override
  String get landingBudgetComfortableTitle => 'Confortável';

  @override
  String get landingBudgetComfortableBody =>
      'Uma margem mais segura se você quer mais fôlego para lidar com atritos na moradia, adaptação mais lenta ou custos inesperados de instalação.';

  @override
  String get landingBudget30DaysLabel => 'Referência para os primeiros 30 dias';

  @override
  String get landingBudgetMonthlyBaseLabel => 'Base mensal';

  @override
  String get landingBudgetSetupLabel => 'Instalação e entrada';

  @override
  String get landingBudgetBufferLabel => 'Margem de segurança';

  @override
  String landingBudget90DaysLabel(String amount) {
    return 'Se quiser um fôlego de 90 dias, use algo perto de $amount';
  }

  @override
  String get landingBudgetDisclaimer =>
      'Estas estimativas são direcionais, não preços oficiais. Elas combinam sinais da cidade, pressão de instalação e risco do timing para ajudar você a planejar a reserva antes da mudança.';

  @override
  String landingBudgetExchangeUpdatedAt(Object value) {
    return 'Câmbio oficial atualizado em $value';
  }

  @override
  String get landingBudgetExchangeUnavailable =>
      'Não foi possível atualizar o câmbio oficial agora. Os valores em reais continuam como referência.';

  @override
  String get arrivalExecutionSectionTitle => 'Primeiros 7 / 30 / 90 dias';

  @override
  String get arrivalExecutionStageWeek => 'Primeiros 7 dias';

  @override
  String get arrivalExecutionStageMonth => 'Primeiros 30 dias';

  @override
  String get arrivalExecutionStageQuarter => 'Primeiros 90 dias';

  @override
  String get arrivalExecutionSummaryResearching =>
      'Esta é a camada de execução depois da chegada. Use-a agora para entender o que as primeiras semanas vão exigir além de documentos.';

  @override
  String get arrivalExecutionSummaryTwelveMonths =>
      'Com mais tempo, esta camada ajuda a enxergar o que a instalação vai exigir, para a mudança não ser planejada só por documento e reserva.';

  @override
  String get arrivalExecutionSummarySixMonths =>
      'Seis meses já permitem planejar a chegada como uma sequência operacional, e não só como uma decisão de destino.';

  @override
  String get arrivalExecutionSummaryAsap =>
      'Se a chegada está perto, esta camada de 7 / 30 / 90 dias importa agora. É nela que o atrito do cotidiano costuma aparecer primeiro.';

  @override
  String get arrivalExecutionConnectivityTitle =>
      'Resolva a conectividade no primeiro dia';

  @override
  String get arrivalExecutionConnectivityBody =>
      'Comece com chip local, internet móvel e a estrutura digital mínima para mapas, banco e acompanhamento documental.';

  @override
  String get arrivalExecutionTransportTitle =>
      'Aprenda a primeira rotina de deslocamento';

  @override
  String get arrivalExecutionTransportBody =>
      'Mapeie como você vai se deslocar na primeira semana para que moradia, serviços e burocracia não dependam de improviso.';

  @override
  String arrivalExecutionTransportBodyWithCity(String city) {
    return 'Mapeie como você vai se deslocar em $city na primeira semana para que moradia, serviços e burocracia não dependam de improviso.';
  }

  @override
  String get arrivalExecutionHealthTitle =>
      'Defina seu primeiro plano de saúde de apoio';

  @override
  String get arrivalExecutionHealthBody =>
      'Saiba onde fica sua primeira porta de entrada em saúde pública ou privada para que um problema simples não vire caos na chegada.';

  @override
  String get arrivalExecutionBankTitle =>
      'Estabilize pagamentos e fluxo bancário';

  @override
  String get arrivalExecutionBankBody =>
      'Garanta que seu primeiro fluxo local de pagamento funcione: conta, Pix, uso de cartão e como o dinheiro vai circular no primeiro mês.';

  @override
  String get arrivalExecutionHousingTitle =>
      'Transforme moradia em rotina, não só em entrada';

  @override
  String get arrivalExecutionHousingBody =>
      'Depois de chegar, confirme se a área escolhida realmente sustenta trabalho, transporte, segurança e o ritmo de vida de que você precisa.';

  @override
  String get arrivalExecutionGoalWorkTitle =>
      'Transforme a chegada em empregabilidade';

  @override
  String get arrivalExecutionGoalWorkBody =>
      'Use o primeiro mês para testar como documentos, idioma e cidade afetam de verdade sua chance de conseguir trabalho.';

  @override
  String get arrivalExecutionGoalRemoteTitle =>
      'Transforme a chegada em base remota estável';

  @override
  String get arrivalExecutionGoalRemoteBody =>
      'Valide a qualidade da internet, a rotina silenciosa, o fluxo bancário e o custo real de sustentar trabalho remoto na nova cidade.';

  @override
  String get arrivalExecutionGoalStudyTitle =>
      'Transforme a chegada em rotina de estudo';

  @override
  String get arrivalExecutionGoalStudyBody =>
      'Use o primeiro mês para confirmar se matrícula, deslocamento, aulas e custo diário ainda sustentam o estudo como base do plano.';

  @override
  String get arrivalExecutionGoalEntrepreneurTitle =>
      'Transforme a chegada em capacidade de operar';

  @override
  String get arrivalExecutionGoalEntrepreneurBody =>
      'Use o primeiro mês para validar se banco, documentos, rotina local e contexto da cidade realmente sustentam operar com segurança.';

  @override
  String get arrivalExecutionGoalRetireTitle =>
      'Transforme a chegada em rotina previsível';

  @override
  String get arrivalExecutionGoalRetireBody =>
      'Use o primeiro mês para testar se acesso à saúde, rotina de bairro e custos recorrentes parecem sustentáveis na prática.';

  @override
  String get arrivalExecutionGoalQualityTitle =>
      'Transforme a chegada em qualidade de vida real';

  @override
  String get arrivalExecutionGoalQualityBody =>
      'Use o primeiro mês para verificar se a cidade faz sentido no cotidiano, e não só no papel ou em ranking.';

  @override
  String get arrivalExecutionRealityCheckTitle =>
      'Faça um reality check aos 90 dias';

  @override
  String get arrivalExecutionRealityCheckBody =>
      'Compare custo real, atrito da rotina e aderência da cidade com o que o plano sugeriu. É aqui que a mudança deixa de ser hipotética.';

  @override
  String get arrivalExecutionDocumentsTitle =>
      'Feche as pontas documentais em aberto';

  @override
  String get arrivalExecutionDocumentsBody =>
      'Até os primeiros 90 dias, reduza pendências de residência, comprovações, banco e registros locais que ainda bloqueiam a estabilidade.';

  @override
  String get arrivalExecutionReplanTitle =>
      'Replaneje antes que a inércia tome conta';

  @override
  String get arrivalExecutionReplanBody =>
      'Se cidade, custo ou ritmo não estiverem alinhados com o plano original, ajuste a rota antes que o atrito temporário vire o seu normal.';

  @override
  String arrivalExecutionReplanBodyWithCity(String city) {
    return 'Se $city não estiver alinhada com o plano original na prática, ajuste a rota antes que o atrito temporário vire o seu normal.';
  }

  @override
  String get publicHomeResumePlanAction => 'Continuar meu plano';

  @override
  String get publicHomeResumePlanTitle => 'Retome de onde você parou';

  @override
  String get publicHomeResumePlanBody =>
      'Seu último plano de mudança ainda está aqui. Reabra para continuar a checklist, a prontidão documental e a reserva de aterrissagem.';

  @override
  String publicHomeResumePlanBodyWithCity(String city, String state) {
    return 'Seu último plano ainda está aqui, com $city ($state) como cidade atual de referência. Reabra para continuar a checklist, a prontidão documental e a reserva de aterrissagem.';
  }

  @override
  String get publicHomeRetakePlanAction => 'Refazer plano';

  @override
  String get migrationPlanCopilotTitle => 'Guia da mudança';

  @override
  String get migrationPlanCopilotAction => 'Abrir guia';

  @override
  String get migrationPlanCopilotGuideEyebrow => 'Guia rápido';

  @override
  String get migrationPlanCopilotGuideTitle => 'Como usar o guia da mudança';

  @override
  String get migrationPlanCopilotGuideBody =>
      'Esta área transforma a cidade escolhida em preparação prática. Abra a etapa certa, resolva o que é prioridade e volte ao resumo sem perder a ordem do plano.';

  @override
  String get migrationPlanCopilotGuideStepOneTitle => 'Comece pelo resumo';

  @override
  String get migrationPlanCopilotGuideStepOneBody =>
      'A visão geral mostra a etapa mais importante agora e ajuda você a não dispersar energia.';

  @override
  String get migrationPlanCopilotGuideStepTwoTitle =>
      'Entre na etapa prioritária';

  @override
  String get migrationPlanCopilotGuideStepTwoBody =>
      'Documentos, moradia, trabalho e chegada ficam separados para você resolver um bloco por vez.';

  @override
  String get migrationPlanCopilotGuideStepThreeTitle =>
      'Use os atalhos práticos';

  @override
  String get migrationPlanCopilotGuideStepThreeBody =>
      'Abra links, fontes e blocos guiados dentro do app para sair do plano e ir para a execução.';

  @override
  String get migrationPlanCopilotGuideHideNextTime => 'Não mostrar novamente';

  @override
  String get migrationPlanCopilotGuideStepsLabel => '3 passos';

  @override
  String get migrationPlanCopilotGuideDismissAction => 'Agora não';

  @override
  String get migrationPlanCopilotGuidePrimaryAction => 'Entendi';

  @override
  String get migrationPlanCopilotIntroTitle =>
      'Quando quiser sair da decisão para a execução';

  @override
  String get migrationPlanCopilotIntroBody =>
      'Esta etapa organiza checklist, documentos, moradia e reserva de aterrissagem. Use-a quando você já quiser começar a preparar a mudança.';

  @override
  String migrationPlanCopilotIntroBodyWithCity(String city, String state) {
    return 'Esta etapa organiza checklist, documentos, moradia e reserva de aterrissagem com $city ($state) como referência principal do seu plano.';
  }

  @override
  String get migrationPlanCopilotResultBody =>
      'Primeiro, veja se a cidade recomendada faz sentido para você. Quando quiser transformar essa decisão em preparação concreta, abra a camada guiada com checklist, documentos e reserva de chegada.';

  @override
  String migrationPlanCopilotStepCounter(Object current, Object total) {
    return 'Etapa $current de $total';
  }

  @override
  String get migrationPlanCopilotStepStartTitle =>
      'Comece pelo que destrava a mudança';

  @override
  String get migrationPlanCopilotStepStartBody =>
      'Foque primeiro nas checagens que reduzem risco antes de gastar energia com o resto.';

  @override
  String get migrationPlanCopilotStepDocumentsTitle =>
      'Organize os documentos-chave';

  @override
  String get migrationPlanCopilotStepDocumentsBody =>
      'Use esta etapa para colocar em ordem a camada documental que costuma travar o avanço depois.';

  @override
  String get migrationPlanCopilotStepBudgetTitle =>
      'Planeje reserva e entrada de moradia';

  @override
  String get migrationPlanCopilotStepBudgetBody =>
      'Estime sua reserva inicial e revise o atrito de moradia antes que a chegada fique urgente.';

  @override
  String get migrationPlanCopilotStepArrivalTitle =>
      'Prepare os primeiros 7 / 30 / 90 dias';

  @override
  String get migrationPlanCopilotStepArrivalBody =>
      'Transforme o plano em execução para a chegada não depender de improviso.';

  @override
  String get migrationPlanCopilotHomeTitle => 'O que fazer agora';

  @override
  String get migrationPlanCopilotHomeBody =>
      'Use esta home para ver os próximos passos, o principal risco e a etapa que merece atenção primeiro.';

  @override
  String migrationPlanCopilotStageCountLabel(Object count) {
    return '$count etapas guiadas';
  }

  @override
  String get migrationPlanCopilotNextActionsTitle => 'Seus próximos 3 passos';

  @override
  String get migrationPlanCopilotNextActionsBody =>
      'Comece pelas tarefas que destravam a mudança antes de aprofundar o restante.';

  @override
  String get migrationPlanCopilotNextActionStart =>
      'Reduza os primeiros bloqueios';

  @override
  String get migrationPlanCopilotNextActionDocuments =>
      'Coloque os documentos em movimento';

  @override
  String get migrationPlanCopilotNextActionBudget =>
      'Revise reserva e entrada de moradia';

  @override
  String get migrationPlanCopilotNextActionBudgetBody =>
      'Estime sua reserva inicial e entenda como a entrada de moradia pode pesar na chegada.';

  @override
  String get migrationPlanCopilotFallbackActionBody =>
      'Abra esta etapa para ver a primeira ação recomendada.';

  @override
  String get migrationPlanCopilotRiskTitle => 'Principal risco agora';

  @override
  String get migrationPlanCopilotRiskDocuments =>
      'A camada documental ainda é o maior risco. Se ela ficar solta, as etapas seguintes podem travar mesmo com cidade e orçamento já decididos.';

  @override
  String get migrationPlanCopilotRiskReadiness =>
      'A mudança ainda precisa de uma base inicial mais forte. Resolva os primeiros bloqueios práticos antes de gastar mais energia com detalhes.';

  @override
  String get migrationPlanCopilotRiskHousing =>
      'A entrada em moradia ainda pode gerar atrito na chegada. Revise reserva, garantias e plano de fallback antes de tratar a mudança como operacional.';

  @override
  String get migrationPlanCopilotStagesTitle => 'Abra uma etapa guiada';

  @override
  String get migrationPlanCopilotStagesBody =>
      'Você pode entrar direto na etapa que precisa, mas o Movaro mantém a ordem clara para a mudança não perder prioridade.';

  @override
  String get migrationPlanCopilotRecommendedTitle =>
      'Próximo passo recomendado';

  @override
  String get migrationPlanCopilotRecommendedReadinessBody =>
      'Comece por esta etapa para destravar os primeiros bloqueios e dar base real para o restante do plano.';

  @override
  String get migrationPlanCopilotRecommendedDocumentsBody =>
      'A camada documental ainda merece atenção primeiro. Resolva isso agora para evitar travas mais caras depois.';

  @override
  String get migrationPlanCopilotRecommendedBudgetBody =>
      'Agora vale transformar o plano em números reais e revisar a entrada em moradia antes da chegada apertar.';

  @override
  String get migrationPlanCopilotRecommendedArrivalBody =>
      'Você já tem base suficiente para organizar a chegada. Use esta etapa para sair do plano e entrar em execução.';

  @override
  String get migrationPlanCopilotRecommendedOpen => 'Abrir etapa recomendada';

  @override
  String get migrationPlanCopilotQuickQuestionsTitle => 'Dúvidas rápidas';

  @override
  String get migrationPlanCopilotQuickQuestionsBody =>
      'Use estas respostas curtas quando bater uma dúvida prática antes de avançar.';

  @override
  String get migrationPlanCopilotQuickQuestionDocumentsTitle =>
      'Quais documentos eu devo mover primeiro?';

  @override
  String get migrationPlanCopilotQuickQuestionDocumentsAnswer =>
      'Comece pelos documentos que demoram mais para sair ou vencer primeiro. A etapa documental do Movaro ajuda a separar o que destrava residência, CPF e chegada prática sem te jogar num fluxo burocrático inteiro de uma vez.';

  @override
  String get migrationPlanCopilotQuickQuestionHousingTitle =>
      'Preciso resolver moradia definitiva agora?';

  @override
  String get migrationPlanCopilotQuickQuestionHousingAnswer =>
      'Nem sempre. Em muitos casos, faz mais sentido entrar com um plano de moradia temporária, entender garantias e só depois assumir um aluguel maior. O importante agora é estimar reserva, custo de entrada e plano de fallback.';

  @override
  String get migrationPlanCopilotQuickQuestionArrivalTitle =>
      'O que eu preciso resolver logo na chegada?';

  @override
  String get migrationPlanCopilotQuickQuestionArrivalAnswer =>
      'Pense primeiro no que reduz atrito nos primeiros dias: onde ficar, como se mover, o que precisa ser resolvido nos 7 primeiros dias e quais tarefas não podem passar do primeiro mês. A etapa de chegada já organiza isso por prioridade.';

  @override
  String get migrationPlanCopilotQuickQuestionOpenStage => 'Ir para esta etapa';

  @override
  String get migrationPlanCopilotActionOpen => 'Resolver agora';

  @override
  String get migrationPlanCopilotOverviewAction => 'Começar preparação guiada';

  @override
  String get migrationPlanCopilotOverviewBackAction => 'Voltar ao resumo';

  @override
  String get migrationPlanCopilotFinishAction => 'Concluir por agora';

  @override
  String get migrationPlanDecisionLabel => 'Escolha da cidade';

  @override
  String migrationPlanDecisionTitle(Object goal) {
    return 'Agora compare as cidades que mais combinam com $goal';
  }

  @override
  String migrationPlanDecisionBody(Object timeline) {
    return 'Com base no seu prazo de $timeline, estas opções aparecem primeiro porque se aproximam mais do perfil que você marcou.';
  }

  @override
  String get migrationPlanDecisionSummaryTitle => 'Como ler esta etapa';

  @override
  String get migrationPlanDecisionSummaryBody =>
      'Primeiro, escolha a cidade que faz mais sentido para você. O checklist detalhada entra só depois dessa decisão.';

  @override
  String migrationPlanHeroTitle(Object city) {
    return '$city é sua cidade mais forte para começar agora';
  }

  @override
  String migrationPlanHeroBody(Object timeline) {
    return 'Com base no seu prazo de $timeline, comece olhando as 3 cidades abaixo e abra a que parecer mais forte para a sua mudança.';
  }

  @override
  String get migrationPlanConfidenceLow => 'Recomendação inicial';

  @override
  String get migrationPlanConfidenceHigh => 'Recomendação forte';

  @override
  String migrationPlanSummaryArchetype(Object value) {
    return 'Perfil detectado: $value';
  }

  @override
  String migrationPlanSummaryVariant(Object value) {
    return 'Modo usado: $value';
  }

  @override
  String migrationPlanSummaryFunding(Object value) {
    return 'Sustento inicial: $value';
  }

  @override
  String get migrationPlanCandidateCitiesTitle =>
      'Cidades mais alinhadas ao seu perfil';

  @override
  String get migrationPlanCandidateCitiesBody =>
      'A lista já vem ordenada para deixar primeiro o que tende a fazer mais sentido para argentinos com esse objetivo.';

  @override
  String get migrationPlanShortlistTitle => '3 cidades para revisar agora';

  @override
  String get migrationPlanShortlistBody =>
      'Estas são as 3 opções mais fortes para começar. Abra uma cidade para comparar com o seu contexto real.';

  @override
  String get migrationPlanCandidateCitiesSheetBody =>
      'Abra os detalhes para entender melhor cada cidade. A confirmação da cidade acontece dentro da tela de detalhe, depois de ver mais contexto.';

  @override
  String get migrationPlanSelectedCityBadge => 'Escolhida';

  @override
  String get migrationPlanSuggestedCityBadge => 'Na frente agora';

  @override
  String get migrationPlanChooseCityAction => 'Escolher esta cidade';

  @override
  String get migrationPlanSelectedCityAction => 'Cidade escolhida';

  @override
  String get migrationPlanInspectCityAction => 'Abrir detalhes';

  @override
  String get migrationPlanOpenCitiesAction => 'Ver cidades sugeridas';

  @override
  String get migrationPlanCompareOtherCitiesAction => 'Comparar outras cidades';

  @override
  String migrationPlanSuggestedCityTitle(Object city) {
    return '$city está na frente por enquanto';
  }

  @override
  String migrationPlanSuggestedCityBody(Object city, Object housing) {
    return '$city aparece na frente pelo perfil que você marcou, com leitura de entrada em moradia em $housing. Antes de decidir, abra os detalhes e compare com as outras opções.';
  }

  @override
  String migrationPlanConfirmedCityTitle(Object city) {
    return '$city foi a cidade que você escolheu';
  }

  @override
  String migrationPlanSelectedCityTitle(Object city) {
    return '$city está na frente agora';
  }

  @override
  String migrationPlanSelectedCityBody(Object city, Object housing) {
    return '$city aparece forte para o seu contexto atual, com leitura de entrada em moradia em $housing. Se essa cidade fizer sentido para você, aí sim vale abrir a preparação guiada.';
  }

  @override
  String get migrationPlanPreparationTitle => 'Quando partir para a preparação';

  @override
  String migrationPlanPreparationBody(Object city) {
    return 'Se você decidir seguir com $city, a preparação guiada abre checklist, documentos, moradia e reserva de chegada com foco nessa cidade.';
  }

  @override
  String get migrationPlanScrollHint => 'Ver mais';

  @override
  String get languageSelectorSystem => 'Sistema';

  @override
  String get bmpDisclaimer =>
      'Isto monta um ponto de partida. Não é consultoria legal.';

  @override
  String bmpProgressStep(Object current, Object total) {
    return 'Etapa $current de $total';
  }

  @override
  String get bmpCtaBack => 'Voltar';

  @override
  String get bmpCtaContinue => 'Continuar';

  @override
  String get bmpCtaSkip => 'Pular';

  @override
  String get bmpCtaGenerate => 'Gerar meu plano';

  @override
  String get bmpExitDialogTitle => 'Quer sair deste plano?';

  @override
  String get bmpExitDialogBody =>
      'Se você voltar para a home, vai perder este fluxo e as respostas atuais.';

  @override
  String get bmpExitDialogStay => 'Continuar aqui';

  @override
  String get bmpExitDialogLeave => 'Voltar para a home';

  @override
  String get bmpCtaRefineYes => 'Sim, refinar';

  @override
  String get bmpCtaRefineNo => 'Não, gerar meu plano';

  @override
  String get bmpVariantTitle => 'Como você quer montar seu plano?';

  @override
  String get bmpVariantSubtitle =>
      'Você pode ir mais rápido ou responder uma pergunta extra para uma recomendação mais precisa.';

  @override
  String get bmpVariantLeanTitle => 'Plano rápido';

  @override
  String get bmpVariantLeanBody =>
      '3 perguntas e um refinamento opcional para chegar a uma direção inicial com pouca fricção.';

  @override
  String get bmpVariantLeanTag => 'Mais rápido';

  @override
  String get bmpVariantStrategicTitle => 'Plano estratégico';

  @override
  String get bmpVariantStrategicBody =>
      'Inclui como você pretende se sustentar e gera uma leitura inicial mais precisa para começar.';

  @override
  String get bmpVariantStrategicTag => 'Mais preciso';

  @override
  String get bmpGuideEyebrow => 'Monte seu plano';

  @override
  String get bmpGuideTitle => 'Como este planejador funciona';

  @override
  String get bmpGuideBody =>
      'Comece pelo modo que combina com o nível de detalhe que você quer agora. As duas opções levam a uma cidade sugerida e a uma primeira sequência de ações, mas mudam em profundidade.';

  @override
  String get bmpGuideStepsLabel => 'O que muda entre os dois modos';

  @override
  String get bmpGuideStepQuickTitle => 'Plano rápido';

  @override
  String get bmpGuideStepQuickBody =>
      'Este é o caminho mais ágil. Você responde as perguntas centrais, recebe uma direção inicial e pode refinar depois se o primeiro resultado ainda estiver amplo demais.';

  @override
  String get bmpGuideStepStrategicTitle => 'Plano estratégico';

  @override
  String get bmpGuideStepStrategicBody =>
      'Aqui entra uma camada extra sobre como você pretende se sustentar após a mudança, então a recomendação fica mais precisa e mais prática.';

  @override
  String get bmpGuideStepUseTitle => 'Como usar o resultado';

  @override
  String get bmpGuideStepUseBody =>
      'Use o plano como ponto de partida, não como veredito final. O próximo melhor passo normalmente é comparar a cidade sugerida, confirmar documentos e ajustar o plano se sua prioridade mudar.';

  @override
  String get bmpGuideHideNextTime =>
      'Não abrir esta explicação automaticamente de novo';

  @override
  String get bmpGuideDismissAction => 'Fechar';

  @override
  String get bmpGuidePrimaryAction => 'Começar plano';

  @override
  String get bmpRefineTitle =>
      'Quer refinar a recomendação com mais 1 pergunta?';

  @override
  String get bmpRefineSubtitle => '(Opcional) Leva cerca de 5 segundos';

  @override
  String get qIntentPrompt => 'O que você busca no Brasil agora?';

  @override
  String get qFundingPrompt =>
      'Como você pretende se sustentar nos primeiros 3 meses?';

  @override
  String get qFundingSubtitle =>
      'Isso ajuda a ajustar seu ponto de partida sem pedir dados pessoais.';

  @override
  String get qTimelinePrompt =>
      'Quando você gostaria de estar no Brasil? (aprox.)';

  @override
  String get qPrioritiesPrompt =>
      'No seu primeiro ano, quais 2 pontos mais importam na escolha da cidade?';

  @override
  String get qPrioritiesHelper => 'Selecione 2 para continuar';

  @override
  String qPrioritiesSelectedCount(Object selected, Object total) {
    return '$selected/$total';
  }

  @override
  String get qPrioritiesValidation => 'Escolha 2 opções para continuar';

  @override
  String get qConstraintsPrompt => 'Existe algo que você NÃO quer negociar?';

  @override
  String get qConstraintsSubtitle => '(Opcional) Escolha até 2';

  @override
  String get bmpScrollHint => 'Ver mais opções';

  @override
  String get qConstraintsValidation => 'Você pode escolher até 2 opções';

  @override
  String get qConstraintsNone => 'Não tenho condições fixas';

  @override
  String get questionOptionFindJobBr => 'Conseguir trabalho no Brasil';

  @override
  String get questionOptionRemoteIncome => 'Trabalhar remoto (já tenho renda)';

  @override
  String get questionOptionFundingSavings => 'Tenho reservas para começar';

  @override
  String get questionOptionFundingJobSearch => 'Vou buscar trabalho no Brasil';

  @override
  String get questionOptionFundingJobOffer => 'Já tenho oferta ou contrato';

  @override
  String get questionOptionFundingFamilySupport =>
      'Ajuda de família ou parceiro';

  @override
  String get questionOptionFundingDontKnow => 'Ainda não sei';

  @override
  String get questionOptionFamilyPartner => 'Mudança por parceiro ou família';

  @override
  String get questionOptionFreshStart => 'Melhor qualidade de vida / recomeçar';

  @override
  String get questionOptionExploreUnsure => 'Só quero entender as opções';

  @override
  String get questionOptionJustExploring => 'Só explorando';

  @override
  String get questionOptionIn03Months => 'Em 0–3 meses';

  @override
  String get questionOptionIn36Months => 'Em 3–6 meses';

  @override
  String get questionOptionIn612Months => 'Em 6–12 meses';

  @override
  String get questionOptionIn12PlusMonths => 'Em mais de 12 meses';

  @override
  String get questionOptionDepends => 'Depende / ainda estou vendo';

  @override
  String get questionOptionLowCost => 'Custo de vida mais baixo';

  @override
  String get questionOptionJobOpportunities => 'Mais oportunidades de trabalho';

  @override
  String get questionOptionSafetyPriority => 'Segurança / tranquilidade';

  @override
  String get questionOptionWarmClimateBeach => 'Clima mais quente / praia';

  @override
  String get questionOptionTransitInfra => 'Boa infraestrutura e transporte';

  @override
  String get questionOptionNature => 'Natureza';

  @override
  String get questionOptionUniversity => 'Ambiente universitário';

  @override
  String get questionOptionCommunity => 'Comunidade / fazer amigos';

  @override
  String get questionOptionCloseToArgentina => 'Perto da Argentina';

  @override
  String get questionOptionBalancedUnsure => 'Quero equilíbrio / ainda não sei';

  @override
  String get questionOptionPreferSouth => 'Prefiro estar no Sul';

  @override
  String get questionOptionNeedBigCity => 'Preciso de cidade grande';

  @override
  String get questionOptionPreferMidCity => 'Prefiro cidade média ou tranquila';

  @override
  String get questionOptionWantCoast => 'Quero litoral ou praia';

  @override
  String get questionOptionPreferCooler => 'Prefiro clima mais fresco';

  @override
  String get questionOptionNeedTransit => 'Preciso de transporte forte';

  @override
  String get questionOptionAvoidExpensive => 'Quero evitar cidades caras';

  @override
  String get planReasonBudgetFit =>
      'Melhor encaixe se você quer proteger o orçamento.';

  @override
  String get planReasonJobMobility =>
      'Mais espaço para buscar trabalho e se movimentar.';

  @override
  String get planReasonSafety => 'Combina com sua prioridade de tranquilidade.';

  @override
  String get planReasonClimateNature =>
      'Bom ponto de partida se você busca clima e vida ao ar livre.';

  @override
  String get planReasonTransit => 'Mais prático para se mover sem carro.';

  @override
  String get planReasonProximityArgentina =>
      'Mais perto para voltar à Argentina quando precisar.';

  @override
  String get planReasonUniversity => 'Mais alinhado se o seu plano é estudar.';

  @override
  String get planReasonCommunity => 'Mais chance de criar rede e comunidade.';

  @override
  String get planReasonBalancedProfile =>
      'Aparece como uma opção equilibrada para começar.';

  @override
  String get archetypeJobHunter => 'Busca de trabalho';

  @override
  String get archetypeJobHunterWithOffer => 'Trabalho com oferta';

  @override
  String get archetypeJobHunterSearching => 'Busca ativa de trabalho';

  @override
  String get archetypeRemoteWorker => 'Trabalho remoto';

  @override
  String get archetypeRemoteStable => 'Trabalho remoto estável';

  @override
  String get archetypeStudent => 'Estudo';

  @override
  String get archetypeFamilyMove => 'Mudança familiar';

  @override
  String get archetypeFreshStart => 'Recomeço';

  @override
  String get archetypeExplorer => 'Exploração';

  @override
  String get planStepTitleChooseBaseCity => 'Escolha sua cidade base';

  @override
  String get planStepTitleResidencePath => 'Entenda a rota de residência';

  @override
  String get planStepTitleCpfStart => 'Comece seu CPF';

  @override
  String get planStepDescriptionChooseBaseCityExplore =>
      'Escolha 1 cidade para começar e olhe bairros, custo de vida e mobilidade básica. Não é definitivo: é para começar com clareza.';

  @override
  String get planStepDescriptionChooseBaseCityBalanced =>
      'Defina uma cidade base e compare 2 bairros, aluguel e mobilidade para tirar o plano do campo da ideia.';

  @override
  String get planStepDescriptionChooseBaseCityUrgent =>
      'Defina uma cidade base e uma data tentativa nesta semana para organizar as decisões mais urgentes.';

  @override
  String get planStepDescriptionChooseBaseCityOffer =>
      'Como você já tem uma oferta ou contrato, escolha a cidade base e valide bairro, deslocamento e custo de entrada.';

  @override
  String get planStepDescriptionResidencePathExplore =>
      'Revise a rota de residência mais comum entre Argentina e Brasil e quais documentos base você vai precisar depois.';

  @override
  String get planStepDescriptionResidencePathBalanced =>
      'Entenda a rota de residência e comece a separar os documentos base antes de entrar em burocracia detalhada.';

  @override
  String get planStepDescriptionResidencePathUrgent =>
      'Revise a rota de residência e separe agora os documentos base para não travar a execução.';

  @override
  String get planStepDescriptionResidencePathFundingUnknown =>
      'Antes de avançar, entenda a rota de residência e esclareça como vai se sustentar nos primeiros meses para evitar bloqueios.';

  @override
  String get planStepDescriptionCpfStart =>
      'O CPF destrava várias etapas práticas no Brasil. Comece com a orientação oficial e depois siga no Movaro passo a passo.';

  @override
  String get migrationPlanPrepHeroTitle =>
      'Prepare a mudança sem se perder no processo';

  @override
  String get migrationPlanPrepHeroBody =>
      'Aqui a ideia não é marcar checklist. Primeiro entenda o que emitir, onde abrir cada tema e qual guia resolve seu próximo passo.';

  @override
  String get migrationPlanPrepHeroBodyCompact =>
      'Abra a etapa certa e prepare a mudança sem perder a ordem do plano.';

  @override
  String get migrationPlanPrepTabOverview => 'Visão geral';

  @override
  String get migrationPlanPrepTabDocuments => 'Documentação';

  @override
  String get migrationPlanPrepTabHousing => 'Moradia e custos';

  @override
  String get migrationPlanPrepTabWork => 'Trabalho e vida prática';

  @override
  String get migrationPlanPrepTabArrival => 'Chegada';

  @override
  String get migrationPlanPrepOverviewTitle =>
      'Comece pela parte que realmente destrava a mudança';

  @override
  String get migrationPlanPrepOverviewBody =>
      'Em vez de um checklist longo, esta área virou um guia prático. Documentação entra primeiro, depois moradia, custos, trabalho e chegada.';

  @override
  String get migrationPlanPrepChooseCityTitle =>
      'Escolha uma cidade para destravar a preparação';

  @override
  String get migrationPlanPrepChooseCityBody =>
      'A preparação só faz sentido com uma cidade-base confirmada. Primeiro eleja a cidade que vai guiar moradia, custos, trabalho e chegada.';

  @override
  String get migrationPlanPrepChooseCityAction => 'Escolher cidade do plano';

  @override
  String get migrationPlanPrepQuestionDocsTitle =>
      'Como regularizar meus documentos?';

  @override
  String get migrationPlanPrepQuestionDocsBody =>
      'Abra CPF, registro, banco e contratos de um jeito mais guiado, sem cair em um fluxo burocrático solto.';

  @override
  String get migrationPlanPrepQuestionRentTitle =>
      'O que eu preciso para alugar?';

  @override
  String get migrationPlanPrepQuestionRentBody =>
      'Veja garantias, caução, aluguel temporário e o que costuma ser pedido para entrar em moradia no começo.';

  @override
  String get migrationPlanPrepQuestionMoneyTitle => 'Quanto dinheiro levar?';

  @override
  String get migrationPlanPrepQuestionMoneyBody =>
      'Use uma leitura mais conservadora da chegada, com margem de segurança e sem empurrar números irreais.';

  @override
  String get migrationPlanPrepQuestionHealthTitle =>
      'Saúde é pública ou privada?';

  @override
  String get migrationPlanPrepQuestionHealthBody =>
      'Entenda quando faz sentido SUS, posto de saúde, hospital ou plano privado sem misturar tudo.';

  @override
  String get migrationPlanPrepQuestionWorkTitle =>
      'Posso trabalhar e abrir conta?';

  @override
  String get migrationPlanPrepQuestionWorkBody =>
      'Abra trabalho formal, renda, banco e contrato de forma prática, com foco no que destrava a vida real.';

  @override
  String get migrationPlanPrepQuestionArrivalTitle =>
      'O que eu resolvo logo na chegada?';

  @override
  String get migrationPlanPrepQuestionArrivalBody =>
      'Organize os primeiros dias, a primeira base de moradia e a rotina inicial para não improvisar tudo.';

  @override
  String get migrationPlanPrepQuestionFlightsTitle =>
      'Como consultar voos para a cidade?';

  @override
  String get migrationPlanPrepQuestionFlightsBody =>
      'Abra uma busca externa de voos para comparar rotas até a cidade escolhida no Brasil.';

  @override
  String get migrationPlanPrepPrimaryEyebrow => 'Primeiro passo';

  @override
  String get migrationPlanPrepCardToneGuide => 'Guia rápido';

  @override
  String get migrationPlanPrepCardTonePractical => 'Resolver agora';

  @override
  String get migrationPlanPrepCardTonePriority => 'Prioridade alta';

  @override
  String get migrationPlanPrepCardToneArrival => 'Primeiros passos';

  @override
  String get migrationPlanPrepOpenSection => 'Abrir esta área';

  @override
  String get migrationPlanPrepOpenOfficialSource => 'Abrir fonte oficial';

  @override
  String get migrationPlanPrepExternalToolHint =>
      'Use este atalho como orientação rápida. O próximo passo abre a fonte oficial dentro do app para você continuar sem perder o contexto.';

  @override
  String get migrationPlanPrepOpenGuide => 'Abrir guia completo';

  @override
  String get migrationPlanPrepBackToOverview => 'Voltar ao resumo';

  @override
  String get migrationPlanPrepDocumentsTitle => 'Documentos e residência';

  @override
  String get migrationPlanPrepDocumentsBody =>
      'Veja o que emitir primeiro, como CPF e registro entram na prática e onde abrir a orientação certa sem cair numa pesquisa solta.';

  @override
  String get migrationPlanPrepHousingTitle => 'Moradia e custos';

  @override
  String get migrationPlanPrepHousingBody =>
      'Entenda reserva, entrada no aluguel, garantia e plano de moradia temporária antes da chegada apertar.';

  @override
  String get migrationPlanPrepWorkTitle => 'Trabalho e vida prática';

  @override
  String get migrationPlanPrepWorkBody =>
      'Abra trabalho, saúde e mobilidade em blocos mais diretos para resolver a vida prática sem excesso de leitura.';

  @override
  String get migrationPlanPrepArrivalTitle => 'Primeiros dias no Brasil';

  @override
  String get migrationPlanPrepArrivalBody =>
      'Organize a chegada por horizonte curto: primeira semana, primeiro mês e os 90 dias que estabilizam a mudança.';

  @override
  String get migrationPlanPrepDocumentsGuideTitle =>
      'Comece por documentos, não por checklist';

  @override
  String get migrationPlanPrepDocumentsGuideBody =>
      'Se a camada documental estiver confusa, o resto trava. Por isso esta área te leva direto para o que emitir, como funciona e onde continuar.';

  @override
  String get migrationPlanPrepOpenDocumentsTopic =>
      'Abrir tópico de documentos';

  @override
  String get migrationPlanPrepDocumentsCpfTitle =>
      'CPF e o que ele realmente destrava';

  @override
  String get migrationPlanPrepDocumentsCpfBody =>
      'Abra esta parte para entender quando o CPF ajuda, o que ele não resolve sozinho e como ele entra em banco, contratos e vida prática.';

  @override
  String get migrationPlanPrepDocumentsResidenceTitle =>
      'Registro e residência sem linguagem burocrática';

  @override
  String get migrationPlanPrepDocumentsResidenceBody =>
      'Entenda qual é o caminho de residência mais comum, o papel do protocolo e como isso conversa com a chegada.';

  @override
  String get migrationPlanPrepDocumentsBankTitle =>
      'Banco, cadastro e contratos';

  @override
  String get migrationPlanPrepDocumentsBankBody =>
      'Veja o que costuma ser pedido para abrir conta, assinar aluguel e não travar a vida prática logo no início.';

  @override
  String get migrationPlanPrepTaxesTitle =>
      'Como ficam impostos e residência fiscal';

  @override
  String get migrationPlanPrepTaxesBody =>
      'Abra a orientação oficial da Receita para entender entrada no Brasil, residência fiscal e quando isso começa a importar.';

  @override
  String get migrationPlanPrepDeadlinesTitle => 'Quais prazos não posso perder';

  @override
  String get migrationPlanPrepDeadlinesBody =>
      'Abra a rota oficial da residência para não descobrir tarde demais prazo de registro, emissão e etapas críticas.';

  @override
  String get migrationPlanPrepHousingGuideTitle =>
      'Transforme a mudança em números reais';

  @override
  String get migrationPlanPrepHousingGuideBody =>
      'Aqui você revisa reserva, custo de entrada, garantias e soft landing com uma leitura bem mais prática do que um bloco de checklist.';

  @override
  String get migrationPlanPrepWorkGuideTitle =>
      'Vida prática depois da cidade escolhida';

  @override
  String get migrationPlanPrepWorkGuideBody =>
      'Use estes blocos para abrir rapidamente trabalho, saúde e mobilidade. São os temas que mais viram dúvida depois da decisão da cidade.';

  @override
  String get migrationPlanPrepWorkSignalsTitle =>
      'Sinais de trabalho da cidade';

  @override
  String get migrationPlanPrepWorkSignalsBody =>
      'Hoje o Movaro mostra sinais de mercado, atividade econômica e desemprego. A renda média ainda não está integrada no catálogo atual.';

  @override
  String get migrationPlanPrepMoneyPracticeTitle =>
      'Banco e dinheiro na prática';

  @override
  String get migrationPlanPrepMoneyPracticeBody =>
      'Abra a orientação pública do Banco Central para entender conta, Pix, pagamentos e organização financeira de migrantes.';

  @override
  String get migrationPlanPrepDiplomaTitle => 'Reconhecer diploma e profissão';

  @override
  String get migrationPlanPrepDiplomaBody =>
      'Abra a rota oficial para revalidar diploma estrangeiro e entender quando a profissão pode exigir etapa extra no Brasil.';

  @override
  String get migrationPlanPrepWorkSignalJobs => 'Mercado de trabalho';

  @override
  String get migrationPlanPrepWorkSignalEconomic => 'Atividade econômica';

  @override
  String get migrationPlanPrepWorkSignalUnemployment => 'Desemprego';

  @override
  String get migrationPlanPrepArrivalGuideTitle =>
      'O que resolver primeiro quando você chegar';

  @override
  String get migrationPlanPrepArrivalGuideBody =>
      'Em vez de marcar tarefas soltas, olhe a chegada como uma sequência curta: aterrissar, estabilizar e consolidar a nova rotina.';

  @override
  String get migrationPlanPrepArrivalWeekTitle => 'Primeira semana';

  @override
  String get migrationPlanPrepArrivalWeekBody =>
      'Foque em onde ficar, como circular, o que comprar no básico e como evitar os primeiros erros de moradia.';

  @override
  String get migrationPlanPrepArrivalMonthTitle => 'Primeiro mês';

  @override
  String get migrationPlanPrepArrivalMonthBody =>
      'Ajuste documentos, rotina de bairro, conta, aluguel e os pontos que fazem a chegada deixar de ser improviso.';

  @override
  String get migrationPlanPrepArrivalQuarterTitle => 'Primeiros 90 dias';

  @override
  String get migrationPlanPrepArrivalQuarterBody =>
      'Consolide trabalho, organização financeira, rotina de saúde e os próximos passos para a mudança ficar sustentável.';

  @override
  String get migrationPlanPrepSupportNetworkTitle =>
      'Onde buscar rede de apoio';

  @override
  String get migrationPlanPrepSupportNetworkBody =>
      'Abra redes públicas de apoio a migrantes e refugiados para entender onde procurar atendimento, orientação e acolhimento.';

  @override
  String get migrationPlanPrepArgentineNetworkTitle =>
      'Embaixada e consulados da Argentina';

  @override
  String get migrationPlanPrepArgentineNetworkBody =>
      'Abra a lista oficial da embaixada e dos consulados da Argentina no Brasil para consultar trâmites, contatos e orientação consular oficial.';

  @override
  String get migrationPlanPrepFamilyTitle => 'Como ficam família e filhos';

  @override
  String get migrationPlanPrepFamilyBody =>
      'Abra a orientação pública sobre matrícula e direitos de crianças e adolescentes migrantes no Brasil.';

  @override
  String get migrationPlanPrepRiskAlertsTitle =>
      'Golpes e riscos para não cair';

  @override
  String get migrationPlanPrepRiskAlertsBody =>
      'Abra alertas públicos sobre ofertas enganosas, promessas falsas e riscos que costumam atingir quem está mudando de país.';

  @override
  String get migrationPlanPrepFlightsPlannerTitle => 'Planeje a busca de voo';

  @override
  String migrationPlanPrepFlightsPlannerBody(Object city) {
    return 'Escolha a cidade de saída na Argentina e a data que você pretende mudar para abrir a busca pronta até $city.';
  }

  @override
  String get migrationPlanPrepFlightsOriginLabel => 'Cidade de saída';

  @override
  String get migrationPlanPrepFlightsDateLabel => 'Data estimada da mudança';

  @override
  String get migrationPlanPrepFlightsDatePlaceholder => 'Selecione uma data';

  @override
  String get migrationPlanPrepFlightsDisclaimer =>
      'Os valores finais variam por data, antecedência e disponibilidade. Use esta busca como ponto de partida e compare antes de comprar.';

  @override
  String get migrationPlanPrepFlightsOpenGoogle =>
      'Consultar no Google Flights';

  @override
  String get migrationPlanPrepOfficialIncomeTitle =>
      'Ver renda e indicadores oficiais';

  @override
  String get migrationPlanPrepOfficialIncomeBody =>
      'Abra a página oficial do IBGE desta cidade para consultar indicadores municipais, incluindo o panorama usado como fonte confiável.';

  @override
  String get migrationPlanPrepOfficialJobsTitle =>
      'Buscar vagas no Emprega Brasil';

  @override
  String get migrationPlanPrepOfficialJobsBodyNoCity =>
      'Abra o portal oficial de emprego do governo para procurar vagas formais e usar a sua região como base da busca.';

  @override
  String migrationPlanPrepOfficialJobsBodyWithCity(Object city, Object state) {
    return 'Abra o portal oficial de emprego do governo para procurar vagas formais e usar $city ($state) como referência da busca.';
  }

  @override
  String get migrationPlanPrepOfficialStudyCatalogTitle =>
      'Ver universidades publicas oficiais';

  @override
  String get migrationPlanPrepOfficialStudyCatalogBodyNoCity =>
      'Abra o catalogo oficial do MEC para buscar instituicoes de ensino superior publicas e filtrar por estado ou cidade.';

  @override
  String migrationPlanPrepOfficialStudyCatalogBodyWithCity(
    Object city,
    Object state,
  ) {
    return 'Abra o catalogo oficial do MEC para buscar instituicoes de ensino superior publicas e filtrar por $city ($state) ou pela regiao mais proxima.';
  }

  @override
  String get migrationPlanPrepOfficialStudyForeignersTitle =>
      'Entender ingresso de estrangeiros';

  @override
  String get migrationPlanPrepOfficialStudyForeignersBody =>
      'Abra a rota oficial do PEC-G para entender como funciona o ingresso de estrangeiros e quais universidades participantes ja recebem esse processo.';

  @override
  String get migrationPlanPrepRentalSearchTitle => 'Buscar aluguel na cidade';

  @override
  String migrationPlanPrepRentalSearchBody(Object city, Object state) {
    return 'Abra uma busca de aluguel já filtrada para $city ($state) dentro do app e compare opções por região.';
  }

  @override
  String get migrationPlanPrepRentalProviderLabel => 'Portal de aluguel';

  @override
  String get migrationPlanPrepRentalProviderZap => 'ZAP Imóveis';

  @override
  String get migrationPlanPrepRentalProviderVivaReal => 'Viva Real';

  @override
  String get migrationPlanPrepRentalProviderChaves => 'Chaves na Mão';

  @override
  String get migrationPlanPrepRentalSearchDisclaimer =>
      'Os portais podem variar em cobertura por cidade e disponibilidade do momento. Use mais de uma fonte antes de decidir.';

  @override
  String get migrationPlanPrepRentalSearchOpen => 'Abrir busca de aluguel';

  @override
  String get migrationPlanPrepScamsTitle => 'Como evitar golpes no aluguel';

  @override
  String get migrationPlanPrepScamsBody =>
      'Abra um alerta público sobre fraudes comuns em anúncios e aluguéis para não decidir só pelo preço ou pela pressa.';
}
