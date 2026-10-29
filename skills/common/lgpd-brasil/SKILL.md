---
name: lgpd-brasil
description: "Orienta sobre a Lei Geral de Proteção de Dados (LGPD, Lei 13.709/2018) do Brasil: âmbito, bases legais, dados sensíveis, crianças, direitos do titular, ANPD, incidentes, transferência internacional e sanções, com checklist para sistemas e produtos. Use quando o usuário mencionar LGPD, proteção de dados no Brasil, privacidade de dados, bases legais, direitos do titular, ANPD, dados sensíveis, consentimento, incidente de segurança com dados pessoais ou conformidade com a lei brasileira de dados."
---

# LGPD (Lei Geral de Proteção de Dados, Brasil)

Adaptada de [ericbsantana/llm-skills `lgpd-brasil`](https://github.com/ericbsantana/llm-skills/tree/main/skills/lgpd-brasil) (MIT, Eric Bitencourt de Santana). A adaptação corrige a vigência e a remissão do Art. 14 e acrescenta a natureza da ANPD, comunicação de incidentes, transferência internacional e sanções.

Skill para apoiar o entendimento e a aplicação da **Lei nº 13.709/2018** (LGPD) em sistemas, produtos e processos que tratam dados pessoais no Brasil.

## Visão geral

- **Lei**: 13.709/2018, publicada em 14/08/2018. Alterada pela Lei 13.853/2019 (criou a ANPD) e pela Lei 14.460/2022 (ANPD como autarquia de natureza especial).
- **Vigência**: a maior parte desde 18/09/2020; as sanções administrativas (Arts. 52 a 54) desde 01/08/2021.
- **Objetivo**: proteger os direitos fundamentais de liberdade, privacidade e livre desenvolvimento da personalidade da pessoa natural.
- **Âmbito** (Art. 3º): qualquer operação de tratamento de dados pessoais, em qualquer meio, por pessoa natural ou jurídica (pública ou privada), desde que:
  - a operação ocorra no território nacional; ou
  - a atividade vise oferta de bens ou serviços ou tratamento de dados de pessoas localizadas no Brasil; ou
  - os dados tenham sido coletados no território nacional (titular no Brasil no momento da coleta).

**Exceções** (Art. 4º): uso exclusivamente particular e não econômico; fins jornalísticos e artísticos; fins acadêmicos (observados os arts. 7º e 11); segurança pública, defesa nacional, segurança do Estado, investigação e repressão de infrações penais (legislação específica); dados vindos de fora do Brasil sem comunicação, compartilhamento ou transferência internacional com agentes brasileiros (com ressalvas).

## Conceitos essenciais (Art. 5º)

| Termo | Definição resumida |
|-------|--------------------|
| **Dado pessoal** | Informação relacionada a pessoa natural identificada ou identificável |
| **Dado sensível** | Origem racial ou étnica, convicção religiosa, opinião política, filiação a sindicato ou a organização religiosa, filosófica ou política, saúde, vida sexual, dado genético ou biométrico, quando vinculado a pessoa natural |
| **Dado anonimizado** | Dado que não permite identificar o titular por meios técnicos razoáveis; deixa de ser dado pessoal, salvo se a anonimização puder ser revertida (Art. 12) |
| **Titular** | Pessoa natural a quem se referem os dados |
| **Controlador** | Quem decide sobre o tratamento |
| **Operador** | Quem trata em nome do controlador |
| **Encarregado (DPO)** | Canal entre controlador, titulares e ANPD |
| **Tratamento** | Coleta, produção, recepção, classificação, utilização, acesso, reprodução, transmissão, distribuição, processamento, arquivamento, armazenamento, eliminação, avaliação, controle, modificação, comunicação, transferência, difusão ou extração |
| **Consentimento** | Manifestação livre, informada e inequívoca para finalidade determinada |

## Princípios (Art. 6º)

Toda atividade de tratamento deve observar a boa-fé e:

1. **Finalidade**: propósitos legítimos, específicos, explícitos e informados ao titular, sem tratamento posterior incompatível.
2. **Adequação**: compatibilidade com as finalidades informadas e o contexto.
3. **Necessidade**: mínimo necessário; dados pertinentes, proporcionais e não excessivos.
4. **Livre acesso**: consulta facilitada e gratuita sobre forma, duração e integralidade dos dados.
5. **Qualidade**: exatidão, clareza, relevância e atualização conforme a finalidade.
6. **Transparência**: informações claras, precisas e acessíveis sobre o tratamento e os agentes (respeitados os segredos comercial e industrial).
7. **Segurança**: medidas técnicas e administrativas contra acessos não autorizados e situações ilícitas ou acidentais (destruição, perda, alteração, comunicação, difusão).
8. **Prevenção**: medidas para evitar danos.
9. **Não discriminação**: nenhum tratamento para fins discriminatórios ilícitos ou abusivos.
10. **Responsabilização e prestação de contas**: demonstração de medidas eficazes de conformidade.

## Bases legais para tratamento (Art. 7º)

O tratamento de **dados pessoais** só pode ocorrer quando houver ao menos uma das hipóteses:

- I. Consentimento do titular
- II. Obrigação legal ou regulatória do controlador
- III. Execução de políticas públicas pela administração pública (Cap. IV)
- IV. Estudos por órgão de pesquisa (anonimização quando possível)
- V. Execução de contrato ou procedimentos preliminares a pedido do titular
- VI. Exercício regular de direitos em processo judicial, administrativo ou arbitral
- VII. Proteção da vida ou da incolumidade física do titular ou de terceiro
- VIII. Tutela da saúde (profissionais ou serviços de saúde ou autoridade sanitária)
- IX. Interesses legítimos do controlador ou de terceiro, exceto se prevalecerem direitos e liberdades fundamentais do titular (ver Art. 10)
- X. Proteção do crédito

**Consentimento (Art. 8º)**: por escrito ou outro meio que demonstre a vontade; cláusula destacada se for escrito; ônus da prova no controlador; vedado o tratamento com vício de consentimento; finalidades determinadas (autorizações genéricas são nulas); revogação a qualquer tempo, gratuita e facilitada.

Dados **tornados manifestamente públicos** pelo titular podem ser tratados sem consentimento, respeitados os direitos e os princípios. Dispensar o consentimento **não** dispensa as demais obrigações da lei.

## Dados sensíveis (Art. 11)

Tratamento de **dados sensíveis** somente:

- com **consentimento específico e destacado**, para finalidades específicas; ou
- **sem consentimento**, quando indispensável para: (a) obrigação legal ou regulatória; (b) políticas públicas; (c) estudos por órgão de pesquisa (anonimização quando possível); (d) exercício regular de direitos (contrato ou processo); (e) proteção da vida ou da incolumidade física; (f) tutela da saúde (profissionais, serviços ou autoridade sanitária); (g) prevenção à fraude e segurança do titular na identificação e autenticação em sistemas, respeitados os direitos do titular.

**Vedações**: comunicação ou uso compartilhado de dados de saúde entre controladores para obter vantagem econômica, exceto nas hipóteses legais (por exemplo, portabilidade a pedido do titular ou prestação de serviços de saúde). Operadoras de planos de saúde não podem usar dados de saúde para seleção de riscos na contratação ou na exclusão de beneficiários.

## Crianças e adolescentes (Art. 14)

- Tratamento sempre no **melhor interesse** da criança ou do adolescente.
- Dados de **crianças**: consentimento **específico e em destaque** de pelo menos um dos pais ou do responsável legal.
- Os controladores devem manter pública a informação sobre os tipos de dados coletados, a forma de uso e como exercer os direitos do Art. 18 (Art. 14, § 2º).
- Coleta sem consentimento só quando necessária para contatar os pais ou o responsável (uso uma única vez, sem armazenamento) ou para proteção da criança; nunca repassar a terceiros sem o consentimento do § 1º.
- Não condicionar a participação em jogos ou aplicações à coleta de dados além do estritamente necessário.

## Direitos do titular (Art. 18)

O titular tem direito a obter do controlador, a qualquer momento e mediante requisição:

- I. Confirmação da existência de tratamento
- II. Acesso aos dados
- III. Correção de dados incompletos, inexatos ou desatualizados
- IV. Anonimização, bloqueio ou eliminação de dados desnecessários, excessivos ou tratados em desconformidade com a lei
- V. Portabilidade dos dados a outro fornecedor (conforme regulamentação da ANPD, respeitados os segredos comercial e industrial)
- VI. Eliminação dos dados tratados com consentimento (exceto nas hipóteses do Art. 16)
- VII. Informação sobre as entidades públicas e privadas com as quais houve uso compartilhado
- VIII. Informação sobre a possibilidade de não consentir e as consequências da negativa
- IX. Revogação do consentimento (Art. 8º, § 5º)

O titular pode **peticionar à ANPD** contra o controlador e **opor-se** a tratamento feito com dispensa de consentimento quando houver descumprimento da lei. O requerimento é atendido **sem custos** para o titular, nos prazos regulamentares.

## Término e eliminação (Arts. 15 e 16)

O tratamento termina quando: (I) a finalidade foi alcançada ou os dados deixaram de ser necessários; (II) acabou o período de tratamento; (III) o titular comunicou o término (inclusive revogando o consentimento), resguardado o interesse público; (IV) a ANPD determinou, em caso de violação.

Depois do término, os dados devem ser **eliminados**, exceto quando a conservação for permitida (por exemplo, obrigação legal ou regulatória, estudo com anonimização, uso exclusivo do controlador com dados anonimizados).

## Transferência internacional (Arts. 33 a 36)

Mandar dados pessoais para fora do Brasil (inclusive guardar em nuvem hospedada em outro país) só é permitido em hipóteses como: país com nível de proteção adequado reconhecido pela ANPD; cláusulas-padrão contratuais, normas corporativas globais ou selos e certificados; consentimento específico e destacado do titular; ou as demais hipóteses do Art. 33. A Resolução CD/ANPD nº 19/2024 regulamenta o tema e aprova as cláusulas-padrão.

## Segurança e incidentes (Arts. 46 a 49)

- Agentes de tratamento devem adotar medidas de segurança técnicas e administrativas desde a concepção do produto (*privacy by design*, Art. 46, § 2º).
- Incidente que possa gerar **risco ou dano relevante** aos titulares deve ser comunicado à ANPD e aos titulares (Art. 48). Pela Resolução CD/ANPD nº 15/2024, o prazo é de **3 dias úteis** a partir do conhecimento do incidente.
- A comunicação descreve os dados afetados, os titulares envolvidos, as medidas de segurança, os riscos e as medidas para reverter ou mitigar os efeitos.
- Manter registro dos incidentes, mesmo dos não comunicados.

## ANPD (Autoridade Nacional de Proteção de Dados)

- Autarquia de natureza especial (Lei 14.460/2022), responsável por **zelar, implementar e fiscalizar** o cumprimento da LGPD em todo o território nacional.
- Emite regulamentos e guias e pode solicitar o **relatório de impacto à proteção de dados pessoais (RIPD)**, sobretudo em tratamentos de maior risco ou baseados em interesse legítimo.
- Aplica as sanções administrativas do Art. 52.

## Sanções (Art. 52)

Advertência; multa simples de até **2% do faturamento** da pessoa jurídica, grupo ou conglomerado no Brasil no último exercício, limitada a **R$ 50 milhões por infração**; multa diária; publicização da infração; bloqueio ou eliminação dos dados; suspensão parcial do banco de dados ou da atividade de tratamento; proibição parcial ou total da atividade. A dosimetria segue a Resolução CD/ANPD nº 4/2023.

## Checklist prático para sistemas e produtos

Ao desenhar ou revisar tratamento de dados no Brasil:

- [ ] Verificar se a LGPD se aplica (território, oferta de bens ou serviços, dados coletados no Brasil).
- [ ] Mapear dados pessoais e sensíveis; documentar finalidade e base legal (Art. 7º ou 11).
- [ ] Garantir que o consentimento, quando exigido, seja específico, destacado e revogável de forma gratuita e facilitada.
- [ ] Respeitar os princípios: necessidade (mínimo de dados), transparência, segurança, prevenção.
- [ ] Implementar canais para os direitos do titular (acesso, correção, eliminação, portabilidade, revogação, oposição).
- [ ] Nomear o encarregado e divulgar o canal de contato (titulares e ANPD).
- [ ] Avaliar a necessidade de RIPD em tratamentos de maior risco.
- [ ] Conferir onde os dados ficam hospedados e, se for fora do Brasil, qual hipótese do Art. 33 cobre a transferência.
- [ ] Ter um plano de resposta a incidentes que caiba no prazo de 3 dias úteis.
- [ ] Para dados de crianças: consentimento dos pais ou do responsável; não condicionar atividades à coleta além do necessário.
- [ ] Para dados sensíveis: conferir a hipótese do Art. 11 e as vedações (saúde para vantagem econômica, seleção de riscos em planos de saúde).

## Referência oficial

- Lei 13.709/2018 (texto compilado): [planalto.gov.br](https://www.planalto.gov.br/ccivil_03/_ato2015-2018/2018/lei/l13709.htm)
- ANPD, regulamentos, guias e perguntas frequentes: [gov.br/anpd](https://www.gov.br/anpd/pt-br)
- Consulta por artigo (estrutura da lei e dispositivos): [reference.md](reference.md)

**Aviso**: esta skill resume a LGPD para apoiar análise e implementação. Para decisões jurídicas definitivas ou conformidade formal, consulte a lei, as regulamentações da ANPD e assessoria jurídica especializada.
