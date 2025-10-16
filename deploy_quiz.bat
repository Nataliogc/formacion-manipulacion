@echo off
REM =============================================================
REM  deploy_quiz.bat - Subida automática del cuestionario al repo
REM  Requisitos: Git instalado y repo remoto ya creado en GitHub.
REM  Uso (primera vez):
REM     1) Edita las variables REPO_URL, BRANCH y COMMIT_MSG.
REM     2) Coloca este .bat en la carpeta del proyecto (donde está index.html).
REM     3) Doble clic para subir.
REM =============================================================

REM ---------- CONFIGURACIÓN ----------
set "REPO_URL=https://github.com/Nataliogc/formacion-manipulacion.git"
set "BRANCH=main"
set "COMMIT_MSG=deploy: cuestionario manipulacion + assets"

REM (Opcional) Config git user si no lo has hecho globalmente:
REM git config --global user.name "Tu Nombre"
REM git config --global user.email "tu.email@dominio.com"

REM ---------- COMPROBACIONES ----------
where git >nul 2>nul
if errorlevel 1 (
  echo [ERROR] Git no esta instalado o no esta en PATH.
  echo Descarga: https://git-scm.com/downloads
  pause
  exit /b 1
)

if not exist "index.html" (
  echo [ERROR] No se encuentra index.html en la carpeta actual:
  cd
  pause
  exit /b 1
)

REM ---------- INIT / REMOTE ----------
if not exist ".git" (
  echo [INFO] Inicializando repositorio...
  git init
  git checkout -b %BRANCH%
)

REM Si no existe remote origin, lo creamos
git remote get-url origin >nul 2>nul
if errorlevel 1 (
  if "%REPO_URL%"=="https://github.com/USER/REPO.git" (
    echo [ERROR] Debes editar REPO_URL con tu repo real, por ejemplo:
    echo        https://github.com/Nataliogc/formacion-manipulacion.git
    pause
    exit /b 1
  )
  echo [INFO] Configurando remote origin...
  git remote add origin %REPO_URL%
)

REM ---------- COMMITEAR Y PUBLICAR ----------
echo [INFO] Añadiendo cambios...
git add -A

echo [INFO] Haciendo commit...
git commit -m "%COMMIT_MSG%" 2>nul
if errorlevel 1 (
  echo [INFO] No hay cambios nuevos que commitear o commit previo ya existe.
)

echo [INFO] Subiendo a %BRANCH%...
git push -u origin %BRANCH%
if errorlevel 1 (
  echo [ERROR] Fallo al hacer push. Comprueba permisos (PAT/SSH) y conectividad.
  pause
  exit /b 1
)

echo.
echo [OK] Publicado en GitHub. Si tienes GitHub Pages por Actions,
echo      se desplegara automaticamente segun .github/workflows/deploy-pages.yml
echo.
echo URL de tu repo:
git remote get-url origin

echo.
echo Recuerda editar en index.html la ENDPOINT_URL de tu Cloudflare Worker.
echo.
pause
