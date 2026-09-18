#!/usr/bin/env bash
# Refreshes the vendored copies in skills/ from the upstream repos listed in skills.tsv.
# grill-me is ours and is not touched.
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

  sha="$(git -C "$checkout" rev-parse --short HEAD)"
  echo "| $name | [$repo](https://github.com/$repo/tree/$sha/$path) | \`$sha\` |" >> "$sources"
  echo "synced $name ($repo@$sha)"
done
