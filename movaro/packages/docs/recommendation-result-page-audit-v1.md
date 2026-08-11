# Auditoria da pagina de cidades sugeridas v1

## Escopo e metodo

Avaliacao da tela `MigrationResultRevealPage` depois da conclusao do
questionario, considerando:

- valor percebido e correspondencia com a expectativa do usuario;
- hierarquia de informacao e arquitetura de escolha;
- explicabilidade, confianca calibrada e psicologia de decisao;
- usabilidade mobile e desktop;
- acessibilidade e comportamento tecnico;
- continuidade com o loading de recomendacao.

A auditoria combinou leitura da implementacao, execucao do fluxo completo e
inspecao visual em viewport mobile de 390 x 844 e desktop.

## Veredito

A pagina possui dados valiosos, mas a hierarquia atual esconde a resposta que o
usuario mais quer receber: **por que esta cidade apareceu primeiro para mim?**

O conteudo de explicacao existe, inclusive com motivos, dimensoes, estabilidade,
fontes e alternativas. O problema e a ordem. Antes de chegar aos motivos, o
usuario encontra um banner generico, uma faixa de compatibilidade pouco
explicativa, preco de voo, alertas, prazo, metodologia e, quando habilitado,
pedido de feedback.

Na primeira dobra mobile, a cidade recomendada aparece, mas nenhum motivo
concreto da recomendacao e visivel. Isso enfraquece a recompensa psicologica
depois do formulario e faz a interface parecer mais uma pagina de dados do que
uma resposta personalizada.

## Achados priorizados

### P0 — a proposta de valor fica abaixo da primeira dobra

O titulo `Por que Cabo Frio?` aparece somente depois dos sinais operacionais e
do bloco completo de integridade/metodologia. No teste mobile foi necessario
percorrer uma distancia consideravel ate encontrar os tres motivos.

O primeiro bloco depois do hero deve responder imediatamente:

1. por que a cidade ficou em primeiro;
2. quais respostas do usuario influenciaram o resultado;
3. qual e o principal ponto de atencao;
4. como comparar ou corrigir a recomendacao.

### P0 — o hero pode parecer vazio quando a imagem falha

O `CollapsibleCityHero` usa um `SizedBox.shrink()` como fallback da imagem. No
fluxo web auditado, isso resultou em uma grande area preta antes do nome da
cidade. A primeira impressao perde acabamento e contexto territorial.

O fallback precisa preservar uma composicao visual da marca, com gradiente,
monograma/icone e textura ambiental, sem depender da rede.

### P1 — o primeiro banner e generico e repete o estado da jornada

`Explore options`, `Get an initial shortlist` e `Compare or confirm` descrevem
o que a pagina permite fazer, mas nao entregam evidencia personalizada. Esse
espaco privilegiado deve ser usado pela explicacao da recomendacao.

### P1 — compatibilidade e motivos estao fragmentados

O card `Stronger fit for your profile` e clicavel, mas a explicacao fica
escondida em um modal. Separadamente, os motivos aparecem muito abaixo.

Isso exige que o usuario descubra a interacao e depois reconcilie duas formas
de explicacao. A recomendacao deve ter um unico resumo principal, com detalhes
progressivos.

### P1 — faltam contrapeso e limite no resumo principal

Os tres motivos visiveis sao positivos. Limites e cobertura existem no bloco
tecnico, mas longe da decisao. Somente argumentos favoraveis podem criar
desconfianca ou confianca excessiva.

Mostrar um unico `Ponto para validar` proximo aos beneficios aumenta
credibilidade e ajuda o usuario a decidir de forma mais segura.

### P1 — metodologia domina a leitura antes da decisao

O card de integridade e completo: cobertura, atualidade, estabilidade,
confiabilidade, separacao, metodologia, data, fontes e alertas. Esse nivel de
transparencia e positivo, mas a apresentacao aberta cria carga cognitiva e
empurra o valor personalizado para baixo.

Manter um resumo curto visivel e colocar os detalhes em disclosure:
`Como chegamos a esta recomendacao`.

### P1 — alternativas nao comunicam claramente sua funcao

As alternativas repetem a mesma faixa qualitativa da cidade principal. Em
mobile, o texto e truncado e duas cidades podem parecer igualmente
`Stronger fit`, reduzindo a compreensao da ordenacao.

As alternativas devem apresentar:

- posicao `#2` e `#3`;
- principal vantagem em relacao a cidade recomendada;
- principal concessao/trade-off;
- acao explicita de comparacao.

### P1 — o CTA parece mais comprometedor do que a etapa real

`Comecar preparacao com Cabo Frio` pode soar como uma decisao definitiva logo
depois de uma sugestao inicial. A operacao confirma a cidade e abre o plano.

Uma descricao mais precisa e reversivel reduz ansiedade:
`Escolher Cabo Frio e ver meu plano`.

### P2 — o preview de 35 passos aumenta o custo percebido

O teaser exibe uma badge como `35 steps` e uma linha por fase. Antes da
confirmacao, isso pode transformar valor em sobrecarga. O usuario precisa ver
o proximo movimento, nao toda a extensao da burocracia.

Mostrar somente os tres primeiros passos e apresentar o restante como
continuidade organizada.

### P2 — sinais praticos precisam de agrupamento semantico

Voo, logistica de origem, sazonalidade e prazo sao uteis, mas aparecem como
cards independentes entre a recomendacao e sua explicacao. Agrupa-los sob
`O que vale conferir antes de escolher` melhora o modelo mental.

### P2 — acessibilidade semantica precisa ser validada

O app Flutter Web depende da arvore `Semantics` para expor estrutura ao DOM.
Cards inteiros clicaveis, barras sem valor textual e controles de collapse
precisam de labels, estados e alvos adequados. O resultado tambem precisa ser
testado com escala de texto de 200% e movimento reduzido.

## Psicologia de decisao aplicada

### Recompensa imediata

Depois de responder perguntas, o usuario espera reconhecimento de suas
respostas. Repetir duas ou tres prioridades no primeiro resumo cria a sensacao
de que o formulario foi realmente ouvido.

### Confianca calibrada

Explicar apenas o resultado aumenta risco de aceitacao cega; mostrar apenas
metodologia aumenta ceticismo e esforco. A composicao correta e:

```text
recomendacao + motivos pessoais + um limite relevante + detalhes sob demanda
```

### Reducao de escolha

Uma cidade principal e duas alternativas e uma quantidade adequada para a
primeira decisao. A interface deve deixar a ordenacao clara, sem sugerir que
todas sao equivalentes.

### Autonomia

O resultado deve ser apresentado como orientacao, nao sentenca. Refazer
respostas, comparar alternativas e validar um ponto de atencao ajudam o usuario
a manter controle.

### Compromisso progressivo

O CTA deve confirmar uma cidade para montar o plano, nao sugerir que a mudanca
ja foi decidida. A escolha precisa parecer revisavel.

## Nova hierarquia recomendada

### Primeira dobra

1. Hero da cidade com fallback visual robusto.
2. Badge `Melhor encaixe para seu perfil agora`.
3. Nome e localizacao.
4. Card `Por que esta cidade apareceu primeiro`:
   - faixa qualitativa;
   - ate tres motivos personalizados;
   - prioridades/dimensoes mais fortes;
   - link `Ver comparacao completa`.
5. CTA fixo `Escolher [cidade] e ver meu plano`.

### Segunda dobra

6. `Ponto para validar` com a dimensao mais fraca ou limitacao de dados.
7. `Compare antes de decidir` com as opcoes #2 e #3 e trade-offs.

### Terceira dobra

8. `O que vale conferir antes de escolher`:
   - prazo;
   - voo;
   - logistica;
   - sazonalidade.
9. `O que acontece depois` com somente tres passos do plano.
10. `Como chegamos a esta recomendacao` recolhido por padrao.
11. Feedback opcional no final.

## Relacao com referencias de mercado

- Apple HIG recomenda hierarquia clara, simplicidade e mostrar conteudo o mais
  cedo possivel em vez de uma experiencia vazia.
- Google People + AI recomenda explicacao especifica do resultado, fontes e
  limites para calibrar confianca; tambem alerta que percentuais podem ser
  mal-interpretados e sugere faixas qualitativas e alternativas ordenadas.
- W3C recomenda linguagem simples, blocos curtos e vantagens/desvantagens
  explicitas para apoiar escolhas.
- WCAG 2.2 define alvo minimo de 24 x 24 CSS px; para uma experiencia mobile
  robusta, a meta de produto deve continuar em 44 x 44 px.
- Flutter Web requer `Semantics` para transformar o canvas em estrutura
  acessivel para tecnologias assistivas.

## Criterios de aceite da implementacao

1. O primeiro viewport mobile mostra pelo menos dois motivos personalizados.
2. Falha da foto nunca produz um hero vazio.
3. Beneficios e um ponto de atencao aparecem antes de metodologia.
4. Alternativas exibem posicao e trade-off sem texto truncado essencial.
5. Metodologia permanece acessivel, recolhida por padrao.
6. O CTA descreve o efeito real e reversivel da acao.
7. O preview mostra no maximo tres proximos passos.
8. Todos os caminhos finais usam o mesmo loading artistico e a mesma
   navegacao.
9. Resultado principal nao aguarda prefetch de dados secundarios.
10. Testes cobrem mobile, texto ampliado, movimento reduzido, erro de imagem,
    erro de geracao e caminhos curto/estrategico.

