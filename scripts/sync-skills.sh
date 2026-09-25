#!/usr/bin/env bash
# Refreshes the vendored copies in skills/ from the upstream repos listed in skills.tsv.
# grill-me, art-direction, checkpoint, keep-it-working and playwright are ours and are not touched.
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

sources="$root/SOURCES.md"
{
  echo "# Sources"
  echo
  echo "Vendored by \`scripts/sync-skills.sh\` on $(date +%Y-%m-%d). Each folder keeps its upstream license."
  echo
  echo "| Skill | Upstream | Commit |"
  echo "|---|---|---|"
  echo "| grill-me | ours, adapted from mattpocock/skills (MIT) | — |"
  echo "| art-direction | ours, adapted from AgriciDaniel/banana-claude (MIT) and nexu-io/open-design (Apache-2.0) | — |"
  echo "| checkpoint | ours | — |"
  echo "| keep-it-working | ours, discipline adapted from obra/superpowers (MIT) | — |"
  echo "| playwright | ours | — |"
} > "$sources"

grep -v '^#' "$root/skills.tsv" | while IFS=$'\t' read -r name repo path; do
  [ -z "$name" ] && continue
  checkout="$tmp/${repo//\//_}"
  if [ ! -d "$checkout" ]; then
    git clone -q --depth 1 "https://github.com/$repo" "$checkout"
  fi
  [ -f "$checkout/$path/SKILL.md" ] || { echo "missing: $repo/$path/SKILL.md" >&2; exit 1; }

  rm -rf "$root/skills/$name"
  cp -R "$checkout/$path" "$root/skills/$name"
  for f in LICENSE LICENSE.md LICENSE.txt NOTICE NOTICE.md THIRD_PARTY_NOTICES.md; do
    if [ -f "$checkout/$f" ] && [ ! -e "$root/skills/$name/$f" ]; then
      cp "$checkout/$f" "$root/skills/$name/UPSTREAM-$f"
    fi
  done

  rm -rf "$root/skills/$name/.git"

  sha="$(git -C "$checkout" rev-parse --short HEAD)"
  link="https://github.com/$repo/tree/$sha"
  [ "$path" = "." ] || link="$link/$path"
  echo "| $name | [$repo]($link) | \`$sha\` |" >> "$sources"
  echo "synced $name ($repo@$sha)"
done

# convex publishes this one as a single file on its site, not in a repo
mkdir -p "$root/skills/convex-dev-static-hosting"
curl -fsSL https://www.convex.dev/components/static-hosting/SKILL.md -o "$root/skills/convex-dev-static-hosting/SKILL.md"
curl -fsSL https://raw.githubusercontent.com/get-convex/static-hosting/main/LICENSE -o "$root/skills/convex-dev-static-hosting/UPSTREAM-LICENSE"
echo "| convex-dev-static-hosting | [convex.dev](https://www.convex.dev/components/static-hosting/SKILL.md) | fetched $(date +%Y-%m-%d) |" >> "$sources"
echo "synced convex-dev-static-hosting (convex.dev)"
