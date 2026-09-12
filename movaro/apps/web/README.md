# Mudavi Web

Landing page de apresentação do produto e páginas SEO por cidade.

## Landing page

Aplicação React + TypeScript + Vite em `src/`. Para executar:

```sh
npm install
npm run dev
```

O formulário de acesso antecipado possui apenas o estado visual nesta primeira
etapa. A persistência dos emails será conectada quando o canal de captação for
definido.

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
