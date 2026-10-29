---
name: pull-request-description
description: "Structured pull request description template (context/issue link, what was implemented, how to run, and a \"how to test\" section that pairs automated checks with a BDD manual walkthrough). No filler sentences, no emojis. Invoke when writing or updating a PR description."
---

# Pull Request Description Skill

## Rules

- No emojis anywhere in the description.
- No filler sentences ("This PR fixes...", "As described in the issue..."). Be direct and specific.
- No em-dashes as punctuation separators: use commas, parentheses or colons.
- Present tense, active voice. Write the body in the repository's documentation language (PT-BR here), which is why the section headers below are in PT-BR.
- Every section below is mandatory.
- **"Como testar" always has two parts.** Commands (`pytest`, `flutter test`, `alembic upgrade head`) belong to "Verificação automatizada" and never count as the manual walkthrough.
- **Every PR that changes observable behaviour needs at least one BDD scenario** under "Roteiro manual (BDD)", written as Dado / Quando / Então, one action per Quando.
- **Add a negative or edge scenario whenever one exists**: error response, blocked permission, empty state, concurrency, offline, value at the boundary.
- **Backend PR:** Quando is the endpoint call with its payload, Então is the status code plus the response body or the persisted state. **UI PR:** Quando is the screen and the interaction, Então is what the user sees.
- **Tooling, CI or docs-only PR:** write "Sem roteiro manual" and one line explaining why, instead of inventing a scenario.
- The scenarios must be runnable by a reviewer who did not write the code: name the seeded data, the user role and the starting screen or endpoint.

## Template

````markdown
## Contexto

Closes #<numero-da-issue>

<Uma ou duas frases sobre o problema ou requisito atendido. Foco no porquê, não no o quê.>

---

## O que foi implementado

<Lista de mudanças concretas, citando classe, endpoint, migration ou tela.>

- <Mudança 1>
- <Mudança 2>

---

## Como rodar

1. Instalar dependências.
2. Rodar codegen, se aplicável.
3. Subir o app ou serviço.

---

## Como testar

### Verificação automatizada

```bash
<comandos de migration, teste e análise estática>
```

### Roteiro manual (BDD)

**Pré-condições:** <dados semeados, papel do usuário, ambiente (emulador, Mockoon, backend real)>

**Cenário: <caminho feliz>**
- Dado <estado inicial observável>
- Quando <uma ação: toque na tela X, chamada ao endpoint Y>
- Então <resultado que o revisor consegue conferir na tela, na resposta ou no banco>

**Cenário: <caso negativo ou de borda>**
- Dado <estado inicial>
- Quando <ação>
- Então <erro, bloqueio ou estado preservado>
````

## Example

````markdown
## Contexto

Closes #300 (Requisito: `REQ-PROD-08`)

O cadastro de produtos não distinguia item de revenda de item preparado, e sabores só podiam ser criados junto com o produto, nunca editados depois.

---

## O que foi implementado

- Migration `0016_product_type_flavors.py`: enum `product_type_enum` (`RESALE`, `PREPARED`) e coluna `product_type` em `products`, default `RESALE`.
- `CreateProductUseCase` passa a anexar os sabores iniciais com `current_stock = 0`.
- `UpdateProductUseCase` faz diff de sabores (criar, atualizar, remover) e lança `FlavorReferencedByTabItemException` quando o sabor está em uso.
- `catalog_router.py` e `docs/api/openapi.yaml` atualizados com os novos campos.

---

## Como rodar

1. `cd backend && uv sync --extra dev`
2. `cd backend && alembic upgrade head`
3. `make dev`

---

## Como testar

### Verificação automatizada

```bash
cd backend && alembic upgrade head
cd backend && pytest tests/catalog
cd backend && ruff check . && mypy app
```

### Roteiro manual (BDD)

**Pré-condições:** backend local rodando via `make dev`, token de `MANAGER`, banco com o seed padrão.

**Cenário: criar produto preparado com sabores**
- Dado que não existe produto "Açaí 500ml" no catálogo
- Quando eu envio `POST /api/v1/catalog/products` com `product_type: "PREPARED"` e dois sabores no array `flavors`
- Então a resposta é `201`, o produto retorna `product_type: "PREPARED"` e os dois sabores vêm com `current_stock: 0`

**Cenário: renomear sabor existente**
- Dado o produto "Açaí 500ml" criado no cenário anterior
- Quando eu envio `PUT /api/v1/catalog/products/{id}` alterando o nome do primeiro sabor
- Então a resposta é `200` e `GET /api/v1/catalog/products/{id}` devolve o nome novo, com o mesmo id de sabor

**Cenário: sabor em uso não pode ser removido**
- Dado uma comanda aberta com um item que referencia o sabor "Uva"
- Quando eu envio `PUT /api/v1/catalog/products/{id}` sem "Uva" no array `flavors`
- Então a resposta é `409`, o corpo cita `FlavorReferencedByTabItem` e o sabor continua no catálogo
````
