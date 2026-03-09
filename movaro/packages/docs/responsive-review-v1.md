# Responsive Review V1 - Movaro

## Estrategia Adotada

O app recebeu uma camada simples de responsividade em `lib/core/responsive/` para evitar regras espalhadas por tela. A decisao foi manter a base enxuta, com utilitarios suficientes para mobile, tablet e desktop/web sem criar uma arquitetura pesada.

## Breakpoints

Os breakpoints iniciais adotados foram:

- `mobile`: ate `599px`
- `tablet`: de `600px` ate `1023px`
- `desktop/web`: `1024px` ou mais

Esses breakpoints sao usados para ajustar:

- largura maxima do conteudo
- padding horizontal
- espacamento entre secoes

## Utilitarios Criados

Arquivos centrais:

- `app_breakpoints.dart`
- `responsive_context.dart`
- `responsive_content.dart`

Responsabilidades:

- `AppBreakpoints`: constantes de faixas de tela e larguras maximas
- `ResponsiveContext`: helpers para detectar layout e ler espacamentos
- `ResponsiveContent`: centralizacao de conteudo, largura maxima e `SafeArea`

## Ajustes Feitos

- telas centrais passaram a respeitar largura maxima de leitura em telas largas
- telas com formulario ou card agora usam scroll seguro para evitar quebra em telas pequenas ou com teclado aberto
- estados de `loading`, `error` e `empty` passaram a usar uma estrutura responsiva unica
- telas de cidades deixaram de ficar esticadas demais em web
- a home autenticada passou a usar `Wrap` em pontos onde havia risco de overflow horizontal
- linhas de detalhes da cidade foram ajustadas para cair em coluna quando a largura e pequena

## Comportamento em Mobile e Web

Em mobile:

- paddings mais compactos
- scroll garantido em telas longas
- botoes e cards mantidos em largura confortavel

Em web e desktop:

- conteudo centralizado
- largura maxima para leitura mais confortavel
- sem aparencia de app mobile esticado em tela grande

## Evolucao Futura

Esta base foi preparada para crescer de forma gradual:

- layouts laterais para desktop podem ser adicionados sem refatorar cada tela
- navegacao adaptativa pode entrar depois, se o produto pedir
- tabelas, comparadores e dashboards futuros ja podem reaproveitar a camada de breakpoints e conteudo responsivo
