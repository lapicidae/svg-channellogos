#!/bin/bash

# ==============================================================================
# Generate an SVG logo gallery for GitHub Pages.
# ==============================================================================

set -euo pipefail

# ------------------------------------------------------------------------------
# Configuration
# ------------------------------------------------------------------------------
OUTPUT_DIR="public"
LIGHT_DIR="light"
DARK_DIR="dark"
REPO_LOGO="svg-channellogos-logo.svg"
REPO_NAME="SVG ChannelLogos"
REPO_URL="https://github.com/lapicidae/svg-channellogos"

# ------------------------------------------------------------------------------
# Functions
# ------------------------------------------------------------------------------

err() {
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $*" >&2
}

prepare_assets() {
  if [[ ! -d "${LIGHT_DIR}" ]]; then
    err "Error: Directory '${LIGHT_DIR}' not found."
    exit 1
  fi

  rm -rf "${OUTPUT_DIR}"
  mkdir -p "${OUTPUT_DIR}"

  cp -r "${LIGHT_DIR}" "${OUTPUT_DIR}/"
  [[ -d "${DARK_DIR}" ]] && cp -r "${DARK_DIR}" "${OUTPUT_DIR}/"
  [[ -f "${REPO_LOGO}" ]] && cp "${REPO_LOGO}" "${OUTPUT_DIR}/"
}

generate_html_head() {
  cat << EOF > "${OUTPUT_DIR}/index.html"
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>${REPO_NAME} | Logo Gallery</title>
  <link rel="icon" type="image/svg+xml" href="${REPO_LOGO}">
  <style>
    :root {
      --bg-color: #0f172a;
      --text-color: #f8fafc;
      --card-bg: #1e293b;
      --border-color: #334155;
      --accent-color: #38bdf8;
      --header-bg: rgba(15, 23, 42, 0.9);
      --overlay-bg: rgba(0, 0, 0, 0.85);
    }
    [data-theme="light"] {
      --bg-color: #f8fafc;
      --text-color: #0f172a;
      --card-bg: #ffffff;
      --border-color: #e2e8f0;
      --accent-color: #0284c7;
      --header-bg: rgba(248, 250, 252, 0.9);
      --overlay-bg: rgba(255, 255, 255, 0.9);
    }
    
    * { box-sizing: border-box; }
    body { 
      background-color: var(--bg-color); 
      color: var(--text-color); 
      font-family: 'Inter', system-ui, sans-serif; 
      margin: 0; 
      transition: background-color 0.3s ease;
    }

    /* Accessibility: Focus States */
    :focus-visible {
      outline: 3px solid var(--accent-color);
      outline-offset: 4px;
    }

    header {
      position: sticky; top: 0; z-index: 100;
      background: var(--header-bg); backdrop-filter: blur(8px);
      border-bottom: 1px solid var(--border-color);
      padding: 1rem 2rem;
    }

    .header-container {
      max-width: 1200px; margin: 0 auto;
      display: flex; justify-content: space-between; align-items: center; gap: 1rem;
    }

    .brand { display: flex; align-items: center; gap: 1rem; text-decoration: none; color: inherit; }
    .brand img { width: 40px; height: 40px; }
    .brand h1 { margin: 0; font-size: 1.2rem; }

    .controls { display: flex; gap: 1rem; align-items: center; justify-content: flex-end; }
    
    input[type="search"], button#theme-toggle {
      height: 40px; padding: 0 1rem; border-radius: 99px;
      font-family: inherit; font-size: 0.9rem;
    }

    input[type="search"] {
      border: 1px solid var(--border-color);
      background: var(--card-bg); color: var(--text-color);
      width: 100%; max-width: 250px;
    }

    button#theme-toggle {
      background: var(--text-color); color: var(--bg-color);
      border: none; cursor: pointer; font-weight: 600; white-space: nowrap;
    }

    .github-link {
      display: flex; align-items: center; justify-content: center;
      color: var(--text-color); transition: opacity 0.2s;
      width: 40px; height: 40px; text-decoration: none;
    }
    .github-link:hover { opacity: 0.7; }

    main { max-width: 1200px; margin: 2rem auto; padding: 0 2rem; min-height: 80vh; }
    
    .intro { margin-bottom: 3rem; text-align: center; }
    .intro p { opacity: 0.7; max-width: 700px; margin: 1rem auto; line-height: 1.6; }

    .grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(200px, 1fr)); gap: 1.5rem; }

    .card {
      background: var(--card-bg); border: 1px solid var(--border-color);
      border-radius: 12px; padding: 1.5rem; text-align: center;
      transition: transform 0.2s; cursor: zoom-in;
    }
    .card:hover { transform: translateY(-4px); }
    
    .logo-container { height: 80px; display: flex; align-items: center; justify-content: center; margin-bottom: 1rem; }
    .card img { max-width: 100%; max-height: 80px; pointer-events: none; }
    .card p { margin: 0; font-weight: 500; font-size: 0.85rem; overflow: hidden; text-overflow: ellipsis; }

    dialog {
      padding: 0; border: none; border-radius: 12px;
      background: var(--card-bg); color: var(--text-color);
      max-width: 90vw; max-height: 90vh;
      box-shadow: 0 25px 50px -12px rgba(0,0,0,0.5);
    }
    dialog::backdrop { background: var(--overlay-bg); backdrop-filter: blur(4px); }
    .lightbox-content { padding: 3rem; display: flex; flex-direction: column; align-items: center; }
    .lightbox-content img { max-width: 100%; max-height: 60vh; margin-bottom: 1.5rem; }
    .lightbox-close { 
       position: absolute; top: 1rem; right: 1rem; 
       background: none; border: none; color: inherit; font-size: 1.5rem; cursor: pointer; 
    }

    footer { padding: 3rem; text-align: center; opacity: 0.6; font-size: 0.85rem; border-top: 1px solid var(--border-color); margin-top: 4rem; }
    footer a { color: inherit; font-weight: bold; text-decoration: none; border-bottom: 1px dotted var(--text-color); }
    footer a:hover { border-bottom-style: solid; }

    #back-to-top {
      position: fixed; bottom: 2rem; right: 2rem;
      background: var(--accent-color); color: white;
      width: 48px; height: 48px; border-radius: 50%;
      border: none; cursor: pointer; opacity: 0; visibility: hidden; transition: 0.3s;
      display: flex; align-items: center; justify-content: center; font-size: 1.2rem;
    }
    #back-to-top.visible { opacity: 1; visibility: visible; }

    @media (max-width: 600px) {
      .header-container { flex-direction: column; }
      .controls { width: 100%; justify-content: center; }
      input[type="search"] { max-width: none; }
    }
  </style>
</head>
<body data-theme="dark">

  <header>
    <div class="header-container">
      <a href="${REPO_URL}" class="brand" aria-label="${REPO_NAME} Home">
        <img src="${REPO_LOGO}" alt="" aria-hidden="true">
        <h1>${REPO_NAME}</h1>
      </a>
      <div class="controls" role="search">
        <input type="search" id="search-input" 
               placeholder="Search logos..." 
               aria-label="Search channel logos">
        <button id="theme-toggle" aria-live="polite">Light Mode</button>
        <a href="${REPO_URL}" class="github-link" title="View on GitHub" aria-label="GitHub Repository">
          <svg height="28" viewBox="0 0 16 16" width="28" fill="currentColor" aria-hidden="true">
            <path d="M8 0C3.58 0 0 3.58 0 8c0 3.54 2.29 6.53 5.47 7.59.4.07.55-.17.55-.38 0-.19-.01-.82-.01-1.49-2.01.37-2.53-.49-2.69-.94-.09-.23-.48-.94-.82-1.13-.28-.15-.68-.52-.01-.53.63-.01 1.08.58 1.23.82.72 1.21 1.87.87 2.33.66.07-.52.28-.87.51-1.07-1.78-.2-3.64-.89-3.64-3.95 0-.87.31-1.59.82-2.15-.08-.2-.36-1.02.08-2.12 0 0 .67-.21 2.2.82.64-.18 1.32-.27 2-.27.68 0 1.36.09 2 .27 1.53-1.04 2.2-.82 2.2-.82.44 1.1.16 1.92.08 2.12.51.56.82 1.27.82 2.15 0 3.07-1.87 3.75-3.65 3.95.29.25.54.73.54 1.48 0 1.07-.01 1.93-.01 2.2 0 .21.15.46.55.38A8.013 8.013 0 0016 8c0-4.42-3.58-8-8-8z"></path>
          </svg>
        </a>
      </div>
    </div>
  </header>

  <main>
    <section class="intro">
      <p>
        A collection of SVG logos for German-language TV channels on Astra 19.2° East. 
        Most are styled after the <strong>original corner logos</strong> – hand-picked or 
        <strong>created from scratch</strong>. 
        They are optimized to remain clearly visible on both light and dark backgrounds. 
        Feel free to browse or grab what you need!
      </p>
    </section>
    <div class="grid" id="logo-grid" role="list">
EOF
}

generate_cards() {
  find "${LIGHT_DIR}" -maxdepth 1 -type f -name "*.svg" | sort | while read -r filepath; do
    filename=$(basename "${filepath}")
    display_name="${filename%.svg}"
    dark_override=""
    [[ -f "${DARK_DIR}/${filename}" ]] && dark_override="${DARK_DIR}/${filename}"

    cat << EOF >> "${OUTPUT_DIR}/index.html"
      <div class="card" 
           role="listitem" 
           tabindex="0" 
           aria-label="View logo of ${display_name}"
           onclick="openLightbox('${LIGHT_DIR}/${filename}', '${dark_override}', '${display_name}')"
           onkeydown="if(event.key === 'Enter') openLightbox('${LIGHT_DIR}/${filename}', '${dark_override}', '${display_name}')">
        <div class="logo-container">
          <img class="logo" src="${LIGHT_DIR}/${filename}" 
               data-light="${LIGHT_DIR}/${filename}" data-dark="${dark_override}" 
               alt="Logo of ${display_name}"
               loading="lazy">
        </div>
        <p aria-hidden="true">${display_name}</p>
      </div>
EOF
  done
}

generate_html_foot() {
  cat << EOF >> "${OUTPUT_DIR/}/index.html"
    </div>
  </main>

  <dialog id="lightbox" aria-labelledby="lightbox-title" aria-modal="true">
    <button class="lightbox-close" onclick="this.closest('dialog').close()" aria-label="Close details">✕</button>
    <div class="lightbox-content">
      <img id="lightbox-img" src="" alt="">
      <h3 id="lightbox-title"></h3>
    </div>
  </dialog>

  <footer>
    <p>&copy; $(date +%Y) <a href="${REPO_URL}">${REPO_NAME}</a>. Generated via GitHub Actions.</p>
  </footer>

  <button id="back-to-top" aria-label="Back to top" title="Back to top">↑</button>

  <script>
    const btn = document.getElementById('theme-toggle');
    const search = document.getElementById('search-input');
    const btt = document.getElementById('back-to-top');
    const lightbox = document.getElementById('lightbox');
    const lbImg = document.getElementById('lightbox-img');
    const lbTitle = document.getElementById('lightbox-title');

    function openLightbox(lightSrc, darkSrc, title) {
      const isLightMode = document.body.getAttribute('data-theme') === 'light';
      lbImg.src = (isLightMode && darkSrc) ? darkSrc : lightSrc;
      lbImg.alt = "Enlarged logo of " + title;
      lbTitle.textContent = title;
      lightbox.showModal();
    }

    lightbox.addEventListener('click', e => { if (e.target === lightbox) lightbox.close(); });

    btn.addEventListener('click', () => {
      const isDark = document.body.getAttribute('data-theme') === 'dark';
      const nextTheme = isDark ? 'light' : 'dark';
      document.body.setAttribute('data-theme', nextTheme);
      btn.textContent = isDark ? 'Dark Mode' : 'Light Mode';
      
      document.querySelectorAll('img.logo').forEach(img => {
        img.src = (nextTheme === 'light' && img.dataset.dark) ? img.dataset.dark : img.dataset.light;
      });
    });

    search.addEventListener('input', (e) => {
      const term = e.target.value.toLowerCase();
      document.querySelectorAll('.card').forEach(card => {
        const name = card.querySelector('p').textContent.toLowerCase();
        card.style.display = name.includes(term) ? 'block' : 'none';
      });
    });

    window.addEventListener('scroll', () => {
      btt.classList.toggle('visible', window.scrollY > 300);
    });

    btt.addEventListener('click', () => window.scrollTo({ top: 0, behavior: 'smooth' }));
  </script>
</body>
</html>
EOF
}

main() {
  prepare_assets
  generate_html_head
  generate_cards
  generate_html_foot
  echo "Success: Gallery generated in ${OUTPUT_DIR}/index.html"
}

main "$@"
