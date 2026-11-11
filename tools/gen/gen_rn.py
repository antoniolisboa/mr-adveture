from ne_common import *

def duna(g, x0, w, h, ground=12):
    """Duna em degraus: sobe h blocos e desce de novo, largura w."""
    for i in range(w):
        d = min(i, w - 1 - i)
        top = ground - 1 - min(h - 1, d // 2)
        g.fill(x0 + i, x0 + i, top, ground - 1)

H = 14
# ---------------- Fase 1: Dunas de Genipabu ----------------
g = Grid(196, H)
g.ground(12, gaps=[(36, 38), (84, 86), (128, 131), (168, 170)])
duna(g, 18, 12, 3)
duna(g, 46, 18, 5)
duna(g, 96, 22, 6)
duna(g, 140, 16, 4)
g.put(3, 11, 'P')
g.text(10, 8, '=?=')
g.text(36, 9, 'bbb')
g.text(52, 3, 'bbbbbb')
g.text(70, 8, '=?=')
g.text(84, 9, 'bbb')
g.text(104, 1, 'bbbbbb')         # alto demais: só com o pulo "com emoção"
g.text(128, 9, 'bbbb')
g.text(156, 8, '===')
g.text(156, 7, 'bbb')
g.text(168, 9, 'bbb')
g.text(178, 8, 'bbbb')
for x in [30, 66, 92, 122, 150, 176]:
    g.put(x, 11, 'B')
for x in [14, 42, 76, 90, 136, 162, 184]:
    g.put(x, 7, 'Z')
g.put(80, 11, 'C')
g.put(190, 11, 'F')
write('rio_grande_do_norte_1.gd', 'Rio Grande do Norte', 1, 'DUNAS DE GENIPABU', 'dunas',
      'UM BUGUEIRO JUROU QUE VIU O CARAMELO\\nNO MORRO DO CARECA!', g)

# ---------------- Fase 2: Morro do Careca ----------------
g = Grid(124, H)
g.ground(12, gaps=[(28, 30), (56, 58)])
duna(g, 36, 16, 5)
g.put(3, 11, 'P')
g.text(10, 8, '=?=')
g.text(28, 9, 'bbb')
g.text(41, 4, 'bbbbbb')
g.text(56, 9, 'bbb')
g.text(66, 8, '=?=')
for x in [20, 62, 74]:
    g.put(x, 11, 'B')
for x in [16, 34, 54, 70]:
    g.put(x, 7, 'Z')
g.put(78, 11, 'C')
g.arena(82, 98, 103, 112, 11)
write('rio_grande_do_norte_2.gd', 'Rio Grande do Norte', 2, 'MORRO DO CARECA', 'morrocareca', '', g,
      'const BOSS := "bugueiro"\nconst GOAL := "caju"\n')
