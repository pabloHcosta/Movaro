# Movaro Web — páginas SEO por cidade

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
Variável opcional: `SITE_BASE_URL` (default `https://movaro.app`) define o domínio
canônico nas meta tags e no sitemap.

## Deploy grátis (escolha um)
- **Netlify**: arraste a pasta `public/` em https://app.netlify.com/drop, **ou**
  conecte o repositório com *base directory* = `apps/web` (ver `netlify.toml`).
- **Cloudflare Pages**: build command vazio, output dir = `apps/web/public`.
- **GitHub Pages / qualquer host estático**: publique o conteúdo de `public/`.

## Preview local
```sh
cd apps/web/public
python3 -m http.server 8091
# abra http://127.0.0.1:8091
```

> Os arquivos gerados em `public/` podem ser commitados (deploy simples) ou
> ignorados e gerados no build/CI — escolha do time.
