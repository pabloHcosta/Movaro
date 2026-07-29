import 'package:flutter/material.dart';
import 'package:movaro_app/app/presentation/pages/trust_and_support_page.dart';
import 'package:movaro_app/app/router/app_routes.dart';
import 'package:movaro_app/app/theme/app_colors.dart';
import 'package:movaro_app/core/responsive/responsive_context.dart';
import 'package:movaro_app/core/widgets/ambient_background.dart';
import 'package:movaro_app/core/widgets/app_glass_header.dart';
import 'package:movaro_app/core/widgets/frosted_panel.dart';
import 'package:movaro_app/features/cities/application/cities_controller.dart';
import 'package:movaro_app/features/home/presentation/widgets/main_navigation_bar.dart';
import 'package:movaro_app/features/journey/journey_context_controller.dart';
import 'package:movaro_app/features/migration_questionnaire/application/migration_questionnaire_controller.dart';

String _moreText(
  BuildContext context, {
  required String pt,
  required String es,
  required String en,
}) {
  return switch (Localizations.localeOf(context).languageCode) {
    'pt' => pt,
    'es' => es,
    _ => en,
  };
}

class MorePage extends StatelessWidget {
  const MorePage({
    required this.journeyContextController,
    required this.citiesController,
    required this.migrationQuestionnaireController,
    super.key,
  });

  final JourneyContextController journeyContextController;
  final CitiesController citiesController;
  final MigrationQuestionnaireController migrationQuestionnaireController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          const AmbientBackground(),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: ListView(
                  padding: EdgeInsets.fromLTRB(
                    context.pageHorizontalPadding,
                    context.pageVerticalPadding,
                    context.pageHorizontalPadding,
                    34,
                  ),
                  children: [
                    AppGlassHeader(
                      title: _moreText(
                        context,
                        pt: 'Mais',
                        es: 'Más',
                        en: 'More',
                      ),
                      subtitle: _moreText(
                        context,
                        pt: 'Preferências, itens salvos e suporte',
                        es: 'Preferencias, elementos guardados y soporte',
                        en: 'Preferences, saved items, and support',
                      ),
                    ),
                    const SizedBox(height: 18),
                    _MoreSection(
                      title: _moreText(
                        context,
                        pt: 'Seu aplicativo',
                        es: 'Tu aplicación',
                        en: 'Your app',
                      ),
                      children: [
                        _MoreDestinationTile(
                          icon: Icons.settings_outlined,
                          tone: AppColors.primary,
                          title: _moreText(
                            context,
                            pt: 'Configurações',
                            es: 'Configuración',
                            en: 'Settings',
                          ),
                          body: _moreText(
                            context,
                            pt: 'Idioma, aparência, moeda, localização e privacidade.',
                            es: 'Idioma, apariencia, moneda, ubicación y privacidad.',
                            en: 'Language, appearance, currency, location, and privacy.',
                          ),
                          onTap: () =>
                              Navigator.pushNamed(context, AppRoutes.settings),
                        ),
                        _MoreDestinationTile(
                          icon: Icons.favorite_outline_rounded,
                          tone: const Color(0xFFE34D7B),
                          title: _moreText(
                            context,
                            pt: 'Cidades favoritas',
                            es: 'Ciudades favoritas',
                            en: 'Favorite cities',
                          ),
                          body: _moreText(
                            context,
                            pt: '${citiesController.favoriteCities.length} de ${CitiesController.maxFavoriteCities} cidades salvas.',
                            es: '${citiesController.favoriteCities.length} de ${CitiesController.maxFavoriteCities} ciudades guardadas.',
                            en: '${citiesController.favoriteCities.length} of ${CitiesController.maxFavoriteCities} cities saved.',
                          ),
                          onTap: () =>
                              Navigator.pushNamed(context, AppRoutes.favorites),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _MoreSection(
                      title: _moreText(
                        context,
                        pt: 'Ajuda e confiança',
                        es: 'Ayuda y confianza',
                        en: 'Help and trust',
                      ),
                      children: [
                        _MoreDestinationTile(
                          icon: Icons.verified_user_outlined,
                          tone: AppColors.success,
                          title: _moreText(
                            context,
                            pt: 'Confiança e apoio oficial',
                            es: 'Confianza y apoyo oficial',
                            en: 'Trust and official support',
                          ),
                          body: _moreText(
                            context,
                            pt: 'Entenda as fontes, limites e canais oficiais usados pelo Movaro.',
                            es: 'Entiende las fuentes, límites y canales oficiales usados por Movaro.',
                            en: 'Understand Movaro sources, limits, and official channels.',
                          ),
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => const TrustAndSupportPage(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: MainNavigationBar(
        currentIndex: 4,
        journeyContextController: journeyContextController,
        citiesController: citiesController,
        migrationQuestionnaireController: migrationQuestionnaireController,
      ),
    );
  }
}

class _MoreSection extends StatelessWidget {
  const _MoreSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: AppColors.textSoftFor(context),
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        FrostedPanel(
          padding: EdgeInsets.zero,
          borderRadius: BorderRadius.circular(22),
          child: Column(
            children: [
              for (var index = 0; index < children.length; index++) ...[
                children[index],
                if (index < children.length - 1)
                  Divider(
                    height: 1,
                    indent: 66,
                    color: AppColors.borderFor(context),
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _MoreDestinationTile extends StatelessWidget {
  const _MoreDestinationTile({
    required this.icon,
    required this.tone,
    required this.title,
    required this.body,
    required this.onTap,
  });

  final IconData icon;
  final Color tone;
  final String title;
  final String body;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      minTileHeight: 72,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: tone.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(13),
        ),
        child: Icon(icon, color: tone, size: 21),
      ),
      title: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
      ),
      subtitle: Text(
        body,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: AppColors.textSoftFor(context),
          height: 1.35,
        ),
      ),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
    );
  }
}
