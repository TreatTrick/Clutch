#!/usr/bin/env python3
"""Package a built Universal MouseSpell.app with a drag-to-install window and offline guide.

Install the packaging dependency with: python3 -m pip install dmgbuild==1.6.5
Usage: python3 scripts/package_dmg.py /path/to/MouseSpell.app /path/to/MouseSpell.dmg
"""

import argparse
import base64
from pathlib import Path
import re
import subprocess
import tempfile

import dmgbuild


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("app", type=Path)
    parser.add_argument("output", type=Path)
    args = parser.parse_args()
    app = args.app.resolve()
    output = args.output.resolve()
    root = Path(__file__).resolve().parent.parent

    if app.name != "MouseSpell.app" or not app.is_dir():
        parser.error("app must point to a built MouseSpell.app")
    if output.suffix != ".dmg" or output.exists():
        parser.error("output must be a new .dmg file")
    architectures = subprocess.check_output(
        ["/usr/bin/lipo", "-archs", str(app / "Contents/MacOS/MouseSpell")], text=True
    ).split()
    if set(architectures) != {"arm64", "x86_64"}:
        parser.error("MouseSpell.app must contain arm64 and x86_64")
    subprocess.run(
        ["/usr/bin/codesign", "--verify", "--deep", "--strict", str(app)], check=True
    )
    signature = subprocess.run(
        ["/usr/bin/codesign", "--display", "--verbose=4", str(app)],
        check=True,
        capture_output=True,
        text=True,
    ).stderr
    if "Authority=Developer ID Application:" not in signature or (
        "TeamIdentifier=6JG2G82DRK" not in signature
    ):
        parser.error("app must be signed with this team's Developer ID Application certificate")
    subprocess.run(
        ["/usr/bin/xcrun", "stapler", "validate", str(app)], check=True
    )
    subprocess.run(
        ["/usr/sbin/spctl", "--assess", "--type", "execute", str(app)], check=True
    )
    output.parent.mkdir(parents=True, exist_ok=True)

    # Embed screenshots so the guide remains a single file when copied off the DMG.
    guide = root / "docs/installation.html"

    def embed_image(match):
        data = (guide.parent / match.group(1)).read_bytes()
        return 'src="data:image/png;base64,' + base64.b64encode(data).decode("ascii") + '"'

    html = re.sub(r'src="(assets/[^\"]+\.png)"', embed_image, guide.read_text())
    with tempfile.TemporaryDirectory(prefix="mousespell-dmg-") as staging:
        install = Path(staging) / "INSTALL.html"
        install.write_text(html)
        dmgbuild.build_dmg(
            str(output),
            "MouseSpell",
            settings={
                "format": "UDZO",
                "compression_level": 9,
                "filesystem": "HFS+",
                "size": "64M",
                "files": [str(app), str(install), str(root / "LICENSE")],
                "symlinks": {"Applications": "/Applications"},
                "background": "builtin-arrow",
                "icon": str(app / "Contents/Resources/AppIcon.icns"),
                "window_rect": ((150, 150), (640, 420)),
                "default_view": "icon-view",
                "icon_size": 96,
                "text_size": 14,
                "icon_locations": {
                    "MouseSpell.app": (170, 115),
                    "Applications": (470, 115),
                    "INSTALL.html": (170, 315),
                    "LICENSE": (470, 315),
                },
            },
        )
    print(output)


if __name__ == "__main__":
    main()
