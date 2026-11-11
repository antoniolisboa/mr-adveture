import re, sys
s = open(sys.argv[1]).read()
pal = set(re.findall(r'^\t"(.)": Color', s, re.M))
base = set(re.findall(r'^\t"(.)": Color', open('/home/rocket/projects/mr-adveture/scripts/art.gd').read(), re.M))
for m in re.finditer(r'\t"(\w+)": \[\n(.*?)\n\t\],', s, re.S):
    rows = re.findall(r'"([^"]*)"', m.group(2))
    ws = {len(r) for r in rows}
    bad = {c for r in rows for c in r} - pal - base - {'.'}
    if len(ws) != 1 or bad:
        print("PROBLEMA", m.group(1), ws, bad)
print("ok", len(re.findall(r'\t"(\w+)": \[\n', s)))
