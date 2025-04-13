#!/usr/bin/env sh
# shellcheck disable=SC2317,SC2086,SC2059
# Summary:
# This shell script finds and checks shell script files in specified paths using ShellCheck.
# It excludes certain directories from the check and displays the results for each script.


PATHS_OF_SCRIPTS=$(find . -type d \
    \( \
        -path ./.idea \
        -o -path .git \
     \) -prune -o -name "*.sh" -type f | sort)

_echo() (
  fmt=%s end='\n' IFS=' '
  while [ $# -gt 1 ] ; do
    case "$1" in ([!-]*|-*[!neE]*) break;; esac # not a flag
    case "$1" in (*n*) end='';; esac # no newline
    case "$1" in (*e*) fmt=%b;; esac # interpret backslash escapes
    case "$1" in (*E*) fmt=%s;; esac # don't interpret backslashes
    shift
  done
  printf "$fmt$end" "$*"
)

_logExclude() {
  _echo -e "  > \\e[33mexcluding ${1}\\e[39m"
}

echo "=========== EXCLUDES ==========="
_logExclude "./.idea"
_logExclude ".git"
_logExclude "./ansible/roles/deploy-acd-old/files"
_logExclude "./extras/scripts/acd/origin"
_logExclude "./extras/scripts/acd/deploy-acd-old/diff"
_logExclude "./extras/scripts/acd/nodes"
echo ""

echo "=========== TO CHECK ==========="
testresult=true
for f in $PATHS_OF_SCRIPTS;do
  test -f "$f" || continue

  _echo -n "  > $f"
  if shellcheck "$f";then
    _echo -e " \\e[32mPASS\\e[39m"
  else
    _echo -e " \\e[31mFAIL\\e[39m"
    testresult=false
  fi
done

if [ "$testresult" != "true" ];then
  exit 1
fi

exit 0
