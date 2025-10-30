#!/bin/zsh

set -euo pipefail
cd "$(dirname "$0")"

DERIVED="$(pwd)/derived"
mkdir -p "$DERIVED"

swiftformat --swiftversion 6.0 . --indent 4

CMD=(xcodebuild \
    -workspace Example/*.xcworkspace \
    -scheme "ConfigurableExample" \
    -configuration Release \
    -destination "generic/platform=iOS" \
    -derivedDataPath "$DERIVED" \
    clean build \
    CODE_SIGN_IDENTITY="" CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO)

if command -v xcbeautify >/dev/null 2>&1; then
    "${CMD[@]}" | xcbeautify -q --is-ci --disable-colored-output --disable-logging
else
    echo "xcbeautify not found; showing raw xcodebuild output" >&2
    "${CMD[@]}"
fi
