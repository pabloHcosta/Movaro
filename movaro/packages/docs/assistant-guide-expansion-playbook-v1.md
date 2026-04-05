# Assistant + Guide Expansion Playbook v1

## Objetivo

Adicionar um novo corredor migratório ao Movaro sem quebrar:

- a tela `Assistente`
- a feature `Guia de mudança`
- os prompts rápidos
- a resolução determinística antes da IA

## Arquitetura atual

Hoje a expansão de corredores passa por duas registries principais:

### Backend

- `apps/api/src/modules/chat/data/guide-catalog.registry.ts`
  - registra o catálogo de guia por corredor
  - define `corridorKey`, `destinationCountry`, `items`, `phaseOrder` e aliases
- `apps/api/src/modules/chat/application/services/resolvers/corridor-guidance-profiles.ts`
  - registra o comportamento do assistente por corredor
  - define respostas rápidas e respostas determinísticas por tópico

### App

- `apps/app/lib/features/migration_questionnaire/application/services/migration_guide_registry.dart`
  - registra qual datasource constrói o guia para cada corredor

## Checklist para novo corredor

### 1. Normalização de país

Atualize:

- `apps/api/src/modules/chat/application/services/chat-country-normalizer.ts`
- `apps/app/lib/features/migration_questionnaire/application/services/migration_guide_registry.dart`

Garanta que aliases como ISO, inglês e português/espanhol normalizem para o mesmo ID canônico.

Exemplo:

- `cl`, `chile` -> `chile`
- `uy`, `uruguay`, `uruguai` -> `uruguai`

### 2. Criar o catálogo do guia

Crie um datasource estruturado no backend com:

- `GuideItem[]`
- `phase`
- `title`
- `summary`
- `notes`

Padrão atual:

- `apps/api/src/modules/chat/data/argentina-brazil-guide.datasource.ts`

Depois registre em:

- `apps/api/src/modules/chat/data/guide-catalog.registry.ts`

Cada catálogo precisa informar:

- `corridorKey`
- `destinationCountry`
- `items`
- `phaseOrder`
- `completedItemAliases` quando existir compatibilidade com IDs legados do app

### 3. Criar o profile do assistente

Adicione um novo `CorridorGuidanceProfile` em:

- `apps/api/src/modules/chat/application/services/resolvers/corridor-guidance-profiles.ts`

Esse profile define:

- label de prompt rápido
- mensagem de prompt rápido
- respostas determinísticas por tópico:
  - `documents`
  - `cpf`
  - `visa`
  - `costs`
  - `housing`
  - `activities`
  - `best_time`

Se o corredor não usar algum tópico, responda de forma curta e segura, sem inventar regra local.

### 4. Criar respostas rápidas do guia

Popular:

- `assistant_guide_answers`
- `assistant_document_entries`
- `assistant_quick_prompt_templates`
- `assistant_faq_entries`

Essas tabelas permitem que o assistente responda com a mesma base usada no guia, antes de cair em IA.

### 5. Registrar o guia no app

Crie o datasource Flutter do corredor e registre em:

- `apps/app/lib/features/migration_questionnaire/application/services/migration_guide_registry.dart`

Ideal:

- um datasource por corredor
- sem `if` espalhado por tela
- sem componentes de UI conhecendo implementação concreta

### 6. Validar o corredor

Rodar no mínimo:

```bash
cd apps/api
npm test -- --runInBand \
  assistant-knowledge.service.spec.ts \
  city-resolver.service.spec.ts \
  corridor-guidance-resolver.service.spec.ts \
  doc-resolver.service.spec.ts \
  guide-catalog.registry.spec.ts
```

```bash
cd apps/app
flutter analyze \
  lib/features/info/presentation/pages/assistant_page.dart \
  lib/features/migration_questionnaire/application/services/migration_guide_registry.dart
```

## Regras de implementação

- Não acoplar resolvers centrais a `ArgentinaBrazilGuideDataSource`.
- Não gerar `corridorKey` com concatenação manual fora dos normalizers.
- Preferir registries a `if/else` espalhado.
- Se o novo corredor ainda não tiver conteúdo suficiente, retornar resposta estruturada de cobertura parcial em vez de depender direto da IA.
- A IA deve ser fallback, não fonte primária.

## Critério de pronto

Um novo corredor está pronto quando:

- o guia aparece na registry
- o assistente responde perguntas rápidas sem IA para os tópicos centrais
- os mesmos temas existem no guia e no assistente
- a normalização de país/corredor está coberta por teste
- não existe lógica crítica acoplada ao nome `argentina-brazil`
