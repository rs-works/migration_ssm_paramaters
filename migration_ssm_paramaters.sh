#!/bin/bash -e
set -o pipefail
#
# SSMパラメータストアの値を移行するスクリプト
# 現在の値を取得してplanを表示、確認をはさんで移行処理をします
# SecureStringのみ対応
#

function usage() {
  cat <<EOT
  Usage:
      -h, --help          This help text
      --from_profile      AWS profile used for migration source
      --from_key          Source SSM parameter store key
      --to_profile        AWS profile to use for migration destination
      --to_key            Destination SSM parameter store key
EOT
}

# -option
while getopts "h-:" opt; do
  case $opt in
    h) usage; exit ;;
    -) break ;; # long option
  esac
done

# --long option
while [ $# -gt 0 ]; do
  if [[ $1 != *"--"* ]]; then shift; continue; fi

  v="${1/--/}"
  case $v in
    from_key)
      declare $v="$2" ;;
    from_profile)
      declare $v="$2" ;;
    to_key)
      declare $v="$2" ;;
    to_profile)
      declare $v="$2" ;;
    *)
      echo "$0 illegal long option -- " $v; exit 1 ;;
  esac
  shift
done
shift $((OPTIND - 1))

# SSMパラメータ取得
from_value=$(aws --profile ${from_profile} ssm get-parameters \
    --name ${from_key} \
    --with-decryption \
| jq -r .Parameters[0].Value)

to_value=$(aws --profile ${to_profile} ssm get-parameters \
    --name ${to_key} \
    --with-decryption \
| jq -r .Parameters[0].Value)

# 取得できたかチェック
if [ "${from_value}" == "" ] || [ "${from_value}" == "null" ]; then
  echo "InvalidParameters ${from_profile}:${from_key}"
  exit 1
fi

if [ "${to_value}" == "" ] || [ "${to_value}" == "null" ]; then
  echo "InvalidParameters ${to_profile}:${to_key}"
  exit 1
fi

# plan出力
cat <<EOT
------------------------------------
Migration SSM Paramater Stores Value
------------------------------------
From
    profile = ${from_profile}
    key     = ${from_key}
    value   = ${from_value}
To
    profile = ${to_profile}
    key     = ${to_key}
  ~ value   = ${to_value} -> ${from_value}

EOT

# 差分がなければ終了
if [[ "${from_value}" == "${to_value}" ]]; then
  echo "No changes. Parameters is up-to-date."
  exit
fi

# applove
read -p "ok? (y/N): " yn; case "$yn" in [yY]*) ;; *) echo "abort"; exit 1 ;; esac

# SSMパラメータを更新
aws --profile ${to_profile} ssm put-parameter \
    --name ${to_key} \
    --value "${from_value}" \
    --type "SecureString" \
    --overwrite

echo "Complate Migration"
