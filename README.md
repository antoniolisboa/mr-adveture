# Resgate do Caramelo

Protótipo de jogo de plataforma em pixel art, feito na Godot 4.7.
Estados prontos: toda a região Sudeste (Minas Gerais com 4 fases, Rio de Janeiro com 2, Espírito Santo com 2
e São Paulo com 3) e a Bahia (4 fases), escolhidos no mapa do Brasil.

## Como rodar

1. Baixe a Godot 4.7 (versão padrão, não a "mono"): https://godotengine.org/download
2. Abra a Godot, clique em **Importar** e escolha o arquivo `project.godot` desta pasta.
3. Aperte **F5** para jogar.

## Rodar pelo terminal (isolado)

O binário da Godot fica em `tools/godot/` (fora do git). `tools/godot.sh` roda ele dentro do
bubblewrap: sem rede, sistema somente leitura e só a pasta do projeto gravável.

```
tools/godot.sh --headless --import                      # importa o projeto
tools/godot.sh                                          # abre o jogo
tools/godot.sh --headless -s res://tests/smoke_test.gd  # teste automático de todas as fases
tools/godot.sh --headless -s res://tests/box_test.gd    # testa se dá para pegar o item de cada caixa
```

O teste automático abre cada fase de cada estado pronto, faz um robô correr e pular,
e leva ele até a arena para lutar contra o boss. No fim mostra até onde chegou e se o boss caiu.
Com `TESTE_DETALHADO=1` mostra a luta segundo a segundo.

Para ver como ficou o visual sem jogar: `tools/godot.sh -s res://tests/screenshots.gd -- BA`
abre a janela por alguns segundos e salva fotos de cada fase do estado em `tests/screens/`.

## Controles

| Ação | Teclado | Controle |
| --- | --- | --- |
| Andar | Setas ou A/D | Direcional ou analógico |
| Pular | Z, Espaço, W ou seta para cima | A |
| Usar o item do estado (ver cada estado; a sombrinha de frevo plana enquanto segura) | X, J ou Shift | X ou B |
| Voltar ao último cartaz | R | Back/Select |
| Escolher personagem / estado no mapa | Setas esquerda-direita | Direcional |
| Escolher a fase no mapa | Setas cima-baixo | Direcional |
| Sair do estado e voltar ao mapa | Esc ou Backspace | |
| Confirmar no menu | Enter | Start |

## As fases de Minas Gerais

| Fase | Nome | Cenário | Novidade |
| --- | --- | --- | --- |
| 1 | A Serra | Montanhas, igrejinha e pés de café | Queijos bravos, buracos, caixotes |
| 2 | Ouro Preto | Casario colorido e calçamento de pedra | Ladeiras e a xícara de café que pula |
| 3 | Mina de Ouro | Caverna com escoras e lampiões | Teto baixo e túneis apertados |
| 4 | Estação da Maria Fumaça | Pôr do sol com postes de telégrafo | Boss O Trem |

As fases 1 a 3 terminam na placa verde de **SAÍDA**, com uma pista de para onde o caramelo foi.
O poder do pão de queijo passa de uma fase para a outra. Os biscoitos e o checkpoint são por fase.
No mapa dá para escolher a fase inicial (útil para testar).

## O mapa do Brasil

Depois de escolher o personagem aparece o mapa com os 27 estados. Amarelo = pronto,
verde = concluído, cinza = ainda não feito. A lista fica em `levels/states.gd`.

## As fases do Rio de Janeiro

| Fase | Nome | Cenário | Novidade |
| --- | --- | --- | --- |
| 1 | Calçadão de Copacabana | Mar, Pão de Açúcar e coqueiros | Pombos que voam e frescobolistas que sacam bolinhas |
| 2 | A Praia | Areia e guarda-sóis | Boss Vendedor de Mate |

- Item de poder: **raquete de frescobol**. O X dá uma raquetada que derruba inimigos
  e rebate bolinhas e biscoitos de volta.
- Boss **Vendedor de Mate**: anda pela arena arremessando biscoitos (dá para rebater) e
  de vez em quando grita "GELADINHO!" e espirra jatos de mate rente ao chão (pule).
  Vida 6; pisão tira 2, raquetada ou biscoito rebatido tira 1. Com metade da vida ele acelera.
- O fim do estado é o guarda-sol com a coleira do caramelo esquecida.
- Música de samba (cavaquinho, surdo, tamborim e ganzá), também gerada em código.

## O que tem nas fases

- Escolha entre ele e ela no menu.
- Caixa de poder: dê uma cabeçada por baixo para soltar o pão de queijo.
- Com o pão de queijo, a camisa muda de cor e o X arremessa pães que quicam. Levou dano, perde o poder.
- Queijo bravo e xícara de café pulante: morrem com pisão ou com pão de queijo.
- Biscoitos de polvilho para coletar em todas as fases.
- Cartaz de PROCURA-SE no meio da fase serve de checkpoint.
- Boss **O Trem**: a arena fecha quando você entra. Ele arremessa panelas, xícaras e
  queijinhos, apita e dispara pela arena. Pule por cima; quando ele bate na parede fica tonto.
  Pisão tira 2 de vida e pão de queijo tira 1 (vida total: 6). Com metade da vida ele acelera.
- Na fase 4, um cartaz fica logo antes da arena, para recomeçar perto do boss.
- A casinha vazia do caramelo, depois da arena, marca o fim da fase.
- Efeitos sonoros 8-bit e música de forró (baião com sanfona, zabumba e triângulo),
  tudo gerado em código, sem arquivos de áudio. Na luta contra o boss a música acelera.

## As fases da Bahia

| Fase | Nome | Cenário | Novidade |
| --- | --- | --- | --- |
| 1 | Pelourinho | Casario colorido com fitas | Ladeira, foliões pipoca e pimentas do acarajé |
| 2 | Elevador Lacerda | Baía de Todos os Santos | Fase alta com elevadores entre a Cidade Baixa e a Alta |
| 3 | Farol da Barra | Pôr do sol com o farol e o forte | Mais buracos e pedras no meio do vão |
| 4 | Circuito do Carnaval | Noite de festa com a multidão | Boss Trio Elétrico Desgovernado |

- Item de poder: **berimbau**. O X dá uma rasteira de capoeira que pega os dois lados ao mesmo tempo.
- **Folião pipoca:** dança no lugar e, quando você pula, ele pula junto ("tira o pé do chão!").
- **Pimenta do acarajé:** quando te vê na mesma altura, esquenta, treme e dá uma arrancada.
- **Elevador:** plataforma que sobe e desce; dá para subir nela pulando por baixo.
- Boss **Trio Elétrico Desgovernado**: anda pela arena soltando notas musicais. As baixas pedem pulo;
  as altas passam por cima de quem fica no chão. Ao bater na parede, "O SOM CAIU!": ele para e a música
  some. Dá para pular por cima dele. Vida 8; pisão tira 2, rasteira tira 1. Com metade da vida ele acelera
  e faz chover confete.
- O fim do estado é o cordão do bloco com um abadá do tamanho do caramelo e as pegadas dele.
- Música de axé (metais, surdos de samba-reggae, repique e ganzá), também gerada em código.

## As fases do Espírito Santo

| Fase | Nome | Cenário | Novidade |
| --- | --- | --- | --- |
| 1 | Terceira Ponte | Baía de Vitória, a ponte e o Convento da Penha ao fundo | Vãos sobre o mar e a corcova da ponte |
| 2 | Ladeira da Penha | Mata atlântica e o convento no alto do morro | Subida em degraus e o boss Panela de Moqueca Gigante |

- Item de poder: **panela de barro**. O X levanta a panela na frente como escudo por meio segundo:
  tiros que batem nela fazem "clang" e somem, e inimigo que encosta nela leva uma panelada.
- **Robalo:** quando te vê, solta um "!" e corre atrás de você... e logo esquece que você existe ("?").
  Depois de esquecer, demora um pouco para reparar de novo.
- **Gaivota distraída:** mergulha quando você passa embaixo, mas esquece no meio do caminho e volta para cima.
- Boss **Panela de Moqueca Gigante** ("MOQUECA É CAPIXABA, O RESTO É PEIXADA!"): ferve (treme, sai vapor e
  em cima fica quente demais para pisar), a tampa poca e voam tomates e postas de peixe, depois ela dá
  pulos atrás de você e cada pouso espirra moqueca rente ao chão para os dois lados. Aí ela cansa, a tampa
  fica torta e é a hora de pisar. Vida 8; pisão tira 2, panelada tira 1. Com metade da vida joga mais coisa
  e pula três vezes.
- O fim do estado é uma panelinha de moqueca lambida, a espinha do peixe e as pegadas do caramelo.
- Música de congo capixaba (flauta, tambores de congo e casaca), gerada em código.
- Na tela final: "SIM, ELE EXISTE!".

## As fases de São Paulo

| Fase | Nome | Cenário | Novidade |
| --- | --- | --- | --- |
| 1 | Marginal | Céu cinza, o rio, placas verdes e garoa | Carros do trânsito parado que andam um pouquinho e param (dá para subir no teto) |
| 2 | Faria Lima | Torres de vidro espelhado e a ciclovia | Coachinhos, patinetes desgovernados e canteiros em degrau |
| 3 | Terraço do Coworking | Fim de tarde, mar de prédios, antenas e garoa | Boss Coach Quântico |

- Item de poder: **patinete**. O X dá uma arrancada rápida para a frente que atravessa vãos maiores
  e atropela os inimigos no caminho. Virar para trás corta a arrancada.
- **Patinete desgovernado:** patinete de aluguel largado que resolveu andar sozinho; corre e vira na beirada.
- **Coachinho:** fica parado e dispara frases motivacionais ("FOCO!", "MINDSET!") em balões na altura da cabeça.
- **Carro:** no trânsito da Marginal, anda um pouco e para; serve de plataforma.
- Boss **Coach Quântico** ("BEM-VINDO À SUA ZONA DE DESCONFORTO!"): dá palestra andando pelo palco e soltando
  palavras em balões (as baixas pedem pulo, as altas passam por cima), se teletransporta para o outro lado
  ("QUÂNTICO!") e, a cada dois teleportes, faz a "IMERSÃO": vira três (quatro com metade da vida). Os clones
  falham de vez em quando, como imagem com defeito; acertar um clone faz ele sumir, acertar o verdadeiro acaba
  com a imersão. Vida 10; pisão tira 2, golpe tira 1. Ao cair: "GRATIDÃO...".
- O fim do estado é um pufe de coworking amassado no formato de um cachorro e o crachá "CARAMELO - ESTAGIÁRIO".
- Música "garoa" (sintetizador, baixo e bateria), gerada em código.

## O Nordeste inteiro

Além da Bahia, os outros 8 estados do Nordeste. Todos têm item próprio, inimigos novos,
música própria (gerada em código) e boss. Os estados grandes (Maranhão e Piauí) têm 3 fases;
os outros, 2.

| Estado | Fases | Item de poder (X) | Inimigos novos | Boss | Música |
| --- | --- | --- | --- | --- | --- |
| Pernambuco | Ladeiras de Olinda, Alto da Sé | **Sombrinha de frevo**: segure X no ar para planar; o pisão quica mais alto | Sombrinha saltitante | Boneco Gigante de Olinda | frevo |
| Paraíba | Arraial de Campina Grande, Parque do Povo | **Sanfona**: giro de forró que derruba dos dois lados | Rojão (sobe e estoura em faíscas), sanfona andante | Quadrilha Gigante | forró de São João |
| Rio Grande do Norte | Dunas de Genipabu, Morro do Careca | **Chave do buggy**: anda de buggy (mais rápido, pulo maior); X = pulo "com emoção" | Buggy desgovernado, caju que cai do pé | Bugueiro "Com Emoção" | coco |
| Ceará | Praia de Iracema, Feirinha da Beira-Mar | **Microfone**: conta piada; o inimigo fica rindo parado (e inofensivo) por 3 s | Piadista (a piada dele faz você rir parado) | O Rei da Resenha | xote |
| Maranhão | Lençóis Maranhenses, Centro Histórico de São Luís, Arraial do Boi | **Disco de reggae**: pulo alto e lento; X joga o disco, que vai e volta | Regueiro, ilhota da lagoa que afunda e volta | Bumba Meu Boi Gigante | reggae |
| Piauí | Teresina ao Meio-Dia, Serra da Capivara, Ponte Estaiada | **Leque**: X abana (sopra inimigos e refresca); esquenta na metade do tempo | Onda de calor (não dá para pisar), calango | O Sol de Teresina | baião de meio-dia |
| Alagoas | Piscinas Naturais de Maragogi, Galés de Maragogi | **Snorkel**: fôlego sem fim e nado rápido; X acelera debaixo d'água | Ouriço (não pise), baiacu (incha perto) | Siri de Maragogi | coco de roda |
| Sergipe | Orla de Atalaia (dura uns 10 segundos...), Passarela do Caranguejo (a surpresa) | **Pinça de caranguejo**: X agarra o inimigo da frente; X de novo arremessa, e ele sai rolando | Caranguejo | Caranguejo da Passarela | xote praieiro |

Mecânicas novas:

- **Calor (Piauí):** a barra de CALOR sobe no sol e desce na sombra (qualquer bloco até 6 andares
  acima da cabeça: toldos, marquises, pedras). Encheu, perde o item (ou a vida).
- **Água e maré (Alagoas):** debaixo d'água o pulo vira braçada. A barra de FÔLEGO dura 7 segundos;
  com a cabeça fora d'água ela enche. Na primeira fase a maré sobe e desce: na maré cheia o recife fica
  submerso; na baixa sobram só as piscinas.
- **Risada (Ceará):** levar uma piada deixa o personagem rindo parado ~1 segundo, sem perder vida.
- **Bosses do Nordeste:** o golpe do item só tira vida na hora em que o boss está vulnerável (a mesma
  hora do pisão), para a luta não virar só apertar X. A exceção é a pinça: caranguejinho arremessado
  sempre machuca o Caranguejo da Passarela.

Os bosses:

- **Boneco Gigante de Olinda:** pula frevo atrás de você (corra por baixo quando ele estiver no ar),
  rodopia varrendo o chão com as mangas e, tonto, faz uma reverência: a cabeça desce até o chão.
- **Quadrilha Gigante:** obedece ao marcador: "CAMINHO DA ROÇA!" (a fila atravessa a arena), "OLHA A COBRA!"
  (cobra de pano rente ao chão), "OLHA A CHUVA!" (pingos) e "É MENTIRA!" (todo mundo para e ri: pise no noivo).
- **Bugueiro "Com Emoção":** pergunta "COM OU SEM EMOÇÃO?", atravessa a arena a toda saltando perto de você,
  atola na areia (hora de pisar) e volta "sem emoção" jogando areia.
- **O Rei da Resenha:** conta piadas em balões altos e baixos, ri da própria piada (vulnerável) e vem dar
  um abraço apertado ("MEU AMIGO!").
- **Bumba Meu Boi Gigante:** dança jogando matracas, investe contra a parede e fica vendo estrela.
  Como no auto do boi, ele morre... e ressuscita com metade da vida, mais rápido e pulando.
- **O Sol de Teresina:** de óculos escuros, lá no alto. Marca faixas no chão e manda raios nelas, solta ondas
  de calor e, cansado do próprio calor, desce para tomar uma cajuína: hora de pisar.
- **Siri de Maragogi:** anda de lado com as pinças protegendo o casco, dá botes de pinça e, com cãibra,
  abaixa a guarda. Depois sopra bolhas.
- **Caranguejo da Passarela:** corre de lado, dá martelada na passarela (sai lama pelos dois lados e a pinça
  entala nas tábuas: pise) e chama os caranguejinhos, que viram munição para a pinça.

Completar os 9 estados do Nordeste entrega a **vasilha de água** do caramelo.

## Objetos do caramelo e progresso salvo

- Cada região completa entrega um objeto do caramelo: Norte = coleira, Nordeste = vasilha de água,
  Centro-Oeste = bolinha, Sudeste = osso favorito, Sul = cobertor velho. O Sudeste (osso favorito) e o
  Nordeste (vasilha de água) já podem ser completados.
- A coleção aparece no canto de baixo do mapa (apagado = ainda não achou). No painel do estado aparece
  quantos estados da região já foram concluídos.
- Os estados concluídos e os objetos ficam salvos em `progresso.cfg`, na pasta de dados da Godot
  (rodando pelo `tools/godot.sh`: `tools/home/.local/share/godot/app_userdata/<nome do projeto>/`).
  Apagar esse arquivo zera o progresso. Os testes automáticos não mexem nele.
- Teste da entrega do objeto: `tools/godot.sh --display-driver wayland -s res://tests/region_test.gd -- NE`
  (sem nada = Sudeste).

## Como editar

- **Mapas das fases:** `levels/<estado>_<n>.gd` (ex.: `levels/minas_gerais_1.gd`, `levels/pernambuco_2.gd`). Cada letra é um bloco; a legenda está no topo de cada arquivo (as fases do Nordeste têm a legenda completa, com os inimigos novos e as constantes de calor, água e maré).
  Cada fase também define o nome, o tema do cenário (`serra`, `cidade`, `mina`, `estacao`, `calcadao`, `praia`,
  `pelourinho`, `baia`, `farol`, `carnaval`, `ponte`, `penha`, `marginal`, `farialima`, `terraco`; os do Nordeste
  estão listados em `scripts/bg_ne.gd`), a pista mostrada no fim e, na última, o boss (`BOSS`) e o fim do estado
  (`GOAL`: `casinha`, `barraca`, `abada`, `moqueca`, `cracha`; os do Nordeste em `scripts/goal_ne.gd`).
- **Dados de cada estado** (fases, item, boss, música): `levels/<estado>.gd` (ex.: `levels/sergipe.gd`).
- **Itens de poder:** `scripts/powers.gd`.
- **Novo estado:** crie `levels/<estado>.gd` com as fases e aponte o `data` dele em `levels/states.gd`.
- **Pixel art:** `scripts/art.gd` e `scripts/art_ne.gd` (Nordeste). Cada sprite é desenhado como texto, uma letra por pixel.
  Depois dá para trocar por imagens PNG feitas no Aseprite.
- **Física do pulo e velocidade:** constantes no topo de `scripts/player.gd`.
- **Música:** as melodias (forró, samba, axé, congo, garoa, frevo, reggae, xote, coco...) são listas de notas no topo de `scripts/music.gd` (ex.: `["D5", 2]` = ré, duas semicolcheias).

## Estrutura

```
levels/                lista dos estados, dados de cada estado e o mapa de cada fase
project.godot          configuração (tela 320x180, escala inteira)
scenes/main.tscn       cena inicial
scripts/main.gd        menu, mapa, fase, morte e checkpoint
scripts/game.gd        estado global e controles (autoload "Game")
scripts/level.gd       monta a fase a partir do mapa em texto
scripts/player.gd      herói
scripts/world_map.gd   mapa do Brasil (escolha do estado e da fase)
scripts/powers.gd      itens de poder de cada estado
scripts/queijo.gd      inimigo que anda
scripts/xicara.gd      inimigo que pula
scripts/pombo.gd       inimigo que voa (Rio)
scripts/frescobolista.gd inimigo que saca bolinhas (Rio)
scripts/foliao.gd      inimigo que pula quando você pula (Bahia)
scripts/pimenta.gd     inimigo que dá arrancada (Bahia)
scripts/elevator.gd    plataforma que sobe e desce (Bahia)
scripts/robalo.gd      inimigo que corre atrás e esquece (Espírito Santo)
scripts/gaivota.gd     inimigo que mergulha e esquece (Espírito Santo)
scripts/patinete_mau.gd inimigo que corre e vira na beirada (São Paulo)
scripts/coachinho.gd   inimigo que dispara frases motivacionais (São Paulo)
scripts/carro.gd       carro do trânsito, plataforma que anda e para (São Paulo)
scripts/walker.gd      base dos inimigos do Nordeste (andar, pisão, golpe, rir da piada)
scripts/sombrinha_mau.gd, rojao.gd, sanfona_mau.gd, buggy_mau.gd, caju.gd, piadista.gd,
  regueiro.gd, onda_calor.gd, calango.gd, ourico.gd, baiacu.gd, caranguejo.gd   inimigos do Nordeste
scripts/ilhota.gd      ilhota da lagoa que afunda e volta (Maranhão)
scripts/player_shot.gd piada do microfone, disco de reggae e inimigo arremessado pela pinça
scripts/exit_sign.gd   placa de saída das fases 1 a 3
scripts/power_box.gd   caixa de poder
scripts/pickup.gd      biscoito e item de poder
scripts/projectile.gd  pão de queijo arremessado
scripts/checkpoint.gd  cartaz de PROCURA-SE
scripts/goal.gd        fim do estado (casinha, guarda-sol, cordão do bloco panelinha de moqueca ou crachá)
scripts/boss_arena.gd  arena do boss (portões e câmera)
scripts/boss_trem.gd   boss O Trem (Minas)
scripts/boss_mate.gd   boss Vendedor de Mate (Rio)
scripts/boss_trio.gd   boss Trio Elétrico Desgovernado (Bahia)
scripts/boss_panela.gd boss Panela de Moqueca Gigante (Espírito Santo)
scripts/boss_coach.gd  boss Coach Quântico (São Paulo)
scripts/boss_base.gd   base dos bosses do Nordeste (vida, balão de fala, dano, explosão)
scripts/boss_boneco.gd, boss_quadrilha.gd, boss_bugueiro.gd, boss_resenha.gd, boss_boi.gd,
  boss_sol.gd, boss_siri.gd, boss_caranguejo.gd   bosses do Nordeste
scripts/goal_ne.gd     fins de estado do Nordeste
scripts/enemy_shot.gd  projéteis inimigos (trens, bolinhas, biscoitos, mate, notas, moqueca, frases de coach)
scripts/debris.gd      pedaços do boss quando ele se desmancha
scripts/sfx.gd         efeitos sonoros (autoload "Sfx")
scripts/music.gd       música de forró, samba, axé, congo e garoa (autoload "Music")
scripts/background.gd  fundos com parallax (Sudeste e Bahia)
scripts/bg_ne.gd       fundos do Nordeste
scripts/hud.gd         interface
scripts/title.gd       menu inicial
scripts/pixel_text.gd  fonte em pixel art
scripts/art.gd         sprites (e scripts/art_ne.gd, os do Nordeste)
tests/smoke_test.gd    teste automático das fases (-- PE PB para só alguns estados)
tests/boss_test.gd     derrota cada boss do Nordeste pisando só na hora certa (mede o tempo)
tests/powers_test.gd   testa os 8 itens do Nordeste
tests/load_all.gd      carrega todos os scripts (acha erro de compilação rápido)
tests/box_test.gd      teste das caixas de poder
tests/region_test.gd   teste da entrega do objeto da região
tests/screenshots.gd   fotos de cada fase de um estado
tools/godot.sh         roda a Godot isolada (bubblewrap)
tools/gen/             geradores (Python) dos mapas das fases: python3 tools/gen/gen_pe.py etc.
                       (check_art.py confere se os sprites têm todas as linhas do mesmo tamanho)
```
