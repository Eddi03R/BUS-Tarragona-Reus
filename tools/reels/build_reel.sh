#!/usr/bin/env bash
# Genera i reel (it + en) dal sito: build web -> registrazione -> montaggio.
# Richiede: flutter, node + playwright, ffmpeg, python3.
set -euo pipefail
cd "$(dirname "$0")"
ROOT="$(cd ../.. && pwd)"
( cd "$ROOT" && flutter build web --release --no-web-resources-cdn --dart-define=SKIP_FIREBASE=true )
( cd "$ROOT/build/web" && python3 -m http.server 8099 >/dev/null 2>&1 & echo $! > /tmp/reel_server.pid )
sleep 1
for L in it en; do rm -rf "rec_$L"; node record.js "$L" "rec_$L"; done
kill "$(cat /tmp/reel_server.pid)" || true
# compose.py cerca raw.mp4 in rec_<lingua>: lo ricava dai fotogrammi registrati
python3 - <<'PY'
import json, subprocess
for L in ('it','en'):
    d = json.load(open(f'rec_{L}/marks.json')); fr = d['frames']; t0 = d['t0']
    ready = t0 + d['marks']['ready']; end = t0 + d['marks']['end'] + 0.8
    sel = [f for f in fr if ready <= f['t'] <= end]
    lines = []
    for i, f in enumerate(sel):
        dur = (sel[i+1]['t'] - f['t']) if i + 1 < len(sel) else 0.5
        lines.append(f"file '{f['name']}'\nduration {max(dur, 0.001):.4f}")
    lines.append(f"file '{sel[-1]['name']}'")
    open(f'rec_{L}/list.txt', 'w').write('\n'.join(lines))
    subprocess.run(['ffmpeg','-v','error','-y','-f','concat','-safe','0','-i',f'rec_{L}/list.txt','-vf','fps=30,format=yuv420p','-c:v','libx264','-crf','17',f'rec_{L}/raw.mp4'], check=True)
PY
python3 compose.py
echo "Fatto: reel_it.mp4 e reel_en.mp4 in $(pwd)"
