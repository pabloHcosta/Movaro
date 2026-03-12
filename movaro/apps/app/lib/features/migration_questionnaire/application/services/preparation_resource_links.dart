import 'package:movaro_app/features/cities/domain/entities/city.dart';

enum RentalProvider { zapImoveis, vivaReal, chavesNaMao }

class PreparationResourceLinks {
  const PreparationResourceLinks._();

  static final Uri officialJobsPortal = Uri.parse(
    'https://servicos.mte.gov.br/spme-v2/#/login',
  );

  static final Uri publicUniversitiesCatalog = Uri.parse(
    'https://emec.mec.gov.br/',
  );

  static final Uri foreignStudentGuide = Uri.parse(
    'https://www.gov.br/mre/pt-br/assuntos/cultura-e-educacao/temas-educacionais/programa-de-estudantes-convenio-de-graduacao-pec-g',
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

  static final Uri argentinaResidenceAgreement = Uri.parse(
    'https://www.gov.br/pf/pt-br/assuntos/imigracao/autorizacao-residencia/acordo-de-residencia-brasil-e-argentina',
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

  static final Uri rentalScamAlert = Uri.parse(
    'https://www.comunicacao.pr.gov.br/noticias/aen/42be055d-f9d9-48bc-a40d-9736e9e21cbf',
  );

  static final Uri traffickingAlert = Uri.parse(
    'https://www.gov.br/mj/pt-br/assuntos/noticias/governo-federal-alerta-para-risco-de-trafico-de-brasileiros-atraidos-por-ofertas-de-trabalho-no-sudeste-asiatico',
  );

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

  static Uri buildRentalSearch(City city, RentalProvider provider) {
    final state = city.stateCode.toLowerCase();
    final plusCity = _slugify(city.name).replaceAll('-', '+');
    final hyphenCity = _slugify(city.name);

    return switch (provider) {
      RentalProvider.zapImoveis => Uri.parse(
        'https://www.zapimoveis.com.br/aluguel/imoveis/$state+$plusCity/',
      ),
      RentalProvider.vivaReal => Uri.parse(
        'https://www.vivareal.com.br/aluguel/imoveis/$state+$plusCity/',
      ),
      RentalProvider.chavesNaMao => Uri.parse(
        'https://www.chavesnamao.com.br/imoveis-para-alugar/$state-$hyphenCity/',
      ),
    };
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
