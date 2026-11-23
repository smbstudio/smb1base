#!/usr/bin/env sh

OPTION_LINE_MATCH='^[\s]*[^#\[;]*=.*$'
while IFS= read -r line; do
  ! [[ $line =~ $OPTION_LINE_MATCH ]] && continue
  options="${options} --asm-define ${line} -D ${line}"
  # echo "line: ${line}"
done < build_options.ini

# echo "options: ${options} "

cl65 \
  --cpu 6502x -t nes  -g -Oisr -vm -T \
  -C smb1base.cfg \
  --ld-args --dbgfile,build/smb1base.dbg \
  --include-dir . \
  --asm-include-dir . \
  --bin-include-dir . \
  -l build/smb1base.lst \
  -m build/smb1base.map \
  -o build/smb1base.nes \
  ${options} \
   ./src/main.c ./src/entrypoint.s || exit 1

# Copy the custom audio driver over each AUDIODRV_COPYn marker so every DPCM bank has the same driver.
# See the PRGC memory areas in smb1base.cfg. ROM offsets (ooffs) come from the ld65 debug file.
awk '/^seg\t/ {
  name = size = ooffs = ""
  n = split($0, f, ",")
  for (i = 1; i <= n; i++) {
    eq = index(f[i], "=")
    k = substr(f[i], 1, eq - 1); v = substr(f[i], eq + 1)
    sub(/^seg\t/, "", k); gsub(/"/, "", v)
    if (k == "name") name = v; else if (k == "size") size = v; else if (k == "ooffs") ooffs = v
  }
  if (name == "AUDIODRV") { src = ooffs; len = size }
  else if (name ~ /^AUDIODRV_COPY[0-9]+$/) dst[++nd] = ooffs
}
END { if (src != "") for (i = 1; i <= nd; i++) print src, len, dst[i] }' build/smb1base.dbg |
while read -r src len dst; do
  dd if=build/smb1base.nes of=build/smb1base.nes bs=1 skip=$src seek=$dst count=$((len)) conv=notrunc 2>/dev/null
done

# cl65 \
#   --cpu 6502x -t none --no-target-lib -g -Oisr -v -vm -T \
#   -C smb1base.cfg \
#   --ld-args --dbgfile,build/smb1base.dbg \
#   -l build/smb1base.lst \
#   -m build/smb1base.map \
#   -o build/smb1base.nes \
#   ./entrypoint.s