# SPEC: <Título da funcionalidade>

As seções marcadas com `lite` são as únicas obrigatórias numa spec de tamanho M. O tamanho L preenche todas as seções que se aplicam: apague as que não se aplicam e nunca deixe marcadores sem preencher.

**Issue:** <link> · **Requisito:** <id, se o projeto usar> · **Tamanho:** <M | L> · **Status:** <rascunho | aprovada | entregue>

## 1. Contexto e problema `lite`

<Estado atual e por que importa agora, em no máximo 3 parágrafos curtos. Referencie a issue em vez de repetir o conteúdo dela.>

## 2. Escopo `lite`

### 2.1 O que muda

| Área | Hoje | Depois |
|---|---|---|
| `<arquivo ou componente>` | <comportamento atual> | <comportamento esperado> |

### 2.2 O que não muda

- <comportamento adjacente, arquivo ou fluxo que a implementação deve deixar intacto>
- <escopo que foi para outra issue: #N>

### 2.3 Restrições e premissas

- <versão de biblioteca, limite da plataforma, decisão já tomada, prazo>

## 3. Requisitos funcionais `lite`

| ID | Requisito | Cobre |
|---|---|---|
| FR-01 | <O sistema deve...> | <critério de aceite da issue> |

## 4. Cenários e casos de borda `lite`

- **Principal:** Dado <estado>, quando <ação>, então <resultado observável>.
- **Borda:** <permissão negada, offline, dado ausente, evento duplicado, falha parcial...>

## 5. Desenho da solução

### 5.1 Visão geral

<Como as partes se encaixam, em poucas linhas.>

### 5.2 <Módulo ou camada>

<Mudança com referências a arquivos, funções e linhas aproximadas reais.>

### 5.3 Contratos e dados

```text
<Trecho compilável na linguagem do projeto: payloads, schemas, assinaturas, regras>
```

## 6. Fluxo

<Diagrama do novo fluxo de dados ou do usuário, no formato que a skill do projeto exige.>

## 7. Alternativas consideradas

| Alternativa | Por que não |
|---|---|
| <opção> | <trade-off que a descartou> |

## 8. Arquivos afetados `lite`

| Arquivo | Tipo | Mudança |
|---|---|---|
| `<caminho>` | Modificar | <descrição curta> |
| `<caminho>` | Criar | <descrição curta> |

## 9. Requisitos não funcionais

| Categoria | Requisito | Como verificar |
|---|---|---|
| Segurança / privacidade | | |
| Confiabilidade | | |
| Acessibilidade | | |
| Observabilidade | | |

## 10. Implantação

<Flag, migração, compatibilidade com versões anteriores, ordem de deploy entre app e backend, fallback.>

## 11. Validação e critérios de aceite `lite`

- Unitário / widget: <escopo>
- Integração / backend: <escopo>
- e2e ou manual: <cenários da seção 4>

- [ ] <critério verdadeiro ou falso>
- [ ] Casos de erro e fallback da seção 4 se comportam como descrito.
- [ ] Analyzer, build e os testes relevantes passam sem regressão.

## 12. Perguntas em aberto

- <decisão pendente, responsável>
