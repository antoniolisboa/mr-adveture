extends RefCounted
## Pernambuco: estado pequeno, 2 fases. O boss Boneco Gigante de Olinda fica na última.

const ID := "PE"
const NAME := "PERNAMBUCO"
const POWER := "sombrinha"           # item das caixas de poder (scripts/powers.gd)
const POWER_NAME := "SOMBRINHA DE FREVO"
const BOSS_NAME := "BONECO GIGANTE DE OLINDA"
const MUSIC := "frevo"

const LEVELS := [
	preload("res://levels/pernambuco_1.gd"),
	preload("res://levels/pernambuco_2.gd"),
]

const FINAL_MESSAGE := "PERNAMBUCO CONCLUÍDO!\nÔXE, QUE FREVO ARRETADO!\n\nO CARAMELO PASSOU POR AQUI...\nMAS JÁ FOI LEVADO PARA OUTRO ESTADO!"
