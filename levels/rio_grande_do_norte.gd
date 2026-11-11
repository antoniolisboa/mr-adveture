extends RefCounted
## Rio Grande do Norte: estado pequeno, 2 fases. O boss Bugueiro "Com Emoção" fica na última.

const ID := "RN"
const NAME := "RIO GRANDE DO NORTE"
const POWER := "buggy"               # item das caixas de poder (scripts/powers.gd)
const POWER_NAME := "CHAVE DO BUGGY"
const BOSS_NAME := "BUGUEIRO \"COM EMOÇÃO\""
const MUSIC := "dunas"

const LEVELS := [
	preload("res://levels/rio_grande_do_norte_1.gd"),
	preload("res://levels/rio_grande_do_norte_2.gd"),
]

const FINAL_MESSAGE := "RIO GRANDE DO NORTE CONCLUÍDO!\nFOI COM EMOÇÃO!\n\nO CARAMELO PASSOU POR AQUI...\nMAS JÁ FOI LEVADO PARA OUTRO ESTADO!"
