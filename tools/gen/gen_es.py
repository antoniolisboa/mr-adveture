import sys, re, glob
OUT = sys.argv[1]

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
##   E  elevador (sobe ELEVATOR_RISE blocos e desce; 2 blocos de largura)
##   P  início do jogador
##   C  cartaz de PROCURA-SE (checkpoint)
##   F  placa de saída (fim da fase)
##   [ ]  portões da arena do boss    T  boss (BOSS: "trem", "mate", "trio" ou "panela")
##   G  último lugar do caramelo no estado (fim do estado)
'''

def write(fname, n, name, theme, clue, grid, extra=''):
    rows = grid.rows()
    assert all(len(r) == len(rows[0]) for r in rows)
    body = 'extends RefCounted\n'
    body += '## Espírito Santo - fase %d: %s. Cada caractere é um bloco de 16x16 pixels.\n##\n' % (n, name.title())
    body += LEGEND + '\n'
    body += 'const NAME := "%s"\n' % name
    body += 'const THEME := "%s"\n' % theme
    body += 'const CLUE := "%s"\n' % clue
    body += extra
    body += '\nconst ROWS := [\n' + ''.join('\t"%s",\n' % r for r in rows) + ']\n'
    open(OUT + '/' + fname, 'w').write(body)

# ---------------- Fase 1: Terceira Ponte ----------------
g = Grid(176, 13)
g.fill(0, 175, 11, 12)
for a, b in [(34, 36), (60, 62), (112, 114), (130, 134), (152, 154)]:
    g.clear(a, b, 11, 12)
# Corcova da ponte no vão central (o ponto mais alto).
g.fill(74, 75, 10, 10); g.fill(76, 77, 9, 10); g.fill(78, 98, 8, 10); g.fill(99, 100, 9, 10); g.fill(101, 102, 10, 10)
g.put(3, 10, 'P')
g.text(11, 7, '=?=')
g.text(15, 8, 'bbb')
g.text(33, 7, 'bbbbb')
g.text(59, 7, 'bbbbb')
g.text(88, 4, '=?=')
g.text(82, 5, 'bbb'); g.text(94, 5, 'bbb')
g.text(131, 8, '===')
g.text(131, 7, 'bbb')
g.text(151, 6, 'bbbbb')
g.text(44, 10, 'X'); g.text(44, 9, 'X'); g.text(45, 10, 'X')
g.text(122, 10, 'XX'); g.text(123, 9, 'X')
for x in [22, 40, 52, 68, 84, 92, 108, 120, 140, 146, 162]:
    g.put(x, 10 if not 78 <= x <= 98 else 7, 'R')
for x, y in [(35, 5), (61, 5), (113, 4), (132, 4), (153, 5)]:
    g.put(x, y, 'W')
g.put(104, 10, 'C')
g.put(170, 10, 'F')
write('espirito_santo_1.gd', 1, 'TERCEIRA PONTE', 'ponte',
      'UM PESCADOR VIU O CARAMELO\\nSUBINDO A LADEIRA DA PENHA!', g)

# ---------------- Fase 2: Ladeira da Penha ----------------
g = Grid(124, 13)
g.fill(0, 31, 11, 12)
g.clear(20, 22, 11, 12)
g.fill(32, 39, 9, 12)
g.fill(40, 51, 7, 12)
g.fill(52, 63, 9, 12)
g.clear(57, 59, 9, 12)
g.fill(64, 123, 7, 12)
g.put(3, 10, 'P')
g.text(9, 7, '=?=')
g.text(13, 8, 'bbb')
g.text(20, 7, 'bbb')
g.text(43, 4, 'bbbb')
g.text(57, 6, 'bbb')
g.text(66, 3, '=?=')
for x, y in [(16, 10), (28, 10), (36, 8), (46, 6), (54, 8), (62, 8), (70, 6)]:
    g.put(x, y, 'R')
for x, y in [(21, 6), (34, 4), (58, 4)]:
    g.put(x, y, 'W')
g.put(76, 6, 'C')
g.put(82, 6, '[')
g.put(98, 6, 'T')
g.put(103, 6, ']')
g.put(112, 6, 'G')
write('espirito_santo_2.gd', 2, 'LADEIRA DA PENHA', 'penha', '', g,
      'const BOSS := "panela"\nconst GOAL := "moqueca"\n')

# Atualiza a legenda dos outros mapas.
for f in glob.glob(OUT + '/*_[0-9].gd'):
    t = open(f).read()
    t2 = re.sub(r'## Legenda:\n(##.*\n)+', LEGEND, t, count=1)
    if t2 != t:
        open(f, 'w').write(t2)
print('ok')
