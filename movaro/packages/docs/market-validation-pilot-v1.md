# Piloto de validação de mercado do Movaro

Status: pronto para recrutamento. A instrumentação foi implementada; não há
evidência de mercado até que pessoas externas participem.

## Hipótese central

Para pessoas argentinas preparando uma mudança real para o Brasil, o Movaro
reduz incerteza e transforma orientação dispersa em uma próxima ação correta,
ajudando a executar tarefas fora do aplicativo e a superar bloqueios.

O piloto deve testar quatro perguntas separadamente:

1. A dor ocorre com frequência e intensidade suficientes?
2. O participante entende o que fazer e por quê?
3. A orientação produz avanço verificável fora do aplicativo?
4. Existe intenção real de adotar ou pagar por uma forma específica da solução?

## Público e amostra

- Primeiro ciclo: 8–12 testes moderados de compreensão.
- Segundo ciclo: 15–25 participantes acompanhados por 2–4 semanas.
- Recorte principal: argentinos com intenção de mudar para o Brasil nos
  próximos seis meses, buscando trabalho e considerando um conjunto pequeno de
  cidades.
- Contraste: uma amostra menor com renda remota e cidade já escolhida.

Registrar origem do recrutamento e quantas pessoas foram convidadas, aceitaram,
começaram e concluíram. Não misturar equipe, amigos sem intenção real e público
alvo no mesmo denominador.

## Cenários mínimos

- Pessoa sozinha, buscando trabalho e com pouca reserva.
- Pessoa com filhos, coordenando escola e moradia.
- Pessoa com renda remota e cidade previamente escolhida.

Em cada cenário, observar seleção de origem, recomendação e limites da cidade,
confirmação da cidade, identificação da próxima ação, execução de uma tarefa
real e retomada do plano após interrupção.

## Evidência coletada no produto

O check-in aparece somente após uma tarefa prática e para quem autorizou
métricas anônimas. Ele registra:

- fase ampla: preparação, documentos, moradia, trabalho ou chegada;
- clareza: `clear`, `partial` ou `unclear`;
- progresso externo: `completed`, `blocked` ou `notStarted`;
- ajuda percebida: `high`, `moderate` ou `low`;
- exibição, envio ou recusa do check-in.

O envio exclui tarefa específica, cidade, texto livre, perfil, localização,
documentos e valores. Depois de uma resposta, a fase deixa de perguntar. Uma
recusa cria intervalo de sete dias para reduzir pressão e fadiga.

## Protocolo moderado

Antes do uso, perguntar como a pessoa resolveria a tarefa hoje, quais fontes
usaria, quanto tempo espera gastar e qual consequência teme. Durante o uso,
pedir que pense em voz alta sem ensinar a interface. Depois, pedir que explique
com suas palavras:

- por que a cidade apareceu;
- o que ainda precisa confirmar;
- qual é a próxima ação e seus pré-requisitos;
- o que fez fora do aplicativo;
- onde travou e como tentou resolver.

Guardar observações e citações somente com consentimento de pesquisa separado.
Não inserir texto de entrevista no endpoint de métricas.

## Métricas e denominadores

- Taxa de resposta: envios / check-ins exibidos.
- Clareza: respostas `clear` / respostas enviadas.
- Ação externa: respostas `completed` / respostas enviadas.
- Bloqueio observado: respostas `blocked` / respostas enviadas.
- Valor percebido: respostas `high` / respostas enviadas.
- Retomada: instalações com `taskResumed` após interrupção / instalações que
  iniciaram tarefa.
- Resultado assistido: bloqueios resolvidos com e sem intervenção do moderador.
- Custo operacional: minutos de atendimento humano por participante.

Sempre apresentar numerador, denominador e intervalo do piloto. Comparar fases
somente quando houver ao menos cinco respostas na fase; abaixo disso, mostrar
os casos individualmente sem converter em percentual.

Consulta agregada inicial para uma conexão administrativa ao Supabase:

```sql
select
  validation_phase_band as phase,
  count(*) filter (where event_name = 'pilotCheckInShown') as shown,
  count(*) filter (where event_name = 'pilotCheckInSubmitted') as submitted,
  count(*) filter (
    where event_name = 'pilotCheckInSubmitted'
      and validation_clarity_band = 'clear'
  ) as clear_next_action,
  count(*) filter (
    where event_name = 'pilotCheckInSubmitted'
      and validation_progress_band = 'completed'
  ) as external_action_completed,
  count(*) filter (
    where event_name = 'pilotCheckInSubmitted'
      and validation_progress_band = 'blocked'
  ) as blocked,
  count(*) filter (
    where event_name = 'pilotCheckInSubmitted'
      and validation_value_band = 'high'
  ) as high_value
from public.product_flow_events
where occurred_at >= :pilot_started_at
  and occurred_at < :pilot_ended_at
group by validation_phase_band
order by validation_phase_band;
```

## Critérios iniciais de decisão

Usar os critérios como limites de aprendizado do piloto, não como promessa de
mercado:

- ao menos 80% identificam a próxima ação sem intervenção;
- nenhuma interpretação crítica errada de requisito, segurança ou orçamento;
- participantes realizam ações externas em mais de uma fase da jornada;
- bloqueios recorrentes geram mudanças verificáveis no produto ou conteúdo;
- o nível de atendimento humano cabe no modelo operacional pretendido.

Só testar preço depois de demonstrar uso e resultado. Comparar pacote por
jornada, atendimento opcional e distribuição por organizações com escolhas que
tenham consequência real, como lista de espera, depósito reembolsável ou piloto
pago. Perguntar apenas “você pagaria?” conta como opinião, não como demanda.

## Encerramento do ciclo

Ao final, publicar uma tabela com hipóteses confirmadas, refutadas e ainda
incertas; evidência observada; tamanho da amostra; alterações decididas; e data
do próximo teste. Expandir países, marketplace ou assinatura somente quando a
evidência mostrar que isso resolve um bloqueio frequente do público prioritário.
