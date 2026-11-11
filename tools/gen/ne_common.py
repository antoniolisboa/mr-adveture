import sys
import os
OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..', 'levels')

class Grid:
    def __init__(s, w, h):
        s.w, s.h = w, h
        s.g = [['.'] * w for _ in range(h)]
    def put(s, x, y, ch): s.g[y][x] = ch
    def text(s, x, y, t):
        for i, ch in enumerate(t):
            if ch != ' ': s.g[y][x + i] = ch
    def fill(s, x0, x1, y0, y1, ch='#'):
        for y in range(y0, y1 + 1):
            for x in range(x0, x1 + 1): s.g[y][x] = ch
    def clear(s, x0, x1, y0, y1): s.fill(x0, x1, y0, y1, '.')
    def rows(s): return [''.join(r) for r in s.g]
    def ground(s, row, gaps=()):
        """Chão da linha row até o fim, com buracos [(a, b), ...]."""
        s.fill(0, s.w - 1, row, s.h - 1)
        for a, b in gaps: s.clear(a, b, row, s.h - 1)
    def arena(s, left, boss, right, goal, row):
        s.put(left, row, '['); s.put(boss, row, 'T'); s.put(right, row, ']'); s.put(goal, row, 'G')

LEGEND = '''## Legenda:
##   .  vazio            #  chão (o visual muda conforme o tema)
##   =  bloco de pedra   X  caixote de madeira
##   ?  caixa de poder (solta o item do estado)
##   b  biscoito de polvilho
##   Q  queijo bravo     H  xícara de café pulante
##   V  pombo (voa)      J  frescobolista (arremessa bolinhas)
##   K  pimenta do acarajé (arranca quando vê o jogador)
##   O  folião pipoca (pula quando o jogador pula)
##   R  robalo (corre atrás do jogador e depois esquece)
##   W  gaivota (mergulha no jogador e esquece no meio do caminho)
##   S  patinete desgovernado (corre e vira na beirada)
##   Y  coachinho (dispara frases motivacionais)
##   A  carro no trânsito (anda e para; dá para subir; 2 blocos de largura)
##   U  sombrinha de frevo saltitante      D  rojão (sobe e estoura quando chega perto)
##   N  sanfona andante (estica e encolhe) B  buggy desgovernado
##   Z  caju (cai do pé quando o jogador passa embaixo)
##   M  piadista (conta piada; quem ouve fica rindo parado)
##   I  regueiro (dança devagar)           L  ilhota da lagoa (afunda e volta)
##   u  onda de calor (não dá para pisar)  c  calango (corre e para)
##   o  ouriço (espinhento: não pise)      p  baiacu (incha quando chega perto)
##   k  caranguejo (anda de lado)
##   q  quati (rouba o item e foge; pisar devolve)
##   y  capivara (plataforma que anda devagar; 2 blocos de largura)
##   t  tainha (pula do fundo do buraco)    w  bruxinha (voa e solta feitiço)
##   r  quero-quero (dá rasantes)           v  ovelha (pisar quica alto; não machuca)
##   E  elevador (sobe ELEVATOR_RISE blocos e desce; 2 blocos de largura)
##   P  início do jogador
##   C  cartaz de PROCURA-SE (checkpoint)
##   F  placa de saída (fim da fase)
##   [ ]  portões da arena do boss    T  boss (BOSS: ver scripts/boss_arena.gd)
##   G  último lugar do caramelo no estado (fim do estado)
##
## Constantes opcionais: HEAT (sol de meio-dia, barra de calor), WATER_ROW (linha onde
## começa a água), TIDE (quantos blocos a maré baixa), TIDE_PERIOD (segundos da maré),
## LAGOON (lago azul no fundo dos buracos), WIND (minuano: força do vento, px/s; negativo
## = sopra para a esquerda) e WIND_PERIOD (segundos entre uma rajada e outra).
'''

def write(fname, state, n, name, theme, clue, grid, extra=''):
    rows = grid.rows()
    assert all(len(r) == len(rows[0]) for r in rows)
    body = 'extends RefCounted\n'
    body += '## %s - fase %d: %s. Cada caractere é um bloco de 16x16 pixels.\n##\n' % (state, n, name.title())
    body += LEGEND + '\n'
    body += 'const NAME := "%s"\n' % name
    body += 'const THEME := "%s"\n' % theme
    body += 'const CLUE := "%s"\n' % clue
    body += extra
    body += '\nconst ROWS := [\n' + ''.join('\t"%s",\n' % r for r in rows) + ']\n'
    open(OUT + '/' + fname, 'w').write(body)
    print('ok', fname, len(rows[0]), 'x', len(rows))
