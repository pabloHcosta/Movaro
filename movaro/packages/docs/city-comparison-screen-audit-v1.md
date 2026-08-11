# Auditoria da tela de comparação de cidades

## Escopo

Revisão da primeira dobra da comparação com duas ou três cidades, considerando hierarquia de decisão, clareza dos dados, responsividade, acessibilidade e percepção de valor.

## Diagnóstico do estado anterior

### Crítico

- O cabeçalho tinha altura fixa de 188 px para três cidades e já produzia `RenderFlex overflow` em um viewport real.
- Uma coluna vazia de 72 px reservava espaço para rótulos de métricas que só aparecem em uma seção posterior. Isso retirava cerca de 20% da largura útil do elemento mais importante da tela.
- Três cards verticais precisavam acomodar avatar, nome, UF, código, barra, selo e classificação. O volume de informação era incompatível com a largura disponível.

### Hierarquia e percepção de valor

- O título genérico “Métrica” não explicava a decisão que o usuário estava vendo.
- Todas as cidades recebiam quase o mesmo peso visual, embora a tela já tivesse calculado uma recomendação principal.
- O vencedor aparecia novamente em um segundo card logo abaixo, criando repetição sem acrescentar evidência.
- As iniciais das cidades funcionavam como placeholders técnicos. Fotos ajudam reconhecimento, memória e projeção emocional da escolha.
- A barra de score não explicava sua composição. Sem contexto, um indicador quantitativo passa precisão maior do que o modelo realmente oferece.
- O cabeçalho permanecia fixo durante a rolagem apesar de ocupar bastante altura, reduzindo a área para analisar os dados.

### Conteúdo e ação

- A explicação contextual da recomendação estava depois de dois componentes de ranking. O “por quê” chegava tarde.
- “Iniciar plano” sugeria um compromisso maior do que o necessário naquele ponto da jornada.
- As métricas detalhadas estavam corretas como evidência de apoio, mas não deveriam disputar atenção com a conclusão principal.

## Hierarquia implementada

1. Título orientado à decisão: “Seu melhor encaixe, lado a lado”.
2. Hero fotográfico da cidade líder, com selo explícito e classificação qualitativa.
3. Alternativas em cards fotográficos menores, ordenadas como segunda e terceira opções.
4. Explicação personalizada do critério de comparação e principais forças.
5. CTA de continuidade com menor atrito: escolher a cidade e visualizar o plano.
6. Evidências operacionais: salário x custo, chegada, estabilidade, trade-offs e métricas de apoio.

## Decisões de produto

- O ranking usa o mesmo score contextual já calculado pela tela; não foi criado um segundo critério visual.
- O número bruto não é exposto no hero. A classificação qualitativa reduz falsa precisão e a explicação abaixo entrega o contexto.
- O hero não é fixo. Depois de compreender o ranking, o usuário ganha a tela inteira para comparar evidências.
- Imagens usam o resolvedor e o fallback já adotados no detalhe da cidade, preservando consistência e funcionamento sem foto disponível.
- O componente não depende de altura calculada pelo conteúdo, eliminando a causa estrutural do overflow.

## Critérios de aceite

- Nenhum overflow com duas ou três cidades nos viewports móveis suportados.
- Nomes longos limitados a duas linhas com elipse.
- Contraste preservado por gradiente sobre a imagem e badges com fundo escuro translúcido.
- Ordem visual igual à ordem real do score contextual.
- O vencedor aparece uma única vez como conclusão principal antes das evidências.
