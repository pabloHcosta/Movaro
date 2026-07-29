# Política de privacidade operacional — Movaro

Versão: 2026.07.29
Status: minuta operacional para validação; requer revisão jurídica antes da publicação comercial.

## Escopo

O Movaro oferece orientação educacional baseada em dados para pessoas que avaliam uma mudança da Argentina para o Brasil. Esta minuta descreve o comportamento atual do aplicativo e não substitui uma política pública revisada por profissional habilitado.

## Dados usados no aparelho

- cidade de origem confirmada e ponto municipal aproximado;
- preferências respondidas no questionário;
- plano, progresso, itens dispensados e favoritos;
- idioma, moeda e tema escolhidos.

A localização precisa não é armazenada. Quando autorizada, a coordenada é
reduzida a duas casas decimais antes de ser enviada à API para comparar
distâncias entre municípios. O endpoint de recomendação não persiste a
coordenada nem as respostas. A localização é opcional e o usuário pode informar
a cidade manualmente. O histórico do assistente determinístico permanece
somente na sessão ativa.

## Finalidades

Os dados locais são usados para personalizar comparações de cidades, logística de viagem, ordem das atividades e alertas relevantes. O aplicativo não utiliza IA generativa como requisito para responder.

## Controle do usuário

O usuário pode negar a localização, alterar a cidade de origem, apagar a cidade armazenada e excluir planos ou favoritos pelos controles do aplicativo. Antes da publicação comercial, a versão final deve informar canal de contato, operador, bases legais, retenção, subprocessadores e procedimento completo para direitos previstos na LGPD.

## Limites

O conteúdo é educacional e comparativo. Não constitui consultoria jurídica, migratória, médica, financeira ou tributária. Informações críticas devem ser confirmadas na fonte oficial indicada.
# Métricas de melhoria do produto

- A coleta é desativada até uma autorização explícita no aplicativo.
- São enviados somente nome do evento do funil, horário, índice opcional da
  etapa, ambiente do aplicativo, versão da metodologia, faixas de estabilidade
  e cobertura, posição opcional entre as três recomendações e um token aleatório
  da instalação.
- Não são enviados respostas, cidade, localização, documentos, valores,
  conteúdo de tarefas, identificador da recomendação nem identificadores de
  conta.
- O usuário pode desativar a coleta e apagar a fila e o token local em
  Configurações.
- Falhas de rede mantêm uma fila limitada no aparelho e nunca bloqueiam o uso.
