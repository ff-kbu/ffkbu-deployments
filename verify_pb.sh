#!/usr/bin/env sh
# shellcheck disable=SC2317,SC2086,SC2059
# Script Summary:
# This POSIX-compliant shell script automates checks on Ansible playbooks and roles. It performs several tasks, including:
# - Determining changed files between two Git commits.
# - Excluding specified files or directories from the list of changed files.
# - Identifying Ansible playbooks and their associated roles.
# - Running syntax checks on Ansible playbooks.
# - Filtering and handling error results from Ansible checks.
# - Providing a summary of the results.

# Usage: ./script_name.sh
_getrole() {
  YAML_PATH="$YAMLFILE"
  if printf "%s" "$YAML_PATH" | grep -vq "roles/"; then
    exit
  fi
  IFS="/"
  set -- $YAML_PATH
  i=1
  while [ "$i" -le $# ]; do
    if [ "$1" = "roles" ]; then
      printf "%s" "$2"
    fi
    shift
    i=$((i + 1))
  done
}


_findplaybook() {
  grep "$1" ansible/*.yml | head -n 1 | cut -d ":" -f 1
}

_get_pb_hosts() {
  grep "hosts: " "$1" | cut -d ":" -f2 | tr -d " "
}

LAST_COMMITID=$(git log -1 --pretty="%H")
HEAD=$(git rev-parse --short "$(git merge-base origin/master "$LAST_COMMITID")")
FILES=$(git diff --name-only -r "$HEAD" "$LAST_COMMITID")
EXCLUDES="terraform vagrant/ hosts /group_vars /host_vars /files README.md .git* .ansible-lint *.cfg *.sh *.py *.tf"

printf "\n======================= CHANGED FILES ======================\n"
printf "%s" "$FILES" | tr " " "\n" | sed 's/^/  > /'
printf "\n========================= EXCLUDES =========================\n"

for i in $FILES; do
  for ex in $EXCLUDES; do
    case "$i" in
      *"$ex/"* | "$ex" | *"/$ex" | *"$ex")
        printf "  > \033[33mexcluding $i\033[39m\n"
        FILES=$(printf "%s" "$FILES" | sed "s|$i||")
        break
        ;;
    esac
  done
done

printf "\n====================== MAPPING FILES =======================\n"
PLAYBOOKS=""
for YAMLFILE in $FILES; do
  ANSIBLE_RESULT_FILTER=""
  ANSIBLEBIN=$(command -v ansible-playbook)
  export ANSIBLE_ROLES_PATH="./:./roles:ansible/roles"
  [ -n "$YAMLFILE" ] || continue
  if [ ! -f "$YAMLFILE" ]; then
    printf " \033[33mYAMLFILE not found: '$YAMLFILE' - skipping...\033[39m\n"
    continue
  else
    printf "  > '$YAMLFILE'"
  fi
  if printf "%s" "$YAMLFILE" | grep -q '^ansible/[^/]*\.yml$'; then
    printf " \033[32mis a playbook\033[39m\n"
    PLAYBOOKS="$PLAYBOOKS $YAMLFILE"
  else
    ROLE=$(_getrole)
    if [ -z "$ROLE" ]; then
      printf " \033[31mno matching role!\033[39m\n" >&2
      exit 1
    else
      printf " > \033[32mrole '$ROLE'\033[39m"
    fi
    PLAYBOOK=$(_findplaybook "$ROLE")
    if [ -z "$PLAYBOOK" ]; then
      printf " \033[33mno matching playbook - skipping...\033[39m\n"
      continue
    else
      printf " > \033[32mplaybook '$PLAYBOOK'\033[39m\n"
      PLAYBOOKS="$PLAYBOOKS $PLAYBOOK"
    fi
  fi
done

printf "\n===================== RUNNING CHECKS =======================\n\n"
PLAYBOOK_UNIQARR=""
for x in $PLAYBOOKS; do
  found=0
  for y in $PLAYBOOK_UNIQARR; do
    if [ "$x" = "$y" ]; then
      found=1
      break
    fi
  done
  if [ $found -eq 0 ]; then
    PLAYBOOK_UNIQARR="$PLAYBOOK_UNIQARR $x"
  fi
done



for PB in $PLAYBOOK_UNIQARR; do
  [ -n "$PB" ] || continue
  printf "  > $PB"
  RESULT="$($ANSIBLEBIN --syntax-check "$(find ansible/ -type d -name "env_*" | sed 's/^/-i/g')" "$PB" 2>&1; echo $?)"

  RC=$(echo "$RESULT" | tail -1)
  if ! printf "%s" "$RESULT" | grep -qE "$ANSIBLE_RESULT_FILTER" && [ "$RC" -ne 0 ]; then
    printf "Result code was $RC but error was filtered by configuration\n"
    printf " \033[32mPASS\033[39m\n"
  elif printf "%s" "$RESULT" | grep -qE "$ANSIBLE_RESULT_FILTER" && [ "$RC" -ne 0 ]; then
    printf " \033[31mFAIL\033[39m\n"
    printf "===================== ANSIBLE OUTPUT =======================\n\n"
    printf "%s\n" "$RESULT"
    printf "\n============================================================\n"
    exit 1
  else
    printf " \033[32mPASS\033[39m\n"
  fi
done
exit 0
