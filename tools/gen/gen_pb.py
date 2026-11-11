from ne_common import *

# ---------------- Fase 1: Arraial de Campina Grande ----------------
H = 14
g = Grid(180, H)
g.ground(12, gaps=[(30, 32), (64, 66), (104, 106), (140, 142)])
g.put(3, 11, 'P')
g.text(10, 8, '=?=')
g.text(14, 9, 'bbb')
g.text(30, 9, 'bbb')
g.fill(44, 49, 9, 11)                 # palanque da quadrilha
g.text(45, 6, 'bbbb')
g.text(56, 8, '===')
g.text(56, 7, 'bbb')
g.text(64, 9, 'bbb')
g.text(76, 8, '=?=')
g.fill(86, 87, 10, 11); g.fill(88, 89, 9, 11); g.fill(90, 95, 8, 11)
g.text(91, 5, 'bbbb')
g.text(104, 9, 'bbb')
g.text(116, 8, '====')
g.text(116, 7, 'bbbb')
g.text(128, 11, 'XX'); g.text(129, 10, 'X')
g.text(140, 9, 'bbb')
g.text(152, 8, '=?=')
g.text(164, 9, 'bbbb')
for x in [20, 38, 52, 70, 84, 110, 122, 134, 148, 160]:
    g.put(x, 11, 'D')
for x in [24, 58, 80, 100, 124, 156]:
    g.put(x, 11, 'N')
g.put(98, 11, 'C')
g.put(174, 11, 'F')
write('paraiba_1.gd', 'Paraíba', 1, 'ARRAIAL DE CAMPINA GRANDE', 'arraial',
      'UMA DAMA DA QUADRILHA VIU O CARAMELO\\nCORRENDO PRO PARQUE DO POVO!', g)

# ---------------- Fase 2: Parque do Povo ----------------
g = Grid(124, H)
g.ground(12, gaps=[(26, 28), (48, 50)])
g.put(3, 11, 'P')
g.text(10, 8, '=?=')
g.text(26, 9, 'bbb')
g.fill(36, 41, 9, 11)
g.text(37, 6, 'bbbb')
g.text(48, 9, 'bbb')
g.text(60, 8, '=?=')
for x in [16, 32, 44, 56, 70]:
    g.put(x, 11 if g.g[11][x] == '.' else 8, 'D')
for x in [20, 54, 66]:
    g.put(x, 11, 'N')
g.put(76, 11, 'C')
g.arena(82, 98, 103, 112, 11)
write('paraiba_2.gd', 'Paraíba', 2, 'PARQUE DO POVO', 'parquedopovo', '', g,
      'const BOSS := "quadrilha"\nconst GOAL := "milho"\n')
