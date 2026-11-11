import sys
OUT = sys.argv[1]

class Grid:
    def __init__(s, w, h):
        s.w, s.h = w, h
        s.g = [['.'] * w for _ in range(h)]
    def put(s, x, y, ch):
        s.g[y][x] = ch
    def text(s, x, y, t):
        for i, ch in enumerate(t):
            if ch != ' ':
                s.g[y][x + i] = ch
    def fill(s, x0, x1, y0, y1, ch='#'):
        for y in range(y0, y1 + 1):
            for x in range(x0, x1 + 1):
                s.g[y][x] = ch
    def clear(s, x0, x1, y0, y1):
        s.fill(x0, x1, y0, y1, '.')
    def rows(s):
        return [''.join(r) for r in s.g]

LEGEND = '''##
## Legenda:
##   .  vazio            #  chão (o visual muda conforme o tema)
##   =  bloco de pedra   X  caixote de madeira
##   ?  caixa de poder (solta o item do estado)
##   b  biscoito de polvilho
##   Q  queijo bravo     H  xícara de café pulante
##   V  pombo (voa)      J  frescobolista (arremessa bolinhas)
##   K  pimenta do acarajé (arranca quando vê o jogador)
##   O  folião pipoca (pula quando o jogador pula)
##   E  elevador (sobe ELEVATOR_RISE blocos e desce; 2 blocos de largura)
##   P  início do jogador
##   C  cartaz de PROCURA-SE (checkpoint)
##   F  placa de saída (fim da fase)
##   [ ]  portões da arena do boss    T  boss (BOSS: "trem", "mate" ou "trio")
##   G  último lugar do caramelo no estado (fim do estado)
'''

def write(fname, n, name, theme, clue, grid, extra=''):
    rows = grid.rows()
    assert all(len(r) == len(rows[0]) for r in rows)
    body = 'extends RefCounted\n'
    body += '## Bahia - fase %d: %s. Cada caractere é um bloco de 16x16 pixels.\n' % (n, name.title())
    body += LEGEND + '\n'
    body += 'const NAME := "%s"\n' % name
    body += 'const THEME := "%s"\n' % theme
    body += 'const CLUE := "%s"\n' % clue
    body += extra
    body += '\nconst ROWS := [\n' + ''.join('\t"%s",\n' % r for r in rows) + ']\n'
    open(OUT + '/' + fname, 'w').write(body)

# ---------------- Fase 1: Pelourinho ----------------
g = Grid(192, 13)
g.fill(0, 191, 11, 12)
for a, b in [(40, 42), (96, 98), (141, 143)]:
    g.clear(a, b, 11, 12)
# Ladeira: sobe em degraus e desce de novo.
g.fill(56, 57, 10, 10); g.fill(58, 59, 9, 10); g.fill(60, 76, 8, 10); g.fill(77, 78, 9, 10); g.fill(79, 80, 10, 10)
g.text(10, 7, '=?=')
g.text(14, 8, 'bbb')
g.text(39, 7, 'bbb')
g.text(62, 5, 'bbbbbb')
g.text(95, 7, 'bbb')
g.text(118, 7, '=?=')
g.text(140, 6, 'bbbbbb')
g.text(166, 8, 'bbbb')
g.text(84, 9, 'X'); g.text(84, 10, 'X'); g.text(104, 10, 'XX'); g.text(105, 9, 'X')
g.text(130, 8, '===')
g.text(130, 7, 'bbb')
g.put(3, 10, 'P')
for x in [22, 31, 48, 88, 112, 116, 158, 172]:
    g.put(x, 10, 'O')
for x in [35, 128, 152, 176]:
    g.put(x, 10, 'K')
g.put(70, 7, 'K')
g.put(100, 10, 'C')
g.put(186, 10, 'F')
write('bahia_1.gd', 1, 'PELOURINHO', 'pelourinho',
      'UMA BAIANA DO ACARAJÉ VIU O CARAMELO\\nDESCENDO PARA A CIDADE BAIXA!', g)

# ---------------- Fase 2: Elevador Lacerda ----------------
H = 18
g = Grid(176, H)
# Cidade Baixa (chão em 16-17)
g.fill(0, 37, 16, 17)
# Primeira Cidade Alta (superfície na linha 8)
g.fill(38, 82, 8, 17)
# Cidade Baixa de novo
g.fill(83, 123, 16, 17)
g.clear(100, 102, 16, 17)
# Segunda Cidade Alta
g.fill(126, 175, 8, 17)
g.put(3, 15, 'P')
g.text(8, 12, '=?=')
g.text(12, 13, 'bbb')
g.text(20, 15, 'O'); g.put(29, 15, 'K')
# Elevador 1 encostado na encosta
g.text(36, 15, 'E')
g.text(36, 10, 'b'); g.text(36, 12, 'b'); g.text(36, 14, 'b')
# Em cima
g.text(44, 5, 'bbbb')
g.put(48, 7, 'O'); g.put(56, 7, 'K'); g.put(64, 7, 'O')
g.text(60, 4, '===')
g.text(60, 3, 'bbb')
g.text(68, 7, 'X'); g.text(69, 7, 'X'); g.text(69, 6, 'X')
g.put(74, 7, 'C')
g.put(78, 7, 'O')
# Desce pela encosta até a Cidade Baixa
g.text(84, 13, 'bbb')
g.put(90, 15, 'K'); g.put(96, 15, 'O')
g.text(99, 13, 'bbbbb')
g.put(106, 15, 'O'); g.put(110, 15, 'K'); g.put(116, 15, 'O')
g.text(108, 12, '=?=')
# Elevador 2 e um elevador no meio do vão (sem chão embaixo)
g.text(124, 15, 'E')
g.text(124, 10, 'b'); g.text(124, 12, 'b')
g.put(132, 7, 'O'); g.put(140, 7, 'K'); g.put(150, 7, 'O'); g.put(156, 7, 'K')
g.text(144, 4, 'bbbb')
g.text(145, 5, '==')
g.put(170, 7, 'F')
write('bahia_2.gd', 2, 'ELEVADOR LACERDA', 'baia',
      'O CARAMELO FOI VISTO NA ORLA,\\nPERTO DO FAROL!', g, 'const ELEVATOR_RISE := 8\n')

# ---------------- Fase 3: Farol da Barra ----------------
g = Grid(200, 13)
g.fill(0, 199, 11, 12)
for a, b in [(30, 32), (58, 62), (88, 90), (118, 123), (150, 152), (172, 174)]:
    g.clear(a, b, 11, 12)
g.put(3, 10, 'P')
g.text(12, 7, '=?=')
g.text(29, 7, 'bbb')
g.text(59, 8, '==='); g.text(59, 7, 'bbb')   # pedra no meio do vão
g.text(88, 6, 'bbbb')
g.text(119, 8, '=='); g.text(122, 7, '=='); g.text(119, 7, 'bb'); g.text(122, 6, 'bb')
g.text(140, 7, '=?=')
g.text(151, 6, 'bbbb')
g.text(173, 7, 'bbb')
g.text(70, 10, 'XX'); g.text(71, 9, 'X')
g.text(160, 10, 'X'); g.text(160, 9, 'X')
for x in [20, 26, 44, 50, 78, 98, 104, 132, 136, 166, 182, 188]:
    g.put(x, 10, 'O')
for x in [38, 66, 84, 112, 146, 178]:
    g.put(x, 10, 'K')
g.put(60, 7, '.')
g.put(100, 10, 'C')
g.put(195, 10, 'F')
write('bahia_3.gd', 3, 'FAROL DA BARRA', 'farol',
      'UM FOLIÃO CONTOU QUE O CARAMELO\\nSUBIU NUM TRIO ELÉTRICO!', g)

# ---------------- Fase 4: Circuito do Carnaval ----------------
g = Grid(100, 13)
g.fill(0, 99, 11, 12)
g.clear(26, 28, 11, 12)
g.put(3, 10, 'P')
g.text(9, 7, '=?=')
g.text(14, 8, 'bbb')
g.text(25, 7, 'bbb')
for x in [17, 21, 33, 37, 41]:
    g.put(x, 10, 'O')
for x in [30, 46]:
    g.put(x, 10, 'K')
g.text(44, 7, '=?=')
g.put(52, 10, 'C')
g.put(58, 10, '[')
g.put(74, 10, 'T')
g.put(79, 10, ']')
g.put(88, 10, 'G')
write('bahia_4.gd', 4, 'CIRCUITO DO CARNAVAL', 'carnaval', '', g,
      'const BOSS := "trio"\nconst GOAL := "abada"\n')
print('ok')
