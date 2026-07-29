/**
 * Curated guide items for the Argentina → Brasil corridor.
 *
 * Reviewed deterministic knowledge for backend resolvers. It is not an AI
 * prompt and must not contain unsupported time, price, or approval claims.
 *
 * Phases (in order): preparation → documents → housing → work → arrival
 */

export interface GuideItem {
  id: string;
  phase: 'preparation' | 'documents' | 'housing' | 'work' | 'arrival';
  title: string;
  summary: string;
  /** Key practical details the AI should know to answer questions. */
  notes?: string;
}

export const ARGENTINA_BRAZIL_GUIDE_ITEMS: GuideItem[] = [
  // ── PREPARATION ────────────────────────────────────────────────────────────
  {
    id: 'item_0_2_document_folder',
    phase: 'preparation',
    title: 'Montar a pasta migratória',
    summary:
      'Reunir a documentação civil e confirmar a lista específica do acordo Brasil–Argentina.',
    notes:
      'Os documentos previstos no acordo bilateral têm tratamento próprio. A Polícia Federal informa dispensa de tradução para essa rota, salvo dúvida fundamentada. Documentos acadêmicos ou pedidos por outros órgãos devem seguir a exigência específica do destinatário.',
  },
  {
    id: 'item_0_2_antecedentes',
    phase: 'preparation',
    title: 'Obter certificados de antecedentes',
    summary:
      'Providenciar os certificados exigidos pela rota de residência antes da viagem.',
    notes:
      'Conferir países de residência considerados, validade prática e formato aceito diretamente no serviço atualizado da Polícia Federal.',
  },
  {
    id: 'item_0_3_budget',
    phase: 'preparation',
    title: 'Calcular o orçamento de mudança',
    summary:
      'Estimar passagem, acomodação inicial, moradia, alimentação, transporte e imprevistos.',
    notes:
      'A Lei do Inquilinato limita a caução em dinheiro e não permite acumular mais de uma modalidade de garantia no mesmo contrato.',
  },
  {
    id: 'item_1_3_money',
    phase: 'preparation',
    title: 'Preparar dinheiro para os primeiros dias',
    summary:
      'Organizar reserva acessível e mais de uma forma de pagamento para a chegada.',
    notes:
      'Não depender de um único cartão ou de uma conta brasileira ainda não aprovada.',
  },
  {
    id: 'item_0_5_mercado_trabalho',
    phase: 'preparation',
    title: 'Preparar a busca de trabalho',
    summary:
      'Pesquisar o mercado da cidade e adaptar o currículo antes da mudança.',
    notes:
      'Pesquisar vagas não substitui a regularização necessária para exercer trabalho formal.',
  },
  {
    id: 'item_0_7_ingresso_ensino_superior',
    phase: 'preparation',
    title: 'Definir a rota de ingresso no ensino superior',
    summary:
      'Comparar ENEM/Sisu, processo direto da instituição, PEC-G ou pós-graduação.',
    notes:
      'Editais, calendários, elegibilidade e documentos variam conforme a instituição e a modalidade.',
  },

  // ── DOCUMENTS ──────────────────────────────────────────────────────────────
  {
    id: 'item_2_1_cpf',
    phase: 'documents',
    title: 'Obter CPF na Receita Federal',
    summary:
      'Cadastro de Pessoa Física — o documento mais importante para se estabelecer no Brasil.',
    notes:
      'Pode ser solicitado pelos canais oficiais no Brasil ou no exterior. O serviço público é gratuito; unidades conveniadas podem cobrar a tarifa publicada. Documentos e prazo variam por canal.',
  },
  {
    id: 'item_2_1_govbr',
    phase: 'documents',
    title: 'Criar e validar a conta Gov.br',
    summary: 'Preparar o acesso digital usado por diversos serviços públicos.',
    notes:
      'A conta depende do CPF. O nível necessário varia conforme o serviço acessado.',
  },
  {
    id: 'item_2_2_residencia',
    phase: 'documents',
    title: 'Confirmar residência pelo acordo Brasil–Argentina',
    summary:
      'Avaliar a rota bilateral de residência permanente para argentinos elegíveis.',
    notes:
      'A Polícia Federal mantém uma página específica do acordo bilateral Brasil–Argentina. A estada como visitante não deve ser tratada como prazo universal para pedir residência. Confirmar elegibilidade e requisitos na versão atual do serviço.',
  },
  // ── HOUSING ────────────────────────────────────────────────────────────────
  {
    id: 'item_1_2_housing_temporary',
    phase: 'housing',
    title: 'Garantir onde ficar nos primeiros 30-60 dias',
    summary:
      'Confirmar acomodação temporária antes de chegar para ter estabilidade inicial.',
    notes:
      'Plataformas como Airbnb ou hostels são opções para o início. Evitar fechar aluguel permanente sem visitar o imóvel.',
  },
  {
    id: 'item_4_9_reavaliar_bairro',
    phase: 'housing',
    title: 'Pesquisar bairros e modalidades de aluguel',
    summary: 'Entender a cidade: bairros, transporte e perfil de cada região.',
    notes:
      'A garantia depende do contrato e da Lei do Inquilinato. Não há exigência universal de fiador. O contrato não deve acumular mais de uma garantia; caução em dinheiro tem limite legal.',
  },
  {
    id: 'item_3_2_aluguel_fixo',
    phase: 'housing',
    title: 'Assinar contrato de locação',
    summary: 'Formalizar a moradia e guardar contrato e comprovantes.',
    notes:
      'Não existe exigência universal de registrar o contrato em cartório. Documentos e garantias dependem do contrato e da análise do locador.',
  },

  // ── WORK ───────────────────────────────────────────────────────────────────
  {
    id: 'item_3_1_conta_bancaria',
    phase: 'work',
    title: 'Abrir conta bancária no Brasil',
    summary:
      'Ter conta em banco brasileiro para receber salário e pagar contas.',
    notes:
      'Cada instituição define documentos, análise e disponibilidade. CPF e identificação migratória podem ser solicitados, mas nenhuma combinação garante aprovação.',
  },
  {
    id: 'item_2_3_ctps',
    phase: 'work',
    title: 'Registrar na Carteira de Trabalho Digital (CTPS)',
    summary: 'Obter CTPS para trabalho com carteira assinada no Brasil.',
    notes:
      'A CTPS Digital fica disponível para quem possui CPF e acesso Gov.br. O empregador registra o vínculo no eSocial; a emissão prévia da carteira não deve ser apresentada como barreira universal.',
  },
  {
    id: 'item_3_5_revalidacao_estudos',
    phase: 'work',
    title: 'Validar diploma (revalidação)',
    summary:
      'Revalidar diploma estrangeiro para exercer profissão regulamentada no Brasil.',
    notes:
      'A necessidade depende do uso do diploma e da profissão. A revalidação é processada por universidade pública habilitada, com consulta pela Plataforma Carolina Bori; não deve ser apresentada como um processo feito diretamente pelo MEC.',
  },
  {
    id: 'item_3_4_work_rights',
    phase: 'work',
    title: 'Conhecer direitos e evitar vagas falsas',
    summary:
      'Usar canais confiáveis e reconhecer cobranças, retenção de documentos e propostas abusivas.',
    notes:
      'Esta preparação pode ocorrer antes da viagem e não depende da conclusão da residência.',
  },
  {
    id: 'item_3_4_formal_work_ready',
    phase: 'work',
    title: 'Confirmar os requisitos para iniciar trabalho formal',
    summary:
      'Verificar situação migratória, CPF e acesso aos registros trabalhistas antes da contratação.',
    notes:
      'Pesquisar vagas e preparar currículo pode ocorrer antes. O início do trabalho formal depende de situação migratória que permita trabalhar e de CPF regular.',
  },

  // ── ARRIVAL ────────────────────────────────────────────────────────────────
  {
    id: 'item_1_0_entry_proof',
    phase: 'arrival',
    title: 'Guardar o comprovante de entrada',
    summary:
      'Preservar o registro usado para demonstrar a entrada regular no Brasil.',
    notes:
      'A rota de residência da Polícia Federal inclui comprovante de entrada quando aplicável.',
  },
  {
    id: 'item_4_5_registro_rnm',
    phase: 'arrival',
    title: 'Obter CRNM (Carteira de Registro Nacional Migratório)',
    summary:
      'Documento de identidade do imigrante no Brasil — equivalente ao RG para estrangeiros.',
    notes:
      'O registro e a CRNM seguem a base legal e o prazo indicado no documento. Na rota bilateral, a residência pode ser por prazo indeterminado; confirmar no protocolo e na Polícia Federal.',
  },
  {
    id: 'item_4_2_saude',
    phase: 'arrival',
    title: 'Cadastrar no sistema de saúde (SUS)',
    summary:
      'Acessar saúde pública brasileira gratuitamente com cadastro no posto de saúde.',
    notes:
      'Migrantes têm acesso ao SUS. Urgência não deve aguardar CPF ou CNS; para acompanhamento, confirmar documentos na UBS local. Plano privado é escolha individual.',
  },
  {
    id: 'item_4_1_cnh',
    phase: 'arrival',
    title: 'Transferir ou tirar CNH brasileira',
    summary:
      'Converter ou obter Carteira Nacional de Habilitação para dirigir legalmente no Brasil.',
    notes:
      'Validade e procedimento dependem da regra vigente e do DETRAN estadual. Confirmar documentos, tradução e exames no canal oficial antes de dirigir ou converter.',
  },
];

/** Returns guide items filtered by phase. */
export function getItemsByPhase(phase: string): GuideItem[] {
  return ARGENTINA_BRAZIL_GUIDE_ITEMS.filter((item) => item.phase === phase);
}

/** Returns all guide items for the AR→BR corridor. */
export function getAllItems(): GuideItem[] {
  return ARGENTINA_BRAZIL_GUIDE_ITEMS;
}

/** Ordered list of phases. */
export const PHASE_ORDER = [
  'preparation',
  'documents',
  'housing',
  'work',
  'arrival',
] as const;
