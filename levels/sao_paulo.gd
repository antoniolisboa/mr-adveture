extends RefCounted
## São Paulo: estado médio, 3 fases. O boss Coach Quântico fica na última.

const ID := "SP"
const NAME := "SÃO PAULO"
const POWER := "patinete"            # item das caixas de poder (scripts/powers.gd)
const POWER_NAME := "PATINETE"
const BOSS_NAME := "COACH QUÂNTICO"
const MUSIC := "garoa"

const LEVELS := [
	preload("res://levels/sao_paulo_1.gd"),
	preload("res://levels/sao_paulo_2.gd"),
	preload("res://levels/sao_paulo_3.gd"),
]

const FINAL_MESSAGE := "SÃO PAULO CONCLUÍDO!\n\nO CARAMELO PASSOU POR AQUI... NO HORÁRIO DE PICO.\nJÁ FOI LEVADO PARA OUTRO ESTADO!"
