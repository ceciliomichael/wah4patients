@echo off
setlocal

set "ROOT_DIR=%~dp0"

start "WAH4P Backend" /D "%ROOT_DIR%backend" cmd /k npm run start:dev
start "WAH4P Frontend" /D "%ROOT_DIR%frontend" cmd /k flutter run -d chrome --web-port 3046

endlocal
