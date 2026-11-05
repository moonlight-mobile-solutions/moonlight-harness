# Humanizer: padrões em português do Brasil (PT-BR)

Complemento para textos em português do Brasil. As regras de processo, preservação de fatos, voz e estrutura (§1 a §26 de [`SKILL.md`](SKILL.md)) continuam valendo; este arquivo traz as expressões equivalentes em PT-BR, os decalques do inglês e as particularidades da língua portuguesa.

## A. Encenação em vez de afirmação

Aja ao encontrar uma única ocorrência (§1 a §5).

### 1. Não é X, é Y

**Observar:** não é X, é Y; não é apenas / só / meramente X, mas (também) Y; não se trata de X, trata-se de Y; mais do que X, é Y; X em vez de Y (quando X ninguém defendeu); o contraste dividido em duas frases ("Isso não significa X. Significa Y."); cauda negativa seca ("..., sem adivinhação", "..., sem complicação").
**Problema:** a metade negativa nega algo que ninguém afirmou só para inflar a metade positiva. Diga o ponto diretamente. Mantenha o contraste apenas quando a metade negativa corrigir um equívoco real de quem lê ou quando ambas trouxerem informação.
**Antes:**
> Não se trata apenas de otimizar a consulta; trata-se de repensar como o serviço acessa o banco. Não é só uma melhoria, é uma mudança de postura.
**Depois:**
> A mudança reduz o número de leituras no banco ao concentrar a busca em uma única consulta.
**Antes (cauda seca):**
> As opções vêm do item selecionado, sem adivinhação.
**Depois:**
> As opções vêm do item selecionado, sem obrigar a pessoa a adivinhar.

### 2. Frases de efeito isoladas e fragmentos dramáticos

**Observar:** parágrafo de uma linha que repete o parágrafo anterior; "É aí que mora a diferença."; "Essa distinção importa."; "E isso muda tudo."; "Pense nisso."; "Leia isso de novo."; o mesmo fecho após várias seções; frase após um exemplo que explica o que já ficou claro ("Isso demonstra a importância de...", "A mensagem era clara:"); sequência de fragmentos nominais ("Sem estado global. Sem acoplamento. Sem surpresas.").
**Problema:** a frase pede aplauso para a ideia anterior em vez de acrescentar um fato. Corte o fecho que só repete ou resume o exemplo. Una fragmentos em uma frase com afirmação concreta.
**Antes:**
> O cache evita recomputar a mesma resposta.
>
> É aí que está o ganho real.
>
> A fila absorve picos de tráfego.
>
> É aí que está o ganho real.
**Depois:**
> O cache evita recomputar a mesma resposta e a fila absorve picos de tráfego.

### 3. Frases com verniz de profundidade

**Observar:** a verdadeira questão é, em sua essência, no cerne da questão, na prática o que realmente importa, fundamentalmente, o problema mais profundo, no fim das contas, X é a linguagem de Y, X é a moeda de Y, X vira uma armadilha quando, X não é uma ferramenta, mas um espelho.
**Problema:** um ponto comum aparece vestido de aforismo ou verdade oculta. Troque pela afirmação específica.
**Antes:**
> A verdadeira questão é se o time consegue se adaptar. Em sua essência, o que realmente importa é a maturidade operacional.
**Depois:**
> Resta saber se o time consegue mudar a rotina de deploy.

### 4. Aquecimento encenado antes do ponto

**Observar:** Vamos mergulhar em, vamos explorar, vamos destrinchar, aqui está o que você precisa saber, veja bem, sem mais delongas, aviso rápido, sendo bem sincero?, olha, a verdade é a seguinte, o ponto é o seguinte, convenhamos.
**Problema:** anuncia que vai falar ou encena franqueza antes de um ponto comum. Remova o aquecimento e comece pela afirmação.
**Antes:**
> Vamos mergulhar em como o cache funciona no Next.js. Aqui está o que você precisa saber.
**Depois:**
> O Next.js faz cache em quatro camadas: memoização da requisição, cache de dados, cache de rota completa e cache do roteador no cliente.

### 5. Discutindo com ninguém

**Observar:** Isso não é (principalmente) sobre, não estou dizendo que, para deixar claro, não me entenda mal, isso não quer dizer que, alguns diriam que... mas, uma abordagem tentadora seria, você pode pensar que... mas, seria fácil apenas.
**Problema:** responde a uma objeção que ninguém levantou ou descarta uma alternativa fictícia. Remova a defesa e deixe a afirmação.
**Antes:**
> Para deixar claro, não estou dizendo que documentação não importa. O problema é saber se o agente consegue aplicar a instrução na hora de agir.
**Depois:**
> O problema é saber se o agente consegue aplicar a instrução na hora de agir.

## B. Ritmo por regra

### 6. Tríades forçadas

**Observar:** listas e pares esticados para três itens ("inovação, inspiração e insights"; "rápido, seguro e confiável"), três exemplos paralelos seguidos de moral da história.
**Problema:** ideias vêm em grupos de três para parecerem completas, mesmo quando há apenas duas partes reais. Mantenha três itens só quando os três forem distintos e necessários.
**Antes:**
> O encontro traz palestras técnicas, painéis de debate e oportunidades de networking, oferecendo aprendizado, troca de experiências e visão de mercado.
**Depois:**
> O encontro tem palestras técnicas e painéis, com intervalos para conversa entre participantes.

### 7. Aberturas de frase repetidas

**Problema:** várias frases seguidas começam com o mesmo sujeito ou estrutura ("O serviço valida... O serviço grava... O serviço retorna..."). Agrupe, varie a abertura ou comece pela ação.

### 8. Travessão como conector universal

**Regra:** o texto final não deve conter travessões (longos ou médios) nem hifens duplos espaçados (` -- `) usados como pontuação intercalada, salvo se a amostra da pessoa autora usar. Substitua por vírgula, ponto, dois-pontos ou parênteses, ou reescreva a frase. Não altere código, comandos, caminhos ou URLs.

### 9. Qualificadores empilhados

**Observar:** para ser justo, também é possível que, poderia potencialmente, de certa forma pode-se argumentar que, em alguns casos pode vir a. *Fraco sozinho.*
**Antes:**
> Poderia potencialmente ser argumentado que a mudança talvez tenha algum efeito na latência.
**Depois:**
> A mudança pode aumentar a latência.

### 10. Locuções adjetivas de chavão

**Observar:** de alta qualidade, de ponta a ponta, em tempo real, de longo prazo, voltado para o cliente, de classe mundial repetidos como muleta após cada substantivo. *Fraco sozinho.*
**Problema:** no português o excesso não aparece como hífen (como em inglês), mas como locuções "de + substantivo" coladas em todo termo técnico. Corte as que não especificam nada (ex.: "código de alta qualidade") e mantenha apenas as que definem escopo técnico real (ex.: "criptografia de ponta a ponta").

### 11. Voz passiva, indeterminação e falta de sujeito

**Observar:** "Foi identificado que", "Realizou-se a migração", "Cabe ressaltar que foi feito", "Necessário reiniciar". *Fraco sozinho.*
**Problema:** esconde quem age ou troca um verbo direto por passiva analítica/sintética sem necessidade. Prefira sujeito explícito e voz ativa ("O teste apontou", "Migramos a tabela", "Reinicie o serviço").

## C. Inflação e autoridade emprestada

### 12. Palavras batidas de IA e decalques do inglês

**Observar:** ademais, alinhar-se com, alavancar (figurado), aprimorar, cenário (abstrato: "no cenário atual"), crucial, desvendar, destacar (verbo), divisor de águas, ecossistema (fora de biologia ou plataforma real), em suma, fascinante, fomentar, fundamental, holístico, impecável, impulsionar, intrincado, jornada (para uso de produto ou carreira), mergulhar / mergulho profundo (*deep dive* / *delve*), meticuloso / meticulosamente, multifacetado, navegar (abstrato: "navegar pelos desafios"), no cerne, nuances, paradigma, peça-chave, permear, pilar, ressaltar, robusto (figurado; manter uso técnico), sinergia, tapeçaria (*tapestry*), testamento / testemunho (*testament to*), transcender, valioso, vibrante, vital.
**Problema:** modelos usam essas palavras muito mais do que falantes naturais de português, muitas vezes traduzindo literalmente clichês do inglês (*delve into* vira "mergulhar em", *testament to* vira "um testemunho de", *tapestry* vira "tapeçaria", *landscape* vira "cenário").
**Antes:**
> Ademais, um testemunho duradouro da influência italiana no cenário culinário local é a presença vibrante de massas artesanais, destacando como essas receitas permearam a dieta tradicional.
**Depois:**
> A culinária local também conserva massas artesanais trazidas por imigrantes italianos, comuns até hoje no sul do país.

### 13. Importância inflada

**Observar:** representa um marco, desempenha um papel fundamental / crucial, moldando o futuro de, ressalta a importância de, deixa um legado duradouro, prepara o terreno para, em um cenário em constante evolução; seções prontas como "Desafios e Perspectivas Futuras"; parágrafos finais de despedida ("O futuro parece promissor", "Um passo importante rumo à excelência").
**Problema:** um fato comum ganha peso de momento histórico ou fecha com discurso motivacional. Mantenha o fato e corte o verniz; termine no último dado concreto.
**Antes:**
> O instituto foi criado em 1989, marcando um momento crucial na evolução das estatísticas regionais e refletindo um movimento mais amplo de descentralização administrativa.
**Depois:**
> O instituto foi criado em 1989, durante a descentralização administrativa do país.

### 14. Conexão ou associação vaga

**Observar:** associado a, em associação com, ligado a, conectado a, em conexão com, relacionado a.
**Problema:** afirma que duas coisas têm relação sem dizer qual. Nomeie o vínculo concreto que a fonte traz (criou, dirigiu, financiou, fez parte).

### 15. Caudas de gerúndio vazias

**Observar:** `, destacando...`, `, ressaltando...`, `, enfatizando...`, `, garantindo...`, `, assegurando...`, `, refletindo...`, `, simbolizando...`, `, contribuindo para...`, `, fomentando...`, `, promovendo...`, `, consolidando...`, `, proporcionando...`.
**Problema:** uma oração reduzida de gerúndio é pendurada no fim de uma frase simples para fingir consequência ou profundidade (além do gerundismo "vai estar fazendo"). Corte a cauda de gerúndio ou transforme em fato concreto se a fonte comprovar.
**Antes:**
> A fachada usa azul, verde e dourado, simbolizando a flora da região e refletindo a conexão da comunidade com o território.
**Depois:**
> A fachada é pintada de azul, verde e dourado, cores escolhidas em referência à flora da região.

### 16. Linguagem publicitária

**Observar:** rico patrimônio, profundo compromisso com, exemplifica, beleza exuberante, situado no coração de, inovador / revolucionário, renomado, conta com uma ampla gama de, de tirar o fôlego, parada obrigatória, deslumbrante.
**Problema:** soa como folheto turístico ou release comercial. Diga o que a coisa é.
**Antes:**
> Situada no coração da Serra da Mantiqueira, a cidade encanta com uma rica herança cultural e paisagens de tirar o fôlego.
**Depois:**
> A cidade fica na Serra da Mantiqueira.

### 17. Autoridade emprestada

**Observar:** especialistas apontam, observadores destacam, relatórios do setor indicam, segundo críticos, diversas publicações.
**Problema:** usa uma autoridade sem nome para sustentar uma opinião. Cite quem disse e o que disse, ou corte a frase.

### 18. Fuga dos verbos *ser*, *estar* e *ter*

**Observar:** atua como, serve como, configura-se como, apresenta-se como, posiciona-se como, constitui (no lugar de *é* / *são*); possui, conta com, dispõe de, ostenta, contempla, oferece (no lugar de *tem* quando se trata de característica simples); encontra-se (no lugar de *está*).
**Problema:** troca verbos diretos (*é*, *são*, *está*, *tem*) por circunlóquios formais. "Possui" e "conta com" em toda frase são um dos sinais mais frequentes de texto gerado ou burocrático em PT-BR.
**Antes:**
> A galeria atua como espaço de exposição da associação e conta com quatro salas que totalizam 280 metros quadrados.
**Depois:**
> A galeria é o espaço de exposição da associação e tem quatro salas, num total de 280 metros quadrados.

## D. Formatação por regra

### 19. Negrito como decoração

**Problema:** palavras soltas em negrito no meio do parágrafo sem necessidade, ou listas em que todo item começa com `**Rótulo:**` repetindo as mesmas palavras na frase ao lado. Remova o negrito decorativo e converta listas artificiais em texto corrido quando os rótulos não acrescentarem informação.

### 20. Títulos decorativos e Title Case em português

**Problema:** em português, títulos e subtítulos usam letra maiúscula apenas na primeira palavra e em nomes próprios (norma ortográfica brasileira). Capitalizar Todas As Palavras De Um Título (`## Negociações Estratégicas E Parcerias Globais`) é decalque direto do inglês. Remova também emojis decorativos (`🚀`, `💡`, `📌`) e setas (`→`) em títulos e listas.
**Antes:**
> ## Negociações Estratégicas E Parcerias Globais
**Depois:**
> ## Negociações estratégicas e parcerias globais

### 21. Aspas curvas

**Problema:** respeite o padrão de aspas do arquivo ou projeto. *Fraco sozinho.*

## E. Sobras do chat e do rascunho

Remova integralmente.

### 22. Resíduo de chatbot

**Observar:** Espero que isso ajude!, Espero ter ajudado!, Claro!, Com certeza!, Certamente!, Ótima pergunta!, Excelente ponto!, Você tem toda razão, Gostaria que eu..., Quer que eu...?, Posso detalhar se quiser, Qualquer dúvida estou à disposição, Aqui está uma visão geral sobre...
**Problema:** cumprimentos, elogios e ofertas finais de assistente virtual deixados dentro de um documento, issue, PR ou resposta técnica. Corte o invólucro e entregue o conteúdo.

### 23. Avisos de limite de conhecimento e palpites

**Observar:** até minha última atualização, com base nas informações disponíveis, embora detalhes específicos sejam limitados, não está amplamente documentado, nas fontes fornecidas, provavelmente [estudou, cresceu, começou], acredita-se que.
**Problema:** expõe o corte de treinamento do modelo ou preenche lacuna de fonte com especulação ("provavelmente cresceu em..."). Diga apenas o que a fonte mostra ou omita o trecho.

### 24. Título repetido na primeira frase

**Problema:** o parágrafo logo abaixo de um subtítulo apenas repete o subtítulo com outras palavras antes de entrar no assunto. Corte a primeira frase.

### 25. Escrever sobre o documento em vez do assunto

**Observar:** "Esta função foi adicionada para substituir...", "A tabela abaixo foi compilada a partir de...", "Qualquer dado não confirmado foi sinalizado em vez de estimado", "Esta seção está organizada por...".
**Problema:** narra os bastidores de como o texto foi montado em vez de informar o assunto.

## F. Escrever para a pessoa leitora errada

### 26. Reexplicar o que quem lê já sabe

**Problema:** em respostas de PR, issue ou thread, o modelo reconstrói todo o contexto e deixa a decisão para a última linha. Comece pela decisão ou resposta direta e mantenha só o argumento ou dado que muda a conclusão.
