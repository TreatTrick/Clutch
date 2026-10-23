#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEVELOPER_DIR="${DEVELOPER_DIR:-/Applications/Xcode.app/Contents/Developer}"
export DEVELOPER_DIR
cd "$ROOT_DIR"

VERSION="$(xcodebuild -project MouseSpell.xcodeproj -scheme MouseSpell -configuration Release -showBuildSettings | awk -F ' = ' '$1 ~ /^[[:space:]]*MARKETING_VERSION$/ && !found { print $2; found = 1 }')"
if [[ -z "$VERSION" ]]; then
	echo "Could not read MARKETING_VERSION from the MouseSpell Release configuration." >&2
	exit 1
fi

OUTPUT_DIR="$ROOT_DIR/.build/mousespell/release-v$VERSION"
ARCHIVE_PATH="$OUTPUT_DIR/MouseSpell.xcarchive"
UPLOAD_PATH="$OUTPUT_DIR/notarization-upload"
NOTARIZED_PATH="$OUTPUT_DIR/notarized"
APP_PATH="$NOTARIZED_PATH/MouseSpell.app"
DMG_PATH="$OUTPUT_DIR/MouseSpell-v$VERSION-universal.dmg"
PYTHON_ENV="$ROOT_DIR/.build/mousespell/venv"

for path in "$ARCHIVE_PATH" "$UPLOAD_PATH" "$NOTARIZED_PATH" "$DMG_PATH"; do
	if [[ -e "$path" ]]; then
		echo "Refusing to overwrite existing output: $path" >&2
		exit 1
	fi
done

mkdir -p "$OUTPUT_DIR"
if [[ ! -x "$PYTHON_ENV/bin/python" ]]; then
	python3 -m venv "$PYTHON_ENV"
fi
if ! "$PYTHON_ENV/bin/python" -c 'import dmgbuild' >/dev/null 2>&1; then
	"$PYTHON_ENV/bin/python" -m pip install 'dmgbuild==1.6.5'
fi

xcodebuild \
	-project MouseSpell.xcodeproj \
	-scheme MouseSpell \
	-configuration Release \
	-destination 'generic/platform=macOS' \
	-archivePath "$ARCHIVE_PATH" \
	archive \
	-allowProvisioningUpdates

xcodebuild \
	-exportArchive \
	-archivePath "$ARCHIVE_PATH" \
	-exportPath "$UPLOAD_PATH" \
	-exportOptionsPlist scripts/notarize_options_developer_id.plist \
	-allowProvisioningUpdates

xcodebuild \
	-exportNotarizedApp \
	-archivePath "$ARCHIVE_PATH" \
	-exportPath "$NOTARIZED_PATH"

xcrun stapler staple "$APP_PATH"
xcrun stapler validate "$APP_PATH"
codesign --verify --deep --strict "$APP_PATH"
spctl --assess --type execute --verbose=4 "$APP_PATH"

APP_VERSION="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$APP_PATH/Contents/Info.plist")"
if [[ "$APP_VERSION" != "$VERSION" ]]; then
	echo "Expected app version $VERSION but found $APP_VERSION." >&2
	exit 1
fi

"$PYTHON_ENV/bin/python" scripts/package_dmg.py "$APP_PATH" "$DMG_PATH"
echo "Created $DMG_PATH"
