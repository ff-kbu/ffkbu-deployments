#!/bin/sh
# shellcheck disable=SC2317,SC2086,SC2059
# Script Summary:
# This shell script automates checks on Ansible playbooks and related files. It performs several tasks, including:
# - Determining changed files between two Git commits.
# - Excluding specified files or directories from the list of changed files.
# - Identifying encrypted files and skipping them.
# - Running Ansible Lint on YAML files in specific directories.
# - Displaying results of the checks, indicating pass or fail.

set -e

LAST_COMMITID=$(git log -1 --pretty="%H")
HEAD=$(git rev-parse --short "$(git merge-base origin/master "$LAST_COMMITID")")
FILES=$(git diff --name-only -r "$HEAD" "$LAST_COMMITID")
EXCLUDES="terraform vagrant .tf$ .sh$ .gitlab-ci.yml$ extras deploy"
YELLOW='\033[33m'  # Yellow color code
GREEN='\033[32m'   # Green color code
RED='\033[31m'     # Red color code
RESET='\033[0m'     # Reset color code

echo ""
echo "=========== CHANGED FILES ======="
for f in $FILES; do
  echo "  > $f"
done
echo ""
echo "=========== EXCLUDES ======="

for i in $FILES; do
  for ex in $EXCLUDES; do
    case "$i" in
      *"$ex/"* | "$ex" | *"/$ex" | *"$ex")
        echo "  > ${YELLOW}excluding $i${RESET}"
        FILES=$(echo "$FILES" | sed "s|$i||")
        break
        ;;
    esac
  done
done

echo ""
echo "=========== TO CHECK ======="
for file in $FILES; do
  if [ ! -d "$file" ] && [ -f "$file" ]; then
    if [ "$(head -1 "$file")" = "\$ANSIBLE_VAULT;1.1;AES256" ]; then
      echo "> file \"$file\" is encrypted, skipping..... "
    elif [ ! "$(head -1 "$file")" = "\$ANSIBLE_VAULT;1.1;AES256" ] && [ ! "$file" = "*.*" ]; then
      case "$file" in
        *group_vars/* | *host_vars/*)
          printf "  > $file"
          if RESULT=$(ansible-lint "$file"); then
            echo " ${GREEN}PASS${RESET}"
          else
            printf " ${RED}FAIL${RESET} "
            echo "$RESULT" | cut -d ":" -f 2-3
            exit 1
          fi
          ;;
        *)
          echo "  > no verify for:${YELLOW} $file ${RESET}"
          ;;
      esac
    elif [ "${file##*.}" = "yml" ]; then
      printf "  > $file "
      if RESULT=$(ansible-lint "$file"); then
        echo " ${GREEN}PASS${RESET}"
      else
        printf " ${RED}FAIL${RESET} "
        echo "$RESULT"
        exit 1
      fi
    else
      echo "  > no verify for:${YELLOW} $file ${RESET}"
    fi
  fi
done
