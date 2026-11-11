extends RefCounted
## Minas Gerais: estado grande, 4 fases. O boss O Trem fica na última.

const ID := "MG"
const NAME := "MINAS GERAIS"
const POWER := "pao"                 # item das caixas de poder (scripts/powers.gd)
const POWER_NAME := "PÃO DE QUEIJO"
const BOSS_NAME := "O TREM"
const MUSIC := "forro"

const LEVELS := [
	preload("res://levels/minas_gerais_1.gd"),
	preload("res://levels/minas_gerais_2.gd"),
	preload("res://levels/minas_gerais_3.gd"),
	preload("res://levels/minas_gerais_4.gd"),
]

const FINAL_MESSAGE := "MINAS GERAIS CONCLUÍDO!\n\nO CARAMELO PASSOU POR AQUI...\nMAS JÁ FOI LEVADO PARA OUTRO ESTADO!"
