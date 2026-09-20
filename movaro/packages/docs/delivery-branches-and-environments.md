# Branches, ambientes e publicação

## Branches permanentes

| Branch | Finalidade | Ambiente |
| --- | --- | --- |
| `develop` | integração diária de funcionalidades | preview técnico |
| `staging` | homologação do que está prestes a sair | staging |
| `main` | código aprovado e publicável | produção |

`main` é a única branch de produção. Não existe uma `master` paralela.

## Promoção

1. Criar uma branch curta a partir de `develop`, como `feat/nome-da-feature`.
2. Abrir pull request para `develop` e aguardar o CI.
3. Promover `develop` para `staging` por pull request para homologação.
4. Promover `staging` para `main` por pull request para produção.
5. Correções urgentes partem de `main` como `hotfix/nome`, voltam para `main` e depois são sincronizadas em `staging` e `develop`.

Não faça merge direto entre ambientes sem pull request e CI aprovado.

## Publicação por componente

- Site: `develop`, `staging` e `main` publicam branches correspondentes no projeto Cloudflare Pages `mudavi`. O domínio `mudavi.app` fica ligado somente à produção (`main`).
- API: `staging` publica o Worker/Container `mudavi-api-staging`; `main` publica `mudavi-api` em produção.
- Aplicativo Flutter: as três branches executam análise e testes. A análise é
  bloqueante; temporariamente, os testes aparecem no CI sem bloquear a promoção,
  pois a suíte atual ainda tem cenários visuais pendentes. Publicação na App Store
  e Google Play ficará em workflows separados quando certificados, contas e
  revisão de loja estiverem configurados.

## Ambientes do GitHub

Crie os environments `develop`, `staging` e `production`. A variável `DEPLOY_ENABLED` controla a publicação. Os workflows ficam seguros e inativos até cada ambiente possuir suas credenciais.

Segredos necessários para o site:

- `CLOUDFLARE_ACCOUNT_ID`
- `CLOUDFLARE_API_TOKEN`

O site e a API usam as mesmas credenciais Cloudflare, guardadas separadamente
nos environments de homologação e produção.

Em `production`, configure aprovação manual no GitHub Environment se quiser uma barreira adicional antes do deploy. Nunca reutilize o banco de produção em staging.
