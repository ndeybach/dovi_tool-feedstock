@echo on
setlocal

cd /D %SRC_DIR%\libdovi_src\dolby_vision
if errorlevel 1 exit /b 1

if not defined CARGO_BUILD_TARGET if defined RUST_TARGET set "CARGO_BUILD_TARGET=%RUST_TARGET%"

cargo-bundle-licenses --format yaml --output "%SRC_DIR%\THIRDPARTY_libdovi.yml"
if errorlevel 1 exit /b 1

rem cargo-c does not reliably infer the cross target from env alone.
set "TARGET_ARG="
if defined CARGO_BUILD_TARGET set "TARGET_ARG=--target %CARGO_BUILD_TARGET%"

cargo cinstall --locked --release %TARGET_ARG% --prefix "%LIBRARY_PREFIX%" --libdir "%LIBRARY_LIB%" --includedir "%LIBRARY_INC%"
if errorlevel 1 exit /b 1

if exist "%LIBRARY_LIB%\dovi.lib" del /F /Q "%LIBRARY_LIB%\dovi.lib"
