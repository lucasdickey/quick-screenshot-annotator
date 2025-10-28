#!/bin/bash

# Complete GitHub Push Script
# Run this from your local machine to push to GitHub

echo "🚀 Pushing to GitHub: lucasdickey/quick-screenshot-annotator"
echo "=============================================================="
echo ""

# Check if we're in the right directory
if [ ! -d ".git" ]; then
    echo "❌ Error: Not in a git repository."
    echo "Please run this from the QuickAnnotator directory."
    exit 1
fi

# Check if remote is set
if ! git remote get-url origin &>/dev/null; then
    echo "Setting up remote..."
    git remote add origin https://github.com/lucasdickey/quick-screenshot-annotator.git
    echo "✅ Remote configured"
else
    echo "✅ Remote already configured:"
    git remote get-url origin
fi

echo ""
echo "📊 Current status:"
git status --short
echo ""
echo "📝 Commits ready to push:"
git log --oneline --all
echo ""

echo "🔐 Authentication Note:"
echo "You'll need to authenticate with GitHub. Options:"
echo "  1. GitHub CLI (recommended): gh auth login"
echo "  2. Personal Access Token as password"
echo ""

read -p "Ready to push? (y/n): " confirm

if [ "$confirm" = "y" ]; then
    echo ""
    echo "Pushing to GitHub..."
    git push -u origin main
    
    if [ $? -eq 0 ]; then
        echo ""
        echo "✅ Successfully pushed to GitHub!"
        echo ""
        echo "🎉 View your repository at:"
        echo "   https://github.com/lucasdickey/quick-screenshot-annotator"
        echo ""
    else
        echo ""
        echo "❌ Push failed. Try these solutions:"
        echo ""
        echo "Option 1: Use GitHub CLI"
        echo "  brew install gh"
        echo "  gh auth login"
        echo "  git push -u origin main"
        echo ""
        echo "Option 2: Use Personal Access Token"
        echo "  1. Go to: https://github.com/settings/tokens"
        echo "  2. Generate new token (classic)"
        echo "  3. Select 'repo' scope"
        echo "  4. Use token as password when prompted"
        echo ""
    fi
else
    echo "Push cancelled. Run this script again when ready."
fi
