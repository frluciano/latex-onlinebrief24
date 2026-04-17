#!/bin/sh
set -eu

if [ "$#" -ne 1 ]; then
	printf '%s\n' "Usage: sh scripts/ci-detect-changes.sh <verify|ctan|tooling>" >&2
	exit 1
fi

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
. "$script_dir/lib/common.sh"

mode=$1

case "$mode" in
verify)
	pattern='^(\.github/workflows/build-verify\.yml|onlinebrief24\.cls|examples/|tests/fixtures/|scripts/verify\.sh|scripts/ci-detect-changes\.sh)$'
	;;
ctan)
	pattern='^(\.github/workflows/build-ctan\.yml|\.github/workflows/release-ctan\.yml|onlinebrief24\.cls|ctan/|examples/|scripts/build-ctan\.sh|scripts/generate-announcement-draft\.sh|scripts/generate-release-metadata\.sh|scripts/validate-release-inputs\.sh|scripts/ci-detect-changes\.sh|LICENSE$)'
	;;
tooling)
	pattern='^(\.github/workflows/|scripts/|ctan/onlinebrief24\.pkg$)'
	;;
*)
	printf '%s\n' "Unsupported mode: $mode (expected verify, ctan, or tooling)" >&2
	exit 1
	;;
esac

normalize_gh_token

event_name=${EVENT_NAME:-}
pr_number=${PR_NUMBER:-}
push_before=${PUSH_BEFORE:-}
push_after=${PUSH_AFTER:-}
repository=${GITHUB_REPOSITORY:-}

if [ "$event_name" = "workflow_dispatch" ]; then
	printf '%s\n' "true"
	exit 0
fi

if [ -z "$repository" ]; then
	fail "GITHUB_REPOSITORY is required."
fi

if [ "$event_name" = "pull_request" ]; then
	if [ -z "$pr_number" ]; then
		fail "PR_NUMBER is required for pull_request events."
	fi
	changed_files=$(gh api \
		"repos/${repository}/pulls/${pr_number}/files" \
		--paginate \
		--jq '.[].filename')
else
  if [ -z "$push_before" ] || [ "$push_before" = "0000000000000000000000000000000000000000" ]; then
    printf '%s\n' "true"
    exit 0
  fi
  if ! compare_json=$(gh api \
    "repos/${repository}/compare/${push_before}...${push_after}" 2>&1); then
    printf '%s\n' "::warning::Could not compare ${push_before}...${push_after} — forcing all checks." >&2
    printf '%s\n' "true"
    exit 0
  fi
  # Parse once: extract both the truncated flag and the file list in one pass.
  compare_parsed=$(printf '%s' "$compare_json" | python3 -c \
    "import json,sys; d=json.load(sys.stdin); print(d.get('truncated',False)); [print(f['filename']) for f in d['files']]")
  truncated=$(printf '%s\n' "$compare_parsed" | head -n 1)
  if [ "$truncated" = "True" ]; then
    printf '%s\n' \
      "::warning::Push diff exceeds 300 files; change detection may be incomplete — forcing all checks." >&2
    printf '%s\n' "true"
    exit 0
  fi
  changed_files=$(printf '%s\n' "$compare_parsed" | tail -n +2)
fi

if [ -n "$changed_files" ]; then
	printf '%s\n' "$changed_files" >&2
fi

if printf '%s\n' "$changed_files" | grep -Eq "$pattern"; then
	printf '%s\n' "true"
else
	printf '%s\n' "false"
fi
