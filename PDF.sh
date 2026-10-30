#!/usr/bin/env bash
#
# junta_pdfs.sh
# Reproduz o fluxo:
#   1. Split do AllPages.pdf em páginas separadas (pdfseparate)
#   2. Converte 08.jpg e 36.jpg em PDF (img2pdf)
#   3. Substitui as páginas 8 e 36 pelas versões em JPG
#   4. Junta tudo de volta na ordem correta (pdfunite + sort -V)
#
set -euo pipefail

DIR="/home/neo/Documents/Cognizant/Google/foto03"
PAGINAS="${DIR}/paginas"
ORIGINAL="${DIR}/AllPages.pdf"
SAIDA="${DIR}/AllPages_reunido.pdf"

echo "==> [1/4] Criando pasta de páginas: ${PAGINAS}"
mkdir -p "${PAGINAS}"

echo "==> [2/4] Separando ${ORIGINAL} em páginas..."
pdfseparate "${ORIGINAL}" "${PAGINAS}/pagina-%d.pdf"

echo "==> [3/4] Convertendo JPGs em PDF e substituindo páginas 8 e 36..."
cd "${DIR}"
img2pdf 08.jpg -o 08.pdf
img2pdf 36.jpg -o 36.pdf

cp 08.pdf "${PAGINAS}/pagina-8.pdf"
cp 36.pdf "${PAGINAS}/pagina-36.pdf"

echo "==> [4/4] Juntando tudo na ordem correta..."
cd "${PAGINAS}"
pdfunite $(ls *.pdf | sort -V) "${SAIDA}"

echo
echo "✅ Pronto! PDF final: ${SAIDA}"
ls -lh "${SAIDA}"
