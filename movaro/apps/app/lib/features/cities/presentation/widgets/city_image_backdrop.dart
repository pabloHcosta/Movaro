import 'package:flutter/material.dart';
import 'package:movaro_app/app/theme/app_colors.dart';
import 'package:movaro_app/features/cities/domain/entities/city.dart';

class CityImageBackdrop extends StatelessWidget {
  const CityImageBackdrop({
    required this.city,
    required this.child,
    this.borderRadius = const BorderRadius.all(Radius.circular(24)),
    this.padding = const EdgeInsets.all(16),
    this.overlayOpacity = 0.84,
    super.key,
  });

  final City city;
  final Widget child;
  final BorderRadius borderRadius;
  final EdgeInsetsGeometry padding;
  final double overlayOpacity;

  @override
  Widget build(BuildContext context) {
    final imageUrl = cityImageUrlFor(city.id);
    final isDark = AppColors.isDark(context);
    final topOverlayAlpha = (overlayOpacity - (isDark ? 0.16 : 0.26)).clamp(
      0.0,
      1.0,
    );
    final bottomOverlayAlpha = (overlayOpacity - (isDark ? 0.0 : 0.14)).clamp(
      0.0,
      1.0,
    );
    final ambientTint = isDark
        ? const Color(0xFF07101C).withValues(alpha: 0.08)
        : Colors.white.withValues(alpha: 0.06);

    return ClipRRect(
      borderRadius: borderRadius,
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.heroStart.withValues(alpha: 0.95),
                    AppColors.heroMiddle.withValues(alpha: 0.9),
                    AppColors.heroEnd.withValues(alpha: 0.95),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          if (imageUrl != null)
            Positioned.fill(
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                headers: const {'User-Agent': 'Movaro/1.0'},
                filterQuality: FilterQuality.medium,
                errorBuilder: (_, _, _) => const SizedBox.shrink(),
              ),
            ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(
                      0xFF08111E,
                    ).withValues(alpha: topOverlayAlpha),
                    const Color(
                      0xFF08111E,
                    ).withValues(alpha: bottomOverlayAlpha),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(color: ambientTint),
            ),
          ),
          Padding(padding: padding, child: child),
        ],
      ),
    );
  }
}

class CityImageHeader extends StatelessWidget {
  const CityImageHeader({
    required this.city,
    this.height = 190,
    this.borderRadius = const BorderRadius.vertical(top: Radius.circular(24)),
    this.child,
    super.key,
  });

  final City city;
  final double height;
  final BorderRadius borderRadius;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final imageUrl = cityImageUrlFor(city.id);
    final isDark = AppColors.isDark(context);
    final layers = <Widget>[
      DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? const [
                    AppColors.heroStart,
                    AppColors.heroMiddle,
                    AppColors.heroEnd,
                  ]
                : const [
                    Color(0xFFE8F3FF),
                    Color(0xFFD9EBFF),
                    Color(0xFFC5E1FF),
                  ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      if (imageUrl != null)
        Image.network(
          imageUrl,
          fit: BoxFit.cover,
          headers: const {'User-Agent': 'Movaro/1.0'},
          filterQuality: FilterQuality.medium,
          errorBuilder: (_, _, _) => _CityImageFallback(city: city),
        )
      else
        _CityImageFallback(city: city),
      DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.transparent,
              const Color(0xFF07111F).withValues(alpha: 0.18),
              const Color(0xFF07111F).withValues(alpha: 0.58),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
      ),
    ];
    if (child != null) {
      layers.add(child!);
    }

    return ClipRRect(
      borderRadius: borderRadius,
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: layers,
        ),
      ),
    );
  }
}

class _CityImageFallback extends StatelessWidget {
  const _CityImageFallback({required this.city});

  final City city;

  @override
  Widget build(BuildContext context) {
    final initials = city.name
        .split(' ')
        .where((part) => part.isNotEmpty)
        .take(2)
        .map((part) => part.substring(0, 1).toUpperCase())
        .join();

    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF163457), Color(0xFF2A5F9E), Color(0xFF8AC0FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            top: -20,
            right: -10,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -30,
            left: -20,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Center(
            child: Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
              ),
              child: Center(
                child: Text(
                  initials.isEmpty
                      ? city.name.substring(0, 1).toUpperCase()
                      : initials,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String? cityImageUrlFor(String cityId) {
  const images = <String, String>{
    'florianopolis':
        'https://upload.wikimedia.org/wikipedia/commons/thumb/0/09/Morro_da_Cruz%2C_Florian%C3%B3polis_-_SC%2C_Brazil_-_panoramio_%28cropped%29.jpg/640px-Morro_da_Cruz%2C_Florian%C3%B3polis_-_SC%2C_Brazil_-_panoramio_%28cropped%29.jpg',
    'sao-paulo':
        'https://upload.wikimedia.org/wikipedia/commons/thumb/7/73/Marginal_Pinheiros_e_Jockey_Club.jpg/640px-Marginal_Pinheiros_e_Jockey_Club.jpg',
    'rio-de-janeiro':
        'https://upload.wikimedia.org/wikipedia/commons/thumb/9/98/Cidade_Maravilhosa.jpg/640px-Cidade_Maravilhosa.jpg',
    'armacao-dos-buzios':
        'https://upload.wikimedia.org/wikipedia/commons/thumb/0/0b/Vista_da_Igreja_de_Sant%27Anna_%28Arma%C3%A7%C3%A3o_dos_B%C3%BAzios%29.jpg/640px-Vista_da_Igreja_de_Sant%27Anna_%28Arma%C3%A7%C3%A3o_dos_B%C3%BAzios%29.jpg',
    'arraial-do-cabo':
        'https://upload.wikimedia.org/wikipedia/commons/thumb/3/31/Oven_S_Beach_Arraial_Do_Cabo_%28247765557%29.jpeg/640px-Oven_S_Beach_Arraial_Do_Cabo_%28247765557%29.jpeg',
    'cabo-frio':
        'https://upload.wikimedia.org/wikipedia/commons/thumb/b/b0/Cabo_Frio_-_vista_a%C3%A9rea.jpg/640px-Cabo_Frio_-_vista_a%C3%A9rea.jpg',
    'niteroi':
        'https://upload.wikimedia.org/wikipedia/commons/thumb/3/30/Museu_de_Arte_Contempor%C3%A2nea_by_Diego_Baravelli.jpg/640px-Museu_de_Arte_Contempor%C3%A2nea_by_Diego_Baravelli.jpg',
    'curitiba':
        'https://upload.wikimedia.org/wikipedia/commons/thumb/7/7a/Vista_a%C3%A9rea_de_Curitiba.jpg/640px-Vista_a%C3%A9rea_de_Curitiba.jpg',
    'foz-do-iguacu':
        'https://upload.wikimedia.org/wikipedia/commons/thumb/3/36/SkylineFoz.JPG/640px-SkylineFoz.JPG',
    'balneario-camboriu':
        'https://upload.wikimedia.org/wikipedia/commons/thumb/a/a4/Orla_da_Praia_Central%2C_Balne%C3%A1rio_Cambori%C3%BA_SC.JPG/640px-Orla_da_Praia_Central%2C_Balne%C3%A1rio_Cambori%C3%BA_SC.JPG',
    'bombinhas':
        'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c9/ColagemBombinhas2.png/640px-ColagemBombinhas2.png',
    'maceio':
        'https://upload.wikimedia.org/wikipedia/commons/thumb/f/f0/Ponta_Verde_Lighthouse_landscape_-_Macei%C3%B3%2C_Brazil_%28edited%29.jpg/640px-Ponta_Verde_Lighthouse_landscape_-_Macei%C3%B3%2C_Brazil_%28edited%29.jpg',
    'maragogi':
        'https://upload.wikimedia.org/wikipedia/commons/thumb/1/1d/Maragogi_Alagoas_Brasil.jpg/640px-Maragogi_Alagoas_Brasil.jpg',
    'recife':
        'https://upload.wikimedia.org/wikipedia/commons/thumb/8/82/Antonio_Vaz_island_-_Recife%2C_Pernambuco%2C_Brazil_%28cropped%29.jpg/640px-Antonio_Vaz_island_-_Recife%2C_Pernambuco%2C_Brazil_%28cropped%29.jpg',
    'natal':
        'https://upload.wikimedia.org/wikipedia/commons/thumb/b/b1/Natal%2C_capital_do_Rio_Grande_do_Norte%2C_Brasil.jpg/640px-Natal%2C_capital_do_Rio_Grande_do_Norte%2C_Brasil.jpg',
    'salvador':
        'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c0/Salvador_BA_%28cropped%29_2.jpg/640px-Salvador_BA_%28cropped%29_2.jpg',
    'porto-seguro':
        'https://upload.wikimedia.org/wikipedia/commons/thumb/5/5e/Porto_Seguro.1.jpg/640px-Porto_Seguro.1.jpg',
    'joinville':
        'https://upload.wikimedia.org/wikipedia/commons/thumb/6/66/Joinville%2C_Santa_Catarina%2C_Brazil.jpg/640px-Joinville%2C_Santa_Catarina%2C_Brazil.jpg',
    'itajai':
        'https://commons.wikimedia.org/wiki/Special:FilePath/Itaja%C3%AD%20-%20Santa%20Catarina.jpg?width=640',
    'porto-alegre':
        'https://upload.wikimedia.org/wikipedia/commons/thumb/3/38/Porto_Alegre_Skyline.jpg/640px-Porto_Alegre_Skyline.jpg',
    'joao-pessoa':
        'https://upload.wikimedia.org/wikipedia/commons/thumb/3/3b/Jo%C3%A3o_Pessoa%2C_Para%C3%ADba.jpg/640px-Jo%C3%A3o_Pessoa%2C_Para%C3%ADba.jpg',
    'aracaju':
        'https://upload.wikimedia.org/wikipedia/commons/thumb/7/77/Aracaju%2C_Sergipe%2C_Brasil.jpg/640px-Aracaju%2C_Sergipe%2C_Brasil.jpg',
    'goiania':
        'https://commons.wikimedia.org/wiki/Special:FilePath/Goi%C3%A2nia%20Skyline.JPG?width=640',
    'campo-grande':
        'https://commons.wikimedia.org/wiki/Special:FilePath/Vista%20de%20Campo%20Grande%20%28Mato%20Grosso%20do%20Sul%29.JPG?width=640',
    'santos':
        'https://upload.wikimedia.org/wikipedia/commons/thumb/5/53/Vista_de_Santos.jpg/640px-Vista_de_Santos.jpg',
    'ubatuba':
        'https://upload.wikimedia.org/wikipedia/commons/thumb/6/6b/20230725_084402.jpg/640px-20230725_084402.jpg',
    'paraty':
        'https://upload.wikimedia.org/wikipedia/commons/thumb/b/be/Paraty_05.JPG/640px-Paraty_05.JPG',
    'tibau-do-sul':
        'https://upload.wikimedia.org/wikipedia/commons/thumb/3/39/PipaBeachView.JPG/1920px-PipaBeachView.JPG',
    'jijoca-de-jericoacoara':
        'https://upload.wikimedia.org/wikipedia/commons/thumb/1/1d/Jericoacoara_-_Duna_do_Por_do_Sol_-_PARQUE_NACIONAL_DE_JERICOACOARA_-_1.jpg/960px-Jericoacoara_-_Duna_do_Por_do_Sol_-_PARQUE_NACIONAL_DE_JERICOACOARA_-_1.jpg',
    'ilhabela':
        'https://upload.wikimedia.org/wikipedia/commons/thumb/d/d1/Sunset_View_-_Ilhabela.jpg/640px-Sunset_View_-_Ilhabela.jpg',
    'guaruja':
        'https://upload.wikimedia.org/wikipedia/commons/thumb/2/2d/ROGERIO_CASSIMIRO_morro_da_caixa_dagua_GUARUJA_SP_%2827787693658%29.jpg/640px-ROGERIO_CASSIMIRO_morro_da_caixa_dagua_GUARUJA_SP_%2827787693658%29.jpg',
    'garopaba':
        'https://upload.wikimedia.org/wikipedia/commons/thumb/4/46/0_04192022IMG_024626487.jpg/640px-0_04192022IMG_024626487.jpg',
    'imbituba':
        'https://upload.wikimedia.org/wikipedia/commons/thumb/d/d6/Porto_de_imbituba.jpg/640px-Porto_de_imbituba.jpg',
    'itacare':
        'https://upload.wikimedia.org/wikipedia/commons/thumb/d/df/MARCIO_FILHO_ITACARE_CIDADE_ITACARE_BAHIA_%2840933336562%29.jpg/640px-MARCIO_FILHO_ITACARE_CIDADE_ITACARE_BAHIA_%2840933336562%29.jpg',
    'sao-miguel-do-gostoso':
        'https://upload.wikimedia.org/wikipedia/commons/thumb/5/59/S%C3%A3o_Miguel_do_Gostoso%2C_Rio_Grande_do_Norte.jpg/1920px-S%C3%A3o_Miguel_do_Gostoso%2C_Rio_Grande_do_Norte.jpg',
    'cairu':
        'https://upload.wikimedia.org/wikipedia/commons/thumb/b/ba/Morro1.jpg/640px-Morro1.jpg',
  };

  for (final key in _cityImageLookupKeys(cityId)) {
    final image = images[key];
    if (image != null) {
      return _wikimediaImageUrl(image);
    }
  }

  return null;
}

String _wikimediaImageUrl(String sourceUrl, {int width = 640}) {
  final uri = Uri.parse(sourceUrl);
  if (uri.host == 'commons.wikimedia.org' &&
      uri.pathSegments.length >= 3 &&
      uri.pathSegments[0] == 'wiki' &&
      uri.pathSegments[1] == 'Special:FilePath') {
    return sourceUrl;
  }

  var fileName = uri.pathSegments.isEmpty ? '' : uri.pathSegments.last;
  final sizedMatch = RegExp(r'^\d+px-(.+)$').firstMatch(fileName);
  if (sizedMatch != null) {
    fileName = sizedMatch.group(1)!;
  }

  return Uri(
    scheme: 'https',
    host: 'commons.wikimedia.org',
    pathSegments: ['wiki', 'Special:FilePath', fileName],
    queryParameters: {'width': '$width'},
  ).toString();
}

Iterable<String> _cityImageLookupKeys(String cityId) sync* {
  final normalized = cityId.trim().toLowerCase().replaceAll('_', '-');
  yield normalized;

  final parts = normalized.split('-');
  if (parts.length > 1 && parts.last.length == 2) {
    yield parts.sublist(0, parts.length - 1).join('-');
  }
}
