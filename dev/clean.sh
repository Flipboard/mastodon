#!/usr/bin/env bash
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

pg_path="$SCRIPT_DIR/../postgres14"
gems_path="$SCRIPT_DIR/../vendor/bundle"
public_assets="$SCRIPT_DIR/../public/assets"
public_packs="$SCRIPT_DIR/../public/packs"
public_packs_test="$SCRIPT_DIR/../public/packs-test"
public_system="$SCRIPT_DIR/../public/system"

paths=(
    $pg_path
    $gems_path
    $public_assets
    $public_packs
    $public_packs_test
    $public_system
)

for path in "${paths[@]}"
do
    echo "deleting: $path"
    rm -rf $path
done
