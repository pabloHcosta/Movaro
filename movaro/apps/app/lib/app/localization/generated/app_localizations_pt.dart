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
      'O Movaro vai usar essa escolha para montar a experiência certa para você. Hoje o beta está liberado para Argentina -> Brasil, mas a estrutura já está pronta para crescer.';

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
      'Hoje só o trajeto Argentina -> Brasil está disponível para uso completo. Os demais países já aparecem para sinalizar a direção global do produto.';

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
      'O Movaro hoje foi desenhado para quem está avaliando a mudança da Argentina para o Brasil. Em vez de mostrar tudo de uma vez, ele ajuda você a escolher o melhor primeiro passo.';

  @override
  String publicHomeSelectedJourneyDescription(
    String origin,
    String destination,
  ) {
    return 'O Movaro vai organizar sua experiência para a jornada $origin -> $destination. Você começa com o essencial e aprofunda só quando fizer sentido.';
  }

  @override
  String get publicHomePrimaryQuestionTitle => 'Comece pela decisao principal';

  @override
  String get publicHomePrimaryQuestionBody =>
      'Primeiro descubra se você precisa de um plano guiado, de comparação entre cidades ou apenas de um panorama rápido do produto.';

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
  String get publicHomeSecondaryTitle => 'Documentação entra depois';

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
  String get publicHomePlanTitle => 'Gerar meu plano';

  @override
  String get publicHomePlanBody =>
      'Responda poucas perguntas e receba um ponto de partida simples.';

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
      'Use o sinal de adaptação com o idioma para encontrar lugares que parecem mais fáceis para quem ainda depende do espanhol.';

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
  String get commonNeedsTitle => 'Se você ainda não sabe por onde entrar';

  @override
  String get commonNeedsBody =>
      'Estes são os atalhos mais úteis para quem chega com dúvida difusa e quer reduzir a ansiedade antes de decidir.';

  @override
  String get commonNeedCompareCostTitle =>
      'Quero comparar custo e aluguel primeiro';

  @override
  String get commonNeedCompareCostBody =>
      'Vá direto para cidades e use os sinais de custo, aluguel, idioma e trabalho como leitura inicial.';

  @override
  String get commonNeedDocumentsTitle =>
      'Preciso entender documentos antes de tudo';

  @override
  String get commonNeedDocumentsBody =>
      'A documentação resume CPF, registro, permanência, trabalho e banco com fonte oficial e linguagem simples.';

  @override
  String get commonNeedDirectionTitle =>
      'Ainda não sei qual caminho faz sentido';

  @override
  String get commonNeedDirectionBody =>
      'O plano guiado reduz a dúvida para uma cidade inicial e uma ordem curta de primeiros passos.';

  @override
  String get commonNeedExploreAllTitle => 'Quero ver tudo sem me prender';

  @override
  String get commonNeedExploreAllBody =>
      'A área Explorar junta cidades, documentação e outros caminhos em um só lugar.';

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
  String get exploreTrailsEyebrow => 'Tres caminhos claros';

  @override
  String get exploreTrailsTitle =>
      'Escolha o tipo de ajuda que voce precisa agora';

  @override
  String get exploreTrailsBody =>
      'Em vez de mostrar tudo de uma vez, o app agora separa a experiencia em tres trilhas: decidir cidade, entender burocracia pratica e preparar a mudanca.';

  @override
  String get exploreTrailCitiesTitle => 'Decidir cidade';

  @override
  String get exploreTrailCitiesBody =>
      'Compare cidades, veja litoral, custo, trabalho, idioma e moradia para entender qual contexto combina mais com voce.';

  @override
  String get exploreTrailDocsTitle => 'Entender burocracia pratica';

  @override
  String get exploreTrailDocsBody =>
      'Veja aluguel, SUS, CPF, trabalho, dirigir e custos iniciais em blocos mais claros e menos espalhados.';

  @override
  String get exploreTrailPrepTitle => 'Preparar a mudanca';

  @override
  String get exploreTrailPrepBodyStart =>
      'Quando voce ainda nao confirmou uma cidade, comece pelo plano inicial para organizar a decisao.';

  @override
  String get exploreTrailPrepBodyReady =>
      'Como voce ja confirmou uma cidade, aqui o foco vira checklist, documentos, moradia e chegada.';

  @override
  String get exploreSavePlanAction => 'Salvar plano';

  @override
  String get documentationPageTitle => 'Documentação e vida prática';

  @override
  String get documentationHeroEyebrow => 'Guia prático';

  @override
  String get documentationHeroTitle =>
      'O que costuma destravar a vida prática no Brasil';

  @override
  String get documentationHeroDescription =>
      'Sem texto infinito. Aqui você vê documentos, saúde, mobilidade e custos aproximados do que costuma importar primeiro para quem vai morar no Brasil.';

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
      'Use estes blocos para encontrar mais rápido aluguel, SUS, trabalho, dirigir e custos sem precisar ler a página inteira de uma vez.';

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
  String get documentationNavigatorDocuments => 'Documentos base';

  @override
  String get documentationPathDocumentsTitle => 'Documentos e permanência';

  @override
  String get documentationPathDocumentsBody =>
      'CPF, registro, prazo de permanência e o que destrava a vida prática primeiro.';

  @override
  String get documentationPathHealthTitle => 'Saúde no dia a dia';

  @override
  String get documentationPathHealthBody =>
      'Entenda quando faz sentido usar SUS, posto de saúde, hospital ou plano privado.';

  @override
  String get documentationPathDrivingTitle => 'Dirigir e se locomover';

  @override
  String get documentationPathDrivingBody =>
      'Veja se sua carteira estrangeira ajuda no início e quando você precisa olhar o Detran.';

  @override
  String get documentationPathWorkTitle => 'Trabalho e contribuição';

  @override
  String get documentationPathWorkBody =>
      'Entenda carteira assinada, PJ e como isso conversa com a previdência.';

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
      'Antes de abrir cada card, comece por estas respostas curtas. Se alguma delas já resolve sua dúvida, você ganha tempo.';

  @override
  String get documentationAnswerWorkQuestion =>
      'Posso trabalhar só com visto de visita?';

  @override
  String get documentationAnswerWorkAnswer =>
      'Não. Para trabalho formal, você precisa de situação migratória compatível e registro regular.';

  @override
  String get documentationAnswerCpfQuestion =>
      'CPF sozinho resolve banco e contrato?';

  @override
  String get documentationAnswerCpfAnswer =>
      'Não. CPF ajuda bastante, mas normalmente não substitui documento migratório regular.';

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
      'Não necessariamente. O cadastro ajuda no acompanhamento, mas o acesso inicial, e principalmente urgências, não deveria depender de você ter tudo pronto.';

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
      'Sim, se você estiver regular no país e cumprir os requisitos do Detran. O processo e as taxas mudam por estado.';

  @override
  String get documentationAnswerWorkCardQuestion =>
      'Carteira assinada ainda existe e como funciona?';

  @override
  String get documentationAnswerWorkCardAnswer =>
      'Sim. No trabalho formal pela CLT, o vínculo fica registrado e a Carteira de Trabalho Digital concentra o historico laboral.';

  @override
  String get documentationAnswerPjQuestion =>
      'Trabalhar como PJ é igual ao monotributo?';

  @override
  String get documentationAnswerPjAnswer =>
      'Pode lembrar essa lógica de trabalho por conta própria e CNPJ, mas não é a mesma estrutura. No Brasil, regras fiscais, previdenciárias e contratuais mudam conforme o enquadramento.';

  @override
  String get documentationAnswerInssQuestion =>
      'A previdência pública no Brasil é o INSS?';

  @override
  String get documentationAnswerInssAnswer =>
      'Sim. O INSS é a porta central da previdência pública para benefícios como aposentadoria, desde que haja contribuição e requisitos atendidos.';

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
      'O mais importante aqui é entender a função de cada caminho. Saúde pública não é plano barato, e saúde privada não substitui, por si só, uma boa leitura de cobertura.';

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
      'Quando existe valor nacional ou uma referência oficial util, o app mostra a conversão aproximada para ajudar sua leitura inicial.';

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
      'O pedido oficial e gratuito; o app trata isso como custo zero.';

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
      'Referência recente do Detran-ES: R\$ 533,34. Seu estado e sua autoescola podem cobrar diferente.';

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
      'Estrangeiro pode pedir CPF; no Brasil, o pedido pode ser feito online ou em entidade conveniada.';

  @override
  String get documentationCpfBulletTwo =>
      'O serviço oficial informa prazo estimado de até 30 dias corridos.';

  @override
  String get documentationCpfBulletThree =>
      'CPF não substitui documento migratório, mas costuma destravar boa parte da vida prática.';

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
      'A CRNM pode levar perto de 30 dias úteis para confecção; o serviço oficial admite prazo total maior, e o protocolo preserva direitos.';

  @override
  String get documentationStayTitle => 'Quanto tempo posso ficar';

  @override
  String get documentationStaySummary =>
      'Para argentinos, o caminho mais prático costuma ser regularizar a residência, e não depender da permanência de visita.';

  @override
  String get documentationStayBulletOne =>
      'O visto de visita não foi pensado para morar no Brasil nem para trabalho remunerado.';

  @override
  String get documentationStayBulletTwo =>
      'A residência pelo Acordo do Mercosul pode ser concedida por 2 anos.';

  @override
  String get documentationStayBulletThree =>
      'Antes do fim desse prazo, você pode pedir conversão para residência por prazo indeterminado se cumprir os requisitos.';

  @override
  String get documentationWorkBankTitle => 'Trabalho e conta bancária';

  @override
  String get documentationWorkBankSummary =>
      'Trabalhar e abrir conta dependem mais da sua regularização do que de um único documento milagroso.';

  @override
  String get documentationWorkBankBulletOne =>
      'Visto de visita não autoriza atividade remunerada no Brasil.';

  @override
  String get documentationWorkBankBulletTwo =>
      'Para trabalhar formalmente, você precisa de situação migratória compatível e registro regular.';

  @override
  String get documentationWorkBankBulletThree =>
      'Banco pode pedir documentos adicionais; CPF ajuda, mas documento migratório regular costuma fazer diferença no cadastro.';

  @override
  String get documentationCitizenshipTitle => 'Naturalização';

  @override
  String get documentationCitizenshipSummary =>
      'A nacionalidade brasileira não vem só por tempo de CPF ou estadia; ela depende de residência regular e regras próprias.';

  @override
  String get documentationCitizenshipBulletOne =>
      'A naturalização ordinária, em regra, exige residência por prazo indeterminado no Brasil.';

  @override
  String get documentationCitizenshipBulletTwo =>
      'A regra geral pede 4 anos de residência antes do pedido, além de outros requisitos legais.';

  @override
  String get documentationCitizenshipBulletThree =>
      'Existem hipóteses oficiais de redução desse prazo, então vale checar a regra exata antes de planejar seu caminho.';

  @override
  String get documentationHealthPublicTitle =>
      'SUS, posto de saúde e acesso público';

  @override
  String get documentationHealthPublicSummary =>
      'Saúde pública no Brasil não é um plano de entrada paga. A lógica é de acesso universal, com portas diferentes para cada tipo de necessidade.';

  @override
  String get documentationHealthPublicBulletOne =>
      'O SUS atende de forma universal, inclusive pessoas estrangeiras em território brasileiro.';

  @override
  String get documentationHealthPublicBulletTwo =>
      'A UBS, ou posto de saúde, costuma ser a porta de entrada para rotina, acompanhamento, vacina e cuidado básico.';

  @override
  String get documentationHealthPublicBulletThree =>
      'Urgência e emergência seguem outra lógica de acesso; não espere ter tudo resolvido no cadastro antes de buscar ajuda.';

  @override
  String get documentationHealthFlowTitle =>
      'Como encontrar o atendimento certo';

  @override
  String get documentationHealthFlowSummary =>
      'Nem toda dúvida de saúde começa em hospital. Vale saber quando procurar UBS, UPA, hospital ou app oficial.';

  @override
  String get documentationHealthFlowBulletOne =>
      'Use UBS ou posto de saúde para rotina, encaminhamento, receitas e acompanhamento.';

  @override
  String get documentationHealthFlowBulletTwo =>
      'Use UPA ou hospital quando o caso for urgente, agudo ou não puder esperar agenda básica.';

  @override
  String get documentationHealthFlowBulletThree =>
      'Meu SUS Digital e a secretaria local ajudam a localizar unidades, exames e informações de acompanhamento.';

  @override
  String get documentationHealthPrivateTitle => 'Saúde privada';

  @override
  String get documentationHealthPrivateSummary =>
      'Plano privado pode acelerar rede e conveniência, mas entra como custo recorrente e exige comparar cobertura com cuidado.';

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
      'Carteira assinada é o jeito mais reconhecível de trabalho formal no Brasil.';

  @override
  String get documentationWorkCltBulletTwo =>
      'O histórico laboral pode ser acompanhado pela Carteira de Trabalho Digital.';

  @override
  String get documentationWorkCltBulletThree =>
      'Nesse modelo, a relação com a contribuição previdenciária costuma ser mais integrada à folha de pagamento.';

  @override
  String get documentationWorkPjTitle => 'PJ, CNPJ e trabalho por conta';

  @override
  String get documentationWorkPjSummary =>
      'Trabalhar como PJ ou por CNPJ muda a lógica do vínculo. Isso pode lembrar o monotributo na comparação cultural, mas não é a mesma estrutura jurídica.';

  @override
  String get documentationWorkPjBulletOne =>
      'PJ não é carteira assinada; o vínculo é empresarial ou autônomo, não empregatício.';

  @override
  String get documentationWorkPjBulletTwo =>
      'Abrir CNPJ e contribuir para a previdência são assuntos conectados, mas não automáticos em todo caso.';

  @override
  String get documentationWorkPjBulletThree =>
      'Antes de aceitar esse formato, vale entender imposto, contrato e como a contribuição previdenciária vai funcionar.';

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
      'O tempo de contribuição continua relevante, especialmente nas regras de transição e na leitura de elegibilidade.';

  @override
  String get documentationRetirementBulletThree =>
      'Para quem chega do exterior, o mais seguro é entender cedo como será sua forma de contribuição no Brasil.';

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
      'Isso ajuda a deixar sua experiência mais útil sem pedir informações demais.';

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
    return 'Com base nas suas respostas, o Movaro sugere olhar primeiro para $city, $stateCode.';
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
      'Se o resultado ajudou, o próximo passo normalmente e confirmar documentos, comparar a cidade sugerida com outras opções ou refazer o plano com outra prioridade.';

  @override
  String get planNextActionDocumentsTitle =>
      'Confirmar documentos antes de agir';

  @override
  String get planNextActionDocumentsBody =>
      'Use o guia prático para checar CPF, registro, permanencia, trabalho e banco sem cair em pesquisa dispersa.';

  @override
  String get planNextActionCitiesTitle =>
      'Comparar outras cidades antes de decidir';

  @override
  String get planNextActionCitiesBody =>
      'Veja se a cidade sugerida continua fazendo sentido quando comparada com custo, idioma, seguranca e trabalho.';

  @override
  String get planNextActionRetakeTitle =>
      'Refazer o plano com outra prioridade';

  @override
  String get planNextActionRetakeBody =>
      'Se sua prioridade mudou, vale responder de novo e ver se a ordem dos passos tambem muda.';

  @override
  String get readinessSectionTitle => 'Checklist pratico para a proxima fase';

  @override
  String get readinessStageNow => 'Comece agora';

  @override
  String get readinessStageSoon => 'Prepare em seguida';

  @override
  String get readinessStageLanding => 'Antes de chegar';

  @override
  String get readinessSummaryResearching =>
      'Como você ainda está explorando, o melhor passo agora é reduzir incerteza antes de abrir frentes demais.';

  @override
  String get readinessSummaryTwelveMonths =>
      'Você ainda tem tempo para preparar bem a mudança, então use esta checklist para reduzir atrito com antecedencia.';

  @override
  String get readinessSummarySixMonths =>
      'Seis meses já é tempo suficiente para sair do improviso e estruturar documentos, dinheiro e cidade.';

  @override
  String get readinessSummaryAsap =>
      'Como o plano está próximo, a prioridade agora é organizar o essencial e evitar erro evitavel.';

  @override
  String get readinessItemMigrationPathTitle =>
      'Confirme primeiro a rota migratoria';

  @override
  String get readinessItemMigrationPathBody =>
      'Antes de banco, moradia ou trabalho, valide qual caminho de residencia faz mais sentido para a sua entrada no Brasil.';

  @override
  String get readinessItemDocumentsTitle =>
      'Monte o pacote documental essencial';

  @override
  String get readinessItemDocumentsBody =>
      'Separe passaporte, antecedentes, necessidade de apostila e documentos que ainda podem exigir traducao.';

  @override
  String get readinessItemBudgetTitle => 'Teste o orçamento de aterrissagem';

  @override
  String get readinessItemBudgetBody =>
      'Projete o que os primeiros 30 a 90 dias vao exigir, e nao so o custo mensal depois que tudo estabilizar.';

  @override
  String get readinessItemCityTitle => 'Transforme a cidade em filtro real';

  @override
  String get readinessItemCityBody =>
      'Use sua selecao atual de cidades para reduzir incerteza de moradia, transporte e rotina antes de entrar no nivel de bairro.';

  @override
  String readinessItemCityBodyWithCity(String city) {
    return 'Use $city como primeiro filtro e compare com alternativas antes de decidir no nivel de bairro.';
  }

  @override
  String get readinessItemLanguageTitle =>
      'Prepare sua primeira camada de idioma';

  @override
  String get readinessItemLanguageBody =>
      'Foque no portugues que reduz atrito no cotidiano: moradia, transporte, banco e servicos.';

  @override
  String get readinessItemLanguageWorkBody =>
      'Foque no portugues que impacta entrevista, rotina de trabalho, negociacao e pedidos basicos de servico.';

  @override
  String get readinessItemLanguageStudyBody =>
      'Foque no portugues necessario para aulas, matricula, rotina diaria e comunicacao institucional.';

  @override
  String get readinessGoalWorkTitle => 'Mapeie empregabilidade antes de chegar';

  @override
  String get readinessGoalWorkBody =>
      'Revise que tipo de trabalho você pode buscar no inicio, quais documentos travam o processo e como a cidade muda suas chances.';

  @override
  String get readinessGoalRemoteTitle => 'Estabilize a base do trabalho remoto';

  @override
  String get readinessGoalRemoteBody =>
      'Cheque internet, fluxo bancario, custo diario e a estrutura minima local antes de depender da renda remota.';

  @override
  String get readinessGoalStudyTitle => 'Valide a rota de estudo';

  @override
  String get readinessGoalStudyBody =>
      'Revise admissao, custo de rotina, timing de estudante e o que precisa estar regular antes de usar estudo como base.';

  @override
  String get readinessGoalEntrepreneurTitle =>
      'Planeje a entrada para empreender';

  @override
  String get readinessGoalEntrepreneurBody =>
      'Mapeie a camada pratica inicial: documentos locais, banco, cidade e estrutura minima para operar com mais seguranca.';

  @override
  String get readinessGoalRetireTitle => 'Proteja rotina e previsibilidade';

  @override
  String get readinessGoalRetireBody =>
      'Priorize acesso a saude, rotina de bairro, custo recorrente e os documentos que protegem uma chegada tranquila.';

  @override
  String get readinessGoalQualityTitle =>
      'Converta qualidade de vida em criterio';

  @override
  String get readinessGoalQualityBody =>
      'Transforme estilo de vida em filtros reais: seguranca, rotina, adaptacao ao idioma e custo de permanencia.';

  @override
  String get readinessItemCpfBankTitle =>
      'Prepare CPF e a primeira base bancaria';

  @override
  String get readinessItemCpfBankBody =>
      'CPF e situacao regular influenciam banco, contrato e boa parte da estrutura pratica da chegada.';

  @override
  String get readinessItemHousingTitle =>
      'Reduza atrito de moradia antes da busca';

  @override
  String get readinessItemHousingBody =>
      'Revise garantia, reserva financeira, prioridade de bairro e comprovacoes que podem ser exigidas antes de falar com proprietarios.';

  @override
  String get readinessItemArrivalTitle =>
      'Monte um plano de chegada de 30 dias';

  @override
  String get readinessItemArrivalBody =>
      'Liste o que precisa funcionar no primeiro mes: conectividade, saude, transporte, pagamentos e acompanhamento documental.';

  @override
  String readinessProgressLabel(int done, int total) {
    return '$done de $total itens concluidos';
  }

  @override
  String planStepMeta(String category, int days) {
    return 'Category: $category  Estimated days: $days';
  }

  @override
  String get planStepOpenDetailsAction => 'Abrir detalhes';

  @override
  String get planStepOpenVisaEyebrow => 'Residencia e visto';

  @override
  String get planStepOpenVisaSummary =>
      'Antes de decidir banco, trabalho ou contrato, vale confirmar qual e a sua base migratoria correta para entrar e permanecer de forma regular.';

  @override
  String get planStepOpenVisaPointOne =>
      'Para argentino, a residência pelo Acordo do Mercosul costuma ser um dos caminhos mais diretos.';

  @override
  String get planStepOpenVisaPointTwo =>
      'Visto de visita não foi feito para morar no Brasil nem para atividade remunerada.';

  @override
  String get planStepOpenVisaPointThree =>
      'Se a sua intencao ja e viver no Brasil, vale resolver isso antes de assumir aluguel ou trabalho.';

  @override
  String get planStepOpenCpfEyebrow => 'Documento fiscal';

  @override
  String get planStepOpenCpfSummary =>
      'CPF ajuda a destravar banco, contrato, cadastro e parte da vida prática logo no começo.';

  @override
  String get planStepOpenCpfPointOne =>
      'O pedido pode ser iniciado online, conforme a orientacao oficial.';

  @override
  String get planStepOpenCpfPointTwo =>
      'O prazo informado oficialmente pode chegar a até 30 dias corridos.';

  @override
  String get planStepOpenCpfPointThree =>
      'CPF ajuda bastante, mas não substitui documento migratório regular.';

  @override
  String get planStepOpenBankEyebrow => 'Conta inicial';

  @override
  String get planStepOpenBankSummary =>
      'Abrir conta depende mais da sua regularização e dos documentos apresentados do que de um banco específico.';

  @override
  String get planStepOpenBankPointOne =>
      'Bancos tradicionais e digitais existem, mas os documentos exigidos podem variar.';

  @override
  String get planStepOpenBankPointTwo =>
      'CPF costuma ajudar, mas CRNM, protocolo ou outro documento regular podem fazer diferença na aprovação.';

  @override
  String get planStepOpenBankPointThree =>
      'Comece comparando conta digital para rotina simples e banco tradicional se você precisa de atendimento fisico.';

  @override
  String get planStepOpenHousingEyebrow => 'Moradia e bairros';

  @override
  String get planStepOpenHousingSummary =>
      'Antes de fechar moradia, vale comparar bairros com melhor rotina, acesso e custo.';

  @override
  String planStepOpenHousingSummaryCity(String city) {
    return 'For $city, compare neighborhoods with better daily routine, access, and cost before closing a housing deal.';
  }

  @override
  String get planStepOpenHousingPointOne =>
      'Priorize bairros com boa conexão ao que você precisa no dia a dia: trabalho, transporte e serviços.';

  @override
  String get planStepOpenHousingPointTwo =>
      'Use a leitura de custo da cidade como ponto de partida, mas confirme aluguel e contrato antes de decidir.';

  @override
  String get planStepOpenHousingPointThree =>
      'A analise por bairro ainda precisa de uma base dedicada; por enquanto, use a cidade recomendada como filtro inicial.';

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
      'Quando a etapa depender de documento oficial, confirme a exigencia mais recente antes de protocolar.';

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
      'Veja sugestões por intencao e entenda por que cada cidade aparece aqui.';

  @override
  String get citiesLoadingLabel => 'Carregando cidades';

  @override
  String get citiesMethodologyNote =>
      'Rankings baseados em dados públicos e metodologia do Movaro.';

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
  String get citiesExploreHousingEasyTitle => 'Melhores para chegada mais leve';

  @override
  String get citiesExploreHousingPressureTitle => 'Pedem mais caixa na entrada';

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
      'Praia com melhor equilibrio de rotina';

  @override
  String get citiesHighlightPopularLabel =>
      'Entre as cidades analisadas pelo Movaro';

  @override
  String get citiesHighlightLanguageLabel =>
      'Boa opção se a adaptação com o idioma importa para você';

  @override
  String get citiesHighlightEconomicalLabel =>
      'Boa opção para quem prioriza custo';

  @override
  String get citiesHighlightWorkLabel =>
      'Boa para quem busca mais oportunidades de trabalho';

  @override
  String get citiesHighlightHousingEasyLabel => 'Boa para soft landing';

  @override
  String get citiesHighlightHousingPressureLabel => 'Pressao de moradia alta';

  @override
  String get citiesHighlightSoftLandingLabel =>
      'Boa para pouso inicial com menos friccao';

  @override
  String get citiesHighlightFamilyStabilityLabel =>
      'Boa para equilibrar seguranca, moradia e rotina';

  @override
  String get citiesHighlightIncomeStartLabel =>
      'Boa para quem precisa ativar renda mais cedo';

  @override
  String get citiesHighlightCoastalLabel => 'Boa para rotina de litoral';

  @override
  String get citiesHighlightMetropolisLabel =>
      'Boa para quem quer ritmo mais urbano';

  @override
  String get citiesHighlightInlandLabel =>
      'Boa para quem busca rotina mais calma';

  @override
  String get citiesHighlightBorderLabel =>
      'Boa para quem quer leitura de cidade de fronteira';

  @override
  String get citiesHighlightCoastalSoftLandingLabel =>
      'Praia com soft landing melhor';

  @override
  String get citiesHighlightCoastalBalancedLabel =>
      'Praia com equilibrio melhor entre rotina e custo';

  @override
  String get citiesExploreEmptyTitle => 'Ainda estamos ampliando este catalogo';

  @override
  String get citiesExploreEmptyDescription =>
      'As sugestões de cidades vao aparecer aqui conforme a base do Movaro crescer.';

  @override
  String get citiesSearchTitle => 'Buscar cidades';

  @override
  String get citiesSearchHeadline => 'Encontre uma cidade no catalogo inicial';

  @override
  String get citiesSearchDescription =>
      'Busque por nome ou explore a lista atual do Movaro.';

  @override
  String get citiesSearchHint => 'Buscar cidade';

  @override
  String get citiesSearchFieldLabel => 'Nome da cidade';

  @override
  String get citiesQuickFilterAll => 'Visao geral';

  @override
  String get citiesQuickFilterPopular => 'Mais populares';

  @override
  String get citiesQuickFilterLowCost => 'Melhor custo';

  @override
  String get citiesQuickFilterWork => 'Mais trabalho';

  @override
  String get citiesQuickFilterLanguage => 'Idioma mais facil';

  @override
  String get citiesQuickFilterHousingEasy => 'Chegada leve';

  @override
  String get citiesQuickFilterHousingPressure => 'Mais caixa';

  @override
  String get citiesQuickFilterSoftLanding => 'Menos atrito';

  @override
  String get citiesQuickFilterFamilyStability => 'Mais previsivel';

  @override
  String get citiesQuickFilterIncomeStart => 'Renda rapida';

  @override
  String get citiesQuickFilterCoastal => 'Praia';

  @override
  String get citiesSearchingLabel => 'Buscando cidades';

  @override
  String get citiesCatalogLoadingLabel => 'Carregando catalogo';

  @override
  String get citiesSearchEmptyTitle => 'Nenhuma cidade encontrada';

  @override
  String get citiesSearchEmptyDescription =>
      'Tente outro nome ou explore o catalogo inicial do Movaro.';

  @override
  String get citiesCatalogEmptyTitle => 'Catalogo ainda vazio';

  @override
  String get citiesCatalogEmptyDescription =>
      'As cidades do catalogo do Movaro vao aparecer aqui.';

  @override
  String get cityDetailTitleFallback => 'Cidade';

  @override
  String get cityDetailLoadingLabel => 'Carregando detalhes da cidade';

  @override
  String get cityDetailEmptyTitle => 'Cidade indisponivel';

  @override
  String get cityDetailEmptyDescription =>
      'Não encontramos os detalhes dessa cidade neste momento.';

  @override
  String get cityDetailContextNote =>
      'Use estes indicadores como ponto de partida, não como verdade absoluta.';

  @override
  String get cityLifestyleCoastalLabel => 'Estilo de vida de litoral';

  @override
  String get cityLifestyleMetropolisLabel => 'Ritmo de metropole';

  @override
  String get cityLifestyleBorderLabel => 'Cidade de fronteira';

  @override
  String get cityLifestyleInlandLabel => 'Rotina de interior';

  @override
  String get cityDetailMapTitle => 'Onde a cidade fica';

  @override
  String get cityDetailMapDescription =>
      'Veja a localizacao da cidade no mapa antes de comparar contexto, distancia e regiao.';

  @override
  String get cityDetailSnapshotTitle => 'Visao rápida';

  @override
  String get cityDetailPopulationLabel => 'Populacao';

  @override
  String get cityDetailCostLabel => 'Custo';

  @override
  String get cityDetailRentLabel => 'Aluguel';

  @override
  String get cityDetailSafetyLabel => 'Seguranca';

  @override
  String get cityDetailPopularityLabel => 'Popularidade entre argentinos';

  @override
  String get cityDetailLanguageLabel => 'Adaptacao com o idioma';

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
  String get cityDetailSourceUrlLabel => 'Referencia';

  @override
  String get citySourceTerritorialTitle => 'Identidade territorial';

  @override
  String get citySourceTerritorialDescription =>
      'Nome oficial, estado, codigo IBGE e regiao municipal.';

  @override
  String get citySourcePopulationTitle => 'Populacao';

  @override
  String get citySourcePopulationDescription =>
      'Referencia oficial de populacao do municipio.';

  @override
  String get citySourceHumanDevelopmentTitle => 'Desenvolvimento humano';

  @override
  String get citySourceHumanDevelopmentDescription =>
      'IDHM municipal oficial com referência no Censo 2010.';

  @override
  String get citySourceCuratedMetricsTitle => 'Metricas curadas do produto';

  @override
  String get citySourceCuratedMetricsDescription =>
      'Hoje vem do dataset curado do Movaro. As substituicoes oficiais prioritarias são Atlas da Violencia (seguranca), Novo Caged (emprego), FipeZAP (aluguel) e IBGE PIB dos Municipios (atividade economica).';

  @override
  String get citySourceRankingTitle => 'Metodologia de score';

  @override
  String get citySourceRankingDescription =>
      'Scores do Movaro calculados sobre dados públicos e dataset curado.';

  @override
  String get cityDetailSaveAction => 'Salvar cidade';

  @override
  String get cityDetailSavedAction => 'Cidade salva';

  @override
  String get cityDetailSavedFeedback =>
      'Cidade salva temporariamente neste dispositivo.';

  @override
  String get cityDetailCompareAction => 'Comparar outras cidades';

  @override
  String get cityDetailPlanAction => 'Montar meu plano';

  @override
  String get cityDetailFooterNote =>
      'Os indicadores ajudam na exploracao inicial e não substituem analise individual.';

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
      'Responda poucas perguntas e receba uma direção prática para o seu próximo passo.';

  @override
  String get introDocumentationTitle => 'Consulte documentação quando precisar';

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
  String get introSkipAction => 'Pular introdução';

  @override
  String get cityPracticalAnswersTitle =>
      'Respostas rápidas para dúvidas comuns';

  @override
  String get cityPracticalLanguageQuestion =>
      'O dia a dia ficaria mais fácil se eu ainda dependo do espanhol?';

  @override
  String get cityPracticalCostQuestion =>
      'Essa cidade parece administrável no custo de vida cotidiano?';

  @override
  String get cityPracticalWorkQuestion =>
      'Parece uma cidade forte para começar a trabalhar?';

  @override
  String get cityPracticalSafetyQuestion =>
      'Parece mais fácil se adaptar com uma rotina mais estavel?';

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
      'O sinal de custo parece mais amigavel para uma mudanca inicial dentro do catalogo atual.';

  @override
  String get cityPracticalCostMedium =>
      'Ela parece equilibrada, mas ainda vale validar aluguel e bairros com cuidado.';

  @override
  String get cityPracticalCostHard =>
      'Ela pode pesar mais no inicio, entao orcamento e moradia importam ainda mais aqui.';

  @override
  String get cityPracticalWorkStrong =>
      'Ela mostra sinais mais fortes de oportunidades de trabalho e estrutura economica inicial.';

  @override
  String get cityPracticalWorkMedium =>
      'Ela pode funcionar dependendo do seu perfil, mas a escolha precisa ser mais deliberada.';

  @override
  String get cityPracticalWorkLow =>
      'Ela parece menos atraente se sua principal preocupação é encontrar trabalho rápido.';

  @override
  String get cityPracticalSafetyGood =>
      'Dentro deste catalogo inicial, ela parece mais adequada para uma rotina diaria mais estavel.';

  @override
  String get cityPracticalSafetyMedium =>
      'Ela parece razoável, mas o contexto local e a escolha do bairro ainda importam bastante.';

  @override
  String get cityPracticalSafetyLow =>
      'Ela merece mais cautela e validação local antes de ser tratada como uma mudança simples.';

  @override
  String get cityMetricBadgePositive => 'Leitura favoravel';

  @override
  String get cityMetricBadgeNeutral => 'Pede equilibrio';

  @override
  String get cityMetricBadgeAttention => 'Pede mais atencao';

  @override
  String get cityMetricCostLowHeadline => 'Baixo custo';

  @override
  String get cityMetricCostLowSupporting =>
      'Mais leve para o orcamento do dia a dia.';

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
  String get cityMetricSafetyHighHeadline => 'Seguranca alta';

  @override
  String get cityMetricSafetyHighSupporting =>
      'Leitura mais confortavel para a rotina inicial.';

  @override
  String get cityMetricSafetyMediumHeadline => 'Seguranca moderada';

  @override
  String get cityMetricSafetyMediumSupporting =>
      'Depende mais de bairro e contexto local.';

  @override
  String get cityMetricSafetyLowHeadline => 'Mais cautela';

  @override
  String get cityMetricSafetyLowSupporting =>
      'Vale validar melhor a cidade antes de tratar como mudanca simples.';

  @override
  String get cityMetricLanguageEasyHeadline => 'Adaptacao fácil';

  @override
  String get cityMetricLanguageEasySupporting =>
      'Tende a ser mais amigavel para quem chega falando espanhol.';

  @override
  String get cityMetricLanguageMediumHeadline => 'Adaptacao moderada';

  @override
  String get cityMetricLanguageMediumSupporting =>
      'Uma base de português ajuda bastante na rotina.';

  @override
  String get cityMetricLanguageHardHeadline => 'Adaptacao mais difícil';

  @override
  String get cityMetricLanguageHardSupporting =>
      'O idioma tende a pesar mais na integração do dia a dia.';

  @override
  String get cityMetricWorkStrongHeadline => 'Mercado forte';

  @override
  String get cityMetricWorkStrongSupporting =>
      'Cidade com leitura mais favoravel para buscar oportunidades.';

  @override
  String get cityMetricWorkMediumHeadline => 'Mercado moderado';

  @override
  String get cityMetricWorkMediumSupporting =>
      'Pode funcionar bem, mas depende mais do seu perfil.';

  @override
  String get cityMetricWorkLowHeadline => 'Mercado mais limitado';

  @override
  String get cityMetricWorkLowSupporting =>
      'Pede mais estrategia se trabalho rapido for sua prioridade.';

  @override
  String get cityIdhmVeryHigh => 'Desenvolvimento muito alto';

  @override
  String get cityIdhmVeryHighSupporting =>
      'Entre os patamares municipais mais fortes no indicador oficial.';

  @override
  String get cityIdhmHigh => 'Desenvolvimento alto';

  @override
  String get cityIdhmHighSupporting =>
      'Leitura solida de desenvolvimento humano no recorte oficial.';

  @override
  String get cityIdhmMedium => 'Desenvolvimento medio';

  @override
  String get cityIdhmMediumSupporting =>
      'Exige leitura mais contextual junto com custo e oportunidades.';

  @override
  String get cityIdhmLow => 'Desenvolvimento baixo';

  @override
  String get cityIdhmLowSupporting =>
      'Pede mais cuidado antes de assumir boa estrutura geral.';

  @override
  String get cityIdhmVeryLow => 'Desenvolvimento muito baixo';

  @override
  String get cityIdhmVeryLowSupporting =>
      'Sinaliza uma base mais fragil no indicador oficial.';

  @override
  String get citySnapshotRentLower => 'Aluguel mais leve';

  @override
  String get citySnapshotRentLowerSupporting =>
      'Tende a pesar menos no inicio da mudanca.';

  @override
  String get citySnapshotRentModerate => 'Aluguel moderado';

  @override
  String get citySnapshotRentModerateSupporting =>
      'Pede equilibrio entre bairro, contrato e rotina.';

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
      'Tende a permitir um pouso inicial mais simples, com menos pressao de aluguel e mais margem para ajustar bairro e rotina.';

  @override
  String get cityHousingViabilityEasyBadge => 'Boa para soft landing';

  @override
  String get cityHousingViabilityBalancedHeadline => 'Entrada equilibrada';

  @override
  String get cityHousingViabilityBalancedSupporting =>
      'Pode funcionar bem se voce chegar com reserva e validar bairro, garantia e custo total antes de assumir contrato.';

  @override
  String get cityHousingViabilityBalancedBadge => 'Exige validacao';

  @override
  String get cityHousingViabilityHardHeadline => 'Exige mais caixa';

  @override
  String get cityHousingViabilityHardSupporting =>
      'Aqui aluguel e entrada tendem a pesar mais. Vale tratar moradia como filtro serio antes de escolher a cidade.';

  @override
  String get cityHousingViabilityHardBadge => 'Pressao de moradia alta';

  @override
  String get citySnapshotPopularityHigh => 'Muito procurada';

  @override
  String get citySnapshotPopularityHighSupporting =>
      'Ja aparece com forte afinidade entre argentinos.';

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
  String get questionOptionUnknown => 'Ainda não sei';

  @override
  String get questionOptionWork => 'Trabalhar';

  @override
  String get questionOptionRemoteWork => 'Trabalhar remoto';

  @override
  String get questionOptionStudy => 'Estudar';

  @override
  String get questionOptionEntrepreneur => 'Empreender';

  @override
  String get questionOptionRetire => 'Aposentar';

  @override
  String get questionOptionQualityOfLife => 'Qualidade de vida';

  @override
  String get questionOptionBeachLife => 'Praia e litoral';

  @override
  String get questionOptionNoPortuguese =>
      'Ainda dependo principalmente do espanhol';

  @override
  String get questionOptionBasicPortuguese =>
      'Consigo me virar no português básico';

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
      'Adaptacao mais fácil se você ainda depende do espanhol';

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
      'Se destaca para quem esta buscando mais oportunidades de trabalho.';

  @override
  String get planReasonGoalRemoteWork =>
      'Combina melhor com quem quer trabalhar remoto e equilibrar custo com qualidade de vida.';

  @override
  String get planReasonGoalStudy =>
      'Tem boa combinação de estrutura urbana e adaptação inicial para quem quer estudar.';

  @override
  String get planReasonGoalEntrepreneur =>
      'Tem sinais mais fortes de atividade economica para quem quer empreender.';

  @override
  String get planReasonGoalRetire =>
      'Faz mais sentido para quem quer uma rotina com mais seguranca e custo mais controlado.';

  @override
  String get planReasonGoalQualityOfLife =>
      'Se encaixa melhor em uma busca por mais qualidade de vida e adaptação gradual.';

  @override
  String get planReasonGoalBeachLife =>
      'Faz mais sentido para quem quer priorizar litoral, praia e uma rotina mais ligada ao mar.';

  @override
  String get planReasonLanguageNeedsSupport =>
      'Como você disse que ainda depende do espanhol, demos mais peso a cidades com melhor adaptação linguística.';

  @override
  String get planReasonLanguageBasic =>
      'Como você disse que só se vira no português básico, a adaptação com o idioma ainda influencia a recomendação.';

  @override
  String get planReasonTimelineAsap =>
      'Ajuda em uma mudança mais rápida por combinar melhor com adaptação inicial e vida prática.';

  @override
  String get planReasonTimeline6Months =>
      'Funciona bem para um horizonte de mudanca mais curto.';

  @override
  String get planReasonTimeline12Months =>
      'Oferece uma base equilibrada para quem ainda esta estruturando a mudanca.';

  @override
  String get planStepTitleVisaResidence =>
      'Verificar tipo de residência ou visto';

  @override
  String get planStepDescriptionVisaResidence =>
      'Mapear a base migratória adequada para a sua motivação principal de mudança.';

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
  String get planStepTitleSettleDocuments => 'Regularizar documentação local';

  @override
  String get planStepDescriptionSettleDocuments =>
      'Conferir registros adicionais, comprovantes e etapas administrativas locais.';

  @override
  String get planStepTitleMapDestinations => 'Mapear destinos possíveis';

  @override
  String get planStepDescriptionMapDestinations =>
      'Comparar opções de país com base no seu objetivo e janela de mudanca.';

  @override
  String get planStepTitleDecisionCriteria => 'Definir critério de decisao';

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
    return '$cityName já entra no recorte de cidade costeira. O próximo filtro é entender se a entrada de moradia e a rotina local combinam com o seu momento.';
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
      'Entrada de moradia no litoral';

  @override
  String get stepCategoryDocumentation => 'Documentacao';

  @override
  String get stepCategoryFinancial => 'Financeiro';

  @override
  String get stepCategoryHousing => 'Moradia';

  @override
  String get stepCategorySettlement => 'Instalacao';

  @override
  String get stepCategoryResearch => 'Pesquisa';

  @override
  String get stepCategoryPlanning => 'Planejamento';

  @override
  String get industryAgribusiness => 'Agronegócio';

  @override
  String get industryCommerce => 'Comercio';

  @override
  String get industryConstruction => 'Construção';

  @override
  String get industryEnergy => 'Energia';

  @override
  String get industryFinance => 'Finanças';

  @override
  String get industryIndustry => 'Industria';

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
      'O Movaro não conseguiu falar com a API agora.';

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
  String get sourceProviderMovaroDataset => 'Movaro Dataset Curado v1';

  @override
  String get sourceProviderMovaroRanking => 'Movaro Ranking Methodology v1';

  @override
  String get sourceProviderReceitaFederalGovBr => 'Receita Federal / Gov.br';

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
  String get sourceProviderBancoCentralBrasil => 'Banco Central do Brasil';

  @override
  String get sourceProviderMovaro => 'Movaro';

  @override
  String get documentReadinessSectionTitle =>
      'Prontidao documental antes da mudanca';

  @override
  String get documentReadinessPriorityCritical => 'Critico agora';

  @override
  String get documentReadinessPriorityPrepare => 'Prepare com antecedencia';

  @override
  String get documentReadinessPriorityArrival => 'Leve pronto para a chegada';

  @override
  String get documentReadinessSummaryResearching =>
      'Antes de comparar caminhos demais, confirme se a sua mudanca depende de um pacote documental que realmente pode ser montado sem surpresa.';

  @override
  String get documentReadinessSummaryTwelveMonths =>
      'Com mais tempo, a meta e remover risco documental evitavel cedo, em vez de descobrir faltas perto da mudanca.';

  @override
  String get documentReadinessSummarySixMonths =>
      'Seis meses ja permitem organizar os documentos mais sensiveis agora e deixar a chegada mais leve.';

  @override
  String get documentReadinessSummaryAsap =>
      'Como a mudanca esta perto, foque primeiro nos documentos que podem travar residencia, banco e moradia.';

  @override
  String get documentReadinessRouteTitle => 'Valide a rota legal de entrada';

  @override
  String get documentReadinessRouteBodyBrazil =>
      'Confirme se a sua mudanca vai usar a residencia Mercosul e o que esse caminho exige antes de montar o resto em cima de suposicoes.';

  @override
  String get documentReadinessRouteBodyGeneric =>
      'Confirme primeiro a rota legal do destino para que o resto do checklist seja montado em cima do caminho migratorio correto.';

  @override
  String get documentReadinessIdentityPackTitle =>
      'Separe o pacote base de identidade';

  @override
  String get documentReadinessIdentityPackBody =>
      'Mantenha passaporte, certidoes, antecedentes e identificacoes pessoais em um unico bloco revisado antes de abrir outras frentes.';

  @override
  String get documentReadinessApostilleTitle =>
      'Revise apostila e validade dos documentos';

  @override
  String get documentReadinessApostilleBodyBrazil =>
      'Para o Brasil, veja quais documentos argentinos precisam de apostila, qual validade pratica eles tem e o que pode vencer antes da chegada.';

  @override
  String get documentReadinessRuleCheckTitle =>
      'Cheque cedo as regras documentais oficiais';

  @override
  String get documentReadinessRuleCheckBody =>
      'Mapeie quais documentos precisam ser originais, apostilados, traduzidos ou reemitidos para nao depender de achismo.';

  @override
  String get documentReadinessTranslationTitle =>
      'Mapeie a traducao antes de pagar duas vezes';

  @override
  String get documentReadinessTranslationBodyBrazil =>
      'Separe o que pode ficar em espanhol do que pode exigir traducao juramentada no Brasil, especialmente para residencia e prova civil.';

  @override
  String get documentReadinessTranslationBodyGeneric =>
      'Separe o que pode permanecer no idioma de origem do que pode exigir traducao certificada no pais de destino.';

  @override
  String get documentReadinessHousingProofTitle =>
      'Prepare provas para moradia e rotina inicial';

  @override
  String get documentReadinessHousingProofBodyBrazil =>
      'Agrupe comprovante de renda, reserva, identidade e documentos de apoio que locadores, bancos ou garantias podem pedir no Brasil.';

  @override
  String get documentReadinessProofPackTitle =>
      'Monte seu pacote pratico de comprovacoes';

  @override
  String get documentReadinessProofPackBody =>
      'Agrupe identidade, prova de fundos, renda e os documentos que costumam destravar banco, moradia e servicos essenciais.';

  @override
  String get documentReadinessCpfTitle =>
      'Trate CPF e status regular como uma camada so';

  @override
  String get documentReadinessCpfBodyBrazil =>
      'CPF, acompanhamento da residencia e primeiro comprovante local costumam destravar a vida pratica. Deixe esse bloco pronto para executar rapido.';

  @override
  String get documentReadinessCopiesTitle =>
      'Mantenha backup fisico e digital alinhado';

  @override
  String get documentReadinessCopiesBody =>
      'Guarde scans, originais e copias de emergencia em uma estrutura acessivel no celular e facil de usar presencialmente se preciso.';

  @override
  String get documentReadinessArrivalFolderTitle =>
      'Prepare uma pasta de chegada, nao arquivos soltos';

  @override
  String get documentReadinessArrivalFolderBodyBrazil =>
      'Monte uma pasta unica com acompanhamento da residencia, referencias do CPF, notas de endereco e as provas que mais tendem a ser pedidas no primeiro mes.';

  @override
  String get documentReadinessArrivalFolderBodyGeneric =>
      'Monte uma pasta unica com os primeiros documentos, notas de comprovacao local e as evidencias que voce mais tende a usar nas primeiras semanas.';

  @override
  String get documentReadinessGoalWorkTitle =>
      'Proteja os documentos de empregabilidade';

  @override
  String get documentReadinessGoalWorkBodyBrazil =>
      'Revise o que pode travar trabalho cedo no Brasil: consistencia de identidade, acompanhamento da residencia e provas especificas da sua area.';

  @override
  String get documentReadinessGoalWorkBodyGeneric =>
      'Revise o que pode travar trabalho cedo no destino: consistencia de identidade, status migratorio e provas especificas da sua profissao.';

  @override
  String get documentReadinessGoalRemoteTitle =>
      'Estabilize a base documental da renda remota';

  @override
  String get documentReadinessGoalRemoteBodyBrazil =>
      'Mantenha identidade fiscal, referencias bancarias e provas que sustentem contratos, transferencias e uma rotina estavel no Brasil.';

  @override
  String get documentReadinessGoalRemoteBodyGeneric =>
      'Mantenha identidade fiscal, referencias bancarias e provas que sustentem contratos e fluxo internacional de renda no novo pais.';

  @override
  String get documentReadinessGoalStudyTitle =>
      'Proteja a rota de estudo com os registros certos';

  @override
  String get documentReadinessGoalStudyBodyBrazil =>
      'Deixe admissao, historicos, identidade e papeis sensiveis a prazo alinhados antes de depender do estudo como porta de entrada.';

  @override
  String get documentReadinessGoalStudyBodyGeneric =>
      'Deixe admissao, historicos, identidade e papeis sensiveis a prazo alinhados antes de depender do estudo como base.';

  @override
  String get documentReadinessGoalEntrepreneurTitle =>
      'Prepare a camada documental para operar';

  @override
  String get documentReadinessGoalEntrepreneurBodyBrazil =>
      'Separe as provas de identidade, banco e residencia que vao influenciar a seguranca para comecar a operar no Brasil.';

  @override
  String get documentReadinessGoalEntrepreneurBodyGeneric =>
      'Separe as provas de identidade, banco e imigracao que vao influenciar a seguranca para comecar a operar no pais de destino.';

  @override
  String get documentReadinessGoalRetireTitle =>
      'Proteja uma chegada calma com papeis revisados';

  @override
  String get documentReadinessGoalRetireBodyBrazil =>
      'Priorize o conjunto documental que reduz surpresa em saude, banco e rotina recorrente quando voce chegar ao Brasil.';

  @override
  String get documentReadinessGoalRetireBodyGeneric =>
      'Priorize o conjunto documental que reduz surpresa em saude, banco e rotina recorrente quando voce chegar.';

  @override
  String get documentReadinessGoalQualityTitle =>
      'Use documentos para reduzir atrito, nao so para cumprir regra';

  @override
  String get documentReadinessGoalQualityBodyBrazil =>
      'Mesmo quando a prioridade e qualidade de vida, a mudanca mais suave e a que chega ao Brasil com identidade, provas e pasta de chegada ja organizadas.';

  @override
  String get documentReadinessGoalQualityBodyGeneric =>
      'Mesmo quando a prioridade e qualidade de vida, a mudanca mais suave e a que chega com identidade, provas e pasta de chegada ja organizadas.';

  @override
  String get documentReadinessRiskBlocking => 'Pode travar a mudanca';

  @override
  String get documentReadinessRiskCaution => 'Evita atraso e retrabalho';

  @override
  String get documentReadinessRiskReview => 'Revisar na etapa certa';

  @override
  String get documentReadinessReviewBeforeBooking =>
      'Revise antes de comprar passagem';

  @override
  String get documentReadinessReviewCloseToMove =>
      'Reconfirme perto da mudanca';

  @override
  String get documentReadinessReviewOnArrival => 'Deixe pronto para a chegada';

  @override
  String documentReadinessSourceLabel(Object source) {
    return 'Base: $source';
  }

  @override
  String get housingDecisionSectionTitle =>
      'Moradia e uma decisao critica antes da cidade';

  @override
  String housingDecisionSectionTitleWithCity(Object city) {
    return 'Moradia pode definir se $city funciona para voce';
  }

  @override
  String get housingDecisionSectionBody =>
      'Antes de decidir a cidade, vale entender como aluguel e garantias funcionam no Brasil. O maior risco nao e so o preco mensal: e chegar sem caminho viavel para contrato, bairro e instalacao inicial.';

  @override
  String housingDecisionSectionBodyWithCity(Object city) {
    return 'Antes de assumir $city como melhor opcao, valide se aluguel, garantias e instalacao inicial parecem viaveis para o seu momento. O risco nao esta so no preco: esta no caminho real para fechar moradia.';
  }

  @override
  String get housingDecisionGuaranteesTitle =>
      'Garantias podem bloquear o aluguel';

  @override
  String get housingDecisionGuaranteesBody =>
      'Fiador local ainda pesa em muitos contratos. Se isso nao existir para voce, compare caucao, seguro-fianca, titulo de capitalizacao e exigencia de comprovacao de renda antes de contar com o bairro.';

  @override
  String get housingDecisionSoftLandingTitle => 'Comeco leve reduz erro caro';

  @override
  String get housingDecisionSoftLandingBody =>
      'Temporario, mobiliado, coliving ou contrato curto por 30 a 90 dias costumam ser um caminho mais seguro do que assumir aluguel longo sem conhecer a rotina local.';

  @override
  String get housingDecisionProofPackTitle =>
      'Leve a pasta que destrava conversa';

  @override
  String get housingDecisionProofPackBody =>
      'Reserve identidade, renda, reserva financeira, referencias e comprovacoes digitais em uma unica pasta. Isso nao garante o contrato, mas reduz friccao logo no primeiro contato.';

  @override
  String get housingDecisionCityReadTitle =>
      'Leia a cidade pela pressao de moradia';

  @override
  String housingDecisionCityReadTitleWithCity(Object city) {
    return 'Leia $city pela pressao de moradia';
  }

  @override
  String get housingDecisionCityReadBody =>
      'Nao compare so o aluguel medio. Olhe bairro, transporte, servicos por perto, necessidade de mobilia, distancia do trabalho e margem de caixa para entrada e imprevisto.';

  @override
  String housingDecisionCityReadBodyWithCity(Object city) {
    return 'Em $city, compare bairros, transporte, servicos por perto, necessidade de mobilia e caixa para entrada e imprevisto antes de tratar aluguel como resolvido.';
  }

  @override
  String get housingDecisionSectionNote =>
      'Movaro hoje organiza o contexto para decidir melhor. Contrato, garantia aceita e politica de cada proprietario ou plataforma ainda precisam ser validados na fonte antes de fechar moradia.';

  @override
  String get housingEntrySectionTitle =>
      'Estimativa de custo de entrada na moradia';

  @override
  String housingEntrySectionTitleWithCity(Object city) {
    return 'Quanto a moradia pode exigir para entrar em $city';
  }

  @override
  String get housingEntrySectionBody =>
      'Um aluguel que parece acessivel no anuncio pode exigir muito mais na entrada. Use esta leitura para simular caução, seguro-fianca ou um comeco temporario antes de decidir a cidade.';

  @override
  String housingEntrySectionBodyWithCity(Object city) {
    return 'Em $city, nao olhe so o aluguel mensal. Use esta leitura para estimar quanto a entrada pode exigir com caucao, seguro-fianca ou um comeco temporario.';
  }

  @override
  String housingEntryRentLabel(Object amount) {
    return 'Aluguel mensal de referencia: $amount';
  }

  @override
  String get housingEntryModeDeposit => 'Caucao';

  @override
  String get housingEntryModeInsurance => 'Seguro-fianca';

  @override
  String get housingEntryModeTemporary => 'Temporario';

  @override
  String get housingEntryModeDepositBody =>
      'Leitura comum quando o contrato pede cerca de 3 meses de caucao mais a primeira mensalidade.';

  @override
  String get housingEntryModeInsuranceBody =>
      'Leitura comum quando o fiador e substituido por uma taxa anual de seguro ou garantia digital.';

  @override
  String get housingEntryModeTemporaryBody =>
      'Leitura mais leve para os primeiros 30 a 90 dias, priorizando flexibilidade antes de fechar contrato longo.';

  @override
  String get housingEntryTotalTitle => 'Quanto pode sair para entrar';

  @override
  String get housingEntryFirstMonthLabel => 'Primeiro mes';

  @override
  String get housingEntryGuaranteeLabel => 'Garantia / caucao';

  @override
  String get housingEntrySetupLabel => 'Taxas e instalacao';

  @override
  String get housingEntryPlatformsTitle => 'Plataformas e caminhos uteis';

  @override
  String get housingEntryPlatformsHeadline =>
      'Use o canal certo para o seu nivel de risco';

  @override
  String get housingEntryPlatformsBody =>
      'A melhor plataforma depende menos do anuncio bonito e mais da burocracia que voce consegue sustentar agora.';

  @override
  String get housingEntryPlatformsQuintoAndar =>
      'Digital e sem fiador, mas exige renda e documentacao consistentes.';

  @override
  String get housingEntryPlatformsZap =>
      'Use filtros como aluguel sem fiador para reduzir perda de tempo na busca.';

  @override
  String get housingEntryPlatformsCredPago =>
      'Garantia digital que pode substituir o fiador em varias imobiliarias.';

  @override
  String get housingEntryPlatformsAirbnb =>
      'Ajuda a pousar por 15 a 30 dias e visitar bairros antes de assumir contrato longo.';

  @override
  String get housingEntryDisclaimer =>
      'Esta simulacao e direcional. O valor real muda por cidade, bairro, plataforma, comprovacao de renda e politica do proprietario. O objetivo aqui e evitar subestimar o custo de entrada.';

  @override
  String get housingSoftLandingTitle =>
      'Como argentinos costumam pousar antes do aluguel fixo';

  @override
  String get housingSoftLandingBody =>
      'Nos primeiros dias, o caminho mais comum nao e ir direto para o contrato tradicional. A sequencia costuma ser desembarque, moradia temporaria e so depois a busca por uma base fixa com menos risco.';

  @override
  String get housingSoftLandingTemporaryTitle =>
      'Desembarque por temporada ou flat';

  @override
  String get housingSoftLandingTemporaryBody =>
      'Airbnb com desconto mensal, aparthotel e flat ajudam a pousar sem fiador nem comprovacao local. Isso compra tempo para visitar bairros e entender a cidade na pratica.';

  @override
  String get housingSoftLandingDirectTitle =>
      'Busca direta com dono ou grupos locais';

  @override
  String get housingSoftLandingDirectBody =>
      'Facebook Marketplace, OLX e contatos diretos costumam ser mais flexiveis do que a imobiliaria tradicional. Em troca, o risco de golpe sobe e a validacao do imovel precisa ser mais dura.';

  @override
  String get housingSoftLandingGuaranteeTitle =>
      'A moeda de troca e a garantia';

  @override
  String get housingSoftLandingGuaranteeBody =>
      'Sem fiador, o argumento mais forte costuma ser caucao, seguro-fianca, titulo de capitalizacao ou alguns meses pagos na frente. O ponto nao e prometer demais, e entrar com uma estrutura crivel.';

  @override
  String get housingSoftLandingSurvivalTitle =>
      'Checklist de sobrevivencia logo na chegada';

  @override
  String get housingSoftLandingSurvivalChip =>
      'Compre um chip brasileiro cedo. Sem numero local, imobiliarias e proprietarios tendem a responder menos.';

  @override
  String get housingSoftLandingSurvivalCpf =>
      'Se o CPF ainda nao estiver resolvido, trate isso como prioridade. Ele pesa em plataforma, banco e conversa de aluguel.';

  @override
  String get housingSoftLandingSurvivalLocation =>
      'Nos primeiros dias, priorize ficar perto de mercado, farmacia, transporte e posto de saude para reduzir custo e friccao.';

  @override
  String get housingSoftLandingSurvivalScam =>
      'Nao deposite reserva sem visitar o imovel ou ter alguem de confianca validando no local.';

  @override
  String get landingBudgetSectionTitle =>
      'Reserva sugerida para a aterrissagem';

  @override
  String landingBudgetSectionTitleWithCity(String city) {
    return 'Reserva sugerida para chegar em $city';
  }

  @override
  String get landingBudgetSummaryResearching =>
      'Use isso como referência de reserva para não desenhar a mudança olhando só o custo mensal depois que tudo estiver estabilizado.';

  @override
  String get landingBudgetSummaryTwelveMonths =>
      'Com mais tempo, a meta é formar uma reserva realista e reduzir o choque dos custos de instalação antes de a mudança chegar.';

  @override
  String get landingBudgetSummarySixMonths =>
      'Seis meses já permitem transformar a mudança em plano com reserva, em vez de uma sequência de gastos reativos.';

  @override
  String get landingBudgetSummaryAsap =>
      'Como a mudança está perto, a reserva importa tanto quanto a cidade. Use esta estimativa para não chegar com pouco fôlego financeiro.';

  @override
  String get landingBudgetLeanTitle => 'Enxuto';

  @override
  String get landingBudgetLeanBody =>
      'Funciona como referencia se voce pretende chegar com gasto mais controlado, expectativa de moradia mais simples e decisoes iniciais mais apertadas.';

  @override
  String get landingBudgetBalancedTitle => 'Equilibrado';

  @override
  String get landingBudgetBalancedBody =>
      'Uma leitura intermediaria para quem quer reduzir estresse sem assumir uma instalacao premium desde o primeiro dia.';

  @override
  String get landingBudgetComfortableTitle => 'Confortável';

  @override
  String get landingBudgetComfortableBody =>
      'Uma margem mais segura se você quer mais fôlego para atrito com moradia, adaptação mais lenta ou custos inesperados de instalação.';

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
  String get arrivalExecutionSectionTitle => 'Primeiros 7 / 30 / 90 dias';

  @override
  String get arrivalExecutionStageWeek => 'Primeiros 7 dias';

  @override
  String get arrivalExecutionStageMonth => 'Primeiros 30 dias';

  @override
  String get arrivalExecutionStageQuarter => 'Primeiros 90 dias';

  @override
  String get arrivalExecutionSummaryResearching =>
      'Esta é a camada de execução depois da chegada. Use agora para entender o que as primeiras semanas vão exigir além de documento.';

  @override
  String get arrivalExecutionSummaryTwelveMonths =>
      'Com mais tempo, esta camada ajuda a enxergar o que a instalação vai exigir, para a mudança não ser planejada só por documento e reserva.';

  @override
  String get arrivalExecutionSummarySixMonths =>
      'Seis meses já permitem planejar a chegada como sequência operacional, e não só como decisão de destino.';

  @override
  String get arrivalExecutionSummaryAsap =>
      'Se a chegada está perto, esta camada 7 / 30 / 90 dias importa agora. É nela que o atrito do cotidiano costuma aparecer primeiro.';

  @override
  String get arrivalExecutionConnectivityTitle =>
      'Resolva conectividade no primeiro dia';

  @override
  String get arrivalExecutionConnectivityBody =>
      'Comece com chip local, internet móvel e a estrutura digital mínima para mapas, banco e acompanhamento documental.';

  @override
  String get arrivalExecutionTransportTitle =>
      'Aprenda a primeira rotina de deslocamento';

  @override
  String get arrivalExecutionTransportBody =>
      'Mapeie como você vai se mover na primeira semana para que moradia, serviços e burocracia não dependam de improviso.';

  @override
  String arrivalExecutionTransportBodyWithCity(String city) {
    return 'Mapeie como você vai se mover em $city na primeira semana para que moradia, serviços e burocracia não dependam de improviso.';
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
      'Depois de chegar, confirme se a area escolhida realmente sustenta trabalho, transporte, seguranca e o ritmo de vida que voce precisa.';

  @override
  String get arrivalExecutionGoalWorkTitle =>
      'Transforme chegada em empregabilidade';

  @override
  String get arrivalExecutionGoalWorkBody =>
      'Use o primeiro mes para testar como documentos, idioma e cidade afetam de verdade sua chance de conseguir trabalho.';

  @override
  String get arrivalExecutionGoalRemoteTitle =>
      'Transforme chegada em base remota estavel';

  @override
  String get arrivalExecutionGoalRemoteBody =>
      'Valide qualidade da internet, rotina silenciosa, fluxo bancario e o custo real de sustentar trabalho remoto na nova cidade.';

  @override
  String get arrivalExecutionGoalStudyTitle =>
      'Transforme chegada em rotina de estudo';

  @override
  String get arrivalExecutionGoalStudyBody =>
      'Use o primeiro mes para confirmar se matricula, deslocamento, aulas e custo diario ainda sustentam estudo como base do plano.';

  @override
  String get arrivalExecutionGoalEntrepreneurTitle =>
      'Transforme chegada em capacidade de operar';

  @override
  String get arrivalExecutionGoalEntrepreneurBody =>
      'Use o primeiro mes para validar se banco, documentos, rotina local e contexto da cidade realmente sustentam operar com seguranca.';

  @override
  String get arrivalExecutionGoalRetireTitle =>
      'Transforme chegada em rotina previsivel';

  @override
  String get arrivalExecutionGoalRetireBody =>
      'Use o primeiro mes para testar se acesso a saude, rotina de bairro e custos recorrentes parecem sustentaveis na pratica.';

  @override
  String get arrivalExecutionGoalQualityTitle =>
      'Transforme chegada em qualidade de vida real';

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
      'Feche as pontas documentais abertas';

  @override
  String get arrivalExecutionDocumentsBody =>
      'Até os primeiros 90 dias, reduza pendências de residência, comprovações, banco e registros locais que ainda bloqueiam estabilidade.';

  @override
  String get arrivalExecutionReplanTitle =>
      'Replaneje antes que a inércia tome conta';

  @override
  String get arrivalExecutionReplanBody =>
      'Se cidade, custo ou ritmo não estiverem batendo com o plano original, ajuste a rota antes que o atrito temporário vire o seu normal.';

  @override
  String arrivalExecutionReplanBodyWithCity(String city) {
    return 'Se $city não estiver batendo com o plano original na prática, ajuste a rota antes que o atrito temporário vire o seu normal.';
  }

  @override
  String get publicHomeResumePlanAction => 'Continuar meu plano';

  @override
  String get publicHomeResumePlanTitle => 'Retome de onde voce parou';

  @override
  String get publicHomeResumePlanBody =>
      'Seu ultimo plano de mudanca ainda esta aqui. Reabra para continuar a checklist, a prontidao documental e a reserva de aterrissagem.';

  @override
  String publicHomeResumePlanBodyWithCity(String city, String state) {
    return 'Seu ultimo plano ainda esta aqui, com $city ($state) como cidade atual de referencia. Reabra para continuar a checklist, a prontidao documental e a reserva de aterrissagem.';
  }

  @override
  String get publicHomeRetakePlanAction => 'Refazer plano';

  @override
  String get migrationPlanCopilotTitle => 'Preparação guiada';

  @override
  String get migrationPlanCopilotAction => 'Abrir preparação';

  @override
  String get migrationPlanCopilotIntroTitle =>
      'Quando quiser sair da decisão para a execução';

  @override
  String get migrationPlanCopilotIntroBody =>
      'Esta etapa organiza checklist, documentos, moradia e reserva de aterrissagem. Use quando você já quiser começar a preparar a mudança.';

  @override
  String migrationPlanCopilotIntroBodyWithCity(String city, String state) {
    return 'Esta etapa organiza checklist, documentos, moradia e reserva de aterrissagem com $city ($state) como referência principal do seu plano.';
  }

  @override
  String get migrationPlanCopilotResultBody =>
      'Primeiro veja se a cidade recomendada faz sentido para você. Quando quiser transformar essa decisão em preparação concreta, abra a camada guiada com checklist, documentos e reserva de chegada.';

  @override
  String get migrationPlanDecisionLabel => 'Escolha de cidade';

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
      'Primeiro escolha a cidade que faz mais sentido para você. O checklist detalhado entra só depois dessa decisão.';

  @override
  String get migrationPlanCandidateCitiesTitle =>
      'Cidades mais alinhadas ao seu perfil';

  @override
  String get migrationPlanCandidateCitiesBody =>
      'A lista já vem ordenada para deixar primeiro o que tende a fazer mais sentido para argentinos com esse objetivo.';

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
    return 'Se você decidir seguir com $city, o copiloto abre checklist, documentos, moradia e reserva de chegada focando nessa cidade.';
  }

  @override
  String get languageSelectorSystem => 'Sistema';
}
