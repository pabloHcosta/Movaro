# Movaro

Movaro transforma a decisão de mudar de país em um plano executável. O
produto atual é focado no corredor Argentina → Brasil: ajuda a escolher uma
cidade, organiza a preparação na ordem certa e mantém documentos, custos,
moradia, trabalho, saúde e chegada em um único fluxo.

## O que o produto entrega

- descoberta e comparação de cidades brasileiras;
- recomendação de cidade a partir do objetivo, prazo e prioridades;
- refinamento explícito para família e crianças, tipo de renda, pets,
  medicação contínua, veículo e fonte de recursos;
- plano personalizado com etapas condicionais e ordem por dependência;
- acompanhamento da execução, progresso persistente, fontes e alertas;
- ferramentas de apoio para documentação, idioma, segurança, câmbio e
  contexto da cidade;
- experiência em português, espanhol e inglês.

O Movaro é uma ferramenta de orientação e planejamento. Ele não substitui
aconselhamento jurídico, migratório, médico ou financeiro profissional.

## Fluxo principal

1. O usuário confirma origem e destino.
2. Informa objetivo, prazo e prioridades.
3. Decide se quer refinar o contexto pessoal.
4. Analisa a cidade recomendada e as alternativas.
5. Confirma uma cidade.
6. Executa o plano guiado e acompanha o progresso.

Quem já conhece a cidade pode ir diretamente à exploração, validar a escolha
e gerar o plano sem passar pela recomendação.

## Arquitetura

```text
apps/
  app/                  Flutter (Android, iOS, web e desktop)
  api/                  NestJS + Fastify
packages/
  contracts/            Contratos compartilhados
  docs/                 Estratégia, arquitetura e auditorias de conteúdo
infra/
  supabase/             Banco de dados e infraestrutura
```

O aplicativo segue organização por funcionalidades e separa apresentação,
aplicação, domínio e dados. A API expõe módulos de cidades, detalhes de
cidade, migração, assistente, referências, analytics e saúde. Dados locais
permitem que os fluxos essenciais continuem úteis quando serviços externos
estão indisponíveis.

## Executar o aplicativo

Requisitos: Flutter compatível com o SDK declarado em
`apps/app/pubspec.yaml`.

```bash
cd apps/app
flutter pub get
flutter run \
  --target lib/main_development.dart \
  --dart-define-from-file=.env.development.json
```

Para uma compilação de produção:

```bash
cd apps/app
flutter build web \
  --release \
  --target lib/main_production.dart \
  --dart-define-from-file=.env.production.json
```

## Executar a API

Requisitos: Node.js e npm.

```bash
cd apps/api
npm install
npm run start:dev
```

## Qualidade

```bash
cd apps/app
flutter analyze
flutter test

cd ../api
npm run build
npm test -- --runInBand
```

Antes de publicar, confirme as variáveis de ambiente e as chaves externas,
restrinja as chaves de cliente por aplicativo/domínio e execute o checklist
em `packages/docs/store-release-readiness-v1.md`.
