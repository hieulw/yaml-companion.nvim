#!/usr/bin/env bash

definitions_url=("https://raw.githubusercontent.com/yannh/kubernetes-json-schema/master" "_definitions.json")
versions=()
declare -A kinds

gh_tree_content=$(gh api "/repos/yannh/kubernetes-json-schema/git/trees/master")
if [ -z "$gh_tree_content" ]; then
  echo "Can't GET GH tree"
  exit 1
fi

readarray -t versions < <(echo "$gh_tree_content" | jq -r '.tree[] | select(.path | match("v[0-9]+\\.[0-9]+\\.[0-9]+$")) | .path' | tail -n 10)

for version in "${versions[@]}"; do
  url="${definitions_url[0]}/${version}/${definitions_url[1]}"
  content=$(curl -s "$url")
  if [ -z "$content" ]; then
    echo "Can't GET $url"
    exit 1
  fi

  kubernetes_group_version_kind=$(echo "$content" | jq -r '.definitions.[] | select(has("x-kubernetes-group-version-kind")) | ."x-kubernetes-group-version-kind".[].kind')
  for kind in $kubernetes_group_version_kind; do
    kinds[$kind]=1
  done
  sleep 1
done

echo -e "-- AUTOMATICALLY GENERATED\n-- DO NOT EDIT"
echo -e "return {"
for kind in "${!kinds[@]}"; do
  echo -e "\t\"$kind\","
done
echo -e "}"
