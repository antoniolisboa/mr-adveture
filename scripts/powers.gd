extends RefCounted
## Itens de poder de cada estado. O item aparece nas caixas de poder da fase.
##   item   = nome do sprite do item (scripts/art.gd)
##   hud    = texto no canto da tela
##   colors = cores da camisa do personagem com o poder ("y" = amarelo, "g" = verde)

const POWERS := {
	"pao": {
		"item": "pao",
		"hud": "PÃO DE QUEIJO - X ARREMESSA",
		"colors": {"y": Color("fbe3a0"), "g": Color("e0a03c")},
	},
	"raquete": {
		"item": "raquete",
		"hud": "RAQUETE DE FRESCOBOL - X REBATE",
		"colors": {"y": Color("ffffff"), "g": Color("2bb3c0")},
	},
	"berimbau": {
		"item": "berimbau",
		"hud": "BERIMBAU - X DÁ RASTEIRA",
		"colors": {"y": Color("ffffff"), "g": Color("d64545")},
	},
	"barro": {
		"item": "panela_barro",
		"hud": "PANELA DE BARRO - X DEFENDE",
		"colors": {"y": Color("c98a5a"), "g": Color("43352e")},
	},
	"patinete": {
		"item": "patinete",
		"hud": "PATINETE - X DÁ ARRANCADA",
		"colors": {"y": Color("3fbf6f"), "g": Color("2b1d2e")},
	},
	"sombrinha": {
		"item": "sombrinha",
		"hud": "SOMBRINHA DE FREVO - SEGURE X NO AR",
		"colors": {"y": Color("f7d038"), "g": Color("d64545")},
	},
	"sanfona": {
		"item": "sanfona",
		"hud": "SANFONA - X DÁ GIRO DE FORRÓ",
		"colors": {"y": Color("d64545"), "g": Color("f7d038")},
	},
	"buggy": {
		"item": "chave_buggy",
		"hud": "BUGGY - X: PULO COM EMOÇÃO",
		"colors": {"y": Color("f07a2a"), "g": Color("ffffff")},
	},
	"microfone": {
		"item": "microfone",
		"hud": "MICROFONE - X CONTA PIADA",
		"colors": {"y": Color("ffffff"), "g": Color("2b5fb4")},
	},
	"reggae": {
		"item": "disco",
		"hud": "DISCO DE REGGAE - PULO ALTO, X JOGA",
		"colors": {"y": Color("2a9d4a"), "g": Color("d64545")},
	},
	"leque": {
		"item": "leque",
		"hud": "LEQUE - X ABANA E SOPRA",
		"colors": {"y": Color("e85d75"), "g": Color("ffffff")},
	},
	"snorkel": {
		"item": "snorkel",
		"hud": "SNORKEL - FÔLEGO SEM FIM, X ACELERA",
		"colors": {"y": Color("6fd0c0"), "g": Color("f7d038")},
	},
	"pinca": {
		"item": "pinca",
		"hud": "PINÇA - X AGARRA E ARREMESSA",
		"colors": {"y": Color("e85a3a"), "g": Color("8a3a22")},
	},
}
