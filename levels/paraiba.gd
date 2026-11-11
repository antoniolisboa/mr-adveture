extends RefCounted
## Paraíba: estado pequeno, 2 fases. O boss Quadrilha Gigante fica na última.

const ID := "PB"
const NAME := "PARAÍBA"
const POWER := "sanfona"             # item das caixas de poder (scripts/powers.gd)
const POWER_NAME := "SANFONA"
const BOSS_NAME := "QUADRILHA GIGANTE"
const MUSIC := "arraial"

const LEVELS := [
	preload("res://levels/paraiba_1.gd"),
	preload("res://levels/paraiba_2.gd"),
]

const FINAL_MESSAGE := "PARAÍBA CONCLUÍDA!\nO MAIOR SÃO JOÃO DO MUNDO!\n\nO CARAMELO PASSOU POR AQUI...\nMAS JÁ FOI LEVADO PARA OUTRO ESTADO!"
