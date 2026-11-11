from ne_common import *

H = 14
HEAT = 'const HEAT := true\n'

def sombra(g, x, w=4, row=8):
    """Marquise/toldo: bloco no alto que faz sombra embaixo."""
    g.text(x, row, '=' * w)

# ---------------- Fase 1: Teresina ao meio-dia ----------------
g = Grid(186, H)
g.ground(12, gaps=[(36, 38), (80, 82), (124, 126), (164, 166)])
g.put(3, 11, 'P')
g.text(8, 8, '=?=')
for x in [18, 46, 60, 92, 108, 134, 150, 172]:
    sombra(g, x)
g.text(19, 7, 'bbbb'); g.text(36, 9, 'bbb'); g.text(47, 7, 'bbbb')
g.text(70, 8, '=?=')
g.text(80, 9, 'bbb'); g.text(93, 7, 'bbbb'); g.text(109, 7, 'bbbb')
g.text(124, 9, 'bbb'); g.text(135, 7, 'bbbb'); g.text(151, 7, 'bbbb')
g.text(164, 9, 'bbb')
g.text(140, 8, '=?=')
for x in [26, 54, 88, 116, 144, 158, 178]:
    g.put(x, 11, 'c')
for x in [42, 74, 100, 130, 168]:
    g.put(x, 8, 'u')
g.put(104, 11, 'C')
g.put(180, 11, 'F')
write('piaui_1.gd', 'Piauí', 1, 'TERESINA AO MEIO-DIA', 'teresina',
      'UM VENDEDOR DE PICOLÉ VIU O CARAMELO\\nNA SERRA DA CAPIVARA!', g, HEAT)

# ---------------- Fase 2: Serra da Capivara ----------------
g = Grid(190, H)
g.ground(12, gaps=[(30, 32), (70, 73), (112, 114), (150, 153)])
# Paredões e lapas (pedra que faz sombra por cima)
g.fill(40, 47, 9, 11); g.text(40, 5, '========')
g.fill(56, 59, 10, 11)
g.text(74, 7, '====='); g.text(84, 9, '===')
g.fill(94, 105, 8, 11); g.text(96, 3, '======')
g.fill(120, 123, 10, 11); g.fill(124, 129, 9, 11)
g.text(136, 8, '=====')
g.fill(160, 167, 9, 11); g.text(160, 5, '========')
g.put(3, 11, 'P')
g.text(10, 8, '=?=')
g.text(16, 8, '====')
g.text(30, 9, 'bbb'); g.text(41, 7, 'bbbbbb'); g.text(70, 9, 'bbbb')
g.text(75, 6, 'bbbbb'); g.text(97, 6, 'bbbbbb')
g.text(22, 8, '=?=')
g.text(112, 9, 'bbb'); g.text(137, 7, 'bbbbb'); g.text(150, 9, 'bbbb'); g.text(161, 7, 'bbbbbb')
for x in [22, 52, 66, 90, 118, 132, 146, 174]:
    g.put(x, 11 if g.g[11][x] == '.' else 7, 'c')
for x in [36, 62, 86, 128, 156, 180]:
    g.put(x, 7, 'u')
g.put(108, 11, 'C')
g.put(184, 11, 'F')
write('piaui_2.gd', 'Piauí', 2, 'SERRA DA CAPIVARA', 'capivara',
      'UM GUIA DO PARQUE VIU O CARAMELO\\nATRAVESSANDO A PONTE ESTAIADA!', g, HEAT)

# ---------------- Fase 3: Ponte Estaiada ----------------
g = Grid(124, H)
g.ground(12, gaps=[(26, 28), (50, 52)])
g.put(3, 11, 'P')
g.text(10, 8, '=?=')
for x in [16, 36, 58, 70]:
    sombra(g, x)
g.text(26, 9, 'bbb'); g.text(37, 7, 'bbbb'); g.text(50, 9, 'bbb')
g.text(64, 8, '=?=')
for x in [22, 44, 62]:
    g.put(x, 11, 'c')
for x in [32, 54]:
    g.put(x, 8, 'u')
g.put(78, 11, 'C')
g.arena(82, 98, 103, 112, 11)
g.text(86, 8, '==='); g.text(96, 8, '===')     # toldos na arena: sombra para esfriar
write('piaui_3.gd', 'Piauí', 3, 'PONTE ESTAIADA', 'estaiada', '', g,
      HEAT + 'const BOSS := "sol"\nconst GOAL := "cajuina"\n')
