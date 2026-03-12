import 'package:flutter/material.dart';
import 'package:movaro_app/app/theme/app_colors.dart';
import 'package:movaro_app/features/cities/domain/entities/city.dart';

class CityImageBackdrop extends StatelessWidget {
  const CityImageBackdrop({
    required this.city,
    required this.child,
    this.borderRadius = const BorderRadius.all(Radius.circular(24)),
    this.padding = const EdgeInsets.all(16),
    this.overlayOpacity = 0.72,
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

    return ClipRRect(
      borderRadius: borderRadius,
      child: Stack(
        fit: StackFit.expand,
        children: [
          DecoratedBox(
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
          if (imageUrl != null)
            Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => const SizedBox.shrink(),
            ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF08111E).withValues(alpha: overlayOpacity - 0.12),
                  const Color(0xFF08111E).withValues(alpha: overlayOpacity),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Padding(padding: padding, child: child),
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
  };

  return images[cityId];
}
