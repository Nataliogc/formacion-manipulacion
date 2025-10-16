# Formación Manipulación de Alimentos – Kit completo

Este paquete contiene el cuestionario interactivo con 3 bloques (25 preguntas por bloque), ranking local, resumen de errores, recomendaciones y envío de resultados a GitHub mediante un Cloudflare Worker.

## Contenido
```
index.html
img/
  ├─ guadiana-logo.jpg
  └─ cumbria-logo.jpg
.github/
  └─ workflows/
     └─ deploy-pages.yml
cloudflare-worker-github.js
deploy_quiz.bat
data/
  └─ .keep
```

## 1) Publicar en GitHub Pages
1. Crea el repositorio en GitHub (ej. `Nataliogc/formacion-manipulacion`).
2. Sube todos los archivos de este paquete.
3. Activa **GitHub Pages** con **GitHub Actions** (el workflow `deploy-pages.yml` ya está incluido).

## 2) Subida automática desde Windows
1. Edita `deploy_quiz.bat` y pon tu URL de repo:
   ```bat
   set "REPO_URL=https://github.com/Nataliogc/formacion-manipulacion.git"
   ```
2. Ejecuta `deploy_quiz.bat`. La primera vez hará `git init`, añadirá el remoto y subirá a `main`.

## 3) Guardar resultados en GitHub (Cloudflare Worker)
1. Ve a Cloudflare → Workers → Crear Worker → pega el código de `cloudflare-worker-github.js`.
2. Añade variables/secretos en el Worker:
   - `GITHUB_TOKEN` → PAT con **contents:write** al repo.
   - `REPO_OWNER` → `Nataliogc`
   - `REPO_NAME` → `formacion-manipulacion`
   - `BRANCH` → `main`
   - `BASE_PATH` → `data/submissions`
3. Publica el Worker y copia la URL (ej.: `https://<tu-worker>.workers.dev/submit`).
4. En `index.html`, busca `ENDPOINT_URL` y sustitúyelo por la URL del Worker.
5. Listo: cada guardado en el ranking también enviará un JSON al Worker, que lo **commiteará** en `data/submissions/YYYYMMDD/*.json` del repo.

## 4) Opcional
- Si quieres ranking **compartido** entre varios equipos sin depender del navegador, podemos cambiar el ranking local a uno centralizado en el repo.
- Si quieres imprimir el resumen con tu cabecera/pie de Blogger, puedo añadir estilos `@media print` y tu cabecera estándar.

---

**Nota RGPD interna:** si recoges nombres de personas, confirma el uso interno y la conservación en el repositorio.
