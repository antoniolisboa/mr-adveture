extends RefCounted
## Paraná: Curitiba na garoa (com as capivaras do Barigui) e as Cataratas do Iguaçu,
## onde mora o Quati-Rei.

const ID := "PR"
const NAME := "PARANÁ"
const POWER := "pinhao"              # item das caixas de poder (scripts/powers.gd)
const POWER_NAME := "PINHÃO"
const BOSS_NAME := "QUATI-REI DAS CATARATAS"
const MUSIC := "polca"

const LEVELS := [
	preload("res://levels/parana_1.gd"),
	preload("res://levels/parana_2.gd"),
]

const FINAL_MESSAGE := "PARANÁ CONCLUÍDO!\nO QUATI-REI DEVOLVEU OS LANCHES DOS TURISTAS!\n\nO CARAMELO PASSOU POR AQUI...\nMAS JÁ FOI LEVADO PARA OUTRO ESTADO!"
