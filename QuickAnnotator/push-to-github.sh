#!/bin/bash

# GitHub Push Setup Script for Quick Annotator
# This script helps you push the project to GitHub

echo "🚀 Quick Annotator - GitHub Push Helper"
echo "========================================"
echo ""

# Check if we're in a git repository
if [ ! -d .git ]; then
    echo "❌ Error: Not in a git repository. Run this from the QuickAnnotator directory."
    exit 1
fi

echo "✅ Git repository detected"
echo ""

# Check if remote already exists
if git remote get-url origin &>/dev/null; then
    echo "📡 Remote 'origin' already configured:"
    git remote get-url origin
    echo ""
    read -p "Do you want to change the remote URL? (y/n): " change_remote
    if [ "$change_remote" = "y" ]; then
        read -p "Enter new GitHub repository URL: " repo_url
        git remote set-url origin "$repo_url"
        echo "✅ Remote URL updated"
    fi
else
    echo "No remote repository configured yet."
    echo ""
    echo "📝 Steps to create a GitHub repository:"
    echo "1. Go to https://github.com/new"
    echo "2. Repository name: quick-annotator (or your choice)"
    echo "3. Description: Native MacOS app for quick screenshot annotation"
    echo "4. Make it Public or Private (your choice)"
    echo "5. Do NOT initialize with README (we already have one)"
    echo "6. Copy the repository URL"
    echo ""
    read -p "Have you created the GitHub repo? Enter the URL (or 'skip' to exit): " repo_url
    
    if [ "$repo_url" = "skip" ]; then
        echo "Exiting without setting remote. You can set it later with:"
        echo "  git remote add origin <your-repo-url>"
        exit 0
    fi
    
    git remote add origin "$repo_url"
    echo "✅ Remote 'origin' configured"
fi

echo ""
echo "📊 Repository Status:"
git status --short
echo ""

echo "📤 Ready to push to GitHub!"
echo ""
echo "Commands that will be executed:"
echo "  git push -u origin main"
echo ""
read -p "Push to GitHub now? (y/n): " do_push

if [ "$do_push" = "y" ]; then
    echo ""
    echo "Pushing to GitHub..."
    if git push -u origin main; then
        echo ""
        echo "✅ Successfully pushed to GitHub!"
        echo ""
        echo "🎉 Your repository is now live at:"
        git remote get-url origin
        echo ""
        echo "Next steps:"
        echo "  - View your repo in a browser"
        echo "  - Add topics/tags for discoverability"
        echo "  - Consider adding a LICENSE file"
        echo "  - Share with others!"
    else
        echo ""
        echo "❌ Push failed. Common issues:"
        echo "  - Authentication required (use GitHub CLI or personal access token)"
        echo "  - Wrong repository URL"
        echo "  - No write access to repository"
        echo ""
        echo "Try manual push with:"
        echo "  git push -u origin main"
    fi
else
    echo ""
    echo "Push cancelled. When ready, run:"
    echo "  git push -u origin main"
fi

echo ""
echo "Done! 🎊"
