# Auth Strategy - Movaro

## Estrategia Guest-First

O Movaro foi estruturado para permitir exploracao real do produto antes do login. Essa decisao reduz friccao de entrada e preserva a autenticacao apenas para momentos em que existe necessidade concreta de persistencia, identidade ou interacao social.

No modo guest, o usuario pode:

- acessar a home publica
- explorar paises e cidades
- navegar por conteudo publico da comunidade
- iniciar a exploracao do checklist migratorio

O login passa a ser exigido quando a acao envolve:

- salvar plano migratorio
- salvar progresso do checklist
- postar na comunidade
- comentar
- favoritar cidades
- sincronizar dados

## Fluxo de Autenticacao

O fluxo base implementado no app segue esta sequencia:

1. `SplashPage`
2. `PublicHomePage`
3. exploracao publica
4. `Auth Gate` ao tentar acessar rota privada
5. `LoginPage`
6. `OnboardingPage`
7. area autenticada do app

Isso significa que o login nao e ponto de entrada obrigatorio do produto. Ele e uma consequencia de uma intencao do usuario.

## Auth Gate

O controle de acesso foi centralizado no router.

Rotas publicas:

- `/home`
- `/explore`
- `/cities`
- `/countries`

Rotas privadas:

- `/community/create`
- `/migration/save`
- `/profile`

Quando uma rota privada e solicitada sem sessao autenticada:

- a rota original e armazenada como intencao pendente
- o app redireciona para `LoginPage`
- depois do login, o app envia o usuario para `OnboardingPage` se necessario
- ao finalizar onboarding, o app retorna para a rota privada originalmente solicitada

## Arquitetura da Feature Auth

A feature `auth` foi separada em camadas:

- `presentation/`
- `application/`
- `domain/`
- `data/`

Abstracoes principais:

- `AuthRepository`
- `AuthDataSource`
- `AuthSession`

Essa organizacao evita acoplamento da interface com a tecnologia de autenticacao concreta.

## FakeAuthDataSource e Evolucao Futura

Foi implementado um `FakeAuthDataSource` apenas para desenvolvimento.

Ele existe para:

- permitir validar o fluxo real de produto
- preservar contratos de autenticacao desde o inicio
- evitar mockar comportamento de maneira artificial dentro da UI

O restante da aplicacao depende de `AuthRepository` e `AuthSession`, nao da implementacao concreta.

Por isso, a substituicao futura por `SupabaseAuthDataSource` pode ocorrer sem refatoracao estrutural das telas, do router ou do fluxo de onboarding. A troca fica restrita a camada `data` e ao bootstrap da aplicacao.
