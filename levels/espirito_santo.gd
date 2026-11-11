extends RefCounted
## Espírito Santo: estado pequeno, 2 fases. O boss Panela de Moqueca Gigante fica na última.

const ID := "ES"
const NAME := "ESPÍRITO SANTO"
const POWER := "barro"               # item das caixas de poder (scripts/powers.gd)
const POWER_NAME := "PANELA DE BARRO"
const BOSS_NAME := "PANELA DE MOQUECA GIGANTE"
const MUSIC := "congo"

const LEVELS := [
	preload("res://levels/espirito_santo_1.gd"),
	preload("res://levels/espirito_santo_2.gd"),
]

const FINAL_MESSAGE := "ESPÍRITO SANTO CONCLUÍDO!\n(SIM, ELE EXISTE!)\n\nO CARAMELO PASSOU POR AQUI...\nMAS JÁ FOI LEVADO PARA OUTRO ESTADO!"
