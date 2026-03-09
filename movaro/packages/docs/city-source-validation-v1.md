# City Source Validation V1 - Movaro

## Objetivo

Validar se as fontes hoje exibidas no catalogo de cidades do Movaro sao as mais confiaveis disponiveis para cada grupo de dado.

## Resultado da Validacao

### 1. Identidade territorial

Status: validado como melhor fonte atual.

Fonte recomendada:

- IBGE API de Localidades

Motivo:

- e a referencia oficial para municipio, UF, codigo IBGE e recortes territoriais
- possui documentacao publica e contrato estavel

Links:

- https://servicodados.ibge.gov.br/api/docs/localidades

### 2. Populacao

Status: validado como melhor fonte atual.

Fonte recomendada:

- IBGE Cidades e Estados
- IBGE estimativas populacionais / panorama municipal

Motivo:

- e a referencia oficial mais direta e confiavel para populacao municipal
- permite apontar para a pagina concreta do municipio

Links:

- https://cidades.ibge.gov.br/
- https://agenciadenoticias.ibge.gov.br/agencia-noticias/2012-agencia-de-noticias/noticias/41111-populacao-estimada-do-pais-chega-a-212-6-milhoes-de-habitantes-em-2024

### 3. Seguranca

Status: a fonte atual curada nao e a mais confiavel possivel.

Melhor referencia oficial recomendada:

- Atlas da Violencia (Ipea + FBSP), com taxa de homicidios por municipio

Motivo:

- e uma referencia nacional consolidada
- usa base oficial de mortalidade e metodologia publica
- e mais defensavel do que um score curado isolado

Links:

- https://www.ipea.gov.br/atlasviolencia/publicacoes/287/atlas-da-violencia-2024
- https://www.ipea.gov.br/portal/component/content/article/45-todas-as-noticias/noticias/16129-com-queda-de-homicidios-faccoes-expandem-atuacao-e-redesenham-geografia-do-crime-no-brasil

Decisao:

- nao substituimos o numero atual automaticamente nesta etapa, porque os valores ainda nao foram recalculados a partir dessa base
- o app passa a deixar claro que este grupo ainda pertence ao dataset curado do Movaro

### 4. Trabalho / emprego

Status: a fonte atual curada nao e a mais confiavel possivel.

Melhor referencia oficial recomendada:

- Novo Caged / Ministerio do Trabalho e Emprego

Motivo:

- e a principal referencia publica para saldo de empregos formais
- pode ser usada para um score de dinamica de mercado de trabalho

Links:

- https://www.gov.br/trabalho-e-emprego/pt-br/servicos/empregador/caged
- https://www.gov.br/trabalho-e-emprego/pt-br/noticias-e-conteudo/2025/outubro/novo-caged-brasil-gerou-mais-de-213-mil-empregos-formais-em-setembro

Decisao:

- ainda nao substituido no dataset, porque exigiria recalculo padronizado por municipio e ano de referencia

### 5. Atividade economica

Status: a fonte atual curada nao e a mais confiavel possivel.

Melhor referencia oficial recomendada:

- PIB dos Municipios / IBGE

Motivo:

- e a referencia oficial municipal mais solida para atividade economica agregada
- pode alimentar um score economico do produto com lastro oficial

Links:

- https://www.ibge.gov.br/estatisticas/economicas/contas-nacionais/2036-np-produto-interno-bruto-dos-municipios.html
- https://sidra.ibge.gov.br/pesquisa/pib-munic/tabelas

Decisao:

- ainda nao substituido no dataset nesta etapa

### 6. Aluguel

Status: a fonte atual curada nao e a mais confiavel possivel.

Melhor referencia recomendada:

- Indice FipeZAP, quando houver cobertura da cidade

Motivo:

- e a referencia mais reconhecida no mercado brasileiro para anuncios de locacao residencial
- possui metodologia documentada

Limitacao:

- a cobertura nao e nacional para todos os municipios do catalogo atual

Links:

- https://www.fipe.org.br/pt-br/indices/fipezap/
- https://downloads.fipe.org.br/indices/fipezap/fipezap-202504-residencial-locacao.pdf

Decisao:

- nao substituido automaticamente nesta etapa por falta de cobertura uniforme

## Conclusao

As fontes hoje confirmadas como mais confiaveis no stack atual sao:

- IBGE API de Localidades
- IBGE Cidades e Estados

As metricas abaixo ainda estao em dataset curado e nao devem ser apresentadas como oficiais:

- seguranca
- aluguel
- mercado de trabalho
- atividade economica
- popularidade entre argentinos

As fontes oficiais prioritarias para futura substituicao sao:

- Atlas da Violencia / Ipea
- Novo Caged / MTE
- PIB dos Municipios / IBGE
- FipeZAP, onde houver cobertura

## Decisao Aplicada no Produto

- mantivemos como oficiais apenas os grupos realmente sustentados por fonte oficial
- mantivemos as metricas restantes como curadas
- atualizamos a descricao exibida no app para deixar explicito que a migracao para fontes oficiais esta mapeada, mas ainda nao foi integralmente executada
