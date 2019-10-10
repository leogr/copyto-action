#!/bin/sh

set -o pipefail

if [[ -z "$SRC_PATH" ]]; then
  echo "SRC_PATH environment variable is missing."
  exit 1
fi

if [[ -z "$DST_REPO" ]]; then
  echo "DST_REPO environment variable is missing."
  exit 1
fi

if [[ -z "$GH_PAT" ]]; then
  echo "GH_PAT environment variable is missing."
  exit 1
fi

DST_PATH="${DST_PATH:-${SRC_PATH}}"

SRC_BRANCH="${SRC_BRANCH:-master}"
DST_BRANCH="${DST_BRANCH:-master}"

DEFALT_COMMIT_MSG="Update ${DST_PATH} from ${GITHUB_REPOSITORY}"
COMMIT_MSG="${COMMIT_MSG:-${DEFALT_COMMIT_MSG}}"

git config --global user.name "${USERNAME:-${GITHUB_ACTOR}}"
git config --global user.email "${EMAIL:-${GITHUB_ACTOR}@users.noreply.github.com}"

echo "Source https://github.com/${GITHUB_REPOSITORY}"
git clone --branch ${SRC_BRANCH} --single-branch --depth 1 https://${GH_PAT}@github.com/${GITHUB_REPOSITORY}.git src
if [ "$?" -ne 0 ]; then
    echo >&2 "Cloning '${GITHUB_REPOSITORY}' failed"
    exit 1
fi
rm -rf src/.git

echo "Destination https://github.com/${DST_REPO}"
git clone --branch ${DST_BRANCH} --single-branch --depth 1 https://${GH_PAT}@github.com/${DST_REPO}.git dst
if [ "$?" -ne 0 ]; then
    echo >&2 "Cloning '$DST_REPO' failed"
    exit 1
fi

echo "Copying '${SRC_PATH}' from '${GITHUB_REPOSITORY}' to '${DST_PATH}' into '${DST_REPO}'"
mkdir -p dst/${DST_PATH} || exit "$?"
cp -rf src/${SRC_PATH}/* dst/${DST_PATH} || exit "$?"

echo "Pushing https://github.com/${DST_REPO}"
cd dst
if [ -z "$(git status --porcelain)" ]; then
    echo "No changes detected"
else
    git add -A
    git commit --message "${COMMIT_MSG}" || exit "$?"
    git push origin ${DST_BRANCH} || exit "$?"
fi

echo "Done"