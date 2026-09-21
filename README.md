# Build Sprint skills

Every skill a Build Sprint project needs, installable with one command. Copies are vendored from their upstream repos (see [SOURCES.md](SOURCES.md)), so an upstream rename or restructure can't break installs mid-sprint.

## Install

From inside your project folder (works for both Codex and Claude Code):

```
npx --yes skills add GrowthX-Club/build-sprint-skills --skill '*' -a codex -a claude-code -y
```

Then restart Codex / Claude. Skills only load when a session starts.

Already installed an earlier bundle? Run the same command again — it overwrites the copies in place and picks up anything new.

## What's inside

| Skill | Loads when |
|---|---|
| grill-me | You share a new idea or feature that isn't scoped yet. Interviews you before any code |
| frontend-design | Building or reshaping UI |
| impeccable | Any UI work. Type `/impeccable` for its menu (`polish`, `adapt`, `clarify`, `harden`, …) |
| vercel-react-best-practices | Writing or reviewing React / Next.js code |
| convex-expert | Writing code in `convex/`. Name it if it doesn't kick in |
| convex-auth | Adding sign-in |
| convex-agent | Adding an AI agent or chat to the app |
| copywriting | Landing page, pricing page, headlines |
| agentation | You want to point at things on your running app instead of describing them. Type `/agentation` once to set it up |
| art-direction | Any image asset — hero, og:image, illustration, empty state. Gives the project one visual point of view first |
| checkpoint | Saves your work to git every time the app works, and gets you back when something breaks |
| keep-it-working | Right after a feature works, or when one breaks. Decides how much proof it needs, from a glance to a test written first |

## Updating the copies

Edit `skills.tsv`, then run `./scripts/sync-skills.sh`. It re-copies every listed skill, keeps upstream licenses next to each one, and rewrites SOURCES.md with the commit each came from. `skills/grill-me`, `skills/art-direction`, `skills/checkpoint` and `skills/keep-it-working` are ours and are never overwritten.
