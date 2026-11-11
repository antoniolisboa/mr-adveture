extends Node
## Efeitos sonoros 8-bit sintetizados em código (autoload "Sfx").
## Cada som é uma lista de trechos: [frequência inicial, frequência final, duração, onda].
## Ondas: "square" (quadrada), "thin" (quadrada fina com vibrato), "noise" (ruído),
## "rumble" (ruído que vai ficando grave).

const RATE := 22050
const VOICES := 8

const SOUNDS := {
	"jump": [[280.0, 560.0, 0.12, "square"]],
	"biscoito": [[988.0, 988.0, 0.05, "square"], [1319.0, 1319.0, 0.12, "square"]],
	"stomp": [[420.0, 90.0, 0.12, "square"]],
	"kick": [[300.0, 100.0, 0.1, "square"]],
	"bump": [[160.0, 110.0, 0.07, "square"]],
	"item": [[392.0, 392.0, 0.05, "square"], [523.0, 523.0, 0.05, "square"],
			[659.0, 659.0, 0.05, "square"], [784.0, 784.0, 0.08, "square"]],
	"powerup": [[523.0, 523.0, 0.06, "square"], [659.0, 659.0, 0.06, "square"],
			[784.0, 784.0, 0.06, "square"], [1047.0, 1047.0, 0.06, "square"],
			[1319.0, 1319.0, 0.14, "square"]],
	"throw": [[900.0, 300.0, 0.08, "square"]],
	"hurt": [[700.0, 200.0, 0.25, "square"]],
	"die": [[880.0, 660.0, 0.12, "square"], [660.0, 440.0, 0.12, "square"],
			[440.0, 110.0, 0.4, "square"]],
	"checkpoint": [[784.0, 784.0, 0.08, "square"], [988.0, 988.0, 0.08, "square"],
			[1175.0, 1175.0, 0.16, "square"]],
	"clear": [[523.0, 523.0, 0.12, "square"], [659.0, 659.0, 0.12, "square"],
			[784.0, 784.0, 0.12, "square"], [1047.0, 1047.0, 0.4, "square"]],
	"whistle": [[1175.0, 1175.0, 0.18, "thin"], [1397.0, 1397.0, 0.45, "thin"]],
	"boss_hit": [[0.0, 0.0, 0.08, "noise"], [220.0, 70.0, 0.18, "square"]],
	"crash": [[0.0, 0.0, 0.25, "rumble"]],
	"boss_break": [[0.0, 0.0, 0.8, "rumble"]],
	"swing": [[0.0, 0.0, 0.06, "noise"], [600.0, 900.0, 0.05, "square"]],
	"reflect": [[1400.0, 1400.0, 0.04, "square"], [1800.0, 1800.0, 0.06, "square"]],
	"serve": [[700.0, 500.0, 0.05, "square"]],
	"splash": [[0.0, 0.0, 0.12, "noise"]],
	"shout": [[330.0, 440.0, 0.08, "thin"], [440.0, 330.0, 0.12, "thin"]],
	"rasteira": [[0.0, 0.0, 0.05, "noise"], [196.0, 185.0, 0.12, "thin"], [262.0, 262.0, 0.08, "thin"]],
	"buzina": [[330.0, 330.0, 0.18, "square"], [415.0, 415.0, 0.3, "square"]],
	"som": [[880.0, 990.0, 0.05, "square"]],
	"pane": [[600.0, 80.0, 0.5, "square"], [0.0, 0.0, 0.3, "rumble"]],
	"sizzle": [[0.0, 0.0, 0.25, "noise"]],
	"panela": [[240.0, 300.0, 0.06, "square"]],
	"clang": [[1500.0, 1100.0, 0.05, "square"], [0.0, 0.0, 0.06, "noise"], [1100.0, 1000.0, 0.08, "thin"]],
	"alerta": [[900.0, 1400.0, 0.07, "square"]],
	"esquece": [[600.0, 760.0, 0.08, "thin"], [760.0, 520.0, 0.14, "thin"]],
	"gaivota": [[1400.0, 1100.0, 0.07, "thin"], [1350.0, 950.0, 0.1, "thin"]],
	"ferve": [[0.0, 0.0, 0.35, "noise"], [180.0, 240.0, 0.1, "square"]],
	"patinete": [[300.0, 900.0, 0.18, "square"], [900.0, 850.0, 0.2, "thin"]],
	"buzina_moto": [[520.0, 520.0, 0.08, "square"], [0.0, 0.0, 0.04, "noise"], [520.0, 520.0, 0.1, "square"]],
	"fala": [[500.0, 700.0, 0.05, "thin"], [700.0, 600.0, 0.06, "thin"]],
	"teleporte": [[200.0, 1600.0, 0.15, "thin"], [1600.0, 400.0, 0.12, "thin"]],
	"puf": [[0.0, 0.0, 0.12, "noise"], [800.0, 300.0, 0.08, "thin"]],
	"pocar": [[180.0, 700.0, 0.08, "square"], [0.0, 0.0, 0.2, "noise"]],
	"nado": [[0.0, 0.0, 0.06, "noise"], [300.0, 420.0, 0.06, "thin"]],
	"risada": [[700.0, 600.0, 0.05, "thin"], [0.0, 0.0, 0.02, "noise"], [720.0, 620.0, 0.05, "thin"],
			[0.0, 0.0, 0.02, "noise"], [740.0, 560.0, 0.08, "thin"]],
	"piada": [[520.0, 780.0, 0.06, "thin"], [780.0, 660.0, 0.06, "thin"]],
	"sombrinha": [[400.0, 900.0, 0.1, "thin"]],
	"sanfona": [[262.0, 330.0, 0.08, "square"], [330.0, 392.0, 0.08, "square"], [392.0, 523.0, 0.1, "square"]],
	"emocao": [[200.0, 1200.0, 0.22, "square"], [0.0, 0.0, 0.08, "noise"]],
	"leque": [[0.0, 0.0, 0.16, "noise"]],
	"pinca": [[900.0, 1300.0, 0.04, "square"], [1300.0, 700.0, 0.04, "square"]],
	"rojao": [[400.0, 1800.0, 0.35, "thin"]],
	"estouro": [[0.0, 0.0, 0.3, "rumble"], [1200.0, 300.0, 0.1, "square"]],
	"muu": [[160.0, 120.0, 0.25, "square"], [120.0, 90.0, 0.35, "square"]],
	"matraca": [[0.0, 0.0, 0.03, "noise"], [0.0, 0.0, 0.03, "noise"], [0.0, 0.0, 0.03, "noise"]],
	"raio": [[1600.0, 200.0, 0.3, "thin"], [0.0, 0.0, 0.15, "noise"]],
	"bolha": [[300.0, 900.0, 0.06, "thin"]],
	"motor": [[90.0, 140.0, 0.25, "square"]],
	"apito": [[1500.0, 1500.0, 0.1, "thin"], [1200.0, 1200.0, 0.14, "thin"]],
	"badumtss": [[200.0, 80.0, 0.08, "square"], [180.0, 70.0, 0.08, "square"], [0.0, 0.0, 0.3, "noise"]],
	"slam": [[0.0, 0.0, 0.2, "rumble"], [150.0, 60.0, 0.15, "square"]],
}

var _players: Array[AudioStreamPlayer] = []
var _streams := {}


func _ready() -> void:
	for i in VOICES:
		var p := AudioStreamPlayer.new()
		p.volume_db = -10.0
		add_child(p)
		_players.append(p)
	for sound_name in SOUNDS:
		_streams[sound_name] = _make(SOUNDS[sound_name])


func play(sound_name: String) -> void:
	if not _streams.has(sound_name):
		return
	var player := _players[0]
	for p in _players:
		if not p.playing:
			player = p
			break
	player.stream = _streams[sound_name]
	player.play()


func _make(segments: Array) -> AudioStreamWAV:
	var data := PackedByteArray()
	var rng := RandomNumberGenerator.new()
	rng.seed = 7
	var phase := 0.0
	var noise := 0.0
	for seg in segments:
		var f0: float = seg[0]
		var f1: float = seg[1]
		var n := int(seg[2] * RATE)
		var wave: String = seg[3]
		for i in n:
			var t := float(i) / n
			var f := lerpf(f0, f1, t)
			var env := 1.0 - t * 0.6
			if t > 0.9:
				env *= (1.0 - t) * 10.0
			var s := 0.0
			match wave:
				"square":
					phase += f / RATE
					s = 1.0 if fmod(phase, 1.0) < 0.5 else -1.0
				"thin":
					phase += (f + sin(i * 0.004) * 25.0) / RATE
					s = 1.0 if fmod(phase, 1.0) < 0.25 else -1.0
				"noise":
					if i % 3 == 0:
						noise = rng.randf_range(-1.0, 1.0)
					s = noise
				"rumble":
					if i % (2 + int(t * 24.0)) == 0:
						noise = rng.randf_range(-1.0, 1.0)
					s = noise
			var v := int(clampf(s * env * 0.35, -1.0, 1.0) * 32767.0)
			data.append(v & 0xFF)
			data.append((v >> 8) & 0xFF)
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = RATE
	wav.stereo = false
	wav.data = data
	return wav
