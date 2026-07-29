import 'package:movaro_app/features/cities/domain/entities/city.dart';

class FederalPoliceUnitContact {
  const FederalPoliceUnitContact({required this.label, required this.email});

  final String label;
  final String email;

  Uri buildMailtoUri(City city) {
    final subject = Uri.encodeComponent(
      'Agendamento de imigração para ${city.name}/${city.stateCode}',
    );
    final body = Uri.encodeComponent(
      'Olá, moro ou pretendo residir em ${city.name}/${city.stateCode} e preciso de orientação sobre o agendamento de imigração / CRNM.',
    );
    return Uri.parse('mailto:$email?subject=$subject&body=$body');
  }
}

enum RentalProvider { zapImoveis, vivaReal, chavesNaMao }

enum TemporaryHousingDuration { oneWeek, oneMonth, twoThreeMonths }

class PreparationResourceLinks {
  const PreparationResourceLinks._();

  static final Uri officialJobsPortal = Uri.parse(
    'https://www.gov.br/trabalho-e-emprego/pt-br/servicos/trabalhador/carteira-de-trabalho',
  );

  static final Uri govBrAccountGuide = Uri.parse(
    'https://www.gov.br/pt-br/servicos/criar-sua-conta-gov.br',
  );

  static final Uri migrationDocumentRules = Uri.parse(
    'https://www.gov.br/pf/pt-br/assuntos/imigracao/pt/duvidas',
  );

  static final Uri foreignDrivingGuide = Uri.parse(
    'https://www.gov.br/transportes/pt-br/assuntos/transito/conteudo-Senatran/carteira-internacional/',
  );

  static final Uri migrantWorkerGuide = Uri.parse(
    'https://www.gov.br/trabalho-e-emprego/pt-br/servicos/trabalhador',
  );

  static final Uri publicUniversitiesCatalog = Uri.parse(
    'https://emec.mec.gov.br/',
  );

  static final Uri foreignStudentGuide = Uri.parse(
    'https://www.gov.br/pt-br/servicos/estudar-o-ensino-superior-no-brasil?id=5999&origem=servico',
  );

  static final Uri sisuGuide = Uri.parse(
    'https://www.gov.br/mec/pt-br/assuntos/es/sistema-de-selecao-unificada-sisu',
  );

  static final Uri pecGGuide = Uri.parse(
    'https://www.gov.br/mre/pt-br/assuntos/cultura-e-educacao/temas-educacionais/programas-de-estudo-para-estrangeiros/pec-g',
  );

  static final Uri taxEntryGuide = Uri.parse(
    'https://www.gov.br/receitafederal/pt-br/centrais-de-conteudo/formularios/declaracoes/declaracao-entrada-brasil',
  );

  static final Uri taxResidentGuide = Uri.parse(
    'https://www.gov.br/receitafederal/pt-br/assuntos/meu-imposto-de-renda/preenchimento/dsdp/nao-residente',
  );

  static final Uri financialGuide = Uri.parse(
    'https://www.bcb.gov.br/detalhenoticia/450/noticia',
  );

  static final Uri mercadoPagoPixArgentina = Uri.parse(
    'https://www.mercadolibre.com.ar/ayuda/terminos-y-condiciones_299',
  );

  static final Uri prexPixBrazil = Uri.parse(
    'https://www.prexcard.com.ar/pix-brasil',
  );

  static final Uri beloPixBrazil = Uri.parse(
    'https://help.belo.app/en/articles/6076271-what-qr-codes-can-you-scan-with-belo',
  );

  static final Uri argentinaResidenceAgreement = Uri.parse(
    'https://www.gov.br/pf/pt-br/assuntos/imigracao/autorizacao-residencia/acordo-de-residencia-brasil-e-argentina',
  );

  static final Uri federalPoliceMigration = Uri.parse(
    'https://www.gov.br/pf/pt-br/assuntos/imigracao',
  );

  static final Uri entryDocumentsGuide = Uri.parse(
    'https://www.gov.br/pf/pt-br/assuntos/passaporte/suporte/duvidas_/inicio/mercosul',
  );

  static final Uri cpfInBrazil = Uri.parse(
    'https://www.gov.br/pt-br/servicos/inscrever-no-cpf',
  );

  static final Uri cpfInExterior = Uri.parse(
    'https://www.gov.br/pt-br/servicos/inscrever-no-cpf-no-exterior',
  );

  static final Uri rnMRegistrationGuide = Uri.parse(
    'https://www.gov.br/pt-br/servicos/registrar-se-como-estrangeiro-no-brasil',
  );
  static final Uri consumerFinancialEducation = Uri.parse(
    'https://www.bcb.gov.br/cidadaniafinanceira',
  );

  static final Uri migrantSupportNetwork = Uri.parse(
    'https://www.gov.br/mj/pt-br/assuntos/seus-direitos/refugio/integracao-local/rede-de-apoio-a-refugiados',
  );

  static final Uri argentinaConsulatesBrazil = Uri.parse(
    'https://ebras.cancilleria.gob.ar/es/content/representaciones-de-la-argentina-en-la-rep%C3%BAblica-federativa-del-brasil-2',
  );

  static final Uri diplomaValidationGuide = Uri.parse(
    'https://www.gov.br/pt-br/servicos/reconhecer-ou-revalidar-diploma-de-curso-superior-obtido-no-exterior',
  );

  static final Uri familySchoolGuide = Uri.parse(
    'https://www.gov.br/casacivil/pt-br/assuntos/noticias/2020/novembro/conselho-nacional-de-educacao-garante-direito-de-matricula-de-criancas-e-adolescentes-migrantes-e-refugiados',
  );

  static final Uri migrantHealthGuide = Uri.parse(
    'https://www.gov.br/saude/pt-br/composicao/saps/equidade-em-saude/migrantes-refugiadas-e-apatridas',
  );

  static final Uri travelerVaccinationGuide = Uri.parse(
    'https://www.gov.br/saude/pt-br/vacinacao/viajantes',
  );

  static final Uri argentinaBrazilTravelRecommendations = Uri.parse(
    'https://www.argentina.gob.ar/aplicaciones/fronteras/recomendaciones/brasil',
  );

  static final Uri anatelMobileCoverage = Uri.parse(
    'https://www.gov.br/anatel/pt-br/dados/qualidade/qualidade-dos-servicos/mapa-cobertura',
  );

  static final Uri anatelPrepaidRegistration = Uri.parse(
    'https://www.gov.br/anatel/pt-br/dados/utilidade-publica/cadastro-pre-pago',
  );

  static final Uri timForeignVisitors = Uri.parse(
    'https://www.tim.com.br/ajuda/perguntas-frequentes/celular/pre-pago/estrangeiros-no-brasil',
  );

  static final Uri petEntryGuide = Uri.parse(
    'https://www.gov.br/agricultura/pt-br/assuntos/vigilancia-agropecuaria/viajantes-e-bagagens/lista-de-bens-agropecuarios-que-podem-ou-nao-ingressar-no-brasil/animais-vivos/caes-e-gatos',
  );

  static final Uri medicationTravelGuide = Uri.parse(
    'https://www.gov.br/anvisa/pt-br/assuntos/paf/regras-de-bagagem/regras-de-bagagem',
  );

  static final Uri controlledMedicationGuide = Uri.parse(
    'https://www.gov.br/anvisa/pt-br/assuntos/medicamentos/controlados/importacao',
  );

  static final Uri foreignIncomeTaxGuide = Uri.parse(
    'https://www.gov.br/receitafederal/pt-br/assuntos/meu-imposto-de-renda/pagamento/carne-leao/rendimentos',
  );

  static final Uri rentalLawGuide = Uri.parse(
    'https://www.planalto.gov.br/ccivil_03/leis/l8245compilado.htm',
  );

  static final Uri privacyRightsGuide = Uri.parse(
    'https://www.gov.br/anpd/pt-br/assuntos/titular-de-dados-1/direito-dos-titulares',
  );

  static final Uri rentalScamAlert = Uri.parse(
    'https://www.gov.br/turismo/pt-br/assuntos/noticias/vai-viajar-confira-dicas-para-nao-cair-em-golpes',
  );

  static final Uri traffickingAlert = Uri.parse(
    'https://www.gov.br/mj/pt-br/assuntos/noticias/governo-federal-alerta-para-risco-de-trafico-de-brasileiros-atraidos-por-ofertas-de-trabalho-no-sudeste-asiatico',
  );

  static Uri buildHostelworldSearch(City city) {
    final query = Uri.encodeComponent('${city.name}, Brazil');
    return Uri.parse(
      'https://www.hostelworld.com/search#where=$query&accommodation=Hostels',
    );
  }

  static Uri buildQuintoAndarSearch(City city) {
    final uf = city.stateCode.toLowerCase();
    final slug = _slugify(city.name);
    return Uri.parse('https://quintoandar.com.br/alugar/imovel/$uf/$slug/');
  }

  static Uri buildFlatioSearch(City city) {
    final query = Uri.encodeComponent(city.name);
    return Uri.parse(
      'https://www.flatio.com/pt-BR/s?location=$query&country=BR',
    );
  }

  static Uri buildFlightsSearch({
    required String originCity,
    required String destinationCity,
    DateTime? departureDate,
  }) {
    final dateText = departureDate == null
        ? ''
        : ' on ${departureDate.year.toString().padLeft(4, '0')}-${departureDate.month.toString().padLeft(2, '0')}-${departureDate.day.toString().padLeft(2, '0')}';
    final query =
        'Flights from $originCity Argentina to $destinationCity Brazil$dateText';
    return Uri.parse(
      'https://www.google.com/travel/flights?q=${Uri.encodeComponent(query)}',
    );
  }

  static Uri buildIbgePanorama(City city) {
    final state = city.stateCode.toLowerCase();
    final slug = _slugify(city.name);
    return Uri.parse(
      'https://cidades.ibge.gov.br/brasil/$state/$slug/panorama',
    );
  }

  static Uri buildCityGoogleSearch(City city) {
    final query = '${city.name}, ${city.stateName}, Brasil';
    return Uri.parse(
      'https://www.google.com/search?q=${Uri.encodeComponent(query)}',
    );
  }

  static Uri buildRentalSearch(City city, RentalProvider provider) {
    final state = city.stateCode.toLowerCase();
    final hyphenCity = _slugify(city.name);
    final zapCity = _slugify(city.name).replaceAll('-', '%2B');

    return switch (provider) {
      RentalProvider.zapImoveis => Uri.parse(
        'https://www.zapimoveis.com.br/aluguel/imoveis/$state$zapCity/',
      ),
      RentalProvider.vivaReal => Uri.parse(
        'https://www.vivareal.com.br/aluguel/$state/$hyphenCity/',
      ),
      RentalProvider.chavesNaMao => Uri.parse(
        'https://www.chavesnamao.com.br/imoveis-para-alugar/$state-$hyphenCity/',
      ),
    };
  }

  static Uri buildAirbnbSearch(City city, TemporaryHousingDuration duration) {
    final citySlug = _slugify(city.name);
    final stateSlug = _slugify(city.stateName);
    return Uri.parse(
      'https://www.airbnb.com.br/s/$citySlug--$stateSlug/homes'
      '?tab_id=home_tab&refinement_paths[]=/homes'
      '&flexible_trip_lengths[]=${_durationParam(duration)}',
    );
  }

  static Uri buildBookingSearch(City city, TemporaryHousingDuration duration) {
    final cityEncoded = Uri.encodeComponent(city.name);
    final nights = switch (duration) {
      TemporaryHousingDuration.oneWeek => '7',
      TemporaryHousingDuration.oneMonth => '30',
      TemporaryHousingDuration.twoThreeMonths => '60',
    };

    return Uri.parse(
      'https://www.booking.com/searchresults.pt-br.html'
      '?ss=$cityEncoded&nflt=ht_id%3D220&group_adults=1&no_rooms=1&stay_nights=$nights',
    );
  }

  static Uri buildVivaRealTemporarySearch(
    City city,
    TemporaryHousingDuration duration,
  ) {
    final uf = city.stateCode.toLowerCase();
    final slug = _slugify(city.name);
    return Uri.parse('https://www.vivareal.com.br/aluguel/$uf/$slug/');
  }

  static Uri buildZapTemporarySearch(
    City city,
    TemporaryHousingDuration duration,
  ) {
    final uf = city.stateCode.toLowerCase();
    final slug = _slugify(city.name).replaceAll('-', '%2B');
    return Uri.parse('https://www.zapimoveis.com.br/aluguel/imoveis/$uf$slug/');
  }

  static String _durationParam(TemporaryHousingDuration duration) {
    return switch (duration) {
      TemporaryHousingDuration.oneWeek => 'weekend',
      TemporaryHousingDuration.oneMonth => 'one_month',
      TemporaryHousingDuration.twoThreeMonths => 'three_months',
    };
  }

  static final Uri susPortal = Uri.parse(
    'https://www.gov.br/saude/pt-br/composicao/sectics/daf/ceaf/faq/o-que-e-cns-cartao',
  );

  static final Uri ansPortal = Uri.parse('https://www.gov.br/ans/pt-br');

  static Uri buildDetranMapSearch(City city) {
    final query = Uri.encodeComponent('DETRAN ${city.name}');
    return Uri.parse('https://www.google.com/maps/search/$query');
  }

  static Uri buildUpaMapSearch(City city) {
    final query = Uri.encodeComponent('UPA ${city.name}');
    return Uri.parse('https://www.google.com/maps/search/$query');
  }

  static final Uri pfPortal = Uri.parse(
    'https://www.gov.br/pf/pt-br/assuntos/imigracao',
  );

  static final Uri pfScheduling = Uri.parse(
    'https://servicos.pf.gov.br/agenda-web/acessar',
  );

  static final Uri pfFaq = Uri.parse(
    'https://www.gov.br/pf/pt-br/assuntos/imigracao/pt/duvidas',
  );

  static final Uri pfRequestTracking = Uri.parse(
    'https://www.gov.br/pf/pt-br/assuntos/imigracao/outras-informacoes/consultar-requerimento',
  );

  static final Uri pfUnitDirectory = Uri.parse(
    'https://www.gov.br/pf/pt-br/assuntos/imigracao/declaracoes-e-formularios/TabelacircunscrioemailPF2026.pdf',
  );

  static const Map<String, FederalPoliceUnitContact> _pfUnitByCityId = {
    'sao-paulo-sp': FederalPoliceUnitContact(
      label: 'SR/PF/SP',
      email: 'migracao.srsp@pf.gov.br',
    ),
    'rio-de-janeiro-rj': FederalPoliceUnitContact(
      label: 'SR/PF/RJ',
      email: 'migracao.srrj@pf.gov.br',
    ),
    'armacao-dos-buzios-rj': FederalPoliceUnitContact(
      label: 'DPF/MCE/RJ',
      email: 'migracao.mce.rj@pf.gov.br',
    ),
    'arraial-do-cabo-rj': FederalPoliceUnitContact(
      label: 'DPF/MCE/RJ',
      email: 'migracao.mce.rj@pf.gov.br',
    ),
    'cabo-frio-rj': FederalPoliceUnitContact(
      label: 'DPF/MCE/RJ',
      email: 'migracao.mce.rj@pf.gov.br',
    ),
    'niteroi-rj': FederalPoliceUnitContact(
      label: 'DPF/NRI/RJ',
      email: 'migracao.nri.rj@pf.gov.br',
    ),
    'curitiba-pr': FederalPoliceUnitContact(
      label: 'SR/PF/PR',
      email: 'migracao.srpr@pf.gov.br',
    ),
    'foz-do-iguacu-pr': FederalPoliceUnitContact(
      label: 'DPF/FIG/PR',
      email: 'migracao.fig.pr@pf.gov.br',
    ),
    'florianopolis-sc': FederalPoliceUnitContact(
      label: 'SR/PF/SC',
      email: 'migracao.srsc@pf.gov.br',
    ),
    'balneario-camboriu-sc': FederalPoliceUnitContact(
      label: 'DPF/IJI/SC',
      email: 'migracao.iji.sc@pf.gov.br',
    ),
    'bombinhas-sc': FederalPoliceUnitContact(
      label: 'DPF/IJI/SC',
      email: 'migracao.iji.sc@pf.gov.br',
    ),
    'itajai-sc': FederalPoliceUnitContact(
      label: 'DPF/IJI/SC',
      email: 'migracao.iji.sc@pf.gov.br',
    ),
    'joinville-sc': FederalPoliceUnitContact(
      label: 'DPF/JVE/SC',
      email: 'migracao.jve.sc@pf.gov.br',
    ),
    'porto-alegre-rs': FederalPoliceUnitContact(
      label: 'SR/PF/RS',
      email: 'migracao.srrs@pf.gov.br',
    ),
    'maceio-al': FederalPoliceUnitContact(
      label: 'SR/PF/AL',
      email: 'migracao.sral@pf.gov.br',
    ),
    'maragogi-al': FederalPoliceUnitContact(
      label: 'SR/PF/AL',
      email: 'migracao.sral@pf.gov.br',
    ),
    'joao-pessoa-pb': FederalPoliceUnitContact(
      label: 'SR/PF/PB',
      email: 'migracao.srpb@pf.gov.br',
    ),
    'recife-pe': FederalPoliceUnitContact(
      label: 'SR/PF/PE',
      email: 'migracao.srpe@pf.gov.br',
    ),
    'natal-rn': FederalPoliceUnitContact(
      label: 'SR/PF/RN',
      email: 'migracao.srrn@pf.gov.br',
    ),
    'aracaju-se': FederalPoliceUnitContact(
      label: 'SR/PF/SE',
      email: 'migracao.srse@pf.gov.br',
    ),
    'goiania-go': FederalPoliceUnitContact(
      label: 'SR/PF/GO',
      email: 'migracao.srgo@pf.gov.br',
    ),
    'salvador-ba': FederalPoliceUnitContact(
      label: 'SR/PF/BA',
      email: 'migracao.srba@pf.gov.br',
    ),
    'porto-seguro-ba': FederalPoliceUnitContact(
      label: 'DPF/PSO/BA',
      email: 'migracao.pso.ba@pf.gov.br',
    ),
    'campo-grande-ms': FederalPoliceUnitContact(
      label: 'SR/PF/MS',
      email: 'migracao.srms@pf.gov.br',
    ),
  };

  static FederalPoliceUnitContact? resolvePfUnitContact(City city) {
    return _pfUnitByCityId[city.id];
  }

  static String _slugify(String value) {
    const accents = {
      'á': 'a',
      'à': 'a',
      'â': 'a',
      'ã': 'a',
      'ä': 'a',
      'é': 'e',
      'è': 'e',
      'ê': 'e',
      'ë': 'e',
      'í': 'i',
      'ì': 'i',
      'î': 'i',
      'ï': 'i',
      'ó': 'o',
      'ò': 'o',
      'ô': 'o',
      'õ': 'o',
      'ö': 'o',
      'ú': 'u',
      'ù': 'u',
      'û': 'u',
      'ü': 'u',
      'ç': 'c',
      'ñ': 'n',
    };

    final normalized = value
        .toLowerCase()
        .split('')
        .map((char) => accents[char] ?? char)
        .join();

    return normalized
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'-+'), '-')
        .replaceAll(RegExp(r'^-|-$'), '');
  }
}
