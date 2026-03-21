/**
 * Curated guide items for the Argentina → Brasil corridor.
 *
 * This is the backend source of truth for guide content injected into the
 * AI system prompt. Mirrors the Flutter-side ArgentinaBrazilGuideDataSource
 * in terms of IDs and phases so completedItemIds from the client align.
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
    notes: 'Caução costuma ser 2-3 meses de aluguel. Incluir reserva de emergência de 3 meses.',
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
    notes: 'Pode ser solicitado presencialmente em agências da Receita Federal ou pelos Correios. Argentinos com passaporte válido podem solicitar. Sem CPF não é possível abrir conta bancária, assinar contrato de aluguel ou trabalhar formalmente.',
  },
  {
    id: 'doc-02',
    phase: 'documents',
    title: 'Solicitar residência pelo acordo MERCOSUL',
    summary: 'Regularizar situação migratória via acordo de residência do MERCOSUL.',
    notes: 'Argentinos têm direito à residência temporária (2 anos) facilmente renovável para permanente. Solicitar na Polícia Federal. Documentos necessários: passaporte válido, comprovante de renda ou vínculo empregatício, certidão de antecedentes criminais apostilada.',
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
    notes: 'Tradutores juramentados são credenciados pela Junta Comercial de cada estado. Custo médio: R$ 150-300 por documento.',
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
    notes: 'No Brasil o aluguel exige fiador (garantidor) com imóvel quitado, ou seguro fiança (custo ~1.5x aluguel/mês), ou caução (3 meses antecipados), ou título de capitalização.',
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
    notes: 'Bancos digitais (Nubank, Inter, C6) aceitam estrangeiros com passaporte + CPF. Bancos tradicionais podem exigir RNM. Conta digital é o caminho mais rápido.',
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
    notes: 'Currículo brasileiro inclui foto, data de nascimento e estado civil (opcional). Usar LinkedIn com perfil em português. Plataformas: LinkedIn, Catho, InfoJobs, Vagas.com.',
  },

  // ── ARRIVAL ────────────────────────────────────────────────────────────────
  {
    id: 'arr-01',
    phase: 'arrival',
    title: 'Obter CRNM (Carteira de Registro Nacional Migratório)',
    summary: 'Documento de identidade do imigrante no Brasil — equivalente ao RG para estrangeiros.',
    notes: 'Solicitada na Polícia Federal após aprovação da residência MERCOSUL. Tem validade de 2 anos (renovável). Essencial para contratos formais e serviços públicos.',
  },
  {
    id: 'arr-02',
    phase: 'arrival',
    title: 'Cadastrar no sistema de saúde (SUS)',
    summary: 'Acessar saúde pública brasileira gratuitamente com cadastro no posto de saúde.',
    notes: 'SUS é gratuito e universal. Cadastro no posto de saúde do bairro com CPF e comprovante de endereço. Plano de saúde privado recomendado se emprego formal não oferecer.',
  },
  {
    id: 'arr-03',
    phase: 'arrival',
    title: 'Transferir ou tirar CNH brasileira',
    summary: 'Converter ou obter Carteira Nacional de Habilitação para dirigir legalmente no Brasil.',
    notes: 'CNH argentina é válida por 180 dias no Brasil. Para conversão: requerer no DETRAN do estado com passaporte + RNM + CNH argentina apostilada. Processo sem necessidade de nova prova.',
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
