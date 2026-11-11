from ne_common import *

# ---------------- Fase 1: Ladeiras de Olinda ----------------
# Ladeiras sobem e descem em degraus; vãos largos para planar com a sombrinha.
H = 14
g = Grid(184, H)
g.ground(12, gaps=[(34, 36), (70, 72), (120, 125), (150, 152)])
# Ladeira 1: sobe de 1 em 1
for i, x in enumerate(range(44, 56, 2)):
    g.fill(x, x + 1, 11 - i, 11)
g.fill(56, 69, 6, 11)
# depois do vão 70-73 desce
g.fill(74, 75, 7, 11); g.fill(76, 77, 8, 11); g.fill(78, 79, 9, 11); g.fill(80, 81, 10, 11)
# Ladeira 2 (alta) com vão largo no topo: dá para planar ou usar a pedra do meio
for i, x in enumerate(range(100, 110, 2)):
    g.fill(x, x + 1, 11 - i, 11)
g.fill(110, 119, 6, 11)
g.text(122, 8, '==')           # pedra no meio do vão largo
g.fill(126, 135, 6, 11)
g.fill(136, 137, 8, 11); g.fill(138, 139, 10, 11)
g.put(3, 11, 'P')
g.text(12, 8, '=?=')
g.text(16, 9, 'bbb')
g.text(34, 9, 'bbb')
g.text(58, 3, 'bbbb')
g.text(70, 4, 'bbbb')
g.text(88, 8, '=?=')
g.text(119, 3, 'bbbbbbbb')     # caminho no alto para quem plana
g.text(122, 7, 'bb')
g.text(150, 9, 'bbb')
g.text(166, 8, 'bbbb')
g.text(30, 11, 'X'); g.text(92, 11, 'XX'); g.text(93, 10, 'X')
for x in [20, 40, 62, 84, 96, 114, 130, 158, 170]:
    g.put(x, 11 if g.g[11][x] == '.' and g.g[12][x] == '#' else 5, 'U')
for x in [26, 66, 86, 145, 162]:
    g.put(x, 11 if g.g[12][x] == '#' and g.g[11][x] == '.' else 5, 'O')
g.put(98, 11, 'C')
g.put(178, 11, 'F')
write('pernambuco_1.gd', 'Pernambuco', 1, 'LADEIRAS DE OLINDA', 'olinda',
      'UM PASSISTA VIU O CARAMELO\\nSUBINDO PARA O ALTO DA SÉ!', g)

# ---------------- Fase 2: Alto da Sé ----------------
g = Grid(124, H)
g.ground(12, gaps=[(24, 26), (52, 56)])
for i, x in enumerate(range(32, 40, 2)):
    g.fill(x, x + 1, 11 - i, 11)
g.fill(40, 51, 8, 11)
g.text(54, 7, '==')
g.fill(57, 66, 8, 11)
g.fill(67, 68, 9, 11); g.fill(69, 70, 10, 11)
g.put(3, 11, 'P')
g.text(10, 8, '=?=')
g.text(24, 8, 'bbbb')
g.text(44, 4, 'bbbb')
g.text(53, 5, 'bbbb')
g.text(72, 8, '=?=')
for x in [16, 30, 45, 62, 76]:
    g.put(x, 11 if g.g[11][x] == '.' else 7, 'U')
for x in [20, 48]:
    g.put(x, 11 if g.g[11][x] == '.' else 7, 'O')
g.put(78, 11, 'C')
g.arena(82, 98, 103, 112, 11)
write('pernambuco_2.gd', 'Pernambuco', 2, 'ALTO DA SÉ', 'altose', '', g,
      'const BOSS := "boneco"\nconst GOAL := "frevo"\n')
