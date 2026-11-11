from ne_common import *

H = 14
# ---------------- Fase 1: Orla de Atalaia (a fase de 10 segundos) ----------------
g = Grid(40, H)
g.ground(12, gaps=[(20, 21)])
g.put(3, 11, 'P')
g.text(9, 8, '=?=')
g.text(19, 9, 'bbbb')
g.put(15, 11, 'k')
g.put(27, 11, 'k')
g.put(34, 11, 'F')
write('sergipe_1.gd', 'Sergipe', 1, 'ORLA DE ATALAIA', 'atalaia',
      'FOI RAPIDINHO, NÉ? SERGIPE É PEQUENININHO...\\nMAS ESPERA: TEM SURPRESA NA PASSARELA!', g)

# ---------------- Fase 2: Passarela do Caranguejo (a surpresa) ----------------
g = Grid(176, H)
g.ground(12, gaps=[(24, 26), (48, 50), (78, 80), (104, 107), (128, 130)])
g.put(3, 11, 'P')
g.text(10, 8, '=?=')
g.text(24, 9, 'bbb')
g.fill(34, 39, 9, 11)
g.text(35, 6, 'bbbb')
g.text(48, 9, 'bbb')
g.text(58, 8, '=?=')
g.text(66, 8, '===='); g.text(66, 7, 'bbbb')
g.text(78, 9, 'bbb')
g.fill(88, 93, 9, 11)
g.text(105, 8, '=='); g.text(104, 7, 'bbbb')
g.text(114, 8, '=?=')
g.text(128, 9, 'bbb')
for x in [16, 20, 30, 44, 54, 62, 72, 84, 96, 100, 112, 120, 126]:
    g.put(x, 11 if g.g[11][x] == '.' else 8, 'k')
for x in [40, 90, 118]:
    g.put(x, 6, 'W')
g.put(98, 11, 'C')
g.arena(134, 150, 155, 164, 11)
write('sergipe_2.gd', 'Sergipe', 2, 'PASSARELA DO CARANGUEJO', 'passarela', '', g,
      'const BOSS := "caranguejo"\nconst GOAL := "martelinho"\n')
