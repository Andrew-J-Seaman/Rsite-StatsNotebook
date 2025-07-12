#!/bin/bash

# Exit on error
set -e

echo "🔨 Rendering site with R..."
Rscript -e "rmarkdown::render_site('Stats-Notebook-Seaman')"

echo "🧹 Cleaning up old .html files from main..."
find Stats-Notebook-Seaman -name "*.html" -delete

echo "📦 Stashing HTML output before switching branches..."
git stash push --include-untracked -- Stats-Notebook-Seaman/*.html

echo "🔄 Switching to gh-pages branch..."
git checkout gh-pages

echo "🧹 Clearing old gh-pages contents..."
git rm -rf . > /dev/null 2>&1 || true

echo "📂 Restoring HTML from stash..."
git checkout stash -- Stats-Notebook-Seaman

echo "📄 Moving HTML files to root (optional: adjust path)..."
mv Stats-Notebook-Seaman/*.html .

echo "🗑️ Cleaning up working copy..."
rm -rf Stats-Notebook-Seaman

echo "✅ Committing changes to gh-pages..."
git add .
git commit -m "Deploy site"

echo "🚀 Pushing to origin/gh-pages..."
git push origin gh-pages

echo "🔙 Switching back to main..."
git checkout main

echo "✅ Deployment complete."
