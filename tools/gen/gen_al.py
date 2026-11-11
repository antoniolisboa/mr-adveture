from ne_common import *

H = 14

def piscina(g, a, b, floor=13, top=10):
    """Piscina natural: buraco no recife com fundo de areia."""
    g.clear(a, b, top, floor - 1)

# ---------------- Fase 1: Piscinas Naturais de Maragogi ----------------
g = Grid(190, H)
g.ground(10)
for a, b in [(22, 27), (44, 51), (70, 75), (96, 104), (126, 131), (150, 158), (172, 176)]:
    piscina(g, a, b)
g.fill(36, 39, 8, 9)            # pedras de recife mais altas (sempre fora d'água)
g.fill(84, 89, 7, 9)
g.fill(112, 117, 8, 9)
g.fill(138, 141, 7, 9)
g.put(3, 9, 'P')
g.text(10, 6, '=?=')
g.text(23, 11, 'bbbb')          # dentro das piscinas
g.text(45, 11, 'bbbbbb')
g.text(37, 5, 'bbbb')
g.text(64, 6, '=?=')
g.text(85, 4, 'bbbbbb')
g.text(97, 12, 'bbbbbbb')
g.text(127, 11, 'bbbb')
g.text(139, 4, 'bbbb')
g.text(151, 12, 'bbbbbbb')
g.text(162, 6, '=?=')
for x in [24, 47, 50, 72, 99, 102, 128, 153, 156, 174]:
    g.put(x, 12, 'o')            # ouriços no fundo das piscinas
for x in [31, 60, 92, 120, 146, 166]:
    g.put(x, 9, 'o')
for x in [48, 100, 154]:
    g.put(x, 11, 'p')
for x in [25, 73, 129]:
    g.put(x, 11, 'p')
g.put(80, 9, 'C')
g.put(184, 9, 'F')
write('alagoas_1.gd', 'Alagoas', 1, 'PISCINAS NATURAIS DE MARAGOGI', 'maragogi',
      'UM JANGADEIRO VIU O CARAMELO\\nCORRENDO PRAS GALÉS!', g,
      'const WATER_ROW := 8\nconst TIDE := 3.0\nconst TIDE_PERIOD := 14.0\n')

# ---------------- Fase 2: Galés ----------------
g = Grid(124, H)
g.ground(10)
for a, b in [(20, 25), (40, 46), (60, 66)]:
    piscina(g, a, b)
g.fill(32, 35, 8, 9)
g.put(3, 9, 'P')
g.text(10, 6, '=?=')
g.text(21, 11, 'bbbb')
g.text(33, 6, 'bbbb')
g.text(41, 11, 'bbbbb')
g.text(52, 6, '=?=')
g.text(61, 11, 'bbbbb')
for x in [22, 43, 63, 30, 56, 72]:
    g.put(x, 12 if x in (22, 43, 63) else 9, 'o')
for x in [44, 64]:
    g.put(x, 11, 'p')
g.put(76, 9, 'C')
g.arena(82, 98, 103, 112, 9)
write('alagoas_2.gd', 'Alagoas', 2, 'GALÉS DE MARAGOGI', 'gales', '', g,
      'const WATER_ROW := 11\nconst BOSS := "siri"\nconst GOAL := "castelo"\n')
