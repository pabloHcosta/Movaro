import { Injectable } from '@nestjs/common';

export interface FaqResolverResult {
  found: boolean;
  confidence: number;
  answer: string;
}

interface FaqEntry {
  keywords: string[];
  /** Map locale → answer */
  answers: Partial<Record<'pt' | 'es' | 'en', string>>;
}

const FAQ_ENTRIES: FaqEntry[] = [
  // ── Adaptação cultural ────────────────────────────────────────────────────
  {
    keywords: [
      'adaptação', 'adaptacion', 'adaptation', 'adaptar', 'cultura',
      'cultural', 'costumes', 'costumbres', 'customs', 'diferença cultural',
      'diferencia cultural', 'viver no brasil', 'vivir en brasil',
    ],
    answers: {
      pt: `A adaptação de argentinos no Brasil costuma ser tranquila — há muitas semelhanças culturais, mas alguns pontos merecem atenção:

**Língua:** O português brasileiro tem sotaque e vocabulário diferentes do espanhol. O "portuñol" inicial é normal — em 3 a 6 meses você já fala com fluência suficiente para o dia a dia. Brasileiros são muito pacientes com estrangeiros que tentam falar português.

**Ritmo social:** Brasileiros são muito calorosos e informais. Abraços e beijos na bochecha são comuns desde o primeiro encontro. O conceito de horário é mais flexível do que na Argentina — especialmente em contextos sociais.

**Alimentação:** Arroz e feijão são a base de tudo. Nas grandes cidades há muita variedade. Preços no supermercado podem surpreender: frutas são baratas, mas importados (vinho, queijo) são caros.

**Comunidade argentina:** Florianópolis, São Paulo e Campinas têm comunidades argentinas consolidadas com grupos de WhatsApp ativos onde novos chegados obtêm ajuda prática.

💡 O maior desafio não é a cultura — é a burocracia inicial (CPF, conta bancária, aluguel). O Movaro te guia por cada etapa.`,

      es: `La adaptación de argentinos en Brasil suele ser fluida — hay muchas similitudes culturales, pero algunos puntos merecen atención:

**Idioma:** El portugués brasileño tiene acento y vocabulario diferentes al español. El "portuñol" inicial es normal — en 3 a 6 meses ya hablás con suficiente fluidez para el día a día. Los brasileños son muy pacientes con extranjeros que intentan hablar portugués.

**Ritmo social:** Los brasileños son muy cálidos e informales. Abrazos y besos en la mejilla son comunes desde el primer encuentro. El concepto de horario es más flexible que en Argentina — especialmente en contextos sociales.

**Alimentación:** Arroz y frijoles son la base de todo. En las grandes ciudades hay mucha variedad. Los precios en el supermercado pueden sorprender: las frutas son baratas, pero los importados (vino, queso) son caros.

**Comunidad argentina:** Florianópolis, São Paulo y Campinas tienen comunidades argentinas consolidadas con grupos de WhatsApp activos donde los recién llegados obtienen ayuda práctica.

💡 El mayor desafío no es la cultura — es la burocracia inicial (CPF, cuenta bancaria, alquiler). Movaro te guía en cada etapa.`,
    },
  },

  // ── Idioma / português ────────────────────────────────────────────────────
  {
    keywords: [
      'idioma', 'língua', 'lingua', 'language', 'português', 'portugues',
      'portuguese', 'aprender', 'aprende', 'learn', 'difícil', 'dificil',
      'entender', 'comunicar', 'portuñol', 'falar',
    ],
    answers: {
      pt: `**Aprender português para argentinos**

A boa notícia: português e espanhol são muito parecidos — estima-se que 89% do vocabulário é compartilhado. A maioria dos argentinos consegue se comunicar em 2 a 4 semanas de imersão.

O que ajuda mais:
- **Não usar espanhol** — force-se a falar português desde o primeiro dia, mesmo errado
- **Séries e filmes brasileiros** no Netflix com legenda em português
- **Duolingo** ou **Pimsleur Português Brasileiro** para a pronúncia
- **Grupos de intercâmbio** (linguaphiles no Meetup, Hello Talk app)

Dificuldades comuns para argentinos:
- As vogais nasais (ã, em, ão) — não existem em espanhol
- O "de + o = do", "em + a = na" (contrações)
- Falsos cognatos: "borracha" = pneu, não bebedeira

💡 No trabalho formal, 3 meses já são suficientes para reuniões. Fluência plena vem em 6 a 12 meses.`,

      es: `**Aprender portugués para argentinos**

La buena noticia: portugués y español son muy parecidos — se estima que el 89% del vocabulario es compartido. La mayoría de los argentinos puede comunicarse en 2 a 4 semanas de inmersión.

Lo que más ayuda:
- **No usar español** — forzarte a hablar portugués desde el primer día, aunque sea mal
- **Series y películas brasileñas** en Netflix con subtítulos en portugués
- **Duolingo** o **Pimsleur Português Brasileiro** para la pronunciación
- **Grupos de intercambio** (languaphiles en Meetup, app Hello Talk)

Dificultades comunes para argentinos:
- Las vocales nasales (ã, em, ão) — no existen en español
- El "de + o = do", "em + a = na" (contracciones)
- Falsos cognatos: "borracha" = neumático, no borrachera

💡 En el trabajo formal, 3 meses ya son suficientes para reuniones. Fluidez plena llega en 6 a 12 meses.`,
    },
  },

  // ── Saúde / SUS / plano de saúde ─────────────────────────────────────────
  {
    keywords: [
      'saúde', 'salud', 'health', 'sus', 'plano de saúde', 'plano saude',
      'plan de salud', 'médico', 'medico', 'doctor', 'hospital', 'ubs',
      'upa', 'pronto socorro', 'vacina', 'vacuna', 'vaccine', 'seguro saúde',
    ],
    answers: {
      pt: `**Saúde no Brasil para imigrantes**

**SUS (Sistema Único de Saúde):** O sistema público de saúde brasileiro é gratuito e universal — qualquer pessoa, incluindo imigrantes sem documentos, tem direito a atendimento. Para acesso regular, cadastre-se na UBS (Unidade Básica de Saúde) mais próxima com CPF e comprovante de endereço.

**UPA (Urgência e Emergência):** Funciona 24h para casos de urgência. Não precisa de cadastro prévio.

**Plano de saúde privado:** Recomendado se você vai trabalhar formalmente — muitas empresas oferecem como benefício. Planos individuais custam R$ 300–800/mês por pessoa dependendo da cobertura. Unimed, SulAmérica, Bradesco Saúde são os maiores.

**Medicamentos:** Farmácias são facilmente encontradas. O programa Farmácia Popular oferece medicamentos genéricos gratuitos ou com desconto de até 90%.

💡 Priorize o cadastro no SUS logo que tiver CPF e comprovante de endereço — é gratuito e te dá acesso ao sistema de saúde completo.`,

      es: `**Salud en Brasil para inmigrantes**

**SUS (Sistema Único de Saúde):** El sistema público de salud brasileño es gratuito y universal — cualquier persona, incluyendo inmigrantes sin documentos, tiene derecho a atención. Para acceso regular, registrate en la UBS (Unidad Básica de Salud) más cercana con CPF y comprobante de domicilio.

**UPA (Urgencia y Emergencia):** Funciona 24h para casos urgentes. No necesita registro previo.

**Plan de salud privado:** Recomendado si vas a trabajar formalmente — muchas empresas lo ofrecen como beneficio. Planes individuales cuestan R$ 300–800/mes por persona según la cobertura. Unimed, SulAmérica, Bradesco Saúde son los más grandes.

**Medicamentos:** Las farmacias son fáciles de encontrar. El programa Farmácia Popular ofrece medicamentos genéricos gratuitos o con descuento de hasta 90%.

💡 Prioriza el registro en el SUS apenas tengas CPF y comprobante de domicilio — es gratuito y te da acceso al sistema completo.`,
    },
  },

  // ── Moradia / bairros / aluguel ───────────────────────────────────────────
  {
    keywords: [
      'bairro', 'barrio', 'neighborhood', 'moradia', 'housing', 'vivienda',
      'onde morar', 'dónde vivir', 'where to live', 'seguro', 'seguridad',
      'airbnb', 'temporário', 'temporada', 'sublocação', 'quarto', 'cuarto',
      'room', 'república', 'republica', 'flatmate', 'colega de quarto',
    ],
    answers: {
      pt: `**Moradia no Brasil: primeiros passos**

**Estratégia recomendada para os primeiros 30–60 dias:**
Use Airbnb, hostel ou quarto em república — não assine contrato de longo prazo antes de conhecer a cidade. Sem CPF e histórico de crédito no Brasil, fechar um aluguel permanente é difícil.

**Como encontrar moradia permanente:**
- **ZAP Imóveis**, **Viva Real** e **OLX** são os maiores portais
- Grupos do Facebook: "Argentinos em Floripa/SP/Curitiba" têm indicações de imobiliárias sem burocracia
- Imobiliárias aceitam fiador brasileiro ou seguro-fiança (5–10% do aluguel/mês adicional)

**Caução:** Em geral 2–3 meses de aluguel adiantados. Guarde essa reserva.

**Bairros populares entre argentinos:**
- São Paulo: Vila Madalena, Pinheiros, Moema
- Florianópolis: Lagoa da Conceição, Trindade, Ingleses
- Curitiba: Batel, Água Verde, Cristo Rei

💡 O guia Movaro tem um passo a passo completo para encontrar moradia, incluindo dicas de negociação com imobiliárias.`,

      es: `**Vivienda en Brasil: primeros pasos**

**Estrategia recomendada para los primeros 30–60 días:**
Usá Airbnb, hostel o habitación compartida — no firmes contrato de largo plazo antes de conocer la ciudad. Sin CPF e historial crediticio en Brasil, cerrar un alquiler permanente es difícil.

**Cómo encontrar vivienda permanente:**
- **ZAP Imóveis**, **Viva Real** y **OLX** son los portales más grandes
- Grupos de Facebook: "Argentinos en Floripa/SP/Curitiba" tienen recomendaciones de inmobiliarias sin tanta burocracia
- Las inmobiliarias aceptan garante brasileño o seguro-fianza (5–10% del alquiler/mes adicional)

**Depósito:** En general 2–3 meses de alquiler adelantados. Guardá esa reserva.

**Barrios populares entre argentinos:**
- São Paulo: Vila Madalena, Pinheiros, Moema
- Florianópolis: Lagoa da Conceição, Trindade, Ingleses
- Curitiba: Batel, Água Verde, Cristo Rei

💡 La guía Movaro tiene un paso a paso completo para encontrar vivienda, incluyendo consejos para negociar con inmobiliarias.`,
    },
  },

  // ── Transporte / mobilidade ───────────────────────────────────────────────
  {
    keywords: [
      'transporte', 'transport', 'ônibus', 'onibus', 'bus', 'metro',
      'metrô', 'uber', '99', 'taxi', 'bicicleta', 'bike', 'carro',
      'car', 'automóvel', 'dirigir', 'drive', 'app de transporte',
    ],
    answers: {
      pt: `**Transporte no Brasil**

**Aplicativos de transporte:**
- **Uber** e **99** funcionam em todas as capitais e muitas cidades médias
- **99** costuma ser 20–30% mais barato que Uber. Vale ter os dois
- **InDriver** também disponível em algumas cidades

**Transporte público:**
- Ônibus é o mais comum — cartão de transporte (bilhete único em SP, RioCard no RJ) facilita
- Metrô existe em São Paulo, Rio de Janeiro, Porto Alegre, Recife, Belo Horizonte e Fortaleza
- Integração ônibus+metrô costuma reduzir o custo da viagem

**Carro próprio:**
- CNH argentina é válida por até 180 dias no Brasil. Depois precisa converter para CNH brasileira (via Detran)
- Gasolina custa em média R$ 5,50–6,50/litro (2026)
- Seguro obrigatório (DPVAT) e IPVA anuais são obrigatórios

**Bicicleta:** Grandes cidades têm sistemas de bike compartilhada (Itaú Unibike em SP, Tembici em outras cidades).

💡 Para as primeiras semanas, Uber/99 é a opção mais prática enquanto você aprende a cidade.`,

      es: `**Transporte en Brasil**

**Aplicaciones de transporte:**
- **Uber** y **99** funcionan en todas las capitales y muchas ciudades medianas
- **99** suele ser 20–30% más barato que Uber. Vale la pena tener los dos
- **InDriver** también disponible en algunas ciudades

**Transporte público:**
- El bus es el más común — tarjeta de transporte (bilhete único en SP, RioCard en RJ) facilita el uso
- Metro hay en São Paulo, Rio de Janeiro, Porto Alegre, Recife, Belo Horizonte y Fortaleza

**Auto propio:**
- La licencia argentina es válida por hasta 180 días en Brasil. Después hay que convertirla a CNH brasileña (vía Detran)
- La nafta cuesta en promedio R$ 5,50–6,50/litro (2026)
- Seguro obligatorio (DPVAT) e IPVA anual son obligatorios

**Bicicleta:** Las ciudades grandes tienen sistemas de bici compartida (Itaú Unibike en SP, Tembici en otras ciudades).

💡 Para las primeras semanas, Uber/99 es la opción más práctica mientras aprendés la ciudad.`,
    },
  },

  // ── Trabalho / emprego / CLT ──────────────────────────────────────────────
  {
    keywords: [
      'trabalho', 'trabajo', 'work', 'emprego', 'empleo', 'job', 'clt',
      'contrato', 'contratação', 'contratacion', 'salário minimo',
      'salario minimo', 'minimum wage', 'freelance', 'autônomo', 'autonomo',
      'mei', 'pj', 'nota fiscal', 'cnpj', 'entrevista', 'currículo',
      'curriculo', 'curriculum', 'linkedin', 'mercado de trabalho',
    ],
    answers: {
      pt: `**Trabalho no Brasil para argentinos**

**Modalidades de contratação:**
- **CLT (Carteira Assinada):** Regime formal com direitos trabalhistas (férias, 13º, FGTS, plano de saúde pela empresa). Requer CTPS digital e CPF
- **PJ (Pessoa Jurídica via MEI/CNPJ):** Comum para tech e consultorias. Exige abertura de MEI ou empresa. Paga menos impostos, mas sem benefícios CLT
- **Freelance:** Plataformas como Workana, 99Freelas, GetNinjas

**Salário mínimo (2026):** R$ 1.412/mês. Na prática, profissionais qualificados ganham muito mais — desenvolvedores, designers e profissionais de saúde têm boa remuneração.

**Currículo brasileiro:** Formato diferente do argentino — inclui foto, data de nascimento e estado civil ainda são comuns. Use o LinkedIn em português.

**Setores com alta demanda para argentinos:**
- Tecnologia (dev, dados, produto)
- Design e marketing digital
- Gastronomia e hotelaria
- Educação (espanhol como língua estrangeira)

💡 Com CPF, você já pode trabalhar formalmente. A CTPS digital é emitida online pelo Gov.br.`,

      es: `**Trabajo en Brasil para argentinos**

**Modalidades de contratación:**
- **CLT (Carteira Assinada):** Régimen formal con derechos laborales (vacaciones, aguinaldo, FGTS, plan de salud por la empresa). Requiere CTPS digital y CPF
- **PJ (Persona Jurídica via MEI/CNPJ):** Común en tech y consultorías. Requiere apertura de MEI o empresa. Paga menos impuestos, pero sin beneficios CLT
- **Freelance:** Plataformas como Workana, 99Freelas, GetNinjas

**Salario mínimo (2026):** R$ 1.412/mes. En la práctica, profesionales calificados ganan mucho más — desarrolladores, diseñadores y profesionales de la salud tienen buena remuneración.

**Currículum brasileño:** Formato diferente al argentino — foto, fecha de nacimiento y estado civil todavía son comunes. Usá LinkedIn en portugués.

**Sectores con alta demanda para argentinos:**
- Tecnología (dev, datos, producto)
- Diseño y marketing digital
- Gastronomía y hotelería
- Educación (español como lengua extranjera)

💡 Con CPF, ya podés trabajar formalmente. La CTPS digital se emite online en Gov.br.`,
    },
  },

  // ── Educação / escola / filhos ────────────────────────────────────────────
  {
    keywords: [
      'escola', 'escuela', 'school', 'educação', 'educacion', 'education',
      'filho', 'filha', 'hijos', 'children', 'kids', 'creche', 'jardim',
      'colégio', 'colegio', 'ensino', 'universidade', 'faculdade',
      'vestibular', 'enem', 'bilíngue', 'bilingue', 'bilingual',
    ],
    answers: {
      pt: `**Educação no Brasil para filhos de imigrantes**

**Escola pública:** Gratuita e obrigatória para todos, incluindo filhos de imigrantes (mesmo sem documentação completa). Basta comparecer à secretaria da escola com qualquer documento de identidade da criança e comprovante de endereço.

**Adaptação:** Crianças pequenas (até 10 anos) se adaptam ao português em 2 a 4 meses de imersão escolar. A escola pública tem obrigação de acolher e apoiar a adaptação.

**Escola particular:** Custos variam de R$ 600 (escolas menores) a R$ 5.000+/mês (escolas bilíngues premium). Escolas bilíngues português-espanhol existem em São Paulo e Florianópolis.

**Ensino superior:** Estrangeiros com ensino médio completo podem fazer o ENEM e ingressar em universidades públicas. Revalidação de diploma do ensino médio argentino é simples — feita nas secretarias estaduais de educação.

💡 A matrícula escolar não pode ser negada por falta de CPF da criança — isso é garantido pela Resolução CNE 01/2021.`,

      es: `**Educación en Brasil para hijos de inmigrantes**

**Escuela pública:** Gratuita y obligatoria para todos, incluyendo hijos de inmigrantes (aunque no tengan documentación completa). Solo hay que ir a la secretaría de la escuela con cualquier documento de identidad del niño y comprobante de domicilio.

**Adaptación:** Los niños pequeños (hasta 10 años) se adaptan al portugués en 2 a 4 meses de inmersión escolar. La escuela pública tiene obligación de acoger y apoyar la adaptación.

**Escuela privada:** Los costos varían de R$ 600 (escuelas pequeñas) a R$ 5.000+/mes (escuelas bilingües premium). Hay escuelas bilingüe portugués-español en São Paulo y Florianópolis.

**Educación superior:** Extranjeros con secundaria completa pueden rendir el ENEM e ingresar a universidades públicas. La revalidación del título de secundaria argentina es simple — se hace en las secretarías estatales de educación.

💡 La matrícula escolar no puede ser negada por falta de CPF del niño — eso está garantizado por la Resolución CNE 01/2021.`,
    },
  },

  // ── Banco / dinheiro / Pix ────────────────────────────────────────────────
  {
    keywords: [
      'pix', 'ted', 'doc', 'transferência', 'transferencia', 'transfer',
      'banco digital', 'banco', 'banco inter', 'nubank', 'inter', 'c6', 'itau', 'bradesco',
      'fintech', 'cartão', 'tarjeta', 'card', 'débito', 'crédito',
      'wise', 'remessa', 'remittance', 'enviar dinheiro',
      'abrir conta', 'conta bancária', 'conta corrente', 'conta banco',
      'conta digital', 'como abrir conta',
    ],
    answers: {
      pt: `**Dinheiro e bancos no Brasil**

**Para abrir conta bancária você precisa de:** CPF + documento de identidade + comprovante de endereço. Alguns bancos digitais aceitam endereço ainda em regularização.

**Bancos digitais mais fáceis para imigrantes:**
- **Nubank:** Abre conta online em minutos. Cartão de crédito internacional, sem tarifa
- **Banco Inter:** Conta corrente gratuita, investimentos, cartão sem anuidade
- **C6 Bank:** Aceita imigrantes com documentação em processo

**Enviar dinheiro da Argentina:**
- **Wise (antigo TransferWise):** Taxa mais baixa, câmbio justo, recomendado
- **Remessa Online:** Boa para transferências Brasil ↔ Argentina
- **Western Union / MoneyGram:** Mais caro, mas funciona

**Pix:** Sistema de pagamento instantâneo brasileiro — gratuito, 24h/7 dias. Vira o meio de pagamento principal no dia a dia. Funciona com CPF, número de telefone ou e-mail como chave.

💡 Abra o Nubank primeiro — é o mais rápido e não exige comprovante de renda. Com a conta aberta, o Pix estará disponível imediatamente.`,

      es: `**Dinero y bancos en Brasil**

**Para abrir cuenta bancaria necesitás:** CPF + documento de identidad + comprobante de domicilio. Algunos bancos digitales aceptan domicilio en proceso de regularización.

**Bancos digitales más fáciles para inmigrantes:**
- **Nubank:** Abre cuenta online en minutos. Tarjeta de crédito internacional, sin comisión
- **Banco Inter:** Cuenta corriente gratuita, inversiones, tarjeta sin comisión anual
- **C6 Bank:** Acepta inmigrantes con documentación en proceso

**Enviar dinero desde Argentina:**
- **Wise (ex-TransferWise):** Comisión más baja, cambio justo, recomendado
- **Remessa Online:** Bueno para transferencias Brasil ↔ Argentina
- **Western Union / MoneyGram:** Más caro, pero funciona

**Pix:** Sistema de pago instantáneo brasileño — gratuito, 24h/7 días. Se convierte en el principal medio de pago en el día a día. Funciona con CPF, número de teléfono o e-mail como clave.

💡 Abrí Nubank primero — es el más rápido y no requiere comprobante de ingresos. Con la cuenta abierta, el Pix estará disponible de inmediato.`,
    },
  },
];

@Injectable()
export class FaqResolverService {
  resolve(message: string, locale: string = 'pt'): FaqResolverResult {
    const lower = message.toLowerCase();

    let bestEntry: FaqEntry | null = null;
    let bestScore = 0;

    for (const entry of FAQ_ENTRIES) {
      let score = 0;
      for (const kw of entry.keywords) {
        if (lower.includes(kw)) {
          score += 0.1 + kw.length * 0.015;
        }
      }
      if (score > bestScore) {
        bestScore = score;
        bestEntry = entry;
      }
    }

    if (!bestEntry || bestScore < 0.1) {
      return { found: false, confidence: 0, answer: '' };
    }

    const lang = (locale as 'pt' | 'es' | 'en');
    const answer =
      bestEntry.answers[lang] ??
      bestEntry.answers['pt'] ??
      bestEntry.answers['es'] ??
      '';

    const confidence = Math.min(0.90, 0.60 + bestScore * 0.35);

    return { found: true, confidence, answer };
  }
}
