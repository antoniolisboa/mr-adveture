extends RefCounted
## Maranhão: estado grande, 3 fases. O boss Bumba Meu Boi Gigante fica na última.

const ID := "MA"
const NAME := "MARANHÃO"
const POWER := "reggae"              # item das caixas de poder (scripts/powers.gd)
const POWER_NAME := "DISCO DE REGGAE"
const BOSS_NAME := "BUMBA MEU BOI GIGANTE"
const MUSIC := "reggae"

const LEVELS := [
	preload("res://levels/maranhao_1.gd"),
	preload("res://levels/maranhao_2.gd"),
	preload("res://levels/maranhao_3.gd"),
]

const FINAL_MESSAGE := "MARANHÃO CONCLUÍDO!\nA JAMAICA BRASILEIRA AGRADECE!\n\nO CARAMELO PASSOU POR AQUI...\nMAS JÁ FOI LEVADO PARA OUTRO ESTADO!"
