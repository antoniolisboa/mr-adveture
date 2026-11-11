extends RefCounted
## Bahia: estado grande, 4 fases. O boss Trio Elétrico Desgovernado fica na última.

const ID := "BA"
const NAME := "BAHIA"
const POWER := "berimbau"            # item das caixas de poder (scripts/powers.gd)
const POWER_NAME := "BERIMBAU"
const BOSS_NAME := "TRIO ELÉTRICO"
const MUSIC := "axe"

const LEVELS := [
	preload("res://levels/bahia_1.gd"),
	preload("res://levels/bahia_2.gd"),
	preload("res://levels/bahia_3.gd"),
	preload("res://levels/bahia_4.gd"),
]

const FINAL_MESSAGE := "BAHIA CONCLUÍDA!\n\nO CARAMELO PASSOU POR AQUI...\nMAS JÁ FOI LEVADO PARA OUTRO ESTADO!"
