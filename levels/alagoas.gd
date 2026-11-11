extends RefCounted
## Alagoas: estado pequeno, 2 fases com água (piscinas naturais e maré).
## O boss Siri de Maragogi fica na última.

const ID := "AL"
const NAME := "ALAGOAS"
const POWER := "snorkel"             # item das caixas de poder (scripts/powers.gd)
const POWER_NAME := "SNORKEL"
const BOSS_NAME := "SIRI DE MARAGOGI"
const MUSIC := "mare"

const LEVELS := [
	preload("res://levels/alagoas_1.gd"),
	preload("res://levels/alagoas_2.gd"),
]

const FINAL_MESSAGE := "ALAGOAS CONCLUÍDA!\nQUE ÁGUA MAIS AZUL, VISSE?\n\nO CARAMELO PASSOU POR AQUI...\nMAS JÁ FOI LEVADO PARA OUTRO ESTADO!"
