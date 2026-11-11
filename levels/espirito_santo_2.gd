extends RefCounted
## Espírito Santo - fase 2: Ladeira Da Penha. Cada caractere é um bloco de 16x16 pixels.
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
##   E  elevador (sobe ELEVATOR_RISE blocos e desce; 2 blocos de largura)
##   P  início do jogador
##   C  cartaz de PROCURA-SE (checkpoint)
##   F  placa de saída (fim da fase)
##   [ ]  portões da arena do boss    T  boss (BOSS: "trem", "mate", "trio", "panela" ou "coach")
##   G  último lugar do caramelo no estado (fim do estado)

const NAME := "LADEIRA DA PENHA"
const THEME := "penha"
const CLUE := ""
const BOSS := "panela"
const GOAL := "moqueca"

const ROWS := [
	"............................................................................................................................",
	"............................................................................................................................",
	"............................................................................................................................",
	"..................................................................=?=.......................................................",
	"..................................W........bbbb...........W.................................................................",
	"............................................................................................................................",
	".....................W........................R..........bbb..........R.....C.....[...............T....]........G...........",
	".........=?=........bbb.................############............############################################################",
	".............bbb....................R...############..R.......R.############################################################",
	"................................#########################...################################################################",
	"...P............R...........R...#########################...################################################################",
	"####################...##################################...################################################################",
	"####################...##################################...################################################################",
]
