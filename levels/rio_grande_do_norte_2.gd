extends RefCounted
## Rio Grande do Norte - fase 2: Morro Do Careca. Cada caractere é um bloco de 16x16 pixels.
##
## Legenda:
##   .  vazio            #  chão (o visual muda conforme o tema)
##   =  bloco de pedra   X  caixote de madeira
##   ?  caixa de poder (solta o item do estado)
##   b  biscoito de polvilho
##   Q  queijo bravo     H  xícara de café pulante
##   V  pombo (voa)      J  frescobolista (arremessa bolinhas)
##   K  pimenta do acarajé (arranca quando vê o jogador)
##   O  folião pipoca (pula quando o jogador pula)
##   R  robalo (corre atrás do jogador e depois esquece)
##   W  gaivota (mergulha no jogador e esquece no meio do caminho)
##   S  patinete desgovernado (corre e vira na beirada)
##   Y  coachinho (dispara frases motivacionais)
##   A  carro no trânsito (anda e para; dá para subir; 2 blocos de largura)
##   U  sombrinha de frevo saltitante      D  rojão (sobe e estoura quando chega perto)
##   N  sanfona andante (estica e encolhe) B  buggy desgovernado
##   Z  caju (cai do pé quando o jogador passa embaixo)
##   M  piadista (conta piada; quem ouve fica rindo parado)
##   I  regueiro (dança devagar)           L  ilhota da lagoa (afunda e volta)
##   u  onda de calor (não dá para pisar)  c  calango (corre e para)
##   o  ouriço (espinhento: não pise)      p  baiacu (incha quando chega perto)
##   k  caranguejo (anda de lado)
##   E  elevador (sobe ELEVATOR_RISE blocos e desce; 2 blocos de largura)
##   P  início do jogador
##   C  cartaz de PROCURA-SE (checkpoint)
##   F  placa de saída (fim da fase)
##   [ ]  portões da arena do boss    T  boss (BOSS: ver scripts/boss_arena.gd)
##   G  último lugar do caramelo no estado (fim do estado)
##
## Constantes opcionais: HEAT (sol de meio-dia, barra de calor), WATER_ROW (linha onde
## começa a água), TIDE (quantos blocos a maré baixa) e TIDE_PERIOD (segundos da maré).

const NAME := "MORRO DO CARECA"
const THEME := "morrocareca"
const CLUE := ""
const BOSS := "bugueiro"
const GOAL := "caju"

const ROWS := [
	"............................................................................................................................",
	"............................................................................................................................",
	"............................................................................................................................",
	"............................................................................................................................",
	".........................................bbbbbb.............................................................................",
	"............................................................................................................................",
	"............................................................................................................................",
	"................Z.................Z...................Z...............Z.....................................................",
	"..........=?=.............................####....................=?=.......................................................",
	"............................bbb.........########........bbb.................................................................",
	"......................................############..........................................................................",
	"...P................B...............################..........B...........B...C...[...............T....]........G...........",
	"############################...#########################...#################################################################",
	"############################...#########################...#################################################################",
]
