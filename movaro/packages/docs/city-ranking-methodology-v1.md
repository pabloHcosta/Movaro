# City Ranking Methodology V1 - Movaro

## Categorias de Ranking

O MVP do Movaro expoe rankings por intencao:

- `economical`
- `popular_argentina`
- `work`
- `overall`

Cada categoria responde a uma pergunta diferente do usuario. Isso evita colapsar necessidades distintas em uma unica lista.

## Logica de Score

Formula inicial:

- `economical = media(costOfLivingScore, rentScore)`
- `popularForArgentinians = argentinaPopularityScore`
- `workOpportunity = 0.45 * jobMarketScore + 0.35 * economicActivityScore + 0.20 * scoreInvertidoDeDesemprego`
- `overall = 0.30 * economical + 0.25 * safetyScore + 0.30 * workOpportunity + 0.15 * popularForArgentinians`

Interpretacao:

- scores mais altos significam melhor aderencia a aquela intencao especifica
- custo e aluguel sao tratados como scores de acessibilidade, nao como preco bruto
- desemprego entra invertido para favorecer cidades com sinal economico mais forte

## recommendationReasons

O backend gera razoes resumidas por cidade, por exemplo:

- `Boa opcao para quem prioriza custo`
- `Popular entre argentinos`
- `Mercado de trabalho mais forte`
- `Custo mais alto, mas melhor infraestrutura`

Essas razoes ajudam o usuario a entender por que uma cidade apareceu em destaque.

## Limitacoes do MVP

As limitacoes atuais sao explicitas:

- dataset local ainda e curado manualmente
- nao ha serie historica ou persistencia em banco
- os scores nao representam diagnostico definitivo
- o ranking ainda nao considera perfil individual profundo do usuario

Mesmo assim, a base ja e suficiente para exploracao do catalogo, destaques por categoria e detalhamento inicial de cidades com metodologia transparente.
