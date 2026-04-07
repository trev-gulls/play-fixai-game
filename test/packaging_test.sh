#!/bin/sh
# Tests for make build and make site packaging targets.
# Run via: make test
# Verifies exact output manifests — both expected files present and no extras.

set -e

cd "$(dirname "$0")/.."

PASS=0
FAIL=0

pass() { echo "  PASS: $1"; PASS=$((PASS + 1)); }
fail() { echo "  FAIL: $1"; FAIL=$((FAIL + 1)); }

assert_eq() {
    desc="$1"; expected="$2"; actual="$3"
    if [ "$expected" = "$actual" ]; then
        pass "$desc"
    else
        fail "$desc"
        echo "    expected: $expected"
        echo "    actual:   $actual"
    fi
}

assert_file_absent() {
    if [ ! -e "$1" ]; then
        pass "$1 absent"
    else
        fail "$1 should be absent"
    fi
}

# ── make site ──────────────────────────────────────────────────────────────────

echo "make site"
make site > /dev/null

EXPECTED_SITE="$(printf '%s\n' \
    _site/.nojekyll \
    _site/LICENSE.md \
    _site/NOTICE.md \
    _site/README.md \
    _site/SKILL.md \
    "_site/agents/argument-drafter.md" \
| sort)"

ACTUAL_SITE="$(find _site -type f | sort)"

assert_eq "site manifest" "$EXPECTED_SITE" "$ACTUAL_SITE"

# ── make clean (after site) ───────────────────────────────────────────────────

echo "make clean"
make clean > /dev/null

assert_file_absent _site

# idempotent
make clean > /dev/null
assert_file_absent _site

# ── make build ────────────────────────────────────────────────────────────────

echo "make build"
make build > /dev/null

EXPECTED_ZIP="$(printf '%s\n' \
    play-fixai-game/LICENSE.md \
    play-fixai-game/NOTICE.md \
    play-fixai-game/README.md \
    play-fixai-game/SKILL.md \
    "play-fixai-game/agents/argument-drafter.md" \
| sort)"

ACTUAL_ZIP="$(unzip -l play-fixai-game.skill \
    | awk 'NR>3 && /play-fixai-game\// && !/\/$/ {print $4}' \
    | sort)"

assert_eq "build manifest" "$EXPECTED_ZIP" "$ACTUAL_ZIP"

# ── make clean (after build) ──────────────────────────────────────────────────

echo "make clean"
make clean > /dev/null

assert_file_absent play-fixai-game.skill
assert_file_absent build

# idempotent
make clean > /dev/null
assert_file_absent play-fixai-game.skill

# ── results ───────────────────────────────────────────────────────────────────

echo ""
echo "Results: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ]
