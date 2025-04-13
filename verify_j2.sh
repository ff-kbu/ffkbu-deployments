#!/bin/sh
# shellcheck disable=SC2317,SC2086,SC2059

LAST_COMMITID=$(git log -1 --pretty="%H")
HEAD=$(git rev-parse --short "$(git merge-base origin/master "$LAST_COMMITID")")
git diff --name-only -r "$HEAD" "$LAST_COMMITID" > temp.txt
FILES=$(cat temp.txt)
EXCLUDES="terraform/ vagrant/ .tf$ .yaml$ .sh$ .yml$"
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
    if echo "$i" | grep -q "$ex"; then
      printf "  > ${YELLOW}excluding $i${RESET}\n"
      FILES=$(printf "%s\n" "$FILES" | grep -v "$i")
      break
    fi
  done
done

echo ""
echo "=========== TO CHECK ======="
for file in $FILES; do
  if [ -f "$file" ]; then
    if [ "${file##*.}" = "j2" ]; then
      printf "  > $file"
      if ./verify_j2.py "$file"; then
        printf " ${GREEN}PASS${RESET}\n"
      else
        printf " ${RED}FAIL${RESET}\n"
        rm temp.txt
        exit 1
      fi
    else
      echo "> no verify for this file $file"
    fi
  fi
done
rm temp.txt
exit 0
