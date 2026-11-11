extends Node
## Música de fundo 8-bit sintetizada em código (autoload "Music").
## Cada estado tem um ritmo: Minas = baião/forró, Rio = samba, Bahia = axé,
## Espírito Santo = congo (tambores e casaca), São Paulo = "garoa" (baixo, bateria e sintetizador).
## Nordeste: Pernambuco = frevo, Paraíba = forró de São João, Rio Grande do Norte = coco,
## Ceará = xote, Maranhão = reggae, Piauí = baião de meio-dia, Alagoas = coco de roda,
## Sergipe = xote praieiro.
## Sul: Paraná = polca (dos imigrantes de Curitiba), Santa Catarina = surf (guitarra
## da Joaquina), Rio Grande do Sul = vanera (gaita e bombo leguero).
## Cada música tem duas versões: normal ("forro") e mais rápida para o boss ("forro_boss").

const RATE := 22050

# Melodia: [nota, duração em semicolcheias]; "" = pausa. Compasso 2/4 = 8 semicolcheias.
# Acordes: um por compasso; ROOTS dá a nota grave (MIDI) de cada acorde.
const SONGS := {
	# Baião em sol mixolídio: sanfona, zabumba e triângulo.
	"forro": {
		"style": "forro", "bpm": 104.0, "boss_bpm": 136.0,
		"melody": [
			["D5", 2], ["B4", 2], ["G4", 2], ["A4", 1], ["B4", 1],
			["C5", 1], ["B4", 1], ["A4", 1], ["G4", 1], ["F4", 2], ["G4", 2],
			["A4", 2], ["C5", 2], ["F5", 2], ["E5", 1], ["D5", 1],
			["D5", 4], ["B4", 4],
			["E5", 2], ["E5", 1], ["D5", 1], ["C5", 2], ["G4", 2],
			["A4", 1], ["B4", 1], ["C5", 1], ["D5", 1], ["E5", 2], ["G5", 2],
			["F#5", 2], ["E5", 2], ["D5", 2], ["C5", 1], ["A4", 1],
			["G4", 4], ["", 2], ["D4", 2],
		],
		"chords": ["G", "G", "F", "G", "C", "C", "D", "G"],
		"roots": {"G": 43, "F": 41, "C": 48, "D": 50},
	},
	# Samba em dó maior: cavaquinho, surdo, tamborim e ganzá.
	"samba": {
		"style": "samba", "bpm": 100.0, "boss_bpm": 128.0,
		"melody": [
			["E5", 2], ["G5", 2], ["E5", 1], ["D5", 1], ["C5", 2],
			["C#5", 2], ["E5", 2], ["A5", 2], ["G5", 2],
			["F5", 2], ["E5", 1], ["D5", 2], ["A4", 3],
			["B4", 2], ["D5", 2], ["F5", 2], ["E5", 1], ["D5", 1],
			["E5", 1], ["G5", 2], ["E5", 2], ["C5", 3],
			["E5", 2], ["C#5", 2], ["A4", 2], ["E5", 2],
			["D5", 2], ["F5", 2], ["G5", 2], ["B4", 2],
			["C5", 4], ["", 2], ["G4", 2],
		],
		"chords": ["C", "A7", "Dm", "G7", "C", "A7", "Dm", "C"],
		"roots": {"C": 48, "A7": 45, "Dm": 50, "G7": 43},
	},
	# Axé em ré maior: metais, surdos de samba-reggae, repique e caixa.
	"axe": {
		"style": "axe", "bpm": 112.0, "boss_bpm": 140.0,
		"melody": [
			["A4", 2], ["D5", 2], ["F#5", 2], ["A5", 2],
			["G5", 1], ["F#5", 1], ["E5", 2], ["D5", 2], ["E5", 2],
			["F#5", 3], ["E5", 1], ["D5", 2], ["B4", 2],
			["A4", 4], ["", 2], ["A4", 2],
			["B4", 2], ["D5", 2], ["G5", 2], ["B5", 2],
			["A5", 1], ["G5", 1], ["F#5", 2], ["E5", 2], ["G5", 2],
			["F#5", 2], ["E5", 2], ["C#5", 2], ["E5", 2],
			["D5", 4], ["", 2], ["A4", 2],
		],
		"chords": ["D", "D", "Bm", "A", "G", "G", "A", "D"],
		"roots": {"D": 50, "Bm": 47, "A": 45, "G": 43},
	},
	# Congo capixaba em lá menor: apito/flauta, tambores de congo e a casaca raspando.
	"congo": {
		"style": "congo", "bpm": 98.0, "boss_bpm": 128.0,
		"melody": [
			["E5", 2], ["A5", 2], ["G5", 1], ["E5", 1], ["D5", 2],
			["E5", 3], ["D5", 1], ["C5", 2], ["A4", 2],
			["F#5", 2], ["A5", 2], ["F#5", 1], ["E5", 1], ["D5", 2],
			["B4", 4], ["", 2], ["D5", 2],
			["E5", 2], ["G5", 2], ["E5", 1], ["D5", 1], ["C5", 2],
			["D5", 2], ["B4", 2], ["G4", 2], ["B4", 2],
			["A4", 2], ["D5", 2], ["F#5", 2], ["E5", 1], ["D5", 1],
			["E5", 4], ["", 2], ["A4", 2],
		],
		"chords": ["Am", "Am", "D", "G", "C", "G", "D", "Am"],
		"roots": {"Am": 45, "D": 50, "G": 43, "C": 48},
	},
	# "Garoa" em mi menor: sintetizador, baixo andando e bateria de cidade grande.
	"garoa": {
		"style": "garoa", "bpm": 110.0, "boss_bpm": 140.0,
		"melody": [
			["B4", 1], ["E5", 1], ["G5", 2], ["F#5", 1], ["E5", 1], ["D5", 2],
			["E5", 3], ["B4", 1], ["", 2], ["G4", 1], ["A4", 1],
			["C5", 1], ["E5", 1], ["G5", 2], ["A5", 2], ["G5", 1], ["E5", 1],
			["D5", 4], ["", 2], ["D5", 1], ["E5", 1],
			["F#5", 2], ["D5", 2], ["A4", 2], ["D5", 2],
			["G5", 2], ["F#5", 1], ["E5", 1], ["D5", 2], ["B4", 2],
			["C5", 2], ["E5", 2], ["D5", 1], ["C5", 1], ["B4", 2],
			["E5", 4], ["", 4],
		],
		"chords": ["Em", "Em", "C", "G", "D", "G", "C", "Em"],
		"roots": {"Em": 40, "C": 36, "G": 43, "D": 38},
	},
	# Frevo em si bemol: metais rápidos, caixa em todas as semicolcheias e surdo no 2.
	"frevo": {
		"style": "frevo", "bpm": 118.0, "boss_bpm": 144.0,
		"melody": [
			["F5", 1], ["D5", 1], ["Bb4", 1], ["D5", 1], ["F5", 2], ["Bb5", 2],
			["A5", 1], ["G5", 1], ["F5", 1], ["Eb5", 1], ["D5", 2], ["C5", 2],
			["Eb5", 1], ["C5", 1], ["A4", 1], ["C5", 1], ["Eb5", 2], ["G5", 2],
			["F5", 4], ["", 2], ["F4", 1], ["A4", 1],
			["Bb4", 1], ["D5", 1], ["F5", 1], ["Bb5", 1], ["A5", 2], ["F5", 2],
			["G5", 1], ["F5", 1], ["Eb5", 1], ["D5", 1], ["Eb5", 2], ["G5", 2],
			["F5", 1], ["Eb5", 1], ["D5", 1], ["C5", 1], ["D5", 2], ["A4", 2],
			["Bb4", 4], ["", 4],
		],
		"chords": ["Bb", "Bb", "F7", "F7", "Bb", "Eb", "F7", "Bb"],
		"roots": {"Bb": 46, "F7": 41, "Eb": 51},
	},
	# Forró de São João em ré: sanfona, zabumba e triângulo, com cara de quadrilha.
	"arraial": {
		"style": "forro", "bpm": 112.0, "boss_bpm": 140.0,
		"melody": [
			["A4", 2], ["D5", 2], ["F#5", 2], ["E5", 1], ["D5", 1],
			["E5", 2], ["C5", 2], ["A4", 4],
			["G4", 2], ["B4", 2], ["D5", 2], ["C5", 1], ["B4", 1],
			["A4", 2], ["F#4", 2], ["D4", 2], ["", 2],
			["D5", 1], ["E5", 1], ["F#5", 2], ["A5", 2], ["G5", 1], ["F#5", 1],
			["E5", 2], ["C5", 2], ["D5", 2], ["E5", 2],
			["F#5", 2], ["E5", 1], ["D5", 1], ["C5", 2], ["A4", 2],
			["D5", 4], ["", 2], ["A4", 2],
		],
		"chords": ["D", "C", "G", "D", "D", "C", "A", "D"],
		"roots": {"D": 50, "C": 48, "G": 43, "A": 45},
	},
	# Coco potiguar em fá: pífano, ganzá e zabumba batendo forte no 1 e no "e" do 2.
	"dunas": {
		"style": "coco", "bpm": 108.0, "boss_bpm": 138.0,
		"melody": [
			["C5", 2], ["F5", 2], ["E5", 1], ["F5", 1], ["G5", 2],
			["A5", 2], ["G5", 1], ["F5", 1], ["E5", 2], ["C5", 2],
			["D5", 2], ["Bb4", 2], ["D5", 1], ["E5", 1], ["F5", 2],
			["E5", 4], ["", 2], ["C5", 2],
			["A5", 2], ["G5", 1], ["F5", 1], ["G5", 2], ["C5", 2],
			["F5", 2], ["E5", 1], ["D5", 1], ["C5", 2], ["Bb4", 2],
			["A4", 2], ["C5", 2], ["E5", 2], ["G5", 2],
			["F5", 4], ["", 4],
		],
		"chords": ["F", "F", "Bb", "C", "F", "Bb", "C", "F"],
		"roots": {"F": 41, "Bb": 46, "C": 48},
	},
	# Xote cearense em sol: sanfona macia, zabumba no compasso do xote.
	"jangada": {
		"style": "xote", "bpm": 92.0, "boss_bpm": 124.0,
		"melody": [
			["D5", 3], ["B4", 1], ["G4", 2], ["B4", 2],
			["C5", 3], ["A4", 1], ["F#4", 2], ["A4", 2],
			["B4", 2], ["D5", 2], ["G5", 3], ["F#5", 1],
			["E5", 4], ["D5", 4],
			["E5", 3], ["C5", 1], ["A4", 2], ["C5", 2],
			["D5", 3], ["B4", 1], ["G4", 2], ["B4", 2],
			["A4", 2], ["C5", 2], ["F#5", 2], ["E5", 1], ["D5", 1],
			["G4", 4], ["", 4],
		],
		"chords": ["G", "D", "G", "C", "Am", "G", "D", "G"],
		"roots": {"G": 43, "D": 50, "C": 48, "Am": 45},
	},
	# Reggae de São Luís em lá menor: contratempo da guitarra, baixo gordo e bateria "one drop".
	"reggae": {
		"style": "reggae", "bpm": 84.0, "boss_bpm": 112.0,
		"melody": [
			["E5", 3], ["D5", 1], ["C5", 2], ["A4", 2],
			["C5", 2], ["D5", 2], ["E5", 4],
			["G5", 3], ["E5", 1], ["D5", 2], ["C5", 2],
			["D5", 4], ["", 4],
			["E5", 3], ["D5", 1], ["C5", 2], ["A4", 2],
			["G4", 2], ["A4", 2], ["C5", 4],
			["D5", 3], ["C5", 1], ["A4", 2], ["G4", 2],
			["A4", 4], ["", 4],
		],
		"chords": ["Am", "Am", "G", "G", "Am", "F", "G", "Am"],
		"roots": {"Am": 45, "G": 43, "F": 41},
	},
	# Baião de meio-dia em mi: sanfona arrastada pelo calor.
	"calor": {
		"style": "forro", "bpm": 96.0, "boss_bpm": 132.0,
		"melody": [
			["B4", 2], ["E5", 2], ["G#5", 2], ["F#5", 1], ["E5", 1],
			["D5", 2], ["B4", 2], ["E5", 4],
			["A4", 2], ["C#5", 2], ["E5", 2], ["D5", 1], ["C#5", 1],
			["B4", 4], ["", 2], ["B4", 2],
			["E5", 1], ["F#5", 1], ["G#5", 2], ["B5", 2], ["A5", 1], ["G#5", 1],
			["F#5", 2], ["D5", 2], ["B4", 2], ["D5", 2],
			["C#5", 2], ["B4", 1], ["A4", 1], ["G#4", 2], ["B4", 2],
			["E5", 4], ["", 4],
		],
		"chords": ["E", "D", "A", "E", "E", "D", "B7", "E"],
		"roots": {"E": 40, "D": 50, "A": 45, "B7": 47},
	},
	# Coco de roda alagoano em dó: pífano, ganzá e palmas.
	"mare": {
		"style": "coco", "bpm": 104.0, "boss_bpm": 136.0,
		"melody": [
			["G4", 1], ["C5", 1], ["E5", 2], ["G5", 2], ["E5", 2],
			["F5", 2], ["D5", 2], ["B4", 4],
			["A4", 1], ["D5", 1], ["F5", 2], ["A5", 2], ["F5", 2],
			["E5", 2], ["C5", 2], ["G4", 4],
			["C5", 2], ["E5", 1], ["G5", 1], ["A5", 2], ["G5", 2],
			["F5", 2], ["E5", 1], ["D5", 1], ["C5", 2], ["A4", 2],
			["B4", 2], ["D5", 2], ["G5", 2], ["F5", 2],
			["C5", 4], ["", 4],
		],
		"chords": ["C", "G", "Dm", "C", "C", "F", "G", "C"],
		"roots": {"C": 48, "G": 43, "Dm": 50, "F": 41},
	},
	# Xote praieiro sergipano em lá: sanfona e zabumba sem pressa nenhuma.
	"atalaia": {
		"style": "xote", "bpm": 96.0, "boss_bpm": 128.0,
		"melody": [
			["E5", 3], ["C#5", 1], ["A4", 2], ["C#5", 2],
			["D5", 3], ["B4", 1], ["G#4", 2], ["B4", 2],
			["C#5", 2], ["E5", 2], ["A5", 3], ["G#5", 1],
			["F#5", 4], ["E5", 4],
			["F#5", 3], ["D5", 1], ["B4", 2], ["D5", 2],
			["E5", 3], ["C#5", 1], ["A4", 2], ["C#5", 2],
			["B4", 2], ["D5", 2], ["G#5", 2], ["F#5", 1], ["E5", 1],
			["A4", 4], ["", 4],
		],
		"chords": ["A", "E", "A", "D", "Bm", "A", "E", "A"],
		"roots": {"A": 45, "E": 40, "D": 50, "Bm": 47},
	},
	# Polca em dó: sanfona, baixo "pum" no tempo e acorde "pá" no contratempo.
	"polca": {
		"style": "polca", "bpm": 118.0, "boss_bpm": 146.0,
		"melody": [
			["G4", 2], ["C5", 2], ["E5", 2], ["G5", 2],
			["F5", 1], ["E5", 1], ["D5", 2], ["B4", 2], ["G4", 2],
			["A4", 2], ["D5", 2], ["F5", 2], ["A5", 2],
			["G5", 1], ["F5", 1], ["E5", 2], ["C5", 2], ["", 2],
			["E5", 2], ["G5", 2], ["C6", 2], ["B5", 1], ["A5", 1],
			["G5", 2], ["E5", 2], ["C5", 2], ["E5", 2],
			["D5", 2], ["F5", 2], ["B4", 2], ["D5", 2],
			["C5", 4], ["", 2], ["G4", 2],
		],
		"chords": ["C", "G7", "Dm", "G7", "C", "C", "G7", "C"],
		"roots": {"C": 48, "G7": 43, "Dm": 50},
	},
	# Surf em mi menor: guitarra palhetada rápida, baixo e bateria galopando.
	"surf": {
		"style": "surf", "bpm": 120.0, "boss_bpm": 148.0,
		"melody": [
			["E5", 1], ["E5", 1], ["E5", 1], ["E5", 1], ["G5", 2], ["A5", 2],
			["B5", 2], ["A5", 1], ["G5", 1], ["E5", 4],
			["D5", 1], ["D5", 1], ["D5", 1], ["D5", 1], ["F#5", 2], ["G5", 2],
			["A5", 2], ["G5", 1], ["F#5", 1], ["D5", 4],
			["C5", 1], ["C5", 1], ["E5", 1], ["G5", 1], ["C6", 2], ["B5", 2],
			["A5", 2], ["G5", 2], ["E5", 2], ["G5", 2],
			["F#5", 2], ["A5", 2], ["B5", 2], ["D#5", 2],
			["E5", 4], ["", 4],
		],
		"chords": ["Em", "D", "Em", "D", "C", "Am", "B", "Em"],
		"roots": {"Em": 40, "D": 38, "C": 36, "Am": 45, "B": 47},
	},
	# Vanera em sol: gaita ponteando, bombo leguero e o "tchum" do violão no contratempo.
	"vanera": {
		"style": "vanera", "bpm": 112.0, "boss_bpm": 140.0,
		"melody": [
			["D5", 2], ["G5", 1], ["F#5", 1], ["G5", 2], ["B5", 2],
			["A5", 1], ["G5", 1], ["F#5", 1], ["E5", 1], ["D5", 4],
			["C5", 2], ["E5", 1], ["D5", 1], ["C5", 2], ["A4", 2],
			["B4", 1], ["C5", 1], ["D5", 2], ["G4", 4],
			["D5", 2], ["G5", 1], ["F#5", 1], ["G5", 2], ["B5", 2],
			["C6", 1], ["B5", 1], ["A5", 1], ["G5", 1], ["E5", 4],
			["D5", 2], ["C5", 1], ["B4", 1], ["A4", 2], ["F#4", 2],
			["G4", 4], ["", 2], ["D5", 2],
		],
		"chords": ["G", "D7", "Am", "D7", "G", "C", "D7", "G"],
		"roots": {"G": 43, "D7": 50, "Am": 45, "C": 48},
	},
}

var _player: AudioStreamPlayer
var _streams := {}
var _current := ""


func _ready() -> void:
	_player = AudioStreamPlayer.new()
	_player.volume_db = -14.0
	add_child(_player)
	# As músicas são sintetizadas na primeira vez que tocam (são muitas).
	_stream("forro")


func _stream(id: String) -> AudioStreamWAV:
	if not _streams.has(id):
		var base := id.trim_suffix("_boss")
		if not SONGS.has(base):
			return null
		var song: Dictionary = SONGS[base]
		_streams[id] = _render(song, song["boss_bpm"] if id.ends_with("_boss") else song["bpm"])
	return _streams[id]


func play(id: String) -> void:
	if _current == id and _player.playing:
		return
	if _stream(id) == null:
		return
	_current = id
	_player.stream = _streams[id]
	_player.play()


func stop() -> void:
	_current = ""
	_player.stop()


# --- Síntese ---------------------------------------------------------------

func _render(song: Dictionary, bpm: float) -> AudioStreamWAV:
	var step := 60.0 / bpm / 4.0                 # duração de uma semicolcheia
	var chords: Array = song["chords"]
	var roots: Dictionary = song["roots"]
	var total := int(chords.size() * 8 * step * RATE)
	var buf := PackedFloat32Array()
	buf.resize(total)
	var style: String = song["style"]
	var samba := style == "samba"
	var axe := style == "axe"
	var congo := style == "congo"
	var garoa := style == "garoa"
	var frevo := style == "frevo"
	var coco := style == "coco"
	var xote := style == "xote"
	var reggae := style == "reggae"
	var polca := style == "polca"
	var surf := style == "surf"
	var vanera := style == "vanera"

	var pos := 0
	for n in song["melody"]:
		var len16: int = n[1]
		if n[0] != "":
			var f := _freq(_midi(n[0]))
			if surf:
				_lead(buf, _at(pos, step), len16 * step * 0.6, f)
			elif polca or vanera:
				_accordion(buf, _at(pos, step), len16 * step * (0.75 if polca else 0.9), f)
			elif frevo:
				_brass(buf, _at(pos, step), len16 * step * 0.7, f)
			elif coco:
				_flute(buf, _at(pos, step), len16 * step * 0.8, f)
			elif reggae:
				_lead(buf, _at(pos, step), len16 * step * 0.9, f)
			elif garoa:
				_lead(buf, _at(pos, step), len16 * step * 0.85, f)
			elif congo:
				_flute(buf, _at(pos, step), len16 * step * 0.9, f)
			elif axe:
				_brass(buf, _at(pos, step), len16 * step * 0.8, f)
			elif samba:
				_cavaco(buf, _at(pos, step), len16 * step * 0.85, f)
			else:
				_accordion(buf, _at(pos, step), len16 * step * 0.92, f)
		pos += len16

	for bar in chords.size():
		var root: int = roots[chords[bar]]
		var b0 := bar * 8
		if polca:
			# Pum-pá: baixo no tempo (tônica e quinta), acorde no contratempo.
			_bass(buf, _at(b0, step), step * 1.5, _freq(root - 12))
			_bass(buf, _at(b0 + 4, step), step * 1.5, _freq(root - 5))
			for s in [2, 6]:
				for iv in _triad(chords[bar]):
					_accordion(buf, _at(b0 + s, step), step * 0.8, _freq(root + 12 + iv))
			_drum(buf, _at(b0, step), step, _freq(36), 0.35)
			_click(buf, _at(b0 + 2, step), 0.07)
			_click(buf, _at(b0 + 6, step), 0.07)
		elif surf:
			# Baixo em colcheias, bumbo no 1, caixa no 2, galope nos tons.
			for s in [0, 2, 4, 6]:
				_bass(buf, _at(b0 + s, step), step * 1.6, _freq(root + (12 if s == 6 else 0)))
			_drum(buf, _at(b0, step), step, _freq(36), 0.5)
			_shaker(buf, _at(b0 + 4, step), 0.24)
			for s in [5, 6, 7]:
				_drum(buf, _at(b0 + s, step), step, _freq(root + 12), 0.18)
			for s in 8:
				_click(buf, _at(b0 + s, step), 0.04)
		elif vanera:
			# Bombo leguero no 1 e no "e" do 2, violão no contratempo, chocalho.
			_drum(buf, _at(b0, step), 2 * step, _freq(root - 12), 0.55)
			_drum(buf, _at(b0 + 3, step), step, _freq(root), 0.3)
			_drum(buf, _at(b0 + 4, step), 2 * step, _freq(root - 12), 0.4)
			_bass(buf, _at(b0, step), step * 2.5, _freq(root - 12))
			_bass(buf, _at(b0 + 4, step), step * 2.5, _freq(root - 5))
			for s in [2, 6]:
				for iv in _triad(chords[bar]):
					_cavaco(buf, _at(b0 + s, step), step * 0.6, _freq(root + 12 + iv))
			for s in 8:
				_shaker(buf, _at(b0 + s, step), 0.06 if s % 2 == 1 else 0.03)
		elif frevo:
			# Baixo nos tempos, surdo no 2, caixa rufando em todas as semicolcheias.
			_bass(buf, _at(b0, step), step * 1.6, _freq(root - 12))
			_bass(buf, _at(b0 + 4, step), step * 1.6, _freq(root - 5))
			_drum(buf, _at(b0 + 4, step), 2 * step, _freq(root - 12), 0.45)
			for s in 8:
				_shaker(buf, _at(b0 + s, step), 0.11 if s % 4 == 2 else 0.05)
			_click(buf, _at(b0 + 2, step), 0.08)
			_click(buf, _at(b0 + 6, step), 0.08)
		elif reggae:
			# One drop: bumbo e aro juntos no 3; guitarra picada nos contratempos.
			for s in [0, 3, 4, 6]:
				_bass(buf, _at(b0 + s, step), step * 1.5, _freq(root - 12 + (7 if s == 6 else 0)))
			_drum(buf, _at(b0 + 4, step), step, _freq(36), 0.5)
			_click(buf, _at(b0 + 4, step), 0.12)
			for s in [2, 6]:
				for iv in _triad(chords[bar]):
					_cavaco(buf, _at(b0 + s, step), step * 0.7, _freq(root + 12 + iv))
			for s in [1, 3, 5, 7]:
				_shaker(buf, _at(b0 + s, step), 0.03)
		elif xote:
			# Xote: zabumba no 1 e no "e" do 2, bacalhau no 2, triângulo mole.
			_drum(buf, _at(b0, step), 2 * step, _freq(root), 0.5)
			_drum(buf, _at(b0 + 5, step), 2 * step, _freq(root + 7), 0.4)
			_drum(buf, _at(b0 + 6, step), 2 * step, _freq(root), 0.35)
			_shaker(buf, _at(b0 + 4, step), 0.12)
			for s in 8:
				var open := s % 4 == 3
				_triangle(buf, _at(b0 + s, step), 0.08 if open else 0.02, 0.07 if open else 0.04)
			_accordion(buf, _at(b0, step), step * 3.5, _freq(root + 12))
		elif coco:
			# Coco: zabumba forte no 1 e no "e" do 2, ganzá corrido e palma no contratempo.
			_drum(buf, _at(b0, step), 2 * step, _freq(root - 12), 0.55)
			_drum(buf, _at(b0 + 3, step), step, _freq(root), 0.35)
			_drum(buf, _at(b0 + 6, step), 2 * step, _freq(root - 12), 0.45)
			for s in 8:
				_shaker(buf, _at(b0 + s, step), 0.07 if s % 2 == 1 else 0.035)
			_clap(buf, _at(b0 + 2, step))
			_clap(buf, _at(b0 + 6, step))
		elif garoa:
			# Baixo andando em colcheias (tônica e oitava), bumbo, caixa e chimbal.
			for s in [0, 2, 4, 6]:
				var note := root if s % 4 == 0 else root + 12
				_bass(buf, _at(b0 + s, step), step * 1.8, _freq(note))
			_drum(buf, _at(b0, step), step, _freq(36), 0.5)
			_drum(buf, _at(b0 + 3, step), step, _freq(36), 0.35)
			_shaker(buf, _at(b0 + 4, step), 0.22)
			for s in 8:
				_click(buf, _at(b0 + s, step), 0.05 if s % 2 == 0 else 0.03)
		elif congo:
			# Tambores de congo: grave no 1, resposta no "e" do 2 e repique no fim.
			_drum(buf, _at(b0, step), 3 * step, _freq(root - 12), 0.55)
			_drum(buf, _at(b0 + 3, step), step, _freq(root), 0.35)
			_drum(buf, _at(b0 + 5, step), 2 * step, _freq(root - 5), 0.45)
			_drum(buf, _at(b0 + 7, step), step, _freq(root), 0.3)
			# Casaca: raspada comprida nos tempos, curtinha nos contratempos.
			for s in 8:
				_scrape(buf, _at(b0 + s, step), step * (0.9 if s % 2 == 0 else 0.4), 0.07 if s % 2 == 0 else 0.04)
		elif axe:
			# Samba-reggae: surdo grave no 1, surdo agudo no 3 e um dobrado no fim.
			_drum(buf, _at(b0, step), 3 * step, _freq(root - 12), 0.6)
			_drum(buf, _at(b0 + 4, step), 2 * step, _freq(root), 0.45)
			_drum(buf, _at(b0 + 6, step), step, _freq(root), 0.3)
			_drum(buf, _at(b0 + 7, step), step, _freq(root - 12), 0.4)
			# Repique e caixa: estalos no contratempo, ganzá em todas.
			for s in [2, 3, 6]:
				_click(buf, _at(b0 + s, step), 0.13)
			for s in 8:
				_shaker(buf, _at(b0 + s, step), 0.06 if s % 2 == 1 else 0.03)
		elif samba:
			# Surdo: abafado no primeiro tempo, aberto e forte no segundo.
			_drum(buf, _at(b0, step), step, _freq(root), 0.3)
			_drum(buf, _at(b0 + 4, step), 4 * step, _freq(root), 0.6)
			# Tamborim no teleco-teco.
			for s in [0, 2, 3, 5, 7]:
				_click(buf, _at(b0 + s, step), 0.16)
			# Ganzá em todas as semicolcheias, mais forte no contratempo.
			for s in 8:
				_shaker(buf, _at(b0 + s, step), 0.05 if s % 2 == 1 else 0.025)
		else:
			# Zabumba no ritmo de baião: pontuada, semicolcheia, semínima.
			_drum(buf, _at(b0, step), 3 * step, _freq(root), 0.55)
			_drum(buf, _at(b0 + 3, step), step, _freq(root), 0.4)
			_drum(buf, _at(b0 + 4, step), 4 * step, _freq(root + 7), 0.5)
			# Estalo do bacalhau da zabumba nos contratempos.
			_shaker(buf, _at(b0 + 2, step), 0.12)
			_shaker(buf, _at(b0 + 6, step), 0.12)
			# Triângulo: fechado em todas, aberto na última de cada tempo.
			for s in 8:
				var open := s % 4 == 3
				_triangle(buf, _at(b0 + s, step), 0.09 if open else 0.025, 0.09 if open else 0.05)

	var data := PackedByteArray()
	data.resize(total * 2)
	for i in total:
		data.encode_s16(i * 2, int(clampf(buf[i], -1.0, 1.0) * 32767.0))
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = RATE
	wav.stereo = false
	wav.data = data
	wav.loop_mode = AudioStreamWAV.LOOP_FORWARD
	wav.loop_begin = 0
	wav.loop_end = total
	return wav


func _at(sixteenth: int, step: float) -> int:
	return int(sixteenth * step * RATE)


func _midi(note: String) -> int:
	const BASE := {"C": 0, "D": 2, "E": 4, "F": 5, "G": 7, "A": 9, "B": 11}
	var m: int = BASE[note[0]]
	var rest := note.substr(1)
	if rest.begins_with("#"):
		m += 1
		rest = rest.substr(1)
	elif rest.begins_with("b"):
		m -= 1
		rest = rest.substr(1)
	return 12 * (int(rest) + 1) + m


func _freq(midi: int) -> float:
	return 440.0 * pow(2.0, (midi - 69) / 12.0)


## Sanfona: duas ondas quadradas levemente desafinadas, como as palhetas.
func _accordion(buf: PackedFloat32Array, start: int, dur: float, f: float) -> void:
	var n := mini(int(dur * RATE), buf.size() - start)
	var p1 := 0.0
	var p2 := 0.0
	for i in n:
		var t := float(i) / RATE
		var env := minf(t / 0.01, 1.0) * (1.0 - 0.3 * t / dur)
		if i > n - 220:
			env *= float(n - i) / 220.0
		var vib := 1.0 + sin(t * 30.0) * 0.003
		p1 += f * vib / RATE
		p2 += f * 1.006 * vib / RATE
		var s := (1.0 if fmod(p1, 1.0) < 0.25 else -1.0) + (1.0 if fmod(p2, 1.0) < 0.35 else -1.0)
		buf[start + i] += s * 0.11 * env


## Cavaquinho: corda beliscada, ataque forte e queda rápida.
func _cavaco(buf: PackedFloat32Array, start: int, dur: float, f: float) -> void:
	var n := mini(int(dur * RATE), buf.size() - start)
	var p := 0.0
	for i in n:
		var t := float(i) / RATE
		p += f / RATE
		var s := 1.0 if fmod(p, 1.0) < 0.5 else -1.0
		var env := minf(t / 0.004, 1.0) * exp(-t * 5.0)
		if i > n - 220:
			env *= float(n - i) / 220.0
		buf[start + i] += s * 0.16 * env


## Metais: onda dente de serra com ataque rápido e um pouco de vibrato.
func _brass(buf: PackedFloat32Array, start: int, dur: float, f: float) -> void:
	var n := mini(int(dur * RATE), buf.size() - start)
	var p := 0.0
	for i in n:
		var t := float(i) / RATE
		p += f * (1.0 + sin(t * 34.0) * 0.004 * minf(t * 4.0, 1.0)) / RATE
		var saw := 2.0 * fmod(p, 1.0) - 1.0
		var env := minf(t / 0.015, 1.0) * (1.0 - 0.4 * t / dur)
		if i > n - 220:
			env *= float(n - i) / 220.0
		buf[start + i] += saw * 0.12 * env


## Sintetizador: pulso estreito com um pouco de queda.
func _lead(buf: PackedFloat32Array, start: int, dur: float, f: float) -> void:
	var n := mini(int(dur * RATE), buf.size() - start)
	var p := 0.0
	for i in n:
		var t := float(i) / RATE
		p += f / RATE
		var s := 1.0 if fmod(p, 1.0) < 0.125 else -0.15
		var env := minf(t / 0.005, 1.0) * (1.0 - 0.5 * t / dur)
		if i > n - 220:
			env *= float(n - i) / 220.0
		buf[start + i] += s * 0.15 * env


## Baixo: onda quadrada grave e curtinha.
func _bass(buf: PackedFloat32Array, start: int, dur: float, f: float) -> void:
	var n := mini(int(dur * RATE), buf.size() - start)
	var p := 0.0
	for i in n:
		var t := float(i) / RATE
		p += f / RATE
		var s := 1.0 if fmod(p, 1.0) < 0.5 else -1.0
		var env := minf(t / 0.004, 1.0) * exp(-t * 6.0)
		if i > n - 120:
			env *= float(n - i) / 120.0
		buf[start + i] += s * 0.12 * env


## Flauta/apito: onda triangular suave com vibrato.
func _flute(buf: PackedFloat32Array, start: int, dur: float, f: float) -> void:
	var n := mini(int(dur * RATE), buf.size() - start)
	var p := 0.0
	for i in n:
		var t := float(i) / RATE
		p += f * (1.0 + sin(t * 32.0) * 0.006 * minf(t * 3.0, 1.0)) / RATE
		var tri := 4.0 * absf(fmod(p, 1.0) - 0.5) - 1.0
		var env := minf(t / 0.02, 1.0) * (1.0 - 0.25 * t / dur)
		if i > n - 220:
			env *= float(n - i) / 220.0
		buf[start + i] += tri * 0.2 * env


## Casaca (reco-reco de cabeça entalhada): ruído picotado, como a vareta nos dentes.
func _scrape(buf: PackedFloat32Array, start: int, dur: float, vol: float) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = start + 7
	var n := mini(int(dur * RATE), buf.size() - start)
	for i in n:
		var t := float(i) / RATE
		var teeth := 1.0 if fmod(t * 140.0, 1.0) < 0.5 else 0.25
		buf[start + i] += rng.randf_range(-1.0, 1.0) * vol * teeth * (1.0 - t / dur)


## Tambor grave (zabumba ou surdo): onda triangular com queda de afinação.
func _drum(buf: PackedFloat32Array, start: int, dur: float, f: float, vol: float) -> void:
	var n := mini(int(dur * RATE), buf.size() - start)
	var phase := 0.0
	for i in n:
		var t := float(i) / RATE
		phase += f * (1.0 + 1.5 * exp(-t * 40.0)) / RATE
		var s := 4.0 * absf(fmod(phase, 1.0) - 0.5) - 1.0
		buf[start + i] += s * vol * exp(-t * 7.0)


## Ruído curto: estalo da zabumba ou ganzá.
func _shaker(buf: PackedFloat32Array, start: int, vol: float) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = start
	var n := mini(int(0.04 * RATE), buf.size() - start)
	for i in n:
		var t := float(i) / RATE
		buf[start + i] += rng.randf_range(-1.0, 1.0) * vol * exp(-t * 90.0)


## Tamborim: estalo agudo e seco.
func _click(buf: PackedFloat32Array, start: int, vol: float) -> void:
	var n := mini(int(0.03 * RATE), buf.size() - start)
	var p := 0.0
	for i in n:
		var t := float(i) / RATE
		p += 1800.0 / RATE
		var s := 1.0 if fmod(p, 1.0) < 0.5 else -1.0
		buf[start + i] += s * vol * exp(-t * 120.0)


## Triângulo: dois tons agudos multiplicados, som metálico.
func _triangle(buf: PackedFloat32Array, start: int, dur: float, vol: float) -> void:
	var n := mini(int(dur * RATE), buf.size() - start)
	for i in n:
		var t := float(i) / RATE
		var a := 1.0 if sin(TAU * 3520.0 * t) > 0.0 else -1.0
		var b := 1.0 if sin(TAU * 4930.0 * t) > 0.0 else -1.0
		buf[start + i] += a * b * vol * exp(-t * 40.0)


## Intervalos do acorde (maior, menor ou com sétima) a partir do nome.
func _triad(chord: String) -> Array:
	if chord.length() > 1 and chord[1] == "m" or chord.length() > 2 and chord[2] == "m":
		return [0, 3, 7]
	if chord.ends_with("7"):
		return [0, 4, 10]
	return [0, 4, 7]


## Palma: dois estalos de ruído bem juntinhos.
func _clap(buf: PackedFloat32Array, start: int) -> void:
	_shaker(buf, start, 0.09)
	_shaker(buf, start + int(0.012 * RATE), 0.08)
