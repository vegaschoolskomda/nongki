@echo off
echo ============================================
echo   NONGKI - Build dan Deploy ke Android
echo ============================================
echo.

set FLUTTER=C:\Users\Lenovo\develop\flutter\bin\flutter.bat
set ADB=C:\Users\Lenovo\AppData\Local\Android\Sdk\platform-tools\adb.exe
set APK=build\app\outputs\flutter-apk\app-debug.apk
set DEVICE=RRCXC04723D
set PKG=com.example.nongki

echo [1/4] Memeriksa kode...
call %FLUTTER% analyze --no-pub
if %errorlevel% neq 0 (
    echo.
    echo [ERROR] Ada masalah di kode. Perbaiki dulu sebelum build.
    pause
    exit /b 1
)
echo [OK] Kode bersih!
echo.

echo [2/4] Build APK Debug...
call %FLUTTER% build apk --debug --target-platform android-arm64
if %errorlevel% neq 0 (
    echo.
    echo [ERROR] Build gagal.
    pause
    exit /b 1
)
echo [OK] Build selesai!
echo.

echo [3/4] Uninstall APK lama...
%ADB% -s %DEVICE% uninstall %PKG% 2>nul
echo [OK] Uninstall selesai (atau belum terinstall sebelumnya).
echo.

echo [4/4] Install APK baru...
%ADB% -s %DEVICE% install %APK%
if %errorlevel% neq 0 (
    echo.
    echo [ERROR] Install gagal. Pastikan HP terhubung dan USB debugging aktif.
    pause
    exit /b 1
)
echo.
echo ============================================
echo   [SUKSES] NONGKI berhasil diinstall!
echo   Buka aplikasi NONGKI di HP kamu.
echo ============================================
pause
