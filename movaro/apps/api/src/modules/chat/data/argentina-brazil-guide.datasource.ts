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
    id: 'prep-01',
    phase: 'preparation',
    title: 'Pesquisar custo de vida na cidade destino',
    summary: 'Comparar custos de moradia, alimentação e transporte entre cidades brasileiras.',
    notes: 'Usar a seção Explorar do app para comparar cidades por custo de vida, mercado de trabalho e popularidade entre argentinos.',
  },
  {
    id: 'prep-02',
    phase: 'preparation',
    title: 'Calcular orçamento de mudança',
    summary: 'Estimar gastos da mudança: frete, passagens, primeiro mês de aluguel e caução.',
    notes: 'A Lei do Inquilinato limita a caução em dinheiro e não permite acumular mais de uma modalidade de garantia no mesmo contrato. A reserva é uma decisão pessoal.',
  },
  {
    id: 'prep-03',
    phase: 'preparation',
    title: 'Definir estratégia de moradia inicial',
    summary: 'Decidir entre hotel, Airbnb ou sublocação para os primeiros 30-60 dias.',
    notes: 'Recomendado ter moradia temporária pré-confirmada antes de chegar. Alugar permanentemente sem CPF é difícil.',
  },
  {
    id: 'prep-04',
    phase: 'preparation',
    title: 'Organizar documentos pessoais',
    summary: 'Reunir passaporte, certidão de nascimento, diploma e demais documentos originais.',
    notes: 'Documentos argentinos precisam de apostila de Haia para uso oficial no Brasil.',
  },

  // ── DOCUMENTS ──────────────────────────────────────────────────────────────
  {
    id: 'doc-01',
    phase: 'documents',
    title: 'Obter CPF na Receita Federal',
    summary: 'Cadastro de Pessoa Física — o documento mais importante para se estabelecer no Brasil.',
    notes: 'Pode ser solicitado pelos canais oficiais no Brasil ou no exterior. O serviço público é gratuito; unidades conveniadas podem cobrar a tarifa publicada. Documentos e prazo variam por canal.',
  },
  {
    id: 'doc-02',
    phase: 'documents',
    title: 'Confirmar residência pelo acordo Brasil–Argentina',
    summary: 'Avaliar a rota bilateral de residência permanente para argentinos elegíveis.',
    notes: 'A Polícia Federal mantém uma página específica do acordo bilateral Brasil–Argentina. A estada como visitante não deve ser tratada como prazo universal para pedir residência. Confirmar elegibilidade e requisitos na versão atual do serviço.',
  },
  {
    id: 'doc-03',
    phase: 'documents',
    title: 'Apostilar documentos na Argentina',
    summary: 'Obter apostila de Haia em documentos que serão usados oficialmente no Brasil.',
    notes: 'Ministério das Relações Exteriores da Argentina emite apostila. Necessário para certidões, diplomas e outros documentos oficiais.',
  },
  {
    id: 'doc-04',
    phase: 'documents',
    title: 'Traduzir documentos oficiais',
    summary: 'Tradução juramentada de documentos argentinos para uso em contratos e processos brasileiros.',
    notes: 'Tradutores públicos são registrados conforme a regra aplicável. Preço e necessidade de tradução variam; confirmar com o órgão que receberá o documento.',
  },

  // ── HOUSING ────────────────────────────────────────────────────────────────
  {
    id: 'hou-01',
    phase: 'housing',
    title: 'Garantir onde ficar nos primeiros 30-60 dias',
    summary: 'Confirmar acomodação temporária antes de chegar para ter estabilidade inicial.',
    notes: 'Plataformas como Airbnb ou hostels são opções para o início. Evitar fechar aluguel permanente sem visitar o imóvel.',
  },
  {
    id: 'hou-02',
    phase: 'housing',
    title: 'Pesquisar bairros e modalidades de aluguel',
    summary: 'Entender a cidade: bairros, transporte e perfil de cada região.',
    notes: 'A garantia depende do contrato e da Lei do Inquilinato. Não há exigência universal de fiador. O contrato não deve acumular mais de uma garantia; caução em dinheiro tem limite legal.',
  },
  {
    id: 'hou-03',
    phase: 'housing',
    title: 'Assinar contrato de locação',
    summary: 'Formalizar moradia com contrato registrado e comprovante de endereço.',
    notes: 'Comprovante de endereço é exigido por bancos e órgãos públicos. Guardar cópia do contrato. Registro em cartório é recomendado.',
  },

  // ── WORK ───────────────────────────────────────────────────────────────────
  {
    id: 'wor-01',
    phase: 'work',
    title: 'Abrir conta bancária no Brasil',
    summary: 'Ter conta em banco brasileiro para receber salário e pagar contas.',
    notes: 'Cada instituição define documentos, análise e disponibilidade. CPF e identificação migratória podem ser solicitados, mas nenhuma combinação garante aprovação.',
  },
  {
    id: 'wor-02',
    phase: 'work',
    title: 'Registrar na Carteira de Trabalho Digital (CTPS)',
    summary: 'Obter CTPS para trabalho com carteira assinada no Brasil.',
    notes: 'CTPS digital é emitida pelo Gov.br com CPF e conta validada. Necessária para emprego formal.',
  },
  {
    id: 'wor-03',
    phase: 'work',
    title: 'Validar diploma (revalidação)',
    summary: 'Revalidar diploma estrangeiro para exercer profissão regulamentada no Brasil.',
    notes: 'Revalidação pelo MEC para diplomas universitários. Profissões regulamentadas (medicina, engenharia, direito) exigem revalidação obrigatória. Processo pode levar 1-3 anos para medicina (REVALIDA). Para outras áreas, universidades federais realizam o processo.',
  },
  {
    id: 'wor-04',
    phase: 'work',
    title: 'Atualizar currículo para o mercado brasileiro',
    summary: 'Adaptar formato e linguagem do currículo ao padrão brasileiro.',
    notes: 'Adaptar idioma e palavras-chave da vaga. Evitar dados pessoais desnecessários; foto, idade e estado civil não são requisitos gerais.',
  },

  // ── ARRIVAL ────────────────────────────────────────────────────────────────
  {
    id: 'arr-01',
    phase: 'arrival',
    title: 'Obter CRNM (Carteira de Registro Nacional Migratório)',
    summary: 'Documento de identidade do imigrante no Brasil — equivalente ao RG para estrangeiros.',
    notes: 'O registro e a CRNM seguem a base legal e o prazo indicado no documento. Na rota bilateral, a residência pode ser por prazo indeterminado; confirmar no protocolo e na Polícia Federal.',
  },
  {
    id: 'arr-02',
    phase: 'arrival',
    title: 'Cadastrar no sistema de saúde (SUS)',
    summary: 'Acessar saúde pública brasileira gratuitamente com cadastro no posto de saúde.',
    notes: 'Migrantes têm acesso ao SUS. Urgência não deve aguardar CPF ou CNS; para acompanhamento, confirmar documentos na UBS local. Plano privado é escolha individual.',
  },
  {
    id: 'arr-03',
    phase: 'arrival',
    title: 'Transferir ou tirar CNH brasileira',
    summary: 'Converter ou obter Carteira Nacional de Habilitação para dirigir legalmente no Brasil.',
    notes: 'Validade e procedimento dependem da regra vigente e do DETRAN estadual. Confirmar documentos, tradução e exames no canal oficial antes de dirigir ou converter.',
  },
];

/** Returns guide items filtered by phase. */
export function getItemsByPhase(
  phase: string,
): GuideItem[] {
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
