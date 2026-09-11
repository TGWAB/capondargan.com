#!/usr/bin/env bash
# Citation + checklist integrity—DEV-STANDARDS §15.
#
# Three guards:
#   1. Every cross-document `DS §N` citation resolves inside the frozen §1–§19 range.
#   2. The three copies of the launch checklist have not diverged.
#   3. Every path-shaped citation to THIS repo's tree resolves to something that
#      exists.
#
# Guard 1 checks `DS §N` ONLY, on purpose. A bare `§N` is document-local by the §
# convention—a runbook with its own § sections (the wizard runbook, now in
# wizard-web/docs/) legitimately cites its own numbers—so range-checking every
# § would flag correct references. It also does NOT catch
# "§10 says no mailto" (10 is in range); that class needs the DS §N namespace plus
# review, which is why the standard mandates both.
set -euo pipefail

# Every path below is repo-root-relative; anchor to the script's own location so
# a subdirectory invocation cannot rescope guard 1 or silently skip guard 2.
cd "$(dirname "$0")/.."

fail=0

while IFS= read -r hit; do
  n="$(printf '%s' "$hit" | grep -oE 'DS §[0-9]+' | head -1 | grep -oE '[0-9]+')"
  if [ "$n" -lt 1 ] || [ "$n" -gt 19 ]; then
    printf 'out-of-range DS citation: %s\n' "$hit"
    fail=1
  fi
done < <(grep -rnoE 'DS §[0-9]+' \
           --include='*.md' --include='*.js' --include='*.txt' --include='*.html' \
           --include='_headers' . 2>/dev/null | grep -v '^\./\.git/')

# ---------------------------------------------------------------------------
# GUARD 3—a path-shaped citation MUST resolve. DEV-STANDARDS §15.
#
# WHY THIS EXISTS. Guard 1 range-checks section numbers and nothing else, so a
# citation to a file that does not exist passed at exit 0—measured in this repo
# and in TGWAB/tgwab-account (#120). That is the same defect class as
# tgwab-account's README and CLAUDE.md citing `src/entitlement.js`, a file that
# never existed, through three documentation PRs and a green CI.
#
# WHY THE SCOPE IS "FIRST SEGMENT IS A REAL DIRECTORY HERE", AND NOT EVERY PATH.
# Measured over this repo: 203 backticked path-shaped strings in Markdown, of
# which 145 have a first segment that is not a directory in this repo at all—
# `herald/ui/dist`, `ipcow.com/apps/checkip/src/index.ts`,
# `MichalAFerber/tgwab-standards`. Those are OTHER repos, and a checker that
# resolved them against this tree would report 145 failures and be deleted
# within the day. The first-segment test is what makes the guard about this
# repo's own claims. It costs nothing: a citation to a file here necessarily
# starts with a directory here.
#
# `.` and `..` are excluded even though both "exist": `./deploy.sh` and
# `../tgwab-standards/` are illustrations of a shape, not references into this
# tree.
#
# THE EXEMPTIONS BELOW ARE DECLARED, NOT INFERRED, and each names its reason—
# the MUSTER_OPT_OUT pattern §15 uses everywhere else. They exist because two
# legitimate kinds of citation name a path that is correctly absent:
#
#   PRESCRIPTIVE—the path a repo ADOPTING this standard must create. §15's
#   `scripts/no-eval.sh` and PROJECT-STRUCTURE's destination column describe
#   somebody else's tree by design, and often name the template beside them.
#
#   HISTORICAL—a path cited in order to say it is gone. DEV-STANDARDS §6 says
#   "the `templates/contact-form-worker.js` reference implementation is
#   retired"; making that citation resolve would mean restoring a file the
#   estate deliberately deleted. The sentence is correct BECAUSE the file is
#   absent.
#
# Measured before shipping: without these exemptions the guard reports 21
# failures on a clean tree and 0 true positives. A gate that is red on day one
# for something nobody introduced is a gate people learn to ignore, so each
# exemption is written down and reviewable instead.
# ---------------------------------------------------------------------------
path_citation_exempt() {
  case "$1" in
    # PRESCRIPTIVE—the adopting repo's tree, not ours. Each names its template.
    scripts/no-eval.sh) return 0 ;;          # ships as templates/no-eval.sh
    scripts/publish.sh) return 0 ;;          # §10 extension packaging, product repos
    scripts/package-all.sh) return 0 ;;      # §10 extension packaging, product repos
    .github/ruleset-main.json) return 0 ;;   # PROJECT-STRUCTURE destination column
    docs/README.md) return 0 ;;              # §10: the PRODUCT repo's docs/README.md
    # ships as templates/check-rule-preservation.mjs; per-repo because it needs
    # the ADOPTING repo's own ESLint, so it can only ever exist there.
    scripts/check-rule-preservation.mjs) return 0 ;;
    # PRESCRIPTIVE, and cited in order to say it is absent everywhere. §10 names
    # this path to report that it resolves in 0 of 131 repos; ships as
    # templates/pr-base-guard.yml. Unlike its §4 sibling pr-draft-gate.yml, this
    # repo does not vendor it either—which is the finding, not an oversight.
    .github/workflows/pr-base-guard.yml) return 0 ;;
    # HISTORICAL—cited in order to record that it is gone.
    templates/contact-form-worker.js) return 0 ;;  # §6: retired, superseded by the mailer
    docs/wizard-family/) return 0 ;;               # moved to wizard-web/docs/, said so in place
  esac
  return 1
}

while IFS= read -r hit; do
  loc="${hit%%:\`*}"
  cited="$(printf '%s' "$hit" | grep -oE '`[^`]+`' | head -1 | tr -d '`')"
  first="${cited%%/*}"
  # Only this repo's own tree: first segment must be a real directory here.
  case "$first" in .|..) continue ;; esac
  [ -d "$first" ] || continue
  path_citation_exempt "$cited" && continue
  if [ ! -e "$cited" ]; then
    printf 'broken path citation: %s (cited at %s)\n' "$cited" "$loc"
    fail=1
  fi
done < <(grep -rnoE '`[A-Za-z0-9_.-]+/[A-Za-z0-9_./-]+`' \
           --include='*.md' . 2>/dev/null | grep -v '^\./\.git/')

# Guard 2 runs only in the standards repo—detected by either marker, so a
# clone with one renamed or deleted fails loudly instead of self-skipping to a
# false OK. Product repos copy this script for guard 1 alone: §15 makes the
# citation range check a CI MUST in every repo, and product repos are where
# DS §N citations live.
if [ -f DEV-STANDARDS.md ] || [ -f templates/launch-checklist.md ]; then
  # templates/launch-checklist.md is the sole authored copy (§17). `missing` is
  # guard-2-local on purpose: gating the diffs on the global `fail` would let a
  # guard-1 citation error mask a simultaneous checklist divergence.
  missing=0
  for f in DEV-STANDARDS.md templates/launch-checklist.md .github/ISSUE_TEMPLATE/launch.md; do
    if [ ! -f "$f" ]; then
      printf 'missing spec or checklist copy: %s\n' "$f"
      missing=1
      fail=1
    fi
  done

  if [ "$missing" -eq 0 ]; then
    if ! diff -q templates/launch-checklist.md .github/ISSUE_TEMPLATE/launch.md >/dev/null; then
      printf 'launch checklist diverged: .github/ISSUE_TEMPLATE/launch.md\n'
      fail=1
    fi

    # Indented sub-items included: anchoring at column 0 skipped the §13 DNS block,
    # which is exactly where the copies drifted while the guard stayed green. The
    # DEV-STANDARDS side is bounded to §17 so a checkbox in some other section's
    # example can never false-positive as checklist divergence.
    if ! diff -q \
        <(grep -E '^[[:space:]]*- \[ \]' templates/launch-checklist.md) \
        <(sed -n '/^## 17\./,/^## 18\./p' DEV-STANDARDS.md | grep -E '^[[:space:]]*- \[ \]') >/dev/null; then
      printf 'launch checklist diverged: DEV-STANDARDS.md §17\n'
      fail=1
    fi
  fi

  # The three community-health templates (§15): each authored in templates/ and
  # deployed to this repo's own .github/. Guard 3 already catches a DELETED copy,
  # because PROJECT-STRUCTURE.md cites both paths—but presence is not content.
  # Appending a line to .github/pull_request_template.md left this script green
  # at exit 0, while the same corruption applied to .github/ISSUE_TEMPLATE/launch.md
  # failed correctly: the mechanism existed and these three pairs were outside it.
  #
  # Not gated on `missing` above, for the reason given there—a missing launch
  # checklist must not mask a simultaneous template divergence.
  #
  # "local" in the message is load-bearing. CI here cannot see the copies in
  # MichalAFerber/.github and TGWAB/.github, which is where GitHub actually serves
  # these from, and this guard says nothing about those. A message claiming more
  # than was checked is how a guard becomes false assurance rather than none.
  for pair in \
    'templates/pull-request-template.md:.github/pull_request_template.md' \
    'templates/issue-defect.md:.github/ISSUE_TEMPLATE/defect.md' \
    'templates/issue-inaccurate-claim.md:.github/ISSUE_TEMPLATE/inaccurate-claim.md'; do
    authored="${pair%%:*}"
    deployed="${pair#*:}"
    if [ ! -f "$authored" ] || [ ! -f "$deployed" ]; then
      printf 'missing template copy: %s or %s\n' "$authored" "$deployed"
      fail=1
    elif ! diff -q "$authored" "$deployed" >/dev/null; then
      printf 'local template copy diverged: %s\n' "$deployed"
      fail=1
    fi
  done
fi

[ "$fail" -eq 0 ] && printf 'citations + local template copies: OK\n'
exit "$fail"
