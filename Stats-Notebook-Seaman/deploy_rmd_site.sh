#!/bin/zsh

# Exit if anything fails
set -e

# Don't allow running from gh-pages
if [ "$(git branch --show-current)" = "gh-pages" ]; then
  echo "🚫 Don't run this script from gh-pages. Switch to main first."
  exit 1
fi

echo "🔨 Rendering site with R..."
Rscript -e "rmarkdown::render_site()"

echo "🚀 Deploying to gh-pages..."

# Save current branch
CURRENT_BRANCH=$(git branch --show-current)

# Create or switch to gh-pages branch
if git show-ref --quiet refs/heads/gh-pages; then
  git switch gh-pages
else
  git checkout --orphan gh-pages
  git reset --hard
fi

# Clear everything in gh-pages branch
git rm -rf . > /dev/null 2>&1 || true

# Copy from root folder since output_dir: "." is set
cp -r . ../site-temp
rm -rf ./*
cp -r ../site-temp/* .
rm -rf ../site-temp

# Remove files we don’t want to deploy
rm -f deploy_rmd_site.sh
rm -f _site.yml
find . -name "*.Rmd" -delete

# Stage and commit
git add .
git commit -m "Deploy site update: $(date '+%Y-%m-%d %H:%M:%S')"
git push origin gh-pages --force

# Switch back to original branch
git switch "$CURRENT_BRANCH"

echo "✅ Deployment complete. Back on $CURRENT_BRANCH."
