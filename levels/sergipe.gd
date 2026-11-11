extends RefCounted
## Sergipe: o menor estado do Brasil. A primeira fase dura uns 10 segundos...
## e a surpresa é a segunda, na Passarela do Caranguejo, com o boss.

const ID := "SE"
const NAME := "SERGIPE"
const POWER := "pinca"               # item das caixas de poder (scripts/powers.gd)
const POWER_NAME := "PINÇA DE CARANGUEJO"
const BOSS_NAME := "CARANGUEJO DA PASSARELA"
const MUSIC := "atalaia"

const LEVELS := [
	preload("res://levels/sergipe_1.gd"),
	preload("res://levels/sergipe_2.gd"),
]

const FINAL_MESSAGE := "SERGIPE CONCLUÍDO!\nPEQUENO NO MAPA, GRANDE NO CARANGUEJO!\n\nO CARAMELO PASSOU POR AQUI...\nMAS JÁ FOI LEVADO PARA OUTRO ESTADO!"
