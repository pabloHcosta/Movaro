import 'package:flutter/material.dart';
import 'package:movaro_app/app/theme/app_colors.dart';
import 'package:movaro_app/core/responsive/responsive_context.dart';
import 'package:movaro_app/core/widgets/ambient_background.dart';
import 'package:movaro_app/core/widgets/app_glass_header.dart';
import 'package:movaro_app/core/widgets/frosted_panel.dart';
import 'package:movaro_app/features/safety_check/domain/proposal_safety_analyzer.dart';
import 'package:url_launcher/url_launcher.dart';

String _safetyText(
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

class ProposalSafetyCheckPage extends StatefulWidget {
  const ProposalSafetyCheckPage({this.cityName, super.key});

  final String? cityName;

  @override
  State<ProposalSafetyCheckPage> createState() =>
      _ProposalSafetyCheckPageState();
}

class _ProposalSafetyCheckPageState extends State<ProposalSafetyCheckPage> {
  final _controller = TextEditingController();
  ProposalKind _kind = ProposalKind.housing;
  ProposalSafetyAnalysis? _analysis;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _analyze() {
    FocusScope.of(context).unfocus();
    setState(() {
      _analysis = ProposalSafetyAnalyzer.analyze(
        kind: _kind,
        content: _controller.text,
      );
    });
  }

  void _reset() {
    _controller.clear();
    setState(() {
      _analysis = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundFor(context),
      body: Stack(
        children: [
          const Positioned.fill(child: AmbientBackground()),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: ListView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: EdgeInsets.fromLTRB(
                    context.pageHorizontalPadding,
                    8,
                    context.pageHorizontalPadding,
                    32,
                  ),
                  children: [
                    AppGlassHeader(
                      title: _safetyText(
                        context,
                        pt: 'Radar Movaro',
                        es: 'Radar Movaro',
                        en: 'Movaro Radar',
                      ),
                      subtitle: widget.cityName == null
                          ? _safetyText(
                              context,
                              pt: 'Triagem de propostas',
                              es: 'Revisión de propuestas',
                              en: 'Offer safety check',
                            )
                          : _safetyText(
                              context,
                              pt: 'Proteção para sua chegada em ${widget.cityName}',
                              es: 'Protección para tu llegada a ${widget.cityName}',
                              en: 'Protection for your arrival in ${widget.cityName}',
                            ),
                      onBack: () => Navigator.of(context).pop(),
                      trailing: _analysis == null
                          ? null
                          : IconButton(
                              onPressed: _reset,
                              tooltip: _safetyText(
                                context,
                                pt: 'Nova análise',
                                es: 'Nuevo análisis',
                                en: 'New check',
                              ),
                              icon: const Icon(Icons.refresh_rounded),
                            ),
                    ),
                    const SizedBox(height: 18),
                    _SafetyHero(cityName: widget.cityName),
                    const SizedBox(height: 18),
                    _PrivacyBanner(),
                    const SizedBox(height: 18),
                    _KindSelector(
                      value: _kind,
                      onChanged: (value) {
                        setState(() {
                          _kind = value;
                          _analysis = null;
                        });
                      },
                    ),
                    const SizedBox(height: 14),
                    FrostedPanel(
                      padding: const EdgeInsets.all(16),
                      borderRadius: BorderRadius.circular(22),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _inputTitle(context, _kind),
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            _safetyText(
                              context,
                              pt: 'Cole a mensagem, descrição ou condições recebidas. Remova nomes e dados pessoais antes de analisar.',
                              es: 'Pega el mensaje, la descripción o las condiciones recibidas. Quita nombres y datos personales antes de analizar.',
                              en: 'Paste the message, description, or terms you received. Remove names and personal details first.',
                            ),
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: AppColors.textSoftFor(context),
                                  height: 1.4,
                                ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _controller,
                            minLines: 6,
                            maxLines: 12,
                            textCapitalization: TextCapitalization.sentences,
                            onChanged: (_) {
                              setState(() {
                                _analysis = null;
                              });
                            },
                            decoration: InputDecoration(
                              hintText: _inputHint(context, _kind),
                              alignLabelWithHint: true,
                              filled: true,
                              fillColor: AppColors.surfaceMutedFor(context),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(
                                  color: AppColors.borderFor(context),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(
                                  color: AppColors.borderFor(context),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              onPressed: _controller.text.trim().isEmpty
                                  ? null
                                  : _analyze,
                              icon: const Icon(Icons.policy_outlined, size: 19),
                              label: Text(
                                _safetyText(
                                  context,
                                  pt: 'Analisar sinais',
                                  es: 'Analizar señales',
                                  en: 'Check warning signs',
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_analysis != null) ...[
                      const SizedBox(height: 18),
                      _AnalysisResult(analysis: _analysis!),
                    ],
                    const SizedBox(height: 18),
                    _OfficialSources(kind: _kind),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SafetyHero extends StatelessWidget {
  const _SafetyHero({required this.cityName});

  final String? cityName;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF09283D), Color(0xFF075C74), Color(0xFF078A83)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF087F7A).withValues(alpha: 0.22),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(17),
            ),
            child: const Icon(
              Icons.radar_rounded,
              color: Colors.white,
              size: 27,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _safetyText(
                    context,
                    pt: 'Antes de pagar ou enviar documentos',
                    es: 'Antes de pagar o enviar documentos',
                    en: 'Before you pay or share documents',
                  ),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _safetyText(
                    context,
                    pt: 'Encontre sinais conhecidos de fraude e receba um próximo passo seguro, sem uma falsa promessa de que a proposta é legítima.',
                    es: 'Encuentra señales conocidas de fraude y recibe un próximo paso seguro, sin la falsa promesa de que la propuesta es legítima.',
                    en: 'Find known fraud signals and get a safer next step without a false promise that an offer is legitimate.',
                  ),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.88),
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PrivacyBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.20)),
      ),
      child: Row(
        children: [
          const Icon(Icons.lock_outline_rounded, color: AppColors.success),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _safetyText(
                context,
                pt: 'Análise privada: o texto é processado neste aparelho e não é enviado nem salvo.',
                es: 'Análisis privado: el texto se procesa en este dispositivo y no se envía ni se guarda.',
                en: 'Private analysis: the text is processed on this device and is not sent or saved.',
              ),
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _KindSelector extends StatelessWidget {
  const _KindSelector({required this.value, required this.onChanged});

  final ProposalKind value;
  final ValueChanged<ProposalKind> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<ProposalKind>(
      segments: [
        ButtonSegment(
          value: ProposalKind.housing,
          icon: const Icon(Icons.home_work_outlined),
          label: Text(
            _safetyText(context, pt: 'Moradia', es: 'Vivienda', en: 'Housing'),
          ),
        ),
        ButtonSegment(
          value: ProposalKind.job,
          icon: const Icon(Icons.work_outline_rounded),
          label: Text(
            _safetyText(context, pt: 'Trabalho', es: 'Trabajo', en: 'Job'),
          ),
        ),
        ButtonSegment(
          value: ProposalKind.publicService,
          icon: const Icon(Icons.badge_outlined),
          label: Text(
            _safetyText(context, pt: 'Serviço', es: 'Servicio', en: 'Service'),
          ),
        ),
      ],
      selected: {value},
      showSelectedIcon: false,
      onSelectionChanged: (selection) => onChanged(selection.first),
    );
  }
}

class _AnalysisResult extends StatelessWidget {
  const _AnalysisResult({required this.analysis});

  final ProposalSafetyAnalysis analysis;

  @override
  Widget build(BuildContext context) {
    final tone = switch (analysis.level) {
      ProposalSafetyLevel.stopAndVerify => AppColors.danger,
      ProposalSafetyLevel.caution => AppColors.warning,
      ProposalSafetyLevel.noStrongSignal => AppColors.success,
    };
    final icon = switch (analysis.level) {
      ProposalSafetyLevel.stopAndVerify => Icons.front_hand_rounded,
      ProposalSafetyLevel.caution => Icons.search_rounded,
      ProposalSafetyLevel.noStrongSignal => Icons.shield_outlined,
    };
    return Semantics(
      liveRegion: true,
      child: FrostedPanel(
        padding: const EdgeInsets.all(18),
        borderRadius: BorderRadius.circular(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: tone.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(icon, color: tone),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _levelTitle(context, analysis.level),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: tone,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _levelBody(context, analysis.level),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSoftFor(context),
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (analysis.signals.isNotEmpty) ...[
              const SizedBox(height: 18),
              Text(
                _safetyText(
                  context,
                  pt: 'Sinais encontrados',
                  es: 'Señales encontradas',
                  en: 'Signals found',
                ),
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 9),
              for (final signal in analysis.signals) ...[
                _SignalRow(signal: signal),
                const SizedBox(height: 8),
              ],
            ],
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.tintedSurfaceFor(
                  context,
                  tint: AppColors.primary,
                  lightColor: const Color(0xFFF2F7FF),
                ),
                borderRadius: BorderRadius.circular(17),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _safetyText(
                      context,
                      pt: 'Próximo passo mais seguro',
                      es: 'Próximo paso más seguro',
                      en: 'Safer next step',
                    ),
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    _nextStep(context, analysis),
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(height: 1.45),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _safetyText(
                context,
                pt: 'O Radar identifica padrões conhecidos, não confirma identidade, propriedade do imóvel ou legitimidade da proposta.',
                es: 'El Radar identifica patrones conocidos; no confirma identidad, propiedad del inmueble ni legitimidad de la propuesta.',
                en: 'Radar identifies known patterns; it does not confirm identity, property ownership, or offer legitimacy.',
              ),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSoftFor(context),
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SignalRow extends StatelessWidget {
  const _SignalRow({required this.signal});

  final ProposalSafetySignal signal;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceMutedFor(context),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.borderFor(context)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            signal.critical
                ? Icons.error_outline_rounded
                : Icons.info_outline_rounded,
            size: 19,
            color: signal.critical ? AppColors.danger : AppColors.warning,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _signalTitle(context, signal.code),
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 3),
                Text(
                  _signalBody(context, signal.code),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSoftFor(context),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OfficialSources extends StatelessWidget {
  const _OfficialSources({required this.kind});

  final ProposalKind kind;

  @override
  Widget build(BuildContext context) {
    final sources = <({String label, String url})>[
      if (kind == ProposalKind.housing)
        (
          label: 'CRECI-MS · falso aluguel',
          url: 'https://www.crecims.gov.br/noticia.php?id=1801',
        ),
      if (kind == ProposalKind.job)
        (
          label: 'Polícia Civil · falso emprego',
          url:
              'https://www.pc.ms.gov.br/dica-da-policia-civil-fique-atento-para-o-golpe-do-falso-emprego/',
        ),
      if (kind == ProposalKind.publicService)
        (
          label: 'Governo Federal · golpes digitais',
          url:
              'https://www.gov.br/cisc/pt-br/alertas-de-golpes-digitais/falso-programa-de-cnh-cobra-taxa-via-pix',
        ),
      (
        label: 'CERT.br · evite fraudes',
        url: 'https://cartilha.cert.br/fasciculos/',
      ),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _safetyText(
            context,
            pt: 'Base de segurança',
            es: 'Base de seguridad',
            en: 'Safety sources',
          ),
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 5),
        Text(
          _safetyText(
            context,
            pt: 'Os sinais foram transformados em regras explicáveis a partir destas orientações.',
            es: 'Las señales se transformaron en reglas explicables a partir de estas orientaciones.',
            en: 'These signals were turned into explainable rules from the guidance below.',
          ),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.textSoftFor(context),
            height: 1.4,
          ),
        ),
        const SizedBox(height: 10),
        for (final source in sources)
          ListTile(
            contentPadding: EdgeInsets.zero,
            minTileHeight: 48,
            leading: const Icon(Icons.verified_user_outlined),
            title: Text(source.label),
            trailing: const Icon(Icons.open_in_new_rounded, size: 18),
            onTap: () => launchUrl(
              Uri.parse(source.url),
              mode: LaunchMode.externalApplication,
            ),
          ),
      ],
    );
  }
}

String _inputTitle(BuildContext context, ProposalKind kind) {
  return switch (kind) {
    ProposalKind.housing => _safetyText(
      context,
      pt: 'O que o anunciante ou corretor enviou?',
      es: '¿Qué te envió el anunciante o corredor?',
      en: 'What did the advertiser or agent send?',
    ),
    ProposalKind.job => _safetyText(
      context,
      pt: 'O que a empresa ou recrutador enviou?',
      es: '¿Qué te envió la empresa o el reclutador?',
      en: 'What did the company or recruiter send?',
    ),
    ProposalKind.publicService => _safetyText(
      context,
      pt: 'O que o suposto atendimento enviou?',
      es: '¿Qué te envió el supuesto servicio?',
      en: 'What did the supposed service send?',
    ),
  };
}

String _inputHint(BuildContext context, ProposalKind kind) {
  return switch (kind) {
    ProposalKind.housing => _safetyText(
      context,
      pt: 'Ex.: “Para reservar o imóvel, faça um PIX antes da visita...”',
      es: 'Ej.: “Para reservar el inmueble, haz un PIX antes de la visita...”',
      en: 'Example: “To reserve the property, send a PIX before viewing...”',
    ),
    ProposalKind.job => _safetyText(
      context,
      pt: 'Ex.: “A vaga é garantida após pagar a taxa do treinamento...”',
      es: 'Ej.: “El puesto está garantizado después de pagar la capacitación...”',
      en: 'Example: “The job is guaranteed after you pay the training fee...”',
    ),
    ProposalKind.publicService => _safetyText(
      context,
      pt: 'Ex.: “Envie o código recebido e pague a taxa por este link...”',
      es: 'Ej.: “Envía el código recibido y paga la tasa en este enlace...”',
      en: 'Example: “Send the code you received and pay the fee through this link...”',
    ),
  };
}

String _levelTitle(BuildContext context, ProposalSafetyLevel level) {
  return switch (level) {
    ProposalSafetyLevel.stopAndVerify => _safetyText(
      context,
      pt: 'Pare e verifique',
      es: 'Detente y verifica',
      en: 'Stop and verify',
    ),
    ProposalSafetyLevel.caution => _safetyText(
      context,
      pt: 'Atenção antes de continuar',
      es: 'Atención antes de continuar',
      en: 'Check before continuing',
    ),
    ProposalSafetyLevel.noStrongSignal => _safetyText(
      context,
      pt: 'Nenhum sinal forte encontrado',
      es: 'No se encontraron señales fuertes',
      en: 'No strong signal found',
    ),
  };
}

String _levelBody(BuildContext context, ProposalSafetyLevel level) {
  return switch (level) {
    ProposalSafetyLevel.stopAndVerify => _safetyText(
      context,
      pt: 'A mensagem contém um ou mais padrões associados a golpes conhecidos. Não pague nem envie dados até verificar por outro canal.',
      es: 'El mensaje contiene uno o más patrones asociados a fraudes conocidos. No pagues ni envíes datos hasta verificar por otro canal.',
      en: 'The message contains one or more patterns associated with known scams. Do not pay or share data until you verify through another channel.',
    ),
    ProposalSafetyLevel.caution => _safetyText(
      context,
      pt: 'Há elementos que merecem confirmação independente antes de avançar.',
      es: 'Hay elementos que merecen una confirmación independiente antes de avanzar.',
      en: 'Some elements deserve independent verification before you continue.',
    ),
    ProposalSafetyLevel.noStrongSignal => _safetyText(
      context,
      pt: 'O texto não acionou as regras atuais. Isso não prova que a proposta seja segura.',
      es: 'El texto no activó las reglas actuales. Esto no prueba que la propuesta sea segura.',
      en: 'The text did not trigger the current rules. This does not prove the offer is safe.',
    ),
  };
}

String _nextStep(BuildContext context, ProposalSafetyAnalysis analysis) {
  return switch (analysis.kind) {
    ProposalKind.housing => _safetyText(
      context,
      pt: 'Confirme o anunciante por um canal independente, verifique o CRECI quando houver corretor, visite ou faça videochamada e peça contrato antes de qualquer pagamento.',
      es: 'Confirma al anunciante por un canal independiente, verifica el CRECI si hay corredor, visita o haz videollamada y pide contrato antes de pagar.',
      en: 'Confirm the advertiser through an independent channel, check CRECI when an agent is involved, view the property or video call, and request a contract before paying.',
    ),
    ProposalKind.job => _safetyText(
      context,
      pt: 'Procure a vaga no site oficial da empresa e fale com o RH por um contato encontrado por você. Não pague para participar ou ser contratado.',
      es: 'Busca la vacante en el sitio oficial de la empresa y habla con RR. HH. por un contacto que tú encuentres. No pagues para participar o ser contratado.',
      en: 'Find the role on the company’s official site and contact HR through a channel you found yourself. Do not pay to apply or be hired.',
    ),
    ProposalKind.publicService => _safetyText(
      context,
      pt: 'Feche o link recebido e abra o serviço digitando gov.br no navegador ou usando o aplicativo oficial. Nunca compartilhe senha ou código de verificação.',
      es: 'Cierra el enlace recibido y abre el servicio escribiendo gov.br en el navegador o usando la aplicación oficial. Nunca compartas contraseña ni código.',
      en: 'Close the received link and open the service by typing gov.br in the browser or using the official app. Never share a password or verification code.',
    ),
  };
}

String _signalTitle(BuildContext context, ProposalSafetySignalCode code) {
  return switch (code) {
    ProposalSafetySignalCode.advancePayment => _safetyText(
      context,
      pt: 'Pagamento antecipado',
      es: 'Pago anticipado',
      en: 'Advance payment',
    ),
    ProposalSafetySignalCode.pressure => _safetyText(
      context,
      pt: 'Pressão para decidir rápido',
      es: 'Presión para decidir rápido',
      en: 'Pressure to act quickly',
    ),
    ProposalSafetySignalCode.credentialRequest => _safetyText(
      context,
      pt: 'Pedido de senha ou código',
      es: 'Solicitud de contraseña o código',
      en: 'Password or code request',
    ),
    ProposalSafetySignalCode.personalDataRequest => _safetyText(
      context,
      pt: 'Dados sensíveis antes da verificação',
      es: 'Datos sensibles antes de verificar',
      en: 'Sensitive data before verification',
    ),
    ProposalSafetySignalCode.housingWithoutVerification => _safetyText(
      context,
      pt: 'Imóvel sem verificação ou contrato',
      es: 'Inmueble sin verificación o contrato',
      en: 'Property without verification or contract',
    ),
    ProposalSafetySignalCode.housingBelowMarket => _safetyText(
      context,
      pt: 'Preço apresentado como muito abaixo do mercado',
      es: 'Precio presentado muy por debajo del mercado',
      en: 'Price presented as far below market',
    ),
    ProposalSafetySignalCode.jobFee => _safetyText(
      context,
      pt: 'Cobrança para conseguir a vaga',
      es: 'Cobro para conseguir el puesto',
      en: 'Fee to get the job',
    ),
    ProposalSafetySignalCode.jobEasyMoney => _safetyText(
      context,
      pt: 'Promessa de ganho fácil ou garantido',
      es: 'Promesa de ingreso fácil o garantizado',
      en: 'Easy or guaranteed income promise',
    ),
    ProposalSafetySignalCode.unofficialPublicChannel => _safetyText(
      context,
      pt: 'Serviço público com cobrança por canal informal',
      es: 'Servicio público con cobro por canal informal',
      en: 'Public service charging through an informal channel',
    ),
  };
}

String _signalBody(BuildContext context, ProposalSafetySignalCode code) {
  return switch (code) {
    ProposalSafetySignalCode.advancePayment => _safetyText(
      context,
      pt: 'Golpes de aluguel e serviços frequentemente usam PIX ou depósito antes de verificação e contrato.',
      es: 'Los fraudes de alquiler y servicios suelen pedir PIX o depósito antes de verificar y contratar.',
      en: 'Housing and service scams often request PIX or a deposit before verification and a contract.',
    ),
    ProposalSafetySignalCode.pressure => _safetyText(
      context,
      pt: 'Urgência artificial reduz o tempo disponível para conferir identidade, canal e condições.',
      es: 'La urgencia artificial reduce el tiempo para comprobar identidad, canal y condiciones.',
      en: 'Artificial urgency reduces the time available to verify identity, channel, and terms.',
    ),
    ProposalSafetySignalCode.credentialRequest => _safetyText(
      context,
      pt: 'Senhas, tokens e códigos de SMS permitem acesso à sua conta e não devem ser compartilhados.',
      es: 'Contraseñas, tokens y códigos SMS permiten acceder a tu cuenta y no deben compartirse.',
      en: 'Passwords, tokens, and SMS codes can provide account access and must not be shared.',
    ),
    ProposalSafetySignalCode.personalDataRequest => _safetyText(
      context,
      pt: 'A solicitação ocorre antes de você confirmar de forma independente quem está do outro lado.',
      es: 'La solicitud ocurre antes de confirmar de forma independiente quién está del otro lado.',
      en: 'The request happens before you independently confirm who is on the other side.',
    ),
    ProposalSafetySignalCode.housingWithoutVerification => _safetyText(
      context,
      pt: 'Recusar visita, videochamada ou contrato impede confirmar o imóvel e a relação do anunciante com ele.',
      es: 'Rechazar visita, videollamada o contrato impide confirmar el inmueble y la relación del anunciante.',
      en: 'Refusing a viewing, video call, or contract prevents verification of the property and advertiser.',
    ),
    ProposalSafetySignalCode.housingBelowMarket => _safetyText(
      context,
      pt: 'Preço excepcional pode ser usado para provocar pressa e antecipar um pagamento.',
      es: 'Un precio excepcional puede usarse para generar prisa y anticipar un pago.',
      en: 'An exceptional price can be used to create urgency and prompt an advance payment.',
    ),
    ProposalSafetySignalCode.jobFee => _safetyText(
      context,
      pt: 'A Polícia Civil orienta evitar vagas que cobram inscrição, curso ou treinamento para contratar.',
      es: 'La Policía Civil recomienda evitar vacantes que cobran inscripción, curso o capacitación para contratar.',
      en: 'Civil Police guidance says to avoid jobs charging an application, course, or training fee to hire.',
    ),
    ProposalSafetySignalCode.jobEasyMoney => _safetyText(
      context,
      pt: 'Golpes de falso emprego costumam combinar tarefas simples com remuneração muito atraente.',
      es: 'Los fraudes de falso empleo suelen combinar tareas simples con remuneración muy atractiva.',
      en: 'Fake-job scams often pair simple tasks with unusually attractive pay.',
    ),
    ProposalSafetySignalCode.unofficialPublicChannel => _safetyText(
      context,
      pt: 'Sites falsos imitam serviços públicos e direcionam pagamentos ou coleta de dados fora do canal oficial.',
      es: 'Sitios falsos imitan servicios públicos y dirigen pagos o captura de datos fuera del canal oficial.',
      en: 'Fake sites imitate public services and direct payments or data collection outside official channels.',
    ),
  };
}
