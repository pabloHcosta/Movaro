# Governança de validade das fontes

## Janelas de revisão

- regra ou serviço oficial: 90 dias
- dado derivado: 30 dias
- preço ou referência de mercado: 14 dias
- orientação editorial do Movaro: 180 dias

O aplicativo não oculta automaticamente uma orientação vencida. Ele troca o
estado visual para “revisão pendente”, explica que o conteúdo serve apenas como
orientação e mantém a fonte original como ação principal.

Datas futuras são tratadas como inválidas. Cards de conteúdo oficial usam a
mesma política de 90 dias.

## Auditoria técnica

Execute:

```bash
cd apps/api
npm run audit:guide-sources
```

O comando extrai os endereços HTTPS centralizados em
`PreparationResourceLinks`, verifica redirecionamentos e respostas HTTP e
retorna um relatório JSON. Deve ser executado na revisão editorial e no CI
antes de uma versão de produção.
