# Movaro API

API NestJS com adaptador Fastify para os dados e serviços do Movaro.

## Responsabilidades

- catálogo, busca, comparação e detalhes de cidades;
- geração e suporte ao plano migratório;
- contexto do assistente;
- referências de câmbio e dados externos;
- eventos de produto;
- endpoint de saúde.

A aplicação usa validação global, respostas padronizadas, trace ID, limites de
requisição, rate limiting e headers de segurança.

## Desenvolvimento

```bash
npm install
npm run start:dev
```

As variáveis são validadas na inicialização. Consulte os arquivos `.env.*`
locais e `src/common/config/env.validation.ts` para o contrato vigente.

## Validação

```bash
npm run build
npm test -- --runInBand
npm run test:e2e
```

O build também audita o contrato do guia compartilhado com o aplicativo.
