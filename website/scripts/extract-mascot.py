"""将应用已有的透明 HEIC 帧转换成浏览器可使用的 WebP 图集。

仅重新生成素材时需要 Pillow 和 pillow-heif，网站构建不依赖 Python。
"""

import json
from math import ceil
from pathlib import Path

from PIL import Image
import pillow_heif

pillow_heif.register_heif_opener()

WEBSITE = Path(__file__).resolve().parents[1]
SOURCE = WEBSITE.parent / 'MouseSpell' / 'Mascot'
OUTPUT = WEBSITE / 'static' / 'mascot'
FRAME_HEIGHT = 320
COLUMNS = 16
FPS = 24
OUTPUT.mkdir(parents=True, exist_ok=True)

metadata = {'fps': FPS, 'columns': COLUMNS}
frame_size = None

for name, original in [('mood', 'MascotA.heic'), ('jump', 'MascotB.heic')]:
    with Image.open(SOURCE / original) as sequence:
        width = round(sequence.width * FRAME_HEIGHT / sequence.height)
        size = (width, FRAME_HEIGHT)
        if frame_size is not None and frame_size != size:
            raise ValueError('两组动画必须使用相同画布，以保留原有的位置对齐。')
        frame_size = size
        atlas = Image.new('RGBA', (COLUMNS * width, ceil(sequence.n_frames / COLUMNS) * FRAME_HEIGHT))
        for index in range(sequence.n_frames):
            sequence.seek(index)
            # 保留应用已经处理好的透明度、公共画布与角色脚部位置。
            frame = sequence.convert('RGBA').resize(size, Image.Resampling.LANCZOS)
            atlas.paste(frame, ((index % COLUMNS) * width, (index // COLUMNS) * FRAME_HEIGHT))
            if name == 'mood' and index == sequence.n_frames - 1:
                frame.save(OUTPUT / 'happy.webp', quality=88, method=6)
        atlas.save(OUTPUT / f'{name}.webp', quality=82, method=6)
        metadata[name] = sequence.n_frames
        print(f'{original}: {sequence.n_frames} frames -> {name}.webp ({atlas.width}x{atlas.height})')

metadata['width'], metadata['height'] = frame_size
module = WEBSITE / 'src' / 'lib' / 'mascotFrames.ts'
module.write_text(
    '// 由 scripts/extract-mascot.py 从应用素材生成，帧顺序和播放速度与原应用一致。\n'
    f'export const MASCOT_FRAMES = {json.dumps(metadata, indent=2)};\n',
    encoding='utf-8'
)
print(f'Generated sprites: {sum(path.stat().st_size for path in OUTPUT.glob("*.webp")) / 1024:.0f} KiB')
