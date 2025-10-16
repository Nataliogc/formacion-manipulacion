@echo off
setlocal ENABLEDELAYEDEXPANSION
REM =============================================================
REM  deploy_quiz_interactivo.bat
REM  - Pide REPO_URL si no está configurada
REM  - Configura remote origin (set-url si ya existe)
REM  - Hace commit/push a main
REM =============================================================

REM ---------- CONFIGURACION ----------
set "REPO_URL=https://github.com/USER/REPO.git"
set "BRANCH=main"
set "COMMIT_MSG=deploy: cuestionario manipulacion + assets"

where git >nul 2>nul
if errorlevel 1 (
  echo [ERROR] Git no esta instalado o no esta en PATH.
  echo Descarga: https://git-scm.com/downloads
  pause
  exit /b 1
)

if not exist "index.html" (
  echo [ERROR] No se encuentra index.html en la carpeta:
  cd
  pause
  exit /b 1
)

REM ---------- Pedir URL si es placeholder ----------
if "%REPO_URL%"=="https://github.com/USER/REPO.git" (
  set /p REPO_URL=Escribe la URL del repo (HTTPS o SSH): 
)

REM ---------- INIT / BRANCH ----------
if not exist ".git" (
  echo [INFO] Inicializando repositorio local...
  git init
)

for /f "tokens=*" %%b in ('git rev-parse --abbrev-ref HEAD 2^>nul') do set CURBR=%%b
if not "%CURBR%"=="%BRANCH%" (
  git checkout -B %BRANCH%
)

REM ---------- Remote origin ----------
for /f "tokens=*" %%r in ('git remote 2^>nul') do set HASREMOTE=%%r
if not defined HASREMOTE (
  echo [INFO] Configurando remote origin...
  git remote add origin %REPO_URL% 2>nul
) else (
  echo [INFO] Actualizando remote origin...
  git remote set-url origin %REPO_URL%
)

echo [INFO] Añadiendo cambios...
git add -A

echo [INFO] Haciendo commit...
git commit -m "%COMMIT_MSG%" 2>nul
if errorlevel 1 (
  echo [INFO] No hay cambios nuevos o commit previo ya existe.
)

echo [INFO] Subiendo a %BRANCH%...
git push -u origin %BRANCH%
if errorlevel 1 (
  echo [ERROR] Fallo al hacer push. Comprueba credenciales (PAT/SSH) y permisos sobre el repo.
  echo        Si usas HTTPS, autentica con usuario + token personal (PAT).
  pause
  exit /b 1
)

echo.
echo [OK] Publicado en GitHub.
git remote get-url origin
echo.
echo Si tienes el workflow de Pages (.github/workflows/deploy-pages.yml), se desplegara automaticamente.
echo.
pause
