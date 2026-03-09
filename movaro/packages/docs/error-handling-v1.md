# Error Handling V1 - Movaro

## Visao Geral

O Movaro agora possui uma estrategia unificada de tratamento de erros entre API e app Flutter. A meta desta base nao e apenas capturar falhas tecnicas, mas transformar cada erro em uma resposta previsivel para integracao e em um estado de tela claro para o usuario.

## Arquitetura de Erros na API

O backend padroniza todas as respostas com um envelope unico:

- `ApiResponse<T>`
- `ApiError`

Formato:

- sucesso
  - `success: true`
  - `data: T`
- erro
  - `success: false`
  - `error`

O objeto `ApiError` contem:

- `code`
- `message`
- `userMessage`
- `status`
- `traceId`

Componentes principais:

- `ApiResponseInterceptor`: envolve respostas bem-sucedidas
- `GlobalExceptionFilter`: transforma excecoes em `ApiResponse<never>`
- `HttpExceptionMapper`: converte excecoes NestJS e excecoes do dominio em `ApiError`
- `TraceIdMiddleware`: gera ou reaproveita `x-trace-id` por requisicao
- `AppErrorFactory`: centraliza criacao de erros padronizados

Codigos iniciais adotados:

- `CITY_NOT_FOUND`
- `INTERNAL_ERROR`
- `NETWORK_ERROR`
- `VALIDATION_ERROR`
- `UNAUTHORIZED`
- `RESOURCE_NOT_FOUND`

## Arquitetura de Erros no Flutter

No app, a camada de rede e a camada de UX foram separadas.

Em `core/network/`:

- `NetworkClient`: consome a API com parse do envelope `ApiResponse`
- `ApiErrorModel`: representa o erro retornado pela API
- `ApiException`: erro funcional vindo do backend
- `NetworkException`: falhas de conexao, timeout ou resposta invalida

Em `core/errors/`:

- `ErrorHandler`: converte `ApiException` e `NetworkException` em estado visual
- `UiErrorState`: contrato da experiencia de erro no app

Em `core/widgets/`:

- `LoadingStateWidget`
- `ErrorStateWidget`
- `EmptyStateWidget`

## Boas Praticas de UX de Erro

As telas de erro seguem alguns principios:

- explicar o problema sem linguagem tecnica desnecessaria
- mostrar uma acao principal clara
- permitir retorno simples quando retry nao fizer sentido
- separar erro de vazio e de carregamento
- usar ilustracoes leves para reduzir sensacao de quebra brusca

Por isso, o app agora diferencia:

- `loading`
- `error`
- `empty`
- `success`

## Retry e Falhas de Rede

O `NetworkClient` aplica retry automatico em falhas transitorias de rede:

- sem conexao
- timeout
- indisponibilidade momentanea

O retry e curto e limitado, para evitar congelar a experiencia. Quando o erro persiste, ele sobe para a UI como estado offline claro e com CTA de tentar novamente.

## Como Expandir para Logging Futuro

Esta base foi preparada para evoluir sem reestruturacao profunda:

- `traceId` ja permite correlacionar erro da API com logs futuros
- `ApiError.code` viabiliza dashboards e agrupamentos por categoria
- `ErrorHandler` pode ser conectado depois a analytics ou observabilidade
- `NetworkClient` pode receber instrumentacao central de latencia e falha

Os proximos passos naturais seriam:

- envio de `traceId` para observabilidade externa
- mapeamento de erros por dominio do produto
- telemetria de retry e falhas recorrentes
- componente de feedback contextual para erros recuperaveis
