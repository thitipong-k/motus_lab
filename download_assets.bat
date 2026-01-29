@echo off
if not exist "web" mkdir web
echo Downloading sqlite3.wasm...
curl -L -o web/sqlite3.wasm "https://github.com/simolus3/sqlite3.dart/releases/download/sqlite3-2.3.0/sqlite3.wasm"
echo Downloading drift_worker.js...
curl -L -o web/drift_worker.js "https://github.com/simolus3/drift/releases/latest/download/drift_worker.js"
echo Done.
