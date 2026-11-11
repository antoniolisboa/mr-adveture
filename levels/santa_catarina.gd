extends RefCounted
## Santa Catarina: as ondas e as tainhas da Joaquina e a Ponte Hercílio Luz, onde
## mora a Bruxa da Ilha (Florianópolis, a Ilha da Magia).

const ID := "SC"
const NAME := "SANTA CATARINA"
const POWER := "prancha"             # item das caixas de poder (scripts/powers.gd)
const POWER_NAME := "PRANCHA DE SURFE"
const BOSS_NAME := "A BRUXA DA ILHA"
const MUSIC := "surf"

const LEVELS := [
	preload("res://levels/santa_catarina_1.gd"),
	preload("res://levels/santa_catarina_2.gd"),
]

const FINAL_MESSAGE := "SANTA CATARINA CONCLUÍDA!\nNA ILHA DA MAGIA, A BRUXA AGORA DEIXA TODO MUNDO PASSAR!\n\nO CARAMELO PASSOU POR AQUI...\nMAS JÁ FOI LEVADO PARA OUTRO ESTADO!"
