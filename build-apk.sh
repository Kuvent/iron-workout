#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
TOOLS="${IRON_TOOLS:-$PWD/.toolchain}"
mkdir -p "$TOOLS" build/classes build/generated dist
fetch() { if [ ! -s "$2" ]; then curl -fL --connect-timeout 20 --max-time 300 --retry 2 "$1" -o "$2.tmp"; mv "$2.tmp" "$2"; fi; }
fetch https://dl.google.com/android/repository/build-tools_r35_linux.zip "$TOOLS/build-tools.zip"
fetch https://dl.google.com/android/repository/platform-35_r02.zip "$TOOLS/platform.zip"
fetch https://repo.maven.apache.org/maven2/org/eclipse/jdt/ecj/3.40.0/ecj-3.40.0.jar "$TOOLS/ecj.jar"
if [ ! -d "$TOOLS/android-15" ]; then unzip -q -o "$TOOLS/build-tools.zip" -d "$TOOLS"; fi
if [ ! -d "$TOOLS/android-35" ]; then unzip -q -o "$TOOLS/platform.zip" -d "$TOOLS"; fi
BT="$TOOLS/android-15"
ANDROID_JAR="$TOOLS/android-35/android.jar"
"$BT/aapt2" compile --dir app/src/main/res -o build/resources.zip
python3 - <<'PYMANIFEST'
from pathlib import Path
text = Path('app/src/main/AndroidManifest.xml').read_text()
Path('build/AndroidManifest.xml').write_text(text.replace('<manifest ', '<manifest package="com.iron.workout" ', 1))
PYMANIFEST
"$BT/aapt2" link -o build/base.apk -I "$ANDROID_JAR" --manifest build/AndroidManifest.xml --java build/generated -A app/src/main/assets build/resources.zip
java -jar "$TOOLS/ecj.jar" -source 1.8 -target 1.8 -classpath "$ANDROID_JAR" -d build/classes app/src/main/java/com/iron/workout/MainActivity.java
mapfile -t CLASSES < <(find build/classes -name '*.class')
"$BT/d8" --lib "$ANDROID_JAR" --min-api 26 --output build "${CLASSES[@]}"
python3 - <<'PY'
import zipfile,shutil
shutil.copyfile('build/base.apk','build/unsigned.apk')
with zipfile.ZipFile('build/unsigned.apk','a',zipfile.ZIP_DEFLATED) as z:z.write('build/classes.dex','classes.dex')
PY
"$BT/zipalign" -f 4 build/unsigned.apk build/aligned.apk
if [ ! -f "$TOOLS/iron-local.jks" ]; then keytool -genkeypair -keystore "$TOOLS/iron-local.jks" -alias iron -keyalg RSA -keysize 2048 -validity 10000 -storepass android -keypass android -dname 'CN=Iron Local Build,O=Personal,C=US'; fi
"$BT/apksigner" sign --ks "$TOOLS/iron-local.jks" --ks-key-alias iron --ks-pass pass:android --key-pass pass:android --out dist/Iron-1.0.apk build/aligned.apk
"$BT/apksigner" verify --verbose dist/Iron-1.0.apk
"$BT/aapt2" dump badging dist/Iron-1.0.apk
sha256sum dist/Iron-1.0.apk
