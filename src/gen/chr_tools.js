// Helpers shared by src/gen/extract_chr.s and src/gen/gen_chr_map.s.
// The SPR/BG/FLIP_*/SHIFT_* constants come from chr/chr_map.js (or the generator).

// CRC32 of the 8KB CHR in Super Mario Bros. (World)
const SMB1_CHR_CRC32 = 0x867b51ad;

function crc32(bytes) {
  let crc = ~0;
  for (const b of bytes) {
    crc ^= b;
    for (let k = 0; k < 8; k++) crc = (crc >>> 1) ^ (0xedb88320 & -(crc & 1));
  }
  return ~crc >>> 0;
}

// Returns the 8KB CHR from the first file that is an unmodified SMB1 ROM, or undefined.
function findSmb1Chr(files) {
  for (const f of files) {
    const b = f.bytes;
    // iNES header, 2x16KB PRG, 1x8KB CHR
    if (b.length < 16 + 0x8000 + 0x2000 || b[0] !== 0x4e || b[1] !== 0x45 || b[2] !== 0x53
        || b[3] !== 0x1a || b[4] !== 2 || b[5] !== 1) continue;
    const chr = b.subarray(16 + 0x8000, 16 + 0x8000 + 0x2000);
    if (crc32(chr) === SMB1_CHR_CRC32) return chr;
  }
  return undefined;
}

function flipH(b) {
  let r = 0;
  for (let i = 0; i < 8; i++) r |= ((b >> i) & 1) << (7 - i);
  return r;
}

// Returns the 16 bytes for one CHR_MAP entry
function buildTile(romChr, e) {
  const tile = new Uint8Array(16);
  if (Array.isArray(e)) {
    tile.set(e);
    return tile;
  }
  const id = e & (BG | 0xff);
  const src = romChr.subarray(id * 16, id * 16 + 16);
  for (let i = 0; i < 16; i++) {
    // V flip reverses the row order within each 8 byte bitplane
    const row = (e & FLIP_V) ? (i & 8) | (7 - (i & 7)) : i;
    tile[i] = (e & FLIP_H) ? flipH(src[row]) : src[row];
  }
  if (e & SHIFT_DOWN4) tile.set([0,0,0,0, ...tile.slice(0, 4), 0,0,0,0, ...tile.slice(8, 12)]);
  if (e & SHIFT_UP4) tile.set([...tile.slice(4, 8), 0,0,0,0, ...tile.slice(12, 16), 0,0,0,0]);
  return tile;
}
