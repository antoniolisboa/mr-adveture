extends RefCounted
## Ceará: estado médio, 2 fases. O boss O Rei da Resenha fica na última.

const ID := "CE"
const NAME := "CEARÁ"
const POWER := "microfone"           # item das caixas de poder (scripts/powers.gd)
const POWER_NAME := "MICROFONE"
const BOSS_NAME := "O REI DA RESENHA"
const MUSIC := "jangada"

const LEVELS := [
	preload("res://levels/ceara_1.gd"),
	preload("res://levels/ceara_2.gd"),
]

const FINAL_MESSAGE := "CEARÁ CONCLUÍDO!\nÉGUA, MACHO, QUE RESENHA!\n\nO CARAMELO PASSOU POR AQUI...\nMAS JÁ FOI LEVADO PARA OUTRO ESTADO!"
