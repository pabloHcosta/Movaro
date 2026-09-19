# Mudavi Web

Landing page de apresentação do produto e páginas SEO por cidade.

## Landing page

Aplicação React + TypeScript + Vite em `src/`. Para executar:

```sh
npm install
npm run dev
```

A validação de interesse faz duas perguntas de resposta fechada, sem solicitar
email ou outros dados pessoais, e envia o sinal anônimo para
`POST /api/v1/site-analytics/intent`. Configure `VITE_API_BASE_URL` com a URL
pública da API (consulte `.env.example`). A API grava apenas a necessidade
principal, o estágio da mudança, o idioma e um identificador efêmero de sessão
na tabela `public.landing_page_intent_signals`; nenhuma chave do Supabase fica
exposta no navegador.

## Páginas SEO por cidade

Páginas estáticas (HTML) para SEO: "vivir en &lt;ciudad&gt; Brasil / costo / trabajo".
Flutter web é ruim para SEO, então estas páginas dão conteúdo real e indexável
aos buscadores — funil de aquisição do ICP primário (migrante econômico).

## Conteúdo
`public/` é **gerado** (não editar à mão):
- `index.html` — lista de cidades por região
- `cidades/<id>.html` — uma página por cidade (custo, trabalho, trâmites)
- `sitemap.xml`, `robots.txt`

## Regenerar (após mudar dados de cidade)
```sh
cd apps/api
npm run export:snapshot        # se mexeu nos dados/seeds da API
npm run generate:city-pages    # gera apps/web/public/**
```
Variável opcional: `SITE_BASE_URL` define o domínio
canônico nas meta tags e no sitemap.

## Deploy grátis (escolha um)
- **Netlify**: arraste a pasta `public/` em https://app.netlify.com/drop, **ou**
  conecte o repositório com *base directory* = `apps/web` (ver `netlify.toml`).
- **Cloudflare Pages**: build command vazio, output dir = `apps/web/public`.
- **GitHub Pages / qualquer host estático**: publique o conteúdo de `public/`.

> Os arquivos gerados em `public/` podem ser commitados (deploy simples) ou
> ignorados e gerados no build/CI — escolha do time.
