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
##   S  patinete desgovernado (corre e vira na beirada)
##   Y  coachinho (dispara frases motivacionais)
##   A  carro no trânsito (anda e para; dá para subir; 2 blocos de largura)
##   E  elevador (sobe ELEVATOR_RISE blocos e desce; 2 blocos de largura)
##   P  início do jogador
##   C  cartaz de PROCURA-SE (checkpoint)
##   F  placa de saída (fim da fase)
##   [ ]  portões da arena do boss    T  boss (BOSS: "trem", "mate", "trio", "panela" ou "coach")
##   G  último lugar do caramelo no estado (fim do estado)
'''

def write(fname, n, name, theme, clue, grid, extra=''):
    rows = grid.rows()
    assert all(len(r) == len(rows[0]) for r in rows)
    body = 'extends RefCounted\n'
    body += '## São Paulo - fase %d: %s. Cada caractere é um bloco de 16x16 pixels.\n##\n' % (n, name.title())
    body += LEGEND + '\n'
    body += 'const NAME := "%s"\n' % name
    body += 'const THEME := "%s"\n' % theme
    body += 'const CLUE := "%s"\n' % clue
    body += extra
    body += '\nconst ROWS := [\n' + ''.join('\t"%s",\n' % r for r in rows) + ']\n'
    open(OUT + '/' + fname, 'w').write(body)


# ---------------- Fase 1: Marginal ----------------
g = Grid(190, 13)
g.fill(0, 189, 11, 12)
for a, b in [(50, 52), (98, 100), (146, 148)]:
    g.clear(a, b, 11, 12)
g.put(3, 10, 'P')
g.text(10, 7, '=?=')
g.text(14, 8, 'bbb')
for x in [20, 30, 40, 60, 70, 82, 108, 118, 128, 156, 166]:
    g.put(x, 10, 'A')
for x in [22, 32, 42, 62, 72, 84, 110, 120, 130, 158, 168]:
    g.text(x - 1, 7, 'bb')
g.text(49, 7, 'bbbbb'); g.text(97, 7, 'bbbbb'); g.text(145, 7, 'bbbbb')
g.text(88, 7, '=?=')
for x in [26, 46, 66, 78, 94, 114, 124, 140, 162, 176]:
    g.put(x, 10, 'S')
for x in [56, 136]:
    g.put(x, 10, 'Y')
g.put(104, 10, 'C')
g.put(184, 10, 'F')
write('sao_paulo_1.gd', 1, 'MARGINAL', 'marginal',
      'UM MOTOBOY VIU O CARAMELO\\nNA CICLOVIA DA FARIA LIMA!', g)

# ---------------- Fase 2: Faria Lima ----------------
g = Grid(190, 13)
g.fill(0, 189, 11, 12)
for a, b in [(36, 38), (74, 77), (120, 122), (160, 163)]:
    g.clear(a, b, 11, 12)
g.text(75, 8, '==')
g.text(161, 8, '==')
g.put(3, 10, 'P')
g.text(9, 7, '=?=')
g.text(13, 8, 'bbb')
g.text(35, 7, 'bbbbb')
g.text(74, 6, 'bbbb')
g.text(160, 6, 'bbbb')
# Canteiros e degraus de prédio
g.fill(50, 55, 10, 10, '='); g.fill(52, 55, 9, 9, '=')
g.text(52, 7, 'bbbb')
g.fill(130, 137, 10, 10, '='); g.fill(132, 137, 9, 9, '='); g.fill(134, 137, 8, 8, '=')
g.text(134, 6, 'bbbb')
g.text(100, 7, '=?=')
g.text(64, 10, 'XX'); g.text(65, 9, 'X')
g.text(146, 10, 'X'); g.text(146, 9, 'X')
for x in [24, 46, 62, 88, 112, 128, 154, 172]:
    g.put(x, 10, 'Y')
for x in [18, 30, 44, 84, 94, 108, 116, 150, 168, 178]:
    g.put(x, 10, 'S')
g.put(54, 8, 'Y')
g.put(104, 10, 'C')
g.put(184, 10, 'F')
write('sao_paulo_2.gd', 2, 'FARIA LIMA', 'farialima',
      'O CARAMELO FOI VISTO SUBINDO\\nPARA O TERRAÇO DE UM COWORKING!', g)

# ---------------- Fase 3: Terraço do Coworking ----------------
g = Grid(110, 13)
g.fill(0, 109, 11, 12)
for a, b in [(20, 22), (34, 36), (48, 50)]:
    g.clear(a, b, 11, 12)
g.fill(25, 30, 10, 10)            # caixa d'água / casa de máquinas
g.fill(27, 30, 9, 9)
g.put(3, 10, 'P')
g.text(9, 7, '=?=')
g.text(13, 8, 'bbb')
g.text(19, 7, 'bbbbb'); g.text(33, 7, 'bbbbb'); g.text(47, 7, 'bbbbb')
g.text(27, 6, 'bbbb')
for x in [16, 42, 54]:
    g.put(x, 10, 'S')
for x, y in [(29, 8), (44, 10)]:
    g.put(x, y, 'Y')
g.put(58, 10, 'C')
g.put(64, 10, '[')
g.put(80, 10, 'T')
g.put(86, 10, ']')
g.put(96, 10, 'G')
write('sao_paulo_3.gd', 3, 'TERRAÇO DO COWORKING', 'terraco', '', g,
      'const BOSS := "coach"\nconst GOAL := "cracha"\n')

for f in glob.glob(OUT + '/*_[0-9].gd'):
    t = open(f).read()
    t2 = re.sub(r'## Legenda:\n(##.*\n)+', LEGEND, t, count=1)
    if t2 != t:
        open(f, 'w').write(t2)
print('ok')
