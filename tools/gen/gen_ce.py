from ne_common import *

H = 14
# ---------------- Fase 1: Praia de Iracema ----------------
g = Grid(186, H)
g.ground(12, gaps=[(40, 42), (78, 80), (118, 120), (156, 158)])
g.put(3, 11, 'P')
g.text(10, 8, '=?=')
g.text(14, 9, 'bbb')
g.text(24, 9, 'XX'); g.text(24, 10, 'XX'); g.text(24, 11, 'XX')   # jangada parada na areia
g.text(23, 6, 'bbbb')
g.text(40, 9, 'bbb')
g.fill(54, 61, 9, 11)
g.text(55, 6, 'bbbbbb')
g.text(68, 8, '=?=')
g.text(78, 9, 'bbb')
g.text(92, 8, '====')
g.text(92, 7, 'bbbb')
g.text(104, 10, 'XX'); g.text(104, 11, 'XX')
g.text(118, 9, 'bbb')
g.fill(130, 133, 10, 11); g.fill(134, 139, 8, 11)
g.text(135, 5, 'bbbb')
g.text(146, 8, '=?=')
g.text(156, 9, 'bbb')
g.text(168, 9, 'bbbb')
for x in [20, 48, 64, 86, 112, 126, 150, 164]:
    g.put(x, 11, 'M')
for x in [34, 72, 100, 142, 174]:
    g.put(x, 6, 'W')
g.put(96, 11, 'C')
g.put(180, 11, 'F')
write('ceara_1.gd', 'Ceará', 1, 'PRAIA DE IRACEMA', 'jangada',
      'UM JANGADEIRO VIU O CARAMELO\\nNA FEIRINHA DA BEIRA-MAR!', g)

# ---------------- Fase 2: Feirinha da Beira-Mar ----------------
g = Grid(124, H)
g.ground(12, gaps=[(28, 30), (52, 54)])
g.put(3, 11, 'P')
g.text(10, 8, '=?=')
g.text(28, 9, 'bbb')
g.fill(36, 43, 9, 11)
g.text(37, 6, 'bbbbbb')
g.text(52, 9, 'bbb')
g.text(62, 8, '=?=')
for x in [18, 34, 46, 58, 70]:
    g.put(x, 11 if g.g[11][x] == '.' else 8, 'M')
for x in [24, 66]:
    g.put(x, 6, 'W')
g.put(76, 11, 'C')
g.arena(82, 98, 103, 112, 11)
write('ceara_2.gd', 'Ceará', 2, 'FEIRINHA DA BEIRA-MAR', 'beiramar', '', g,
      'const BOSS := "resenha"\nconst GOAL := "rede"\n')
