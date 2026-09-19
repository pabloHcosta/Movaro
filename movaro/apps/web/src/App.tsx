import { useEffect, useState, type TouchEvent } from 'react';
import { motion, useReducedMotion, useScroll, useSpring, useTransform } from 'motion/react';
import { ArrowLeft, ArrowRight, BriefcaseBusiness, Calculator, Check, ChevronDown, ChevronRight, ClipboardList, Compass, FileCheck2, HeartHandshake, House, MapPinned, Menu, Route, ShieldCheck, Sparkles, X } from 'lucide-react';
import brandMark from '../../app/assets/brand/mudavi_mark_light.svg';
import brandWordmark from '../../app/assets/brand/mudavi_wordmark_light.svg';
import pabloPhoto from './assets/pablo-costa.jpg';

type Locale = 'es' | 'pt' | 'en';
function detectLocale(): Locale {
  const preferredLanguages = navigator.languages?.length ? navigator.languages : [navigator.language];
  for (const language of preferredLanguages) {
    const code = language.toLowerCase().split('-')[0];
    if (code === 'pt' || code === 'es' || code === 'en') return code;
  }
  return 'es';
}
const languages: { code: Locale; flag: string; label: string }[] = [
  { code: 'es', flag: '🇦🇷', label: 'Español' }, { code: 'pt', flag: '🇧🇷', label: 'Português' }, { code: 'en', flag: '🇺🇸', label: 'English' },
];

const copy = {
  es: {
    nav: ['Cómo funciona', 'Por qué Mudavi', 'Confianza', 'Contanos qué necesitás'], menu: ['Abrir menú', 'Cerrar menú', 'Seleccionar idioma'],
    hero: ['Tu guía para mudarte de Argentina a Brasil', 'Entendé dónde vivir.', 'Y qué resolver primero.', 'Compará ciudades según tu presupuesto y tu forma de vida, anticipá gastos y convertí dudas sobre vivienda, trabajo y documentos en un plan ordenado.', 'Ver Mudavi por dentro', 'Entender cómo funciona', 'Gratis para usar. Sin tarjeta. Con fuentes visibles.'],
    phone: ['Vista previa de la herramienta Mudavi', 'TU PRÓXIMO PASO', 'Tu plan para vivir en Brasil', 'Preparación', 'AHORA', 'Reuní tu documentación', '3 de 5 tareas completadas', 'DESPUÉS', 'Confirmá tu ciudad', 'Florianópolis y 2 alternativas', 'Orientación revisada y fuentes visibles'],
    problem: ['MUCHO MÁS QUE INFORMACIÓN', 'No alcanza con encontrar datos.', 'Hay que entender qué cambian en tu decisión.', 'Mudavi transforma información dispersa en decisiones conectadas y próximos pasos claros.'],
    benefits: [['Decidí con datos que hablan de tu vida', 'Compará ciudades por costo, vivienda, trabajo, clima y rutina, pero leídos desde tus prioridades y restricciones.'], ['Mirá qué resolver ahora y qué puede esperar', 'Tus respuestas se convierten en una secuencia práctica, en el orden que tiene sentido para tu mudanza.'], ['Sabé cuándo confiar y cuándo verificar', 'Mudavi distingue datos, estimaciones y límites, muestra las fuentes y señala cuándo necesitás confirmación oficial.']],
    journey: ['DE TU CONTEXTO A LA ACCIÓN', 'Tu plan nace de tus respuestas y avanza con vos.', 'Cada respuesta cambia las prioridades del plan. Por eso, dos personas que eligen la misma ciudad pueden recibir caminos diferentes.'],
    steps: [['CONTÁ SOBRE VOS', 'Definí qué buscás', 'Objetivo, familia, ingresos y prioridades'], ['ENTENDÉ EL ESCENARIO', 'Compará antes de decidir', 'Ciudad, costos, trabajo y vida cotidiana'], ['SEGUÍ TU RUTA', 'Avanzá con un plan vivo', 'Tareas ordenadas, fuentes y progreso guardado']],
    trust: ['UNA GUÍA, NO UNA CONSULTORÍA', 'Información para avanzar con más claridad.', 'Mudavi es una herramienta gratuita. Organiza información pública y tu contexto para ayudarte a planificar, sin cobrar por el acceso ni vender asesoramiento individual.', 'Fuentes a la vista', 'Sabés qué información consultar y dónde verificarla.', 'Vos tomás las decisiones', 'Mudavi no reemplaza asesoramiento jurídico, migratorio, médico o financiero.'],
    audienceIntro: ['¿TU MUDANZA TODAVÍA ESTÁ TOMANDO FORMA?', 'Si estas preguntas te acompañan, Mudavi empieza por ahí.'],
    audience: ['¿Qué ciudad encaja con mi presupuesto y mi forma de vivir?', '¿Cuánto necesito y qué documentos debería preparar?', '¿Qué conviene resolver ahora y qué puede esperar?'],
    features: ['LO QUE ENCONTRÁS EN MUDAVI', 'Todo lo necesario, sin información dispersa.', 'Un recorrido reúne los temas que normalmente tendrías que buscar en diferentes lugares.', 'Ciudades', 'Costos', 'Vivienda', 'Trabajo', 'Documentos', 'Llegada'],
    founder: ['CREADO ENTRE BRASIL Y ARGENTINA', 'Una herramienta nacida de una experiencia real.', 'Soy Pablo Costa, brasileño, desarrollador y vivo en Argentina. Al convivir con las dudas y decisiones de una mudanza entre países, entendí lo difícil que es transformar información dispersa en acciones concretas.', 'Creé Mudavi para ayudar a quienes planean mudarse de Argentina a Brasil a comparar posibilidades, organizar los preparativos y entender cuál puede ser el próximo paso.', 'Creador y desarrollador'],
    intent: { label: 'AYUDANOS A PRIORIZAR', title: '¿Qué necesitás resolver primero?', intro: 'Elegí la opción más cercana a tu realidad. Son dos respuestas, menos de 20 segundos y ningún dato personal.', question: 'Lo que más necesito es…', options: ['Elegir una ciudad compatible con mi realidad', 'Entender costos, vivienda y trabajo', 'Organizar documentos y próximos pasos', 'Todavía estoy entendiendo si quiero mudarme'], stageQuestion: '¿En qué momento estás?', stages: ['Solo estoy explorando posibilidades', 'Quiero mudarme en los próximos 6 meses', 'Ya empecé a organizar la mudanza'], success: ['Gracias. Esto nos ayuda a construir mejor.', 'Tu respuesta fue registrada sin email ni datos personales.'], privacy: 'Dos respuestas anónimas. Sin email ni registro.', sending: 'Guardando…', error: 'No pudimos guardar tu respuesta. Intentá nuevamente.', restart: 'Cambiar respuesta' }, footer: 'De la incertidumbre al próximo paso.',
  },
  pt: {
    nav: ['Como funciona', 'Por que Mudavi', 'Confiança', 'Conte o que você precisa'], menu: ['Abrir menu', 'Fechar menu', 'Selecionar idioma'],
    hero: ['Seu guia para mudar da Argentina para o Brasil', 'Entenda onde viver.', 'E o que resolver primeiro.', 'Compare cidades de acordo com seu orçamento e estilo de vida, antecipe gastos e transforme dúvidas sobre moradia, trabalho e documentos em um plano organizado.', 'Ver o Mudavi por dentro', 'Entender como funciona', 'Grátis para usar. Sem cartão. Com fontes visíveis.'],
    phone: ['Prévia da ferramenta Mudavi', 'SEU PRÓXIMO PASSO', 'Seu plano para viver no Brasil', 'Preparação', 'AGORA', 'Reúna sua documentação', '3 de 5 tarefas concluídas', 'DEPOIS', 'Confirme sua cidade', 'Florianópolis e 2 alternativas', 'Orientação revisada e fontes visíveis'],
    problem: ['MUITO MAIS QUE INFORMAÇÃO', 'Não basta encontrar dados.', 'É preciso entender o que eles mudam na sua decisão.', 'O Mudavi transforma informações dispersas em decisões conectadas e próximos passos claros.'],
    benefits: [['Decida com dados que conversam com a sua vida', 'Compare cidades por custo, moradia, trabalho, clima e rotina, sempre considerando suas prioridades e restrições.'], ['Veja o que resolver agora e o que pode esperar', 'Suas respostas viram uma sequência prática, na ordem que faz sentido para a sua mudança.'], ['Saiba quando confiar e quando verificar', 'O Mudavi diferencia dados, estimativas e limites, mostra as fontes e indica quando uma confirmação oficial é necessária.']],
    journey: ['DO SEU CONTEXTO À AÇÃO', 'Seu plano nasce das suas respostas e avança com você.', 'Cada resposta muda as prioridades do plano. Por isso, duas pessoas que escolhem a mesma cidade podem receber caminhos diferentes.'],
    steps: [['CONTE SOBRE VOCÊ', 'Defina o que está buscando', 'Objetivo, família, renda e prioridades'], ['ENTENDA O CENÁRIO', 'Compare antes de decidir', 'Cidade, custos, trabalho e vida prática'], ['SIGA SUA ROTA', 'Avance com um plano vivo', 'Tarefas ordenadas, fontes e progresso salvo']],
    trust: ['UM GUIA, NÃO UMA CONSULTORIA', 'Informação para você avançar com mais clareza.', 'O Mudavi é uma ferramenta gratuita. Ele organiza informações públicas e o seu contexto para ajudar no planejamento, sem cobrar pelo acesso nem vender atendimento individual.', 'Fontes à vista', 'Saiba quais informações consultar e onde verificá-las.', 'Você toma as decisões', 'O Mudavi não substitui assessoria jurídica, migratória, médica ou financeira.'],
    audienceIntro: ['SUA MUDANÇA AINDA ESTÁ TOMANDO FORMA?', 'Se estas perguntas acompanham você, o Mudavi começa por elas.'],
    audience: ['Qual cidade combina com meu orçamento e meu jeito de viver?', 'Quanto preciso e quais documentos devo preparar?', 'O que vale resolver agora e o que pode esperar?'],
    features: ['O QUE VOCÊ ENCONTRA NO MUDAVI', 'Tudo o que importa, sem informação espalhada.', 'Uma única jornada reúne os temas que normalmente você precisaria procurar em lugares diferentes.', 'Cidades', 'Custos', 'Moradia', 'Trabalho', 'Documentos', 'Chegada'],
    founder: ['CRIADO ENTRE BRASIL E ARGENTINA', 'Uma ferramenta que nasceu de uma experiência real.', 'Sou Pablo Costa, brasileiro, desenvolvedor e vivo na Argentina. Ao conviver com as dúvidas e decisões de uma mudança entre países, percebi como é difícil transformar informações dispersas em ações concretas.', 'Criei o Mudavi para ajudar quem planeja mudar da Argentina para o Brasil a comparar possibilidades, organizar os preparativos e entender qual pode ser o próximo passo.', 'Criador e desenvolvedor'],
    intent: { label: 'AJUDE A GENTE A PRIORIZAR', title: 'O que você precisa resolver primeiro?', intro: 'Escolha a opção mais próxima da sua realidade. São duas respostas, menos de 20 segundos e nenhum dado pessoal.', question: 'O que eu mais preciso é…', options: ['Escolher uma cidade compatível com minha realidade', 'Entender custos, moradia e trabalho', 'Organizar documentos e próximos passos', 'Ainda estou entendendo se quero me mudar'], stageQuestion: 'Em que momento você está?', stages: ['Só estou pesquisando possibilidades', 'Quero me mudar nos próximos 6 meses', 'Já comecei a organizar a mudança'], success: ['Obrigado. Isso ajuda a construir melhor.', 'Sua resposta foi registrada sem email ou dados pessoais.'], privacy: 'Duas respostas anônimas. Sem email ou cadastro.', sending: 'Salvando…', error: 'Não foi possível salvar sua resposta. Tente novamente.', restart: 'Alterar resposta' }, footer: 'Da incerteza ao próximo passo.',
  },
  en: {
    nav: ['How it works', 'Why Mudavi', 'Trust', 'Tell us what you need'], menu: ['Open menu', 'Close menu', 'Select language'],
    hero: ['Your guide for moving from Argentina to Brazil', 'Understand where to live.', 'And what to solve first.', 'Compare cities around your budget and way of life, anticipate costs, and turn questions about housing, work, and documents into an organized plan.', 'See inside Mudavi', 'See how it works', 'Free to use. No card required. Sources stay visible.'],
    phone: ['Preview of the Mudavi tool', 'YOUR NEXT STEP', 'Your plan for living in Brazil', 'Preparation', 'NOW', 'Gather your documents', '3 of 5 tasks completed', 'NEXT', 'Confirm your city', 'Florianópolis and 2 alternatives', 'Reviewed guidance and visible sources'],
    problem: ['MUCH MORE THAN INFORMATION', 'Finding data is not enough.', 'You need to understand what it changes in your decision.', 'Mudavi turns scattered information into connected decisions and clear next steps.'],
    benefits: [['Decide with data that fits your life', 'Compare cities by cost, housing, work, climate, and routine through the lens of your priorities and constraints.'], ['See what to solve now and what can wait', 'Your answers become a practical sequence, in the order that makes sense for your move.'], ['Know when to trust and when to verify', 'Mudavi separates data, estimates, and limits, shows its sources, and flags when official confirmation matters.']],
    journey: ['FROM YOUR CONTEXT TO ACTION', 'Your plan starts with your answers and moves with you.', 'Every answer changes the plan’s priorities. Two people choosing the same city can therefore receive different paths.'],
    steps: [['TELL US ABOUT YOU', 'Define what you are looking for', 'Goal, family, income, and priorities'], ['UNDERSTAND THE SCENARIO', 'Compare before deciding', 'City, costs, work, and daily life'], ['FOLLOW YOUR ROUTE', 'Move forward with a living plan', 'Ordered tasks, sources, and saved progress']],
    trust: ['A GUIDE, NOT A CONSULTANCY', 'Information to help you move forward with clarity.', 'Mudavi is a free tool. It organizes public information and your context to support your planning, without charging for access or selling individual advice.', 'Sources in view', 'Know what information to consult and where to verify it.', 'You make the decisions', 'Mudavi does not replace legal, immigration, medical, or financial advice.'],
    audienceIntro: ['IS YOUR MOVE STILL TAKING SHAPE?', 'If these questions are on your mind, Mudavi starts with them.'],
    audience: ['Which city fits my budget and the way I want to live?', 'How much will I need and which documents should I prepare?', 'What should I solve now, and what can wait?'],
    features: ['WHAT YOU FIND IN MUDAVI', 'Everything that matters, without scattered information.', 'One journey brings together the topics you would normally have to find in different places.', 'Cities', 'Costs', 'Housing', 'Work', 'Documents', 'Arrival'],
    founder: ['CREATED BETWEEN BRAZIL AND ARGENTINA', 'A tool born from real experience.', 'I am Pablo Costa, a Brazilian developer living in Argentina. Living with the questions and decisions involved in moving between countries showed me how difficult it is to turn scattered information into concrete action.', 'I created Mudavi to help people planning a move from Argentina to Brazil compare possibilities, organize their preparation, and understand what their next step could be.', 'Creator and developer'],
    intent: { label: 'HELP US PRIORITIZE', title: 'What do you need to solve first?', intro: 'Choose the option closest to your situation. Two answers, less than 20 seconds, and no personal data.', question: 'What I need most is…', options: ['Choose a city that fits my reality', 'Understand costs, housing, and work', 'Organize documents and next steps', 'I am still deciding whether to move'], stageQuestion: 'Where are you in the process?', stages: ['I am only exploring possibilities', 'I want to move within the next 6 months', 'I have already started organizing the move'], success: ['Thank you. This helps us build better.', 'Your answer was recorded without email or personal data.'], privacy: 'Two anonymous answers. No email or signup.', sending: 'Saving…', error: 'We could not save your answer. Please try again.', restart: 'Change answer' }, footer: 'From uncertainty to your next step.',
  },
} as const;

const tourImages = ['/product-tour/01-home.jpg', '/product-tour/02-profile.jpg', '/product-tour/03-city.jpg', '/product-tour/04-work.jpg', '/product-tour/05-season.jpg', '/product-tour/06-plan.jpg', '/product-tour/07-topics.jpg', '/product-tour/08-step.jpg'];
const tourOrder = [5, 2, 7, 0, 1, 3, 4, 6];
const tourCopy = {
  pt: {
    intro: ['O MUDAVI POR DENTRO', 'Conheça o caminho antes de começar.', 'Telas reais do produto mostram como uma dúvida vira contexto, comparação e um plano que você consegue seguir.'],
    items: [['Comece pela sua dúvida', 'Encontre cidades, compare uma opção ou resolva temas práticos sem precisar saber por onde começar.'], ['Conte o que importa', 'Um perfil rápido entende o objetivo da mudança e evita recomendações genéricas.'], ['Conheça cada cidade', 'Veja uma leitura clara de custo, moradia, trabalho, rotina e infraestrutura.'], ['Entenda os dados', 'Números ganham contexto, limites e explicações para não parecerem uma resposta mágica.'], ['Antecipe os momentos difíceis', 'Sazonalidade e outros fatores revelam impactos reais na moradia e no trabalho.'], ['Transforme escolha em plano', 'A cidade escolhida vira uma jornada organizada, com o próximo passo sempre visível.'], ['Resolva por assunto', 'Documentos, moradia, trabalho, saúde e vida cotidiana ficam acessíveis em um só lugar.'], ['Avance com responsabilidade', 'Cada etapa explica o que fazer, quando verificar e onde uma fonte oficial é indispensável.']],
    controls: ['Tela anterior', 'Próxima tela', 'Ir para a tela'],
  },
  es: {
    intro: ['MUDAVI POR DENTRO', 'Conocé el camino antes de empezar.', 'Pantallas reales del producto muestran cómo una duda se convierte en contexto, comparación y un plan posible.'],
    items: [['Empezá por tu duda', 'Encontrá ciudades, compará una opción o resolvé temas prácticos sin saber todavía por dónde empezar.'], ['Contá lo que importa', 'Un perfil rápido entiende el objetivo de la mudanza y evita recomendaciones genéricas.'], ['Conocé cada ciudad', 'Mirá una lectura clara de costo, vivienda, trabajo, rutina e infraestructura.'], ['Entendé los datos', 'Los números incluyen contexto, límites y explicaciones para no parecer una respuesta mágica.'], ['Anticipá los momentos difíciles', 'La estacionalidad y otros factores muestran impactos reales en vivienda y trabajo.'], ['Convertí tu elección en un plan', 'La ciudad elegida se transforma en una jornada ordenada con el próximo paso siempre visible.'], ['Resolvé por tema', 'Documentos, vivienda, trabajo, salud y vida cotidiana quedan reunidos en un solo lugar.'], ['Avanzá con responsabilidad', 'Cada etapa explica qué hacer, cuándo verificar y dónde una fuente oficial es indispensable.']],
    controls: ['Pantalla anterior', 'Pantalla siguiente', 'Ir a la pantalla'],
  },
  en: {
    intro: ['INSIDE MUDAVI', 'See the path before you begin.', 'Real product screens show how a question becomes context, comparison, and a plan you can follow.'],
    items: [['Start with your question', 'Find cities, compare an option, or solve practical topics without already knowing where to begin.'], ['Share what matters', 'A quick profile understands your goal and avoids generic recommendations.'], ['Get to know each city', 'See a clear view of costs, housing, work, daily life, and infrastructure.'], ['Understand the data', 'Numbers come with context, limits, and explanations instead of pretending to be a magic answer.'], ['Anticipate difficult moments', 'Seasonality and other factors reveal real effects on housing and work.'], ['Turn a choice into a plan', 'Your chosen city becomes an organized journey with the next step always in view.'], ['Solve things by topic', 'Documents, housing, work, health, and daily life stay accessible in one place.'], ['Move forward responsibly', 'Every step explains what to do, when to verify, and where an official source is essential.']],
    controls: ['Previous screen', 'Next screen', 'Go to screen'],
  },
} as const;

const benefitIcons = [Compass, Route, FileCheck2];
const audienceIcons = [MapPinned, FileCheck2, ClipboardList];
const featureIcons = [MapPinned, Calculator, House, BriefcaseBusiness, FileCheck2, Route];
const intentIcons = [MapPinned, Calculator, FileCheck2, Compass];
const intentCategories = ['cityFit', 'costsAndHousing', 'documentsAndSteps', 'stillExploring'] as const;
const moveStages = ['exploring', 'withinSixMonths', 'organizingMove'] as const;
type IntentCategory = (typeof intentCategories)[number];
type MoveStage = (typeof moveStages)[number];
const reveal = { hidden: { opacity: 0, y: 24 }, visible: { opacity: 1, y: 0 } };
const apiBaseUrl = (import.meta.env.VITE_API_BASE_URL ?? 'http://localhost:3000').replace(/\/$/, '');
function getSiteSessionId() {
  const key = 'mudavi-site-session-id';
  try {
    const existing = sessionStorage.getItem(key);
    if (existing) return existing;
    const created = crypto.randomUUID();
    sessionStorage.setItem(key, created);
    return created;
  } catch {
    return crypto.randomUUID();
  }
}
function Logo() { return <a className="logo" href="#inicio" aria-label="Mudavi"><img className="logo-wordmark" src={brandWordmark} alt="" /></a>; }

function LanguageSelector({ locale, onChange, label }: { locale: Locale; onChange: (value: Locale) => void; label: string }) {
  const [open, setOpen] = useState(false); const current = languages.find((item) => item.code === locale)!;
  return <div className="language-selector"><button className="language-trigger" type="button" onClick={() => setOpen(!open)} aria-expanded={open} aria-label={label}><span aria-hidden="true">{current.flag}</span><span>{current.code.toUpperCase()}</span><ChevronDown size={14} /></button>{open && <div className="language-menu" role="menu">{languages.map((item) => <button type="button" role="menuitem" className={item.code === locale ? 'active' : ''} key={item.code} onClick={() => { onChange(item.code); setOpen(false); }}><span aria-hidden="true">{item.flag}</span><span>{item.label}</span>{item.code === locale && <Check size={15} />}</button>)}</div>}</div>;
}

function PhonePreview({ text }: { text: readonly string[] }) { return <div className="phone-wrap" aria-label={text[0]}><div className="phone-shadow" /><div className="phone"><span className="dynamic-island" aria-hidden="true" /><img className="phone-screen" src="/product-tour/06-plan.jpg" alt={text[0]} /></div></div>; }

function ProductTour({ locale }: { locale: Locale }) {
  const [active, setActive] = useState(0);
  const [touchStart, setTouchStart] = useState<{ x: number; y: number } | null>(null);
  const reduceMotion = useReducedMotion();
  const text = tourCopy[locale];
  const items = tourOrder.map((index) => text.items[index]);
  const images = tourOrder.map((index) => tourImages[index]);
  const select = (index: number) => setActive((index + images.length) % images.length);
  const onTouchEnd = (event: TouchEvent) => {
    if (touchStart === null) return;
    const distanceX = event.changedTouches[0].clientX - touchStart.x;
    const distanceY = event.changedTouches[0].clientY - touchStart.y;
    if (Math.abs(distanceX) > 45 && Math.abs(distanceX) > Math.abs(distanceY)) select(active + (distanceX < 0 ? 1 : -1));
    setTouchStart(null);
  };

  return <section className="product-tour band" id="produto">
    <div className="tour-heading"><div><p className="section-label">{text.intro[0]}</p><h2>{text.intro[1]}</h2></div><p>{text.intro[2]}</p></div>
    <div className="tour-stage">
      <div className="tour-copy" aria-live="polite"><span className="tour-count">{String(active + 1).padStart(2, '0')} / {String(images.length).padStart(2, '0')}</span><h3>{items[active][0]}</h3><p>{items[active][1]}</p><div className="tour-arrows"><button type="button" onClick={() => select(active - 1)} aria-label={text.controls[0]}><ArrowLeft /></button><button type="button" onClick={() => select(active + 1)} aria-label={text.controls[1]}><ArrowRight /></button></div></div>
      <div className="tour-device" onTouchStart={(event) => setTouchStart({ x: event.touches[0].clientX, y: event.touches[0].clientY })} onTouchEnd={onTouchEnd}>
        <div className="tour-glow" /><div className="tour-phone"><span className="tour-island" /><motion.img key={images[active]} src={images[active]} alt={items[active][0]} initial={{ opacity: 0, scale: .985 }} animate={{ opacity: 1, scale: 1 }} transition={{ duration: .35 }} /></div>
      </div>
      <div className="tour-mobile-panel"><div className="tour-mobile-controls"><button type="button" onClick={() => select(active - 1)} aria-label={text.controls[0]}><ArrowLeft /></button><div className="tour-mobile-status"><span>{String(active + 1).padStart(2, '0')} / {String(images.length).padStart(2, '0')}</span><div aria-hidden="true">{images.map((image, index) => <i key={image} className={index === active ? 'active' : ''} />)}</div></div><button type="button" onClick={() => select(active + 1)} aria-label={text.controls[1]}><ArrowRight /></button></div><motion.div className="tour-mobile-copy" key={`${locale}-${active}`} initial={{ opacity: 0, y: 8 }} animate={{ opacity: 1, y: 0 }} transition={{ duration: reduceMotion ? 0 : .3 }} aria-live="polite"><h3>{items[active][0]}</h3><p>{items[active][1]}</p></motion.div></div>
      <div className="tour-index-shell"><div className="tour-progress-track" aria-hidden="true"><motion.span animate={{ scaleX: (active + 1) / images.length }} transition={{ duration: reduceMotion ? 0 : .45, ease: [.22, 1, .36, 1] }} /></div><div className="tour-index">{items.map(([title], index) => <button type="button" key={title} className={index === active ? 'active' : ''} onClick={() => select(index)} aria-label={`${text.controls[2]} ${index + 1}: ${title}`} aria-current={index === active ? 'step' : undefined}><span className="tour-thumbnail"><img src={images[index]} alt="" loading="lazy" /></span><span className="tour-index-number">{String(index + 1).padStart(2, '0')}</span><strong>{title}</strong></button>)}</div></div>
    </div>
  </section>;
}

export function App() {
  const [locale, setLocale] = useState<Locale>(detectLocale);
  const [menuOpen, setMenuOpen] = useState(false); const [selectedIntent, setSelectedIntent] = useState<IntentCategory | null>(null); const [sent, setSent] = useState(false); const [sending, setSending] = useState(false); const [submitError, setSubmitError] = useState(false); const reduceMotion = useReducedMotion(); const t = copy[locale];
  const { scrollYProgress } = useScroll();
  const progress = useSpring(scrollYProgress, { stiffness: 120, damping: 28, mass: .25 });
  const phoneY = useTransform(scrollYProgress, [0, .22], [0, reduceMotion ? 0 : 90]);
  useEffect(() => { document.documentElement.lang = locale; document.title = `Mudavi | ${t.hero[1]} ${t.hero[2]}`; }, [locale, t.hero]);
  useEffect(() => {
    if (!menuOpen || !window.matchMedia('(max-width: 900px)').matches) return;
    const previousOverflow = document.body.style.overflow;
    const closeOnEscape = (event: KeyboardEvent) => { if (event.key === 'Escape') setMenuOpen(false); };
    document.body.style.overflow = 'hidden';
    window.addEventListener('keydown', closeOnEscape);
    return () => { document.body.style.overflow = previousOverflow; window.removeEventListener('keydown', closeOnEscape); };
  }, [menuOpen]);
  const changeLocale = (value: Locale) => { setLocale(value); setMenuOpen(false); setSelectedIntent(null); setSent(false); setSubmitError(false); };
  const selectIntent = (value: IntentCategory) => { setSelectedIntent(value); setSubmitError(false); };
  const submitIntent = async (moveStage: MoveStage) => {
    if (!selectedIntent || sending) return;
    setSending(true); setSubmitError(false);
    try {
      const response = await fetch(`${apiBaseUrl}/api/v1/site-analytics/intent`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json', 'x-mudavi-client': 'landing-page' },
        body: JSON.stringify({ sessionId: getSiteSessionId(), locale, intentCategory: selectedIntent, moveStage }),
      });
      if (!response.ok) throw new Error('Intent submission failed');
      setSent(true);
    } catch { setSubmitError(true); }
    finally { setSending(false); }
  };
  return <div className="site-shell"><motion.div className="reading-progress" style={{ scaleX: progress }} /><header className="nav-shell"><nav className="nav" aria-label="Mudavi"><Logo /><div id="site-navigation" className={`nav-links ${menuOpen ? 'open' : ''}`}><a href="#como-funciona" onClick={() => setMenuOpen(false)}>{t.nav[0]}</a><a href="#diferencial" onClick={() => setMenuOpen(false)}>{t.nav[1]}</a><a href="#confianza" onClick={() => setMenuOpen(false)}>{t.nav[2]}</a><a className="nav-cta" href="#acceso" onClick={() => setMenuOpen(false)}>{t.nav[3]}</a></div><div className="nav-tools"><LanguageSelector locale={locale} onChange={changeLocale} label={t.menu[2]} /><button className="menu-button" type="button" onClick={() => setMenuOpen(!menuOpen)} aria-controls="site-navigation" aria-expanded={menuOpen} aria-label={menuOpen ? t.menu[1] : t.menu[0]}>{menuOpen ? <X /> : <Menu />}</button></div></nav></header><main>
    <section className="hero" id="inicio"><div className="hero-light" /><div className="hero-countries" aria-hidden="true"><div className="country-flag country-arg"><span /><small>ARG</small></div><div className="country-route"><span>ARG</span><i /><ArrowRight /><span>BR</span></div><div className="country-flag country-br"><span /><small>BR</small></div></div><div className="hero-inner"><motion.div className="hero-copy" initial="hidden" animate="visible" variants={reveal} transition={{ duration: reduceMotion ? 0 : .7 }}><div className="eyebrow"><span>01</span>{t.hero[0]}</div><h1>{t.hero[1]}<br /><span>{t.hero[2]}</span></h1><p className="hero-lead">{t.hero[3]}</p><div className="hero-actions"><a className="button button-primary" href="#produto">{t.hero[4]}<ArrowRight size={18} /></a><a className="text-link" href="#como-funciona">{t.hero[5]}<ChevronRight size={17} /></a></div><div className="trust-line"><ShieldCheck size={18} /><span>{t.hero[6]}</span></div></motion.div><motion.div className="hero-product" style={{ y: phoneY }} initial={{ opacity: 0, scale: .9, rotate: 3 }} animate={{ opacity: 1, scale: 1, rotate: 0 }} transition={{ duration: reduceMotion ? 0 : 1.1, delay: .15, ease: [.22, 1, .36, 1] }}><span className="product-caption">MUDAVI / PRODUCT 01</span><PhonePreview text={t.phone} /></motion.div></div><a className="scroll-cue" href="#produto" aria-label={t.hero[4]}><span /></a></section>
    <section className="audience-strip" aria-labelledby="audience-title"><motion.div className="audience-heading" initial="hidden" whileInView="visible" viewport={{ once: true, amount: .45 }} variants={reveal}><p>{t.audienceIntro[0]}</p><h2 id="audience-title">{t.audienceIntro[1]}</h2></motion.div><div className="audience-path">{t.audience.map((item, index) => { const Icon = audienceIcons[index]; return <motion.article key={item} initial={{ opacity: 0, y: 28 }} whileInView={{ opacity: 1, y: 0 }} viewport={{ once: true, amount: .35 }} transition={{ duration: reduceMotion ? 0 : .6, delay: reduceMotion ? 0 : index * .13 }}><span className="audience-number">0{index + 1}</span><span className="audience-icon"><Icon size={28} strokeWidth={1.7} /></span><p>{item}</p><span className="audience-dot" aria-hidden="true" /></motion.article>; })}</div></section>
    <ProductTour locale={locale} />
    <section className="problem band" id="como-funciona"><motion.div className="section-intro" initial="hidden" whileInView="visible" viewport={{ once: true, amount: .4 }} variants={reveal}><p className="section-label">{t.problem[0]}</p><h2>{t.problem[1]}<br />{t.problem[2]}</h2><p>{t.problem[3]}</p></motion.div><div className="benefit-grid">{t.benefits.map(([title, text], index) => { const Icon = benefitIcons[index]; return <motion.article className={`benefit benefit-${index + 1}`} key={title} initial="hidden" whileInView="visible" viewport={{ once: true, amount: .3 }} variants={reveal} transition={{ duration: reduceMotion ? 0 : .6, delay: reduceMotion ? 0 : index * .12 }}><span className="benefit-icon"><Icon size={32} strokeWidth={1.7} /></span><span className="benefit-number">0{index + 1}</span><h3>{title}</h3><p>{text}</p></motion.article>; })}</div></section>
    <section className="journey band" id="diferencial"><motion.div className="journey-copy" initial="hidden" whileInView="visible" viewport={{ once: true, amount: .3 }} variants={reveal}><p className="section-label">{t.journey[0]}</p><h2>{t.journey[1]}</h2><p>{t.journey[2]}</p></motion.div><div className="journey-visual" aria-label={t.journey[1]}><motion.div className="route-line" initial={{ scaleY: 0 }} whileInView={{ scaleY: 1 }} viewport={{ once: true, amount: .15 }} transition={{ duration: reduceMotion ? 0 : 1.1, ease: [.22, 1, .36, 1] }} />{t.steps.map(([label, title, text], index) => <motion.div className="route-step" key={title} initial={{ opacity: .3, y: 18 }} whileInView={{ opacity: 1, y: 0 }} viewport={{ once: true, amount: .15 }} transition={{ duration: reduceMotion ? 0 : .55, delay: reduceMotion ? 0 : index * .14 }}><motion.span whileInView={{ backgroundColor: '#64daf1', color: '#07172b', scale: [1, 1.12, 1] }} viewport={{ once: true, amount: .2 }} transition={{ duration: reduceMotion ? 0 : .7, delay: reduceMotion ? 0 : index * .16 }}>{index + 1}</motion.span><div><small>{label}</small><strong>{title}</strong><p>{text}</p></div></motion.div>)}</div></section>
    <section className="features band" id="recursos"><div className="features-heading"><div><p className="section-label">{t.features[0]}</p><h2>{t.features[1]}</h2></div><p>{t.features[2]}</p></div><div className="feature-rail">{t.features.slice(3).map((title, index) => { const Icon = featureIcons[index]; return <motion.div key={title} initial={{ opacity: 0, y: 14 }} whileInView={{ opacity: 1, y: 0 }} viewport={{ once: true, amount: .4 }} transition={{ delay: reduceMotion ? 0 : index * .06 }}><Icon size={22} /><span>{title}</span></motion.div>; })}</div></section>
    <section id="criador" className="founder band"><div className="founder-profile"><img className="founder-avatar" src={pabloPhoto} alt="Pablo Costa" width="720" height="678" loading="lazy" decoding="async" /><div><strong>Pablo Costa</strong><small>{t.founder[4]}</small><span><span>🇧🇷</span><ArrowRight size={13} /><span>🇦🇷</span></span></div></div><div className="founder-story"><p className="section-label">{t.founder[0]}</p><h2>{t.founder[1]}</h2><p>{t.founder[2]}</p><p>{t.founder[3]}</p></div></section>
    <section className="trust band" id="confianza"><div className="trust-symbol"><img src={brandMark} alt="" /></div><div className="trust-copy"><p className="section-label">{t.trust[0]}</p><h2>{t.trust[1]}</h2><p>{t.trust[2]}</p></div><div className="trust-points"><div><ShieldCheck /><span><strong>{t.trust[3]}</strong>{t.trust[4]}</span></div><div><HeartHandshake /><span><strong>{t.trust[5]}</strong>{t.trust[6]}</span></div></div></section>
    <section className="signup intent-capture" id="acceso"><div className="signup-inner"><p className="section-label">{t.intent.label}</p><h2>{t.intent.title}</h2><p>{t.intent.intro}</p>{sent ? <div className="intent-success" role="status"><span><Check size={22} /></span><div><strong>{t.intent.success[0]}</strong><p>{t.intent.success[1]}</p></div><button type="button" onClick={() => { setSent(false); setSelectedIntent(null); }}>{t.intent.restart}</button></div> : <div className="intent-flow"><fieldset><legend>{t.intent.question}</legend><div className="intent-options">{intentCategories.map((value, index) => { const Icon = intentIcons[index]; return <button type="button" key={value} className={selectedIntent === value ? 'selected' : ''} aria-pressed={selectedIntent === value} onClick={() => selectIntent(value)}><Icon size={23} /><span>{t.intent.options[index]}</span>{selectedIntent === value && <Check size={18} />}</button>; })}</div></fieldset>{selectedIntent && <motion.fieldset className="stage-step" initial={{ opacity: 0, y: 10 }} animate={{ opacity: 1, y: 0 }}><legend>{t.intent.stageQuestion}</legend><div className="stage-options">{moveStages.map((value, index) => <button type="button" key={value} disabled={sending} onClick={() => submitIntent(value)}><span>{index + 1}</span>{sending ? t.intent.sending : t.intent.stages[index]}<ArrowRight size={17} /></button>)}</div></motion.fieldset>}{submitError && <p className="form-error" role="alert">{t.intent.error}</p>}</div>}<small>{t.intent.privacy}</small></div></section>
  </main><footer><Logo /><p>{t.footer}</p><span>© {new Date().getFullYear()} Mudavi</span></footer></div>;
}
