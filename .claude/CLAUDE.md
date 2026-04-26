# Agent-Native CLI Skill — Auto-Update Configuration

**Version**: 1.2.0  
**Last Updated**: April 26, 2026

---

## Auto-Update Policy

This skill is hosted on GitHub and updates automatically when loaded in Claude Code.

### How It Works

**On every session start:**
1. If the local repo is behind `origin/main`, pull updates
2. If a new git tag exists (e.g., `v1.2.0`), notify the user
3. Apply changes immediately; no restart needed

### For Users: Using This Skill

The skill will auto-sync from GitHub. No action needed — just use it normally.

```bash
# This happens automatically:
git fetch origin main
git pull origin main (if behind)
```

---

## For Authors: Publishing Updates

### Step 1: Commit & Push Changes
```bash
git add .
git commit -m "feat: description of changes"
git push origin main
```

→ Changes appear on users' next session within ~5 minutes

### Step 2: Release Tag (Optional but Recommended)
```bash
git tag -a v1.2.1 -m "Release v1.2.1: bug fixes and improvements"
git push origin --tags
gh release create v1.2.1 --notes "Release notes here"
```

→ Users see a notification about the new version

---

## Technical Details

### Configuration

**Location**: `.claude/CLAUDE.md` (this file)

**Hooks**: None needed — Claude Code's built-in git handler checks for updates on each session.

### What Auto-Updates

- ✅ SKILL.md changes
- ✅ Examples, references, checklists
- ✅ Examples, anti-patterns
- ✅ Everything in the repo

**What Does NOT Auto-Update**
- ❌ This `.claude/CLAUDE.md` file (users see it after next session)
- ❌ Local agent-generated configs (`.claude/settings.local.json`)

---

## Version Pinning (Advanced)

If a user wants to pin to a specific version and not auto-update:

```bash
cd ~/.claude/skills/agent-native-cli  # or wherever the skill is installed
git checkout v1.2.0
# Now locked to v1.2.0; use `git checkout main` to re-enable auto-updates
```

---

## Troubleshooting Auto-Updates

**"I pushed changes but they're not showing up"**
- Check: Did you push to `origin/main`? (Not a feature branch)
- Check: Is your local repo's remote correct? `git config --get remote.origin.url`
- Wait: Can take 1-5 minutes for GitHub sync

**"Skill won't pull updates"**
- Manual: `cd ~/.claude/skills/agent-native-cli && git pull origin main`
- Check permissions: Verify `.claude/settings.local.json` allows git operations

**"I want to revert to an older version"**
```bash
git log --oneline  # Find the commit hash
git checkout <commit-hash>
```

---

## Release Checklist

When publishing a new skill version:

- [ ] All commits pushed to GitHub: `git push origin main`
- [ ] Version updated in SKILL.md metadata: `"version": "X.Y.Z"`
- [ ] Git tag created: `git tag -a vX.Y.Z -m "..."`
- [ ] Tags pushed: `git push origin --tags`
- [ ] Release created: `gh release create vX.Y.Z`
- [ ] README.md changelog updated
- [ ] (Optional) Deployed to SkillsMP or marketplace

After these steps, all users will auto-pull the changes on their next session.

---

## Questions?

For issues with auto-update, file a GitHub issue at:  
https://github.com/Agents365-ai/agent-native-cli/issues
