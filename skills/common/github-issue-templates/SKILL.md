---
name: github-issue-templates
description: "Writing structured GitHub issues: native Issue Type usage (Feature/Bug/Enhancement/Task) instead of labels, BDD-format test scenarios, mandatory acceptance criteria and priority justification, and a template per issue type with a worked example. Invoke when creating a new GitHub issue for a feature, bug, or improvement."
---

# GitHub Issue Templates Skill

## Rules

- **No emojis** anywhere in the title or body.
- **Titles are concise and specific**: describe the problem/feature in one sentence, skip verbs like "fix"/"add" unless they clarify meaning.
- **Plain PT-BR** (the harness language for issues, `harness/principles.md`), present tense, active voice. The templates below are already in PT-BR.
- **Use GitHub's native Issue Type** (`Feature`, `Bug`, `Enhancement`, `Task`) via `--type` at creation time: don't rely on labels for type; reserve labels for area/priority tagging.
- **Acceptance criteria are mandatory**: they define when the issue is done.
- **Priority is mandatory** in the description (`P0 - Critical` / `P1 - Medium` / `P2 - Low`, or the repo's equivalent scale) with a brief justification.
- **Test scenarios in BDD (Given/When/Then)** format: context, action, outcome.

## Issue Types

| Type | Native definition | When to use |
|---|---|---|
| `Feature` | A request, idea, or new functionality | A capability that doesn't exist yet |
| `Bug` | An unexpected problem or behavior | A behavior deviating from the expected outcome |
| `Enhancement` | An improvement to existing functionality | Refactor, performance, UX polish, code quality on existing functionality |
| `Task` | A specific piece of work | Dependency updates, CI config, tooling, docs, chore-style work |

```bash
gh issue create --title "<concise, specific title>" --type "Bug" --label "priority:p1-high,backend" --body-file <path-to-body.md>
```

If `--type` reports the type doesn't exist, list what's actually provisioned before guessing:

```bash
gh api graphql -f query='query { organization(login: "<org>") { issueTypes(first: 20) { nodes { name description } } } }'
```

Creating a *new* org-level issue type changes shared, org-wide configuration: confirm with the user first, and check whether an existing type already covers the need.

## Feature Issue Template

```markdown
## Descrição

<Um parágrafo: o que é esta funcionalidade, por que ela é necessária e qual necessidade do usuário ou requisito de negócio atende.>

## Critérios de aceite

- [ ] <Critério 1: comportamento observável e testável>
- [ ] <Critério 2>

## Cenários de teste

**Unitário**
- Dado <pré-condição>, Quando <ação>, Então <resultado esperado>.

**Widget**
- Dado <renderização inicial>, Quando <interação>, Então <renderização ou gatilho esperado>.

**Integração**
- Dado <tela inicial>, Quando <fluxo de ponta a ponta>, Então <estado final esperado>.

## Prioridade
**<P0/P1/P2>** - <Justificativa breve>

## Fora do escopo

<Escopo excluído explicitamente, se houver.>
```

## Bug Issue Template

```markdown
## Descrição

<O que acontece, onde e qual é o impacto.>

## Passos para reproduzir

1. <Passo 1>
2. Observe: <o que realmente acontece>

## Comportamento esperado

<O que deveria acontecer.>

## Comportamento atual

<O que acontece hoje: seja específico, inclua mensagens de erro e valores errados.>

## Ambiente

- Dispositivo / versão do SO / versão do app, conforme aplicável

## Prioridade
**<P0/P1/P2>** - <Justificativa breve>

## Critérios de aceite

- [ ] O bug não ocorre mais nos passos de reprodução informados.
```

## Enhancement Issue Template

```markdown
## Descrição

<O que existe hoje, sua limitação e a melhoria proposta.>

## Motivação

<Por que isso importa: performance, DX, UX, dívida técnica.>

## Critérios de aceite

- [ ] <Critério 1>

## Prioridade
**<P0/P1/P2>** - <Justificativa breve>
```

## Task (Chore) Issue Template

```markdown
## Descrição

<Uma frase descrevendo a tarefa.>

## Motivação

<Por que: correção de segurança, API descontinuada, melhoria de ferramentas, etc.>

## Prioridade
**<P0/P1/P2>** - <Justificativa breve>

## Critérios de aceite

- [ ] <Critério 1>
```

## Worked Example

```bash
gh issue create \
  --title "Chips de filtro por categoria na tela de catálogo de produtos" \
  --type "Feature" \
  --label "priority:p1-high,frontend" \
  --body-file feature_body.md
```

```markdown
## Descrição

Hoje o usuário não consegue filtrar itens por categoria na visualização do catálogo. Adicionar chips de categoria permite localizar itens rapidamente, sem rolar o catálogo inteiro.

## Critérios de aceite

- [ ] Os chips de filtro por categoria ficam visíveis no topo da tela de catálogo.
- [ ] Selecionar uma categoria filtra a lista para essa categoria.
- [ ] Selecionar "Todas" restaura a lista completa.
- [ ] Testes unitários cobrem a lógica de filtro por categoria no cubit do catálogo.

## Cenários de teste

**Unitário**
- Dado um catálogo carregado, Quando `applyCategoryFilter(categoryId)` é chamado, Então a lista filtrada do estado contém apenas os itens correspondentes.

**Widget**
- Dado a página de catálogo renderizada com itens, Quando um chip de categoria é tocado, Então apenas os cards correspondentes são renderizados.

## Prioridade
**P1 - Medium** - Agiliza a navegação, mas não bloqueia o fluxo principal.

## Fora do escopo

- Seleção de várias categorias (apenas um filtro ativo por vez).
```
