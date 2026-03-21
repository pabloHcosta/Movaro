import 'package:flutter/material.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/preparation_resource_links.dart';
import 'package:movaro_app/features/migration_questionnaire/domain/entities/guide_action_item.dart';
import 'package:movaro_app/features/migration_questionnaire/domain/entities/migration_plan.dart';

class ArgentinaBrazilGuideDataSource {
  const ArgentinaBrazilGuideDataSource._();

  /// Returns `true` when the origin→destination pair matches Argentina→Brazil,
  /// regardless of whether values are ISO codes or journey values.
  static bool isArgentinaToBrazil(String origin, String destination) {
    final o = origin.toUpperCase();
    final d = destination.toUpperCase();
    return (o == 'ARGENTINA' || o == 'AR') &&
        (d == 'BRAZIL' || d == 'BR' || d == 'BRASIL');
  }

  static List<GuideActionItem> build(MigrationPlan plan) {
    final items = <GuideActionItem>[
      const GuideActionItem(
        id: 'item_0_1_rule_90_days',
        title: 'Entender a regra dos 90 dias',
        shortDescription:
            'Como argentino, você pode entrar no Brasil sem visto — mas existem regras importantes sobre quanto tempo pode ficar.',
        fullContent:
            'Como cidadão argentino, você pode entrar no Brasil usando apenas seu DNI válido.\nNão precisa de passaporte, não precisa de visto.\n\nMas atenção: entrando como turista, você tem 90 dias por semestre para ficar\nno país. Após esse prazo, sua situação fica irregular.\n\nO caminho correto é: chegou no Brasil e decidiu ficar? Inicie o processo de\nresidência na Polícia Federal antes de completar 90 dias. Não precisa voltar\npara a Argentina para fazer isso — tudo é solicitado aqui dentro.\n\nResumo do que você NÃO precisa:\n- Passaporte (DNI basta)\n- Visto (Mercosul elimina essa exigência)\n- Tradução juramentada dos seus documentos (isenção pelo Mercosul)\n\nO que você vai precisar resolver ao chegar:\n- CPF (documento fiscal brasileiro)\n- Residência Mercosul na Polícia Federal',
        type: GuideActionType.informative,
        phase: GuidePhase.preparation,
        orderIndex: 0,
        isCompleted: false,
        icon: Icons.schedule_rounded,
      ),
      const GuideActionItem(
        id: 'item_0_2_antecedentes',
        title: 'Providenciar certificado de antecedentes criminais',
        shortDescription:
            'Esse documento é exigido para o processo de residência no Brasil — e demora para emitir na Argentina. Faça antes de viajar.',
        fullContent:
            'Para solicitar a residência Mercosul na Polícia Federal brasileira, você vai\nprecisar apresentar um certificado provando que não tem antecedentes criminais.\n\nEsse certificado é emitido pelo Registro Nacional de Reincidencia (RNR) na\nArgentina, pelo site do Ministério de Justicia argentino.\n\nPode ser solicitado online em: www.argentina.gob.ar/solicitar-certificado-antecedentes\n\nPrazo de emissão: de 5 a 15 dias úteis.\nValidade do certificado: 90 dias a partir da emissão.\n\nDica prática: solicite com antecedência. Se você deixar para pedir depois que\nchegar no Brasil, vai perder semanas esperando enquanto o prazo de 90 dias corre.\n\nOutros documentos que você vai usar no Brasil (não precisa traduzir, mas leve\nas originais e cópias):\n- DNI argentino válido\n- Certidão de nascimento\n- Certidão de casamento (se aplicável)\n- Diplomas (se for usar para trabalho na área)',
        type: GuideActionType.informative,
        phase: GuidePhase.preparation,
        orderIndex: 1,
        isCompleted: false,
        icon: Icons.gpp_good_outlined,
        checklistItems: [
          ChecklistSubItem(
            id: 'ante_1',
            title: 'Solicitar certificado no site do RNR',
            isCompleted: false,
          ),
          ChecklistSubItem(
            id: 'ante_2',
            title: 'Aguardar emissão (5–15 dias úteis)',
            isCompleted: false,
          ),
          ChecklistSubItem(
            id: 'ante_3',
            title: 'Salvar PDF e imprimir cópia',
            isCompleted: false,
          ),
        ],
      ),
      const GuideActionItem(
        id: 'item_0_3_budget',
        title: 'Calcular quanto você vai precisar nos primeiros meses',
        shortDescription:
            'Os primeiros 3 meses são os mais caros. Calcule antes de sair para não ser pego de surpresa.',
        fullContent:
            'Antes de chegar, você precisa ter uma reserva financeira. Os primeiros meses\ntêm custos que muita gente não prevê:\n\nMoradia temporária (Airbnb/Booking enquanto resolve documentos): R\$ 2.500–5.000/mês\nCaução para aluguel fixo (equivalente a 3 meses de aluguel): R\$ 4.500–9.000\nDocumentação (Polícia Federal, fotos, transporte): ~R\$ 300–500\nChip celular + plano mensal: ~R\$ 50–150\nAlimentação antes de ter cozinha própria: R\$ 1.500–2.500/mês\n\nUse a ferramenta de orçamento para calcular com base na cidade escolhida.',
        type: GuideActionType.tool,
        toolType: GuideToolType.budget,
        phase: GuidePhase.preparation,
        orderIndex: 2,
        isCompleted: false,
        icon: Icons.account_balance_wallet_outlined,
      ),
      const GuideActionItem(
        id: 'item_1_3_money',
        title: 'Organizar o dinheiro para os primeiros dias',
        shortDescription:
            'Sem conta brasileira ainda, você vai depender de cartão internacional ou dinheiro em espécie. Entenda as opções.',
        fullContent:
            'Opções para os primeiros dias, antes de ter conta brasileira:\n\nWise (recomendado): cartão internacional que converte na taxa de câmbio real,\nsem as taxas absurdas dos bancos. Funciona em qualquer loja com maquininha.\nCrie sua conta antes de sair da Argentina em wise.com\n\nCartão de crédito internacional: funciona, mas as taxas de câmbio são altas.\nUse como backup, não como principal.\n\nDinheiro em espécie em reais: útil para os primeiros dias, especialmente para\ntransporte e alimentação em lugares sem maquininha.\n\nCâmbio na fronteira ou aeroporto: evite — são as piores taxas. Faça câmbio\nem casas de câmbio na cidade.\n\nQuanto ter disponível para a primeira semana: calcule pelo menos R\$ 1.500 a\nR\$ 2.500 em dinheiro ou cartão funcionando.',
        type: GuideActionType.informative,
        phase: GuidePhase.preparation,
        orderIndex: 3,
        isCompleted: false,
        icon: Icons.payments_outlined,
      ),
      const GuideActionItem(
        id: 'item_0_4_flight',
        title: 'Planejar o voo e a logística da chegada',
        shortDescription:
            'Defina a data de chegada e organize os primeiros dias — moradia temporária e transporte do aeroporto.',
        fullContent:
            'Dicas práticas para a chegada:\n\nAeroporto: ao sair do aeroporto, prefira táxi 99 ou Uber — mais barato e\nconfiável que táxi avulso. Para usar, você vai precisar de um chip brasileiro\n(veja próximo passo).\n\nDia de chegada: chegue com pelo menos 3 noites reservadas em Airbnb ou pousada.\nNão chegue sem reserva esperando resolver na hora — dificulta muito.\n\nCâmbio: leve reais ou dólares. Seu cartão argentino pode funcionar, mas as\ntarifas são altas. O Wise (cartão internacional) é boa alternativa nos primeiros dias.\n\nBagagem: se estiver mudando com muitos pertences, pesquise serviço de transporte\nde bagagem Argentina-Brasil — sai mais barato que despachar pelo avião.',
        type: GuideActionType.tool,
        toolType: GuideToolType.flight,
        phase: GuidePhase.preparation,
        orderIndex: 4,
        isCompleted: false,
        icon: Icons.flight_takeoff_rounded,
      ),
      const GuideActionItem(
        id: 'item_1_1_chip',
        title: 'Comprar chip de celular brasileiro',
        shortDescription:
            'É a primeira coisa a fazer ao chegar. Sem número brasileiro, você não consegue cadastrar em banco, apps ou agendar documentos.',
        fullContent:
            'Por que é urgente: praticamente todos os cadastros no Brasil exigem verificação\npor SMS para um número brasileiro. Sem chip, você não consegue abrir conta no\nNubank, agendar na Polícia Federal, nem usar apps de transporte.\n\nOnde comprar:\n- Lojas das operadoras nos aeroportos (mais caro, mas conveniente)\n- Claro, Vivo, TIM ou Oi — qualquer shopping ou loja de celular\n- Você não precisa de CPF para comprar um chip pré-pago\n\nQual operadora escolher: verifique qual tem melhor cobertura na cidade de destino.\nClaro e Vivo costumam ter a melhor cobertura nacional.\n\nPlano recomendado para começo: pré-pago com recarga. Depois que tiver CPF e\nconta bancária, migre para pós-pago (mais barato no longo prazo).',
        type: GuideActionType.informative,
        phase: GuidePhase.housing,
        orderIndex: 5,
        isCompleted: false,
        icon: Icons.sim_card_outlined,
      ),
      const GuideActionItem(
        id: 'item_1_2_housing_temporary',
        title: 'Garantir onde ficar nos primeiros 30 a 60 dias',
        shortDescription:
            'Não tente alugar imóvel fixo agora — você ainda não tem documentação brasileira. Airbnb ou quarto por mês é a estratégia certa.',
        fullContent:
            'Por que não alugar imóvel fixo agora:\nImobiliárias exigem CPF, comprovante de renda brasileiro e fiador (ou depósito\nequivalente a 3 meses). Você ainda não tem nada disso. Tudo bem — é temporário.\n\nOpções para os primeiros 1 a 3 meses:\n- Airbnb por mês (desconto para estadias longas)\n- Booking (hotéis e flats)\n- Quartos em pensões ou repúblicas — mais econômico\n- Flats mobiliados com contratos mensais — boa opção para quem pode gastar um\n  pouco mais e quer privacidade\n\nDica importante: ao reservar, peça um comprovante de endereço (contrato ou\nconfirmação de reserva com seu nome e o endereço). Você vai precisar disso\npara alguns cadastros durante a fase de documentação.\n\nUse a ferramenta de moradia para buscar opções na sua cidade.',
        type: GuideActionType.tool,
        toolType: GuideToolType.housing,
        phase: GuidePhase.housing,
        orderIndex: 6,
        isCompleted: false,
        icon: Icons.house_outlined,
      ),
      const GuideActionItem(
        id: 'item_2_1_cpf',
        title: 'Tirar o CPF — o documento que desbloqueia tudo',
        shortDescription:
            'O CPF é o número fiscal brasileiro. Sem ele você não abre conta, não aluga imóvel, não assina contrato. É a primeira coisa a resolver.',
        fullContent:
            'O CPF (Cadastro de Pessoas Físicas) é o documento mais importante para sua\nvida no Brasil. É como o CUIL argentino, mas ainda mais exigido no dia a dia.\n\nVocê VAI precisar do CPF para:\n- Abrir conta bancária\n- Alugar imóvel\n- Assinar qualquer contrato\n- Compras online acima de certo valor\n- Plano de saúde\n- Cartão de crédito\n- Trabalho formal (CLT)\n- Quase qualquer cadastro digital\n\nComo tirar:\nVá pessoalmente a uma agência da Receita Federal com:\n- DNI ou passaporte original\n- Comprovante de endereço no Brasil (o da sua moradia temporária serve)\n\nVocê também pode tirar nos Correios (mediante agendamento e taxa de ~R\$ 7).\n\nTempo de processamento: o CPF pode ser emitido na hora em alguns casos,\nou em até 5 dias úteis.\n\nNão precisa esperar a residência estar pronta para tirar o CPF — você tira\ncom o DNI mesmo.',
        type: GuideActionType.informative,
        phase: GuidePhase.documents,
        orderIndex: 7,
        isCompleted: false,
        icon: Icons.badge_outlined,
        dependencies: <String>['item_1_1_chip'],
        checklistItems: [
          ChecklistSubItem(
            id: 'cpf_1',
            title: 'Reunir documentos (DNI + comprovante de endereço)',
            isCompleted: false,
          ),
          ChecklistSubItem(
            id: 'cpf_2',
            title: 'Ir à Receita Federal ou Correios',
            isCompleted: false,
          ),
          ChecklistSubItem(
            id: 'cpf_3',
            title: 'Receber número do CPF',
            isCompleted: false,
          ),
        ],
      ),
      const GuideActionItem(
        id: 'item_2_2_residencia',
        title: 'Solicitar residência Mercosul na Polícia Federal',
        shortDescription:
            'Como argentino, você tem direito à residência no Brasil pelo Acordo Mercosul. Faça esse agendamento o quanto antes — as vagas acabam rápido.',
        fullContent:
            'Pelo Acordo de Residência do Mercosul, argentinos podem solicitar residência\ntemporária no Brasil diretamente na Polícia Federal, sem precisar de visto.\n\nPor que fazer logo:\n- Resolve sua situação migratória antes dos 90 dias acabarem\n- É pré-requisito para emitir a CTPS digital (trabalho formal)\n- Dá segurança para assinar contratos de aluguel e trabalho\n\nDocumentos necessários (leve originais e cópias de tudo):\n- DNI ou passaporte válido\n- Certidão de nascimento (original — não precisa de tradução pelo Mercosul)\n- Certificado de antecedentes criminais argentino (emitido há menos de 90 dias)\n- Comprovante de endereço no Brasil\n- Foto 3x4 recente\n- Comprovante de meios de subsistência (extrato bancário, contrato de trabalho,\n  declaração de renda — qualquer um)\n\nOnde agendar:\nSite da Polícia Federal: servicos.dpf.gov.br\nEscolha a unidade mais próxima da sua cidade.\n\nImportante sobre o agendamento:\nAs vagas na Polícia Federal costumam ter espera de 2 a 6 semanas nas capitais.\nAgende no primeiro ou segundo dia no Brasil — não espere.\n\nO que você recebe no final:\nUm protocolo de residência temporária (CRNM em processamento). Com esse\nprotocolo em mãos, você já pode emitir CTPS e abrir contas em alguns bancos.\nA carteira física (CRNM) chega pelo correio em semanas ou meses depois.',
        type: GuideActionType.informative,
        phase: GuidePhase.documents,
        orderIndex: 8,
        isCompleted: false,
        icon: Icons.account_balance_outlined,
        dependencies: <String>['item_2_1_cpf'],
        checklistItems: [
          ChecklistSubItem(
            id: 'res_1',
            title: 'Agendar no site da Polícia Federal',
            isCompleted: false,
          ),
          ChecklistSubItem(
            id: 'res_2',
            title: 'Reunir documentos e fotos 3x4',
            isCompleted: false,
          ),
          ChecklistSubItem(
            id: 'res_3',
            title: 'Comparecer ao atendimento e biometria',
            isCompleted: false,
          ),
          ChecklistSubItem(
            id: 'res_4',
            title: 'Receber protocolo de residência',
            isCompleted: false,
          ),
        ],
      ),
      const GuideActionItem(
        id: 'item_2_3_ctps',
        title: 'Emitir a Carteira de Trabalho Digital (CTPS)',
        shortDescription:
            'Com CPF e protocolo da Polícia Federal em mãos, a CTPS é emitida em minutos pelo app do governo. Ela é obrigatória para trabalho formal no Brasil.',
        fullContent:
            'A CTPS (Carteira de Trabalho e Previdência Social) é o documento que permite\ntrabalho formal com carteira assinada no Brasil — CLT, FGTS, férias, 13º.\n\nComo emitir:\n1. Baixe o app "Carteira de Trabalho Digital" (disponível em iOS e Android)\n2. Faça login com sua conta Gov.br (crie com o CPF se ainda não tiver)\n3. A CTPS é gerada automaticamente\n\nO que você precisa ter antes:\n- CPF (obrigatório)\n- Protocolo da Polícia Federal ou CRNM (para comprovar regularidade migratória)\n\nPara que serve na prática:\n- Registro de emprego CLT\n- Histórico de vínculos empregatícios\n- Acesso ao FGTS\n- Seguro desemprego\n\nSe você vai trabalhar como autônomo (freelancer, remoto para empresa argentina):\nConsidere abrir um MEI (Microempreendedor Individual) em vez do CLT.\nCom CPF, você abre o MEI online em minutos no portal gov.br/mei.\nO MEI permite emitir nota fiscal, ter CNPJ e contribuir para o INSS.',
        type: GuideActionType.informative,
        phase: GuidePhase.documents,
        orderIndex: 9,
        isCompleted: false,
        icon: Icons.work_outline_rounded,
        dependencies: <String>['item_2_1_cpf'],
      ),
      const GuideActionItem(
        id: 'item_3_1_conta_bancaria',
        title: 'Abrir conta bancária no Brasil',
        shortDescription:
            'Com CPF em mãos, você já pode abrir conta. Bancos digitais são o caminho mais fácil para estrangeiros no início.',
        fullContent:
            'Bancos tradicionais (Itaú, Bradesco, Caixa, Banco do Brasil) costumam exigir\nCRNM física, que demora para chegar. Evite a frustração — comece pelos digitais.\n\nOpções recomendadas para estrangeiros com CPF:\n\nNubank: aceita CPF + foto do DNI/passaporte + selfie. Processo 100% pelo app.\nSem taxa de manutenção. Cartão de crédito disponível após análise de crédito.\n\nBanco Inter: similar ao Nubank. Aceita estrangeiros com CPF e protocolo da PF.\n\nC6 Bank: também aceita estrangeiros. Tem função de câmbio integrada (útil\npara quem recebe da Argentina).\n\nWise: não é banco tradicional, mas tem conta em reais com IBAN. Ótimo para\nquem recebe pagamentos internacionais. Não tem Pix ainda, mas tem TED.\n\nApós abrir a conta:\n- Configure o Pix imediatamente — é como as pessoas pagam e recebem no Brasil.\n  Qualquer transação sem Pix é antiquada aqui.\n- Peça o cartão físico enviado para seu endereço atual.\n\nDica: abra o Nubank primeiro (mais fácil), e depois abra uma conta no banco\nda sua preferência quando tiver a CRNM física.',
        type: GuideActionType.informative,
        phase: GuidePhase.work,
        orderIndex: 10,
        isCompleted: false,
        icon: Icons.account_balance_rounded,
        dependencies: <String>['item_2_1_cpf'],
        checklistItems: [
          ChecklistSubItem(
            id: 'bank_1',
            title: 'Escolher banco digital (Nubank, Inter ou C6)',
            isCompleted: false,
          ),
          ChecklistSubItem(
            id: 'bank_2',
            title: 'Abrir conta pelo app com CPF + DNI',
            isCompleted: false,
          ),
          ChecklistSubItem(
            id: 'bank_3',
            title: 'Configurar chave Pix',
            isCompleted: false,
          ),
        ],
      ),
      const GuideActionItem(
        id: 'item_3_2_aluguel_fixo',
        title: 'Buscar aluguel fixo na sua cidade',
        shortDescription:
            'Com CPF e comprovante de renda ou reserva financeira, agora é possível alugar. Saiba como funciona para estrangeiro no Brasil.',
        fullContent:
            'O aluguel no Brasil é burocrático para estrangeiros, mas tem soluções práticas.\n\nO problema:\nImobiliárias tradicionais exigem fiador brasileiro — alguém com imóvel próprio\nno Brasil que assina como garantia. Se você não tem rede aqui, isso é um obstáculo.\n\nAs soluções:\n\nQuintoAndar (recomendado para estrangeiros):\n- Aceita RNM/protocolo da PF como documento\n- Não exige fiador brasileiro\n- Processo todo online\n- Usa seguro-fiança como garantia (embutido no aluguel, ~10% a mais por mês)\n- Tem listagens em todas as capitais e grandes cidades\n\nZAP Imóveis e Viva Real:\n- Listam imóveis de imobiliárias e proprietários diretos\n- Para proprietários diretos, é mais fácil negociar sem fiador\n- Proprietário pode aceitar depósito caução (3 meses adiantados) como garantia\n\nTítulos de capitalização:\n- Você deposita o equivalente a 6 meses de aluguel numa capitalização\n- Ao final do contrato, o dinheiro é devolvido\n- Aceito pela maioria das imobiliárias\n\nO que você vai precisar para assinar o contrato:\n- CPF\n- Protocolo da PF ou CRNM\n- Comprovante de renda (contracheque, extrato bancário com entradas regulares,\n  contrato de trabalho, declaração de renda do MEI)\n- A modalidade de garantia escolhida (seguro-fiança, depósito ou capitalização)\n\nValores médios de aluguel (sem condomínio e IPTU) por cidade — 2025:\nOs valores são dinâmicos — use a ferramenta de orçamento para dados atualizados.',
        type: GuideActionType.tool,
        toolType: GuideToolType.housing,
        phase: GuidePhase.work,
        orderIndex: 11,
        isCompleted: false,
        icon: Icons.real_estate_agent_outlined,
        dependencies: <String>['item_2_1_cpf'],
      ),
      const GuideActionItem(
        id: 'item_3_3_pix',
        title: 'Entender como funcionam os pagamentos no Brasil',
        shortDescription:
            'O Brasil tem um sistema de pagamentos instantâneos (Pix) que é usado para absolutamente tudo. Sem Pix configurado, você fica de fora do dia a dia.',
        fullContent:
            'O Pix é o sistema de pagamento instantâneo criado pelo Banco Central do Brasil.\nFunciona 24h por dia, 7 dias por semana, sem custo para pessoas físicas.\n\nPara que é usado no dia a dia:\n- Pagar aluguel\n- Pagar contas de mercado e restaurante\n- Receber salário (muitas empresas pagam por Pix)\n- Dividir conta\n- Pagar serviços (cabeleireiro, encanador, qualquer autônomo)\n- Praticamente qualquer transação entre pessoas\n\nComo configurar:\nNo app do seu banco, cadastre uma chave Pix. Pode ser:\n- CPF (mais recomendado — fácil de memorizar e compartilhar)\n- Número de celular brasileiro\n- E-mail\n- Chave aleatória gerada pelo banco\n\nBoleto bancário:\nAinda é usado para pagar contas (luz, água, aluguel formal). O app do banco\npermite pagar boletos escaneando o código de barras.\n\nCartão de débito/crédito:\nFunciona em qualquer lugar com maquininha. Compras online exigem cartão com\nfunção de compra internacional habilitada para sites que aceitam bandeiras Visa/Master.',
        type: GuideActionType.informative,
        phase: GuidePhase.work,
        orderIndex: 12,
        isCompleted: false,
        icon: Icons.pix_outlined,
        dependencies: <String>['item_3_1_conta_bancaria'],
      ),
      const GuideActionItem(
        id: 'item_3_4_trabalho',
        title: 'Estruturar sua renda no Brasil',
        shortDescription:
            'Seja emprego formal, freelance ou remoto para empresa argentina — cada caminho tem uma estratégia diferente. Entenda qual é o seu.',
        fullContent:
            'Existem três caminhos principais, e cada um tem implicações diferentes:\n\nCAMINHO 1 — Emprego CLT (carteira assinada):\nExige: CPF + CTPS digital + CRNM (ou protocolo)\nDireitos: FGTS, 13º, férias, seguro desemprego, INSS\nComo buscar: LinkedIn Brasil, Catho, Infojobs, Vagas.com.br, Indeed Brasil\nDiferencial para estrangeiro: fluência em português e espanhol é valorizado\nem empresas com operação na América Latina\n\nCAMINHO 2 — Trabalho autônomo / Freelancer:\nAbra um MEI (Microempreendedor Individual) no portal gov.br/mei\nCom MEI você: emite nota fiscal, tem CNPJ, contribui para o INSS (aposentadoria)\nIdeal para quem presta serviços, é digital, consultor ou profissional liberal\nLimite de faturamento do MEI: R\$ 81.000/ano (2025)\n\nCAMINHO 3 — Trabalho remoto para empresa argentina:\nPode continuar recebendo em pesos ou dólares pela conta argentina\nPara receber em dólares e converter: use a Wise ou conta na Argentina\nAtenção: se você tiver residência no Brasil, pode haver obrigação de declarar\nrenda no Brasil também — consulte um contador para entender a situação fiscal\n\nValidação de diplomas:\nSe você é profissional regulamentado (médico, engenheiro, advogado), o diploma\nprecisa ser revalidado por universidade federal brasileira (processo Revalida/CFM).\nIsso não é obrigatório para todas as profissões — pesquise o conselho de classe\nda sua área específica.\n\nPlataformas para freelancers:\nWorkana, 99Freelas, Upwork (internacional), Fiverr (internacional)',
        type: GuideActionType.informative,
        phase: GuidePhase.work,
        orderIndex: 13,
        isCompleted: false,
        icon: Icons.work_history_outlined,
        dependencies: <String>['item_2_3_ctps'],
      ),
      const GuideActionItem(
        id: 'item_4_1_cnh',
        title:
            'Converter a carteira de motorista argentina para CNH brasileira',
        shortDescription:
            'Com a residência Mercosul, você não precisa refazer as provas. O processo é pelo DETRAN e elimina a necessidade de habilitar do zero.',
        fullContent:
            'Brasileiros e estrangeiros com residência regularizada podem converter a carteira\nde motorista estrangeira em CNH brasileira sem refazer as provas teóricas ou\npráticas — apenas com exame médico e psicológico.\n\nDocumentos necessários:\n- CNH argentina original (válida)\n- CRNM (Carteira de Registro Nacional Migratório) — precisa da física, não só protocolo\n- CPF\n- Comprovante de residência no Brasil\n\nProcesso:\n1. Vá ao DETRAN do seu estado\n2. Solicite a conversão de CNH estrangeira\n3. Realize os exames médico e psicológico (clínicas credenciadas pelo DETRAN)\n4. Aguarde a emissão (prazo varia por estado, geralmente 15 a 30 dias)\n\nCusto aproximado: R\$ 300 a R\$ 600 (varia por estado e clínica de exames)\n\nImportante: você pode dirigir no Brasil por até 180 dias com a CNH argentina\ne o protocolo de residência. Depois disso, sem a conversão, não pode dirigir\nlegalmente com a carteira estrangeira.',
        type: GuideActionType.informative,
        phase: GuidePhase.arrival,
        orderIndex: 14,
        isCompleted: false,
        icon: Icons.directions_car_outlined,
        dependencies: <String>['item_2_2_residencia'],
      ),
      const GuideActionItem(
        id: 'item_4_2_saude',
        title: 'Cuidar da saúde no Brasil',
        shortDescription:
            'Estrangeiros regularizados têm acesso integral ao SUS. Entenda como funciona e se um plano privado faz sentido para você.',
        fullContent:
            'SUS (Sistema Único de Saúde):\nEstrangeiros com residência regularizada têm direito pleno ao SUS — consultas,\nexames, internações e medicamentos da lista básica são gratuitos.\n\nPara acessar: apresente CPF e CRNM (ou protocolo) no posto de saúde mais próximo\ne solicite o Cartão Nacional de Saúde (CNS).\n\nLimitações do SUS: filas longas em especialidades, especialmente em capitais.\nPara consultas de rotina e UPA (emergência), funciona bem.\n\nPlano de saúde privado:\nSe seu emprego CLT oferecer: aceite — é um dos melhores benefícios no Brasil.\nSe for autônomo: planos individuais custam de R\$ 400 a R\$ 1.500/mês dependendo\nda cobertura e da cidade. Bradesco Saúde, Amil, Unimed e SulAmérica são as\nmaiores operadoras.\n\nO que o plano privado costuma cobrir:\n- Consultas com especialistas sem fila\n- Exames com marcação rápida\n- Internações em hospitais privados\n- Alguns cobrem odontologia (verifique)\n\nDica: se tiver condição, contrate pelo menos um plano ambulatorial (sem internação)\nnos primeiros 6 meses — é quando você ainda não conhece sua saúde no novo país.',
        type: GuideActionType.informative,
        phase: GuidePhase.arrival,
        orderIndex: 15,
        isCompleted: false,
        icon: Icons.local_hospital_outlined,
      ),
      const GuideActionItem(
        id: 'item_4_3_permanencia',
        title: 'Transformar a residência temporária em permanente',
        shortDescription:
            'Esse passo precisa ser feito ANTES de completar 2 anos de residência temporária. Quem perde o prazo precisa recomeçar o processo.',
        fullContent:
            'Sua residência temporária Mercosul tem validade de 2 anos.\n\nAntes de completar esse prazo, você precisa solicitar a transformação em\nresidência por prazo indeterminado — caso contrário, sua situação volta a\nser irregular e você precisa recomeçar todo o processo.\n\nPrazo para solicitar: até 90 dias ANTES do vencimento da sua residência temporária.\n\nOnde solicitar: Polícia Federal (mesmo processo de quando você solicitou a temporária)\n\nDocumentos necessários:\n- CRNM temporária ainda válida\n- Comprovante de meios de vida lícitos (qualquer um abaixo):\n  - Contracheque ou contrato de trabalho CLT\n  - Pró-labore de empresa ou MEI\n  - Declaração de Imposto de Renda brasileiro\n  - Extratos bancários mostrando entradas regulares\n  - Recibo de aluguel (provando que você paga moradia e tem renda)\n\nO que muda com a residência permanente:\n- Você não precisa mais renovar\n- Seus direitos são idênticos aos de um cidadão brasileiro (exceto votar)\n- Após 4 anos de residência permanente, você pode pedir a naturalização\n\nConfigure um lembrete agora para 21 meses após a data do protocolo da sua\nresidência temporária — assim você não corre risco de perder o prazo.',
        type: GuideActionType.informative,
        phase: GuidePhase.arrival,
        orderIndex: 16,
        isCompleted: false,
        icon: Icons.event_available_outlined,
        dependencies: <String>['item_2_2_residencia'],
      ),
      const GuideActionItem(
        id: 'item_4_4_mei',
        title: 'Abrir MEI para trabalhar como autônomo',
        shortDescription:
            'O MEI é a forma mais simples de formalizar sua atividade no Brasil. Você ganha CNPJ, emite nota fiscal e tem acesso à previdência social.',
        fullContent:
            'MEI (Microempreendedor Individual) é ideal para:\n- Freelancers e profissionais autônomos\n- Quem presta serviços para empresas brasileiras (que exigem nota fiscal)\n- Quem quer contribuir para o INSS (aposentadoria) sem ter carteira assinada\n- Quem quer ter CNPJ para abrir conta bancária PJ e ter mais credibilidade\n\nPara abrir o MEI você precisa:\n- CPF\n- CRNM (ou protocolo da Polícia Federal)\n- Conta Gov.br\n\nComo abrir: acesse gov.br/mei e siga o processo — leva menos de 10 minutos.\n\nCustos mensais do MEI:\n- DAS (guia de pagamento): R\$ 70,60 a R\$ 76,90/mês (varia por atividade)\n- Isso já inclui INSS, ICMS ou ISS — dependendo da sua atividade\n\nLimitações do MEI:\n- Limite de faturamento: R\$ 81.000/ano (2025)\n- Não pode ter sócio\n- Algumas profissões regulamentadas não podem ser MEI (médicos, advogados, etc.)\n- Se ultrapassar o limite, precisa migrar para ME (Microempresa)\n\nDica: abra o MEI mesmo que não vá usar imediatamente. O custo é baixo e\nvocê passa a contribuir para a aposentadoria desde o primeiro mês.',
        type: GuideActionType.informative,
        phase: GuidePhase.arrival,
        orderIndex: 17,
        isCompleted: false,
        icon: Icons.storefront_outlined,
        dependencies: <String>['item_2_1_cpf'],
      ),
    ];

    if (plan.goal == 'study') {
      items.add(
        GuideActionItem(
          id: 'item_3_5_revalidacao_estudos',
          title: 'Verificar se seu diploma precisa de revalidação',
          shortDescription:
              'Se você vai estudar ou usar formação anterior no Brasil, veja quando a revalidação realmente é necessária.',
          fullContent:
              'Nem todo curso ou diploma estrangeiro precisa ser revalidado imediatamente.\n\nPara continuar estudos, pedir equivalência acadêmica ou exercer profissões regulamentadas, a exigência pode mudar conforme a instituição e a área.\n\nO melhor caminho é verificar a regra oficial antes de iniciar qualquer processo pago. O portal do governo reúne a orientação base para reconhecimento e revalidação de diploma obtido no exterior.',
          type: GuideActionType.external,
          externalUrl: PreparationResourceLinks.diplomaValidationGuide
              .toString(),
          externalLabel: 'gov.br',
          phase: GuidePhase.work,
          orderIndex: 14,
          isCompleted: false,
          icon: Icons.school_outlined,
          dependencies: const <String>['item_2_2_residencia'],
        ),
      );
    }

    final priorityIds = _priorityOrder(plan.goal);
    final priorityRanks = <String, int>{
      for (var index = 0; index < priorityIds.length; index++)
        priorityIds[index]: index,
    };

    final reordered = items.map((item) => item.copyWith()).toList()
      ..sort((a, b) {
        final aRank = priorityRanks[a.id] ?? 999;
        final bRank = priorityRanks[b.id] ?? 999;
        if (aRank != bRank) {
          return aRank.compareTo(bRank);
        }
        return a.orderIndex.compareTo(b.orderIndex);
      });

    for (var index = 0; index < reordered.length; index++) {
      reordered[index] = reordered[index].copyWith(orderIndex: index);
    }

    return reordered;
  }

  static List<String> _priorityOrder(String goal) {
    switch (goal) {
      case 'work':
      case 'find_job_br':
        return const [
          'item_0_1_rule_90_days',
          'item_0_2_antecedentes',
          'item_0_3_budget',
          'item_1_3_money',
          'item_0_4_flight',
          'item_1_1_chip',
          'item_2_1_cpf',
          'item_2_2_residencia',
          'item_2_3_ctps',
          'item_3_1_conta_bancaria',
          'item_3_4_trabalho',
          'item_3_2_aluguel_fixo',
        ];
      case 'remote_income':
      case 'remote_work':
      case 'entrepreneur':
        return const [
          'item_0_1_rule_90_days',
          'item_0_2_antecedentes',
          'item_0_3_budget',
          'item_1_3_money',
          'item_0_4_flight',
          'item_1_1_chip',
          'item_2_1_cpf',
          'item_3_1_conta_bancaria',
          'item_4_4_mei',
          'item_3_4_trabalho',
          'item_3_2_aluguel_fixo',
        ];
      case 'study':
        return const [
          'item_0_1_rule_90_days',
          'item_0_2_antecedentes',
          'item_0_3_budget',
          'item_1_3_money',
          'item_0_4_flight',
          'item_1_1_chip',
          'item_2_1_cpf',
          'item_2_2_residencia',
          'item_3_1_conta_bancaria',
          'item_3_2_aluguel_fixo',
        ];
      case 'family_partner':
      case 'quality_of_life':
      case 'beach_life':
      case 'fresh_start':
        return const [
          'item_0_1_rule_90_days',
          'item_0_2_antecedentes',
          'item_0_3_budget',
          'item_1_3_money',
          'item_0_4_flight',
          'item_1_1_chip',
          'item_1_2_housing_temporary',
          'item_2_1_cpf',
          'item_2_2_residencia',
          'item_3_1_conta_bancaria',
          'item_3_2_aluguel_fixo',
          'item_4_2_saude',
        ];
      default:
        return const [];
    }
  }
}
