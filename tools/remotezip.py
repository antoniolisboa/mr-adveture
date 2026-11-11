# Baixa só alguns arquivos de dentro de um .zip remoto (sem baixar o zip inteiro).
# Usado para pegar só o modelo Web de dentro do pacote de modelos de exportação da Godot (1,3 GB).
# Uso: python3 tools/remotezip.py <url> <pasta> <arquivo> [...]
import sys, struct, zlib, urllib.request
url, out_dir = sys.argv[1], sys.argv[2]
want = sys.argv[3:]
def rng(a, b):
    req = urllib.request.Request(url, headers={"Range": "bytes=%d-%d" % (a, b)})
    return urllib.request.urlopen(req).read()
size = int(urllib.request.urlopen(urllib.request.Request(url, method="HEAD")).headers["Content-Length"])
tail = rng(size - 65536, size - 1)
i = tail.rfind(b"PK\x05\x06")
cd_size, cd_off = struct.unpack("<II", tail[i+12:i+20])
if cd_off == 0xFFFFFFFF:  # zip64
    j = tail.rfind(b"PK\x06\x06")
    cd_size, cd_off = struct.unpack("<QQ", tail[j+40:j+56])
cd = rng(cd_off, cd_off + cd_size - 1)
p = 0
while p < len(cd) and cd[p:p+4] == b"PK\x01\x02":
    meth, = struct.unpack("<H", cd[p+10:p+12])
    csize, usize = struct.unpack("<II", cd[p+20:p+28])
    nl, el, cl = struct.unpack("<HHH", cd[p+28:p+34])
    off, = struct.unpack("<I", cd[p+42:p+46])
    name = cd[p+46:p+46+nl].decode()
    extra = cd[p+46+nl:p+46+nl+el]
    q = 0
    while q < len(extra):
        hid, hl = struct.unpack("<HH", extra[q:q+4])
        if hid == 1:
            vals = list(struct.unpack("<%dQ" % (hl // 8), extra[q+4:q+4+hl]))
            if usize == 0xFFFFFFFF: usize = vals.pop(0)
            if csize == 0xFFFFFFFF: csize = vals.pop(0)
            if off == 0xFFFFFFFF: off = vals.pop(0)
        q += 4 + hl
    p += 46 + nl + el + cl
    base = name.split("/")[-1]
    if base in want or name.endswith("version.txt"):
        h = rng(off, off + 29)
        fnl, fel = struct.unpack("<HH", h[26:30])
        data = rng(off + 30 + fnl + fel, off + 30 + fnl + fel + csize - 1)
        if meth == 8: data = zlib.decompress(data, -15)
        open(out_dir + "/" + base, "wb").write(data)
        print("ok", name, len(data))
