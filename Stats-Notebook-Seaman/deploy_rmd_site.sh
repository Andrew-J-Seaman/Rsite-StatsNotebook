#!/bin/zsh

# Exit if anything fails
set -e

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

# Copy contents of _site/ to root
cp -r _site/* .

# Stage and commit
git add .
git commit -m "Deploy site update: $(date '+%Y-%m-%d %H:%M:%S')"
git push origin gh-pages --force

# Switch back to original branch
git switch "$CURRENT_BRANCH"

echo "✅ Deployment complete. Back on $CURRENT_BRANCH."
