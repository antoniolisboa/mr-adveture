extends RefCounted
## Piauí: estado grande, 3 fases, todas com o sol de meio-dia (barra de calor).
## O boss O Sol de Teresina fica na última.

const ID := "PI"
const NAME := "PIAUÍ"
const POWER := "leque"               # item das caixas de poder (scripts/powers.gd)
const POWER_NAME := "LEQUE"
const BOSS_NAME := "O SOL DE TERESINA"
const MUSIC := "calor"

const LEVELS := [
	preload("res://levels/piaui_1.gd"),
	preload("res://levels/piaui_2.gd"),
	preload("res://levels/piaui_3.gd"),
]

const FINAL_MESSAGE := "PIAUÍ CONCLUÍDO!\nPODE GUARDAR O LEQUE... SÓ ATÉ AMANHÃ!\n\nO CARAMELO PASSOU POR AQUI...\nMAS JÁ FOI LEVADO PARA OUTRO ESTADO!"
