@echo off
setlocal

REM Configuracion PostgreSQL (servidor RRHH)
set "DB_MODE=postgres"
set "DB_HOST=192.168.108.200"
set "DB_PORT=5432"
set "DB_NAME=rrhh"
set "DB_USER=rrhh_app"
set "DB_PASSWORD=rrhh2026"
set "DB_SSL_MODE=disable"
set "DB_LOG_STATEMENTS=true"

echo Iniciando RRHH App con PostgreSQL en %DB_HOST%:%DB_PORT% ...
flutter run -d windows

endlocal
