#!/usr/bin/env bash

kube_version=$(kubectl version -ojson --client=true | jq .clientVersion.gitVersion)

echo -e "-- AUTOMATICALLY GENERATED\n-- DO NOT EDIT"
echo "return $kube_version"
