# Claude Instructions for Motiva Project

## Git Push Instructions

When the user says "push all" or "push everything":
1. Check all configured remotes with `git remote -v`
2. Push to **both** repositories:
   - `origin` → github.com/K1llly/motiva.git (public)
   - `private` → github.com/K1llly/motiva-private.git (private)
3. Always push to both remotes to keep them in sync
4. **AI-related files (CLAUDE.md, plans, memory files) should ONLY be pushed to the private repo, NOT to origin/public**

## Project Structure

- Flutter app with Clean Architecture
- BLoC for state management
- Hive + SharedPreferences for local storage
- Multi-language support (EN, TR, DE, RU)

## Key Features

- Daily stoic quotes
- Home screen widget customization
- Streak tracking
- Sharing functionality
- Language selection
