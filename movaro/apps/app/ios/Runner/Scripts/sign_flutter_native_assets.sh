#!/bin/sh

set -e

# Flutter native assets are copied after Xcode's normal "Embed Frameworks"
# phase. With recent Xcode betas they can keep an ad-hoc signature (and, for
# device builds, a simulator slice), which makes installd reject the app.
FRAMEWORKS_DIR="${TARGET_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"

if [ ! -d "${FRAMEWORKS_DIR}" ]; then
  exit 0
fi

for FRAMEWORK in "${FRAMEWORKS_DIR}"/*.framework; do
  [ -d "${FRAMEWORK}" ] || continue

  EXECUTABLE_NAME=$(/usr/libexec/PlistBuddy \
    -c "Print :CFBundleExecutable" \
    "${FRAMEWORK}/Info.plist" 2>/dev/null || true)
  EXECUTABLE="${FRAMEWORK}/${EXECUTABLE_NAME}"

  [ -f "${EXECUTABLE}" ] || continue

  if [ "${PLATFORM_NAME}" = "iphoneos" ]; then
    ARCHITECTURES=$(xcrun lipo -archs "${EXECUTABLE}")
    case " ${ARCHITECTURES} " in
      *" x86_64 "*)
        THIN_EXECUTABLE="${TARGET_TEMP_DIR}/${EXECUTABLE_NAME}.device"
        xcrun lipo "${EXECUTABLE}" -remove x86_64 -output "${THIN_EXECUTABLE}"
        cp "${THIN_EXECUTABLE}" "${EXECUTABLE}"
        ;;
    esac
  fi

  xattr -cr "${FRAMEWORK}"

  if [ "${CODE_SIGNING_ALLOWED}" = "YES" ]; then
    SIGNING_IDENTITY="${EXPANDED_CODE_SIGN_IDENTITY:--}"
    /usr/bin/codesign \
      --force \
      --sign "${SIGNING_IDENTITY}" \
      --timestamp=none \
      --preserve-metadata=identifier \
      "${FRAMEWORK}"
  fi
done

