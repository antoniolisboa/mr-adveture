extends RefCounted
## Rio de Janeiro: estado pequeno, 2 fases. O boss Vendedor de Mate fica na última.

const ID := "RJ"
const NAME := "RIO DE JANEIRO"
const POWER := "raquete"             # item das caixas de poder (scripts/powers.gd)
const POWER_NAME := "RAQUETE DE FRESCOBOL"
const BOSS_NAME := "VENDEDOR DE MATE"
const MUSIC := "samba"

const LEVELS := [
	preload("res://levels/rio_de_janeiro_1.gd"),
	preload("res://levels/rio_de_janeiro_2.gd"),
]

const FINAL_MESSAGE := "RIO DE JANEIRO CONCLUÍDO!\n\nO CARAMELO PASSOU POR AQUI...\nMAS JÁ FOI LEVADO PARA OUTRO ESTADO!"
