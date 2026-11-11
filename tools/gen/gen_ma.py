from ne_common import *
from gen_rn import duna

H = 14
# ---------------- Fase 1: Lençóis Maranhenses ----------------
g = Grid(192, H)
lagoas = [(30, 36), (62, 70), (100, 108), (140, 149), (170, 175)]
g.ground(12, gaps=lagoas)
duna(g, 14, 12, 3)
duna(g, 44, 14, 4)
duna(g, 78, 16, 5)
duna(g, 114, 18, 6)
duna(g, 152, 12, 3)
# Ilhotas nas lagoas (afundam e voltam)
for a, b in lagoas:
    for x in range(a + 1, b, 3):
        g.put(x, 10, 'L')
g.put(3, 11, 'P')
g.text(8, 8, '=?=')
g.text(31, 7, 'bbbbb')
g.text(48, 5, 'bbbb')
g.text(63, 7, 'bbbbbbb')
g.text(84, 3, 'bbbb')
g.text(92, 8, '=?=')
g.text(101, 7, 'bbbbbbb')
g.text(120, 1, 'bbbbbb')
g.text(141, 7, 'bbbbbbbb')
g.text(171, 7, 'bbbb')
for x in [24, 56, 96, 132, 160, 182]:
    g.put(x, 11 if g.g[11][x] == '.' else 9, 'I')
for x in [33, 66, 104, 144]:
    g.put(x, 5, 'W')
g.put(128, 11, 'C')
g.put(186, 11, 'F')
write('maranhao_1.gd', 'Maranhão', 1, 'LENÇÓIS MARANHENSES', 'lencois',
      'UM PESCADOR DA LAGOA VIU O CARAMELO\\nINDO PARA SÃO LUÍS!', g, 'const LAGOON := true\n')

# ---------------- Fase 2: Centro Histórico de São Luís ----------------
g = Grid(184, H)
g.ground(12, gaps=[(34, 36), (76, 78), (122, 124), (160, 162)])
# Ladeiras de pedra e sacadas dos sobrados
for i, x in enumerate(range(40, 50, 2)):
    g.fill(x, x + 1, 11 - i, 11)
g.fill(50, 61, 7, 11)
g.fill(62, 63, 9, 11); g.fill(64, 65, 10, 11)
g.text(84, 7, '====='); g.text(92, 4, '====')
g.text(100, 8, '====')
g.fill(128, 139, 8, 11)
g.text(134, 4, '===')
g.put(3, 11, 'P')
g.text(10, 8, '=?=')
g.text(34, 9, 'bbb')
g.text(52, 4, 'bbbb')
g.text(70, 8, '=?=')
g.text(85, 6, 'bbbbb')
g.text(92, 3, 'bbbb')
g.text(122, 9, 'bbb')
g.text(134, 3, 'bbb')
g.text(150, 8, '=?=')
g.text(160, 9, 'bbb')
for x in [20, 30, 56, 72, 88, 108, 116, 132, 146, 168]:
    g.put(x, 11 if g.g[11][x] == '.' else 7, 'I')
g.put(104, 11, 'C')
g.put(178, 11, 'F')
write('maranhao_2.gd', 'Maranhão', 2, 'CENTRO HISTÓRICO DE SÃO LUÍS', 'saoluis',
      'UMA BRINCANTE DO BOI VIU O CARAMELO\\nDANÇANDO NO ARRAIAL!', g)

# ---------------- Fase 3: Arraial do Boi ----------------
g = Grid(124, H)
g.ground(12, gaps=[(26, 28), (50, 52)])
g.put(3, 11, 'P')
g.text(10, 8, '=?=')
g.text(26, 9, 'bbb')
g.fill(36, 41, 9, 11)
g.text(37, 5, 'bbbb')
g.text(50, 9, 'bbb')
g.text(62, 8, '=?=')
for x in [18, 32, 46, 58, 70]:
    g.put(x, 11 if g.g[11][x] == '.' else 8, 'I')
g.put(76, 11, 'C')
g.arena(82, 98, 103, 112, 11)
write('maranhao_3.gd', 'Maranhão', 3, 'ARRAIAL DO BOI', 'boi', '', g,
      'const BOSS := "boi"\nconst GOAL := "boi"\n')
