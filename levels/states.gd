extends RefCounted
## Os 27 estados no mapa do Brasil. "data" aponta para as fases do estado;
## null = ainda não feito (aparece cinza no mapa).
## lon/lat = posição da capital, usada para desenhar o ponto no mapa.

const STATES := [
	{"id": "AC", "name": "ACRE", "lon": -67.8, "lat": -9.97, "data": null},
	{"id": "AL", "name": "ALAGOAS", "lon": -35.7, "lat": -9.65,
		"data": preload("res://levels/alagoas.gd")},
	{"id": "AP", "name": "AMAPÁ", "lon": -51.07, "lat": 0.03, "data": null},
	{"id": "AM", "name": "AMAZONAS", "lon": -60.02, "lat": -3.1, "data": null},
	{"id": "BA", "name": "BAHIA", "lon": -38.5, "lat": -12.97,
		"data": preload("res://levels/bahia.gd")},
	{"id": "CE", "name": "CEARÁ", "lon": -38.54, "lat": -3.72,
		"data": preload("res://levels/ceara.gd")},
	{"id": "DF", "name": "DISTRITO FEDERAL", "lon": -47.88, "lat": -15.79, "data": null},
	{"id": "ES", "name": "ESPÍRITO SANTO", "lon": -40.3, "lat": -20.32,
		"data": preload("res://levels/espirito_santo.gd")},
	{"id": "GO", "name": "GOIÁS", "lon": -49.25, "lat": -16.68, "data": null},
	{"id": "MA", "name": "MARANHÃO", "lon": -44.3, "lat": -2.53,
		"data": preload("res://levels/maranhao.gd")},
	{"id": "MT", "name": "MATO GROSSO", "lon": -56.1, "lat": -15.6, "data": null},
	{"id": "MS", "name": "MATO GROSSO DO SUL", "lon": -54.6, "lat": -20.47, "data": null},
	{"id": "MG", "name": "MINAS GERAIS", "lon": -43.94, "lat": -19.92,
		"data": preload("res://levels/minas_gerais.gd")},
	{"id": "PA", "name": "PARÁ", "lon": -48.5, "lat": -1.46, "data": null},
	{"id": "PB", "name": "PARAÍBA", "lon": -34.86, "lat": -7.12,
		"data": preload("res://levels/paraiba.gd")},
	{"id": "PR", "name": "PARANÁ", "lon": -49.27, "lat": -25.43, "data": null},
	{"id": "PE", "name": "PERNAMBUCO", "lon": -34.88, "lat": -8.05,
		"data": preload("res://levels/pernambuco.gd")},
	{"id": "PI", "name": "PIAUÍ", "lon": -42.8, "lat": -5.09,
		"data": preload("res://levels/piaui.gd")},
	{"id": "RJ", "name": "RIO DE JANEIRO", "lon": -43.2, "lat": -22.9,
		"data": preload("res://levels/rio_de_janeiro.gd")},
	{"id": "RN", "name": "RIO GRANDE DO NORTE", "lon": -35.2, "lat": -5.79,
		"data": preload("res://levels/rio_grande_do_norte.gd")},
	{"id": "RS", "name": "RIO GRANDE DO SUL", "lon": -51.23, "lat": -30.03, "data": null},
	{"id": "RO", "name": "RONDÔNIA", "lon": -63.9, "lat": -8.76, "data": null},
	{"id": "RR", "name": "RORAIMA", "lon": -60.67, "lat": 2.82, "data": null},
	{"id": "SC", "name": "SANTA CATARINA", "lon": -48.55, "lat": -27.6, "data": null},
	{"id": "SP", "name": "SÃO PAULO", "lon": -46.63, "lat": -23.55,
		"data": preload("res://levels/sao_paulo.gd")},
	{"id": "SE", "name": "SERGIPE", "lon": -37.07, "lat": -10.91,
		"data": preload("res://levels/sergipe.gd")},
	{"id": "TO", "name": "TOCANTINS", "lon": -48.33, "lat": -10.18, "data": null},
]

## As 5 regiões. Concluir todos os estados de uma região entrega um objeto do caramelo;
## os 5 objetos abrem Brasília. sprite = nome do sprite em scripts/art.gd.
const REGIONS := [
	{"id": "N", "name": "NORTE", "object": "COLEIRA", "sprite": "obj_coleira",
		"states": ["AC", "AM", "AP", "PA", "RO", "RR", "TO"]},
	{"id": "NE", "name": "NORDESTE", "object": "VASILHA DE ÁGUA", "sprite": "obj_vasilha",
		"states": ["AL", "BA", "CE", "MA", "PB", "PE", "PI", "RN", "SE"]},
	{"id": "CO", "name": "CENTRO-OESTE", "object": "BOLINHA", "sprite": "obj_bolinha",
		"states": ["GO", "MT", "MS"]},
	{"id": "SE", "name": "SUDESTE", "object": "OSSO FAVORITO", "sprite": "obj_osso",
		"states": ["ES", "MG", "RJ", "SP"]},
	{"id": "S", "name": "SUL", "object": "COBERTOR VELHO", "sprite": "obj_cobertor",
		"states": ["PR", "RS", "SC"]},
]


static func region_of(state_id: String) -> Dictionary:
	for r in REGIONS:
		if state_id in r["states"]:
			return r
	return {}


## Contorno simplificado do Brasil (longitude, latitude), no sentido horário a partir de Roraima.
const OUTLINE := [
	Vector2(-60.0, 5.2), Vector2(-56.5, 2.0), Vector2(-54.0, 2.2), Vector2(-51.6, 4.2),
	Vector2(-50.0, 1.8), Vector2(-48.5, -1.0), Vector2(-44.0, -2.4), Vector2(-41.0, -2.9),
	Vector2(-38.5, -3.7), Vector2(-35.2, -5.4), Vector2(-34.8, -7.1), Vector2(-35.2, -9.0),
	Vector2(-37.0, -11.0), Vector2(-38.6, -13.0), Vector2(-39.0, -17.5), Vector2(-40.5, -20.5),
	Vector2(-42.0, -23.0), Vector2(-44.5, -23.3), Vector2(-48.0, -25.5), Vector2(-48.6, -28.5),
	Vector2(-50.0, -30.5), Vector2(-52.0, -32.5), Vector2(-53.4, -33.7), Vector2(-55.5, -30.9),
	Vector2(-57.6, -30.2), Vector2(-54.0, -27.2), Vector2(-54.6, -25.6), Vector2(-55.5, -23.9),
	Vector2(-57.8, -22.1), Vector2(-58.1, -20.0), Vector2(-57.5, -18.0), Vector2(-60.2, -16.2),
	Vector2(-60.0, -13.5), Vector2(-63.0, -12.5), Vector2(-65.3, -10.9), Vector2(-68.0, -10.7),
	Vector2(-70.5, -11.0), Vector2(-73.9, -7.4), Vector2(-72.9, -5.0), Vector2(-70.0, -4.2),
	Vector2(-69.4, -1.2), Vector2(-69.9, 1.1), Vector2(-67.0, 2.0), Vector2(-64.0, 2.0),
	Vector2(-63.4, 3.9), Vector2(-61.0, 4.5),
]
