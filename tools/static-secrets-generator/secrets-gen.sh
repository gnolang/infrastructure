#!/bin/zsh

set -e

ROOT_GNO_PATH=${ROOT_GNO_PATH:-"."}
outpath=out.txt
dest_folder="."

declare -A node_type
node_type[r]="rpc"
node_type[s]="sentry"
node_type[v]="val"

# Help function
show_help() {
    echo "Usage: ./secrets-gen.sh [-r n] [-v n] [-s n] [-h]"
    echo "Options:"
    echo "  -o path Destination folder for secrets"
    echo "  -r n    Generates secrets for n RPC nodes"
    echo "  -v n    Generates secrets for n Validator nodes."
    echo "  -s n    Generates secrets for n Sentry nodes."
    echo "  -h      Displays this help message."
}

# $1 - type of node
# $2 - number of nodes per type
generateSecrets() {
  echo "Generating secrets for $1..."
  if [[ ! $2 =~ ^[0-9]+$ ]]; then
    echo "Error: $1 option requires a numeric argument."
    exit 1
  fi
  for ((i = 1; i <= $2; i++)); do
    valname=$(printf "%s-%02d" $1 $i)
    valpath=$(printf "%s/%s" $dest_folder $valname)
    secrets_path="$valpath/gno-secrets" 
    config_path="$valpath/config/config.toml"

    "$ROOT_GNO_PATH"/gnoland secrets init -data-dir $secrets_path
    echo "$valname:" >> $outpath
    echo address: $("$ROOT_GNO_PATH"/gnoland secrets get validator_key.address -raw -data-dir=$secrets_path) >> $outpath
    echo pub_key: $("$ROOT_GNO_PATH"/gnoland secrets get validator_key.pub_key -raw -data-dir=$secrets_path) >> $outpath
    echo p2p_node_id: $("$ROOT_GNO_PATH"/gnoland secrets get node_id.id -raw -data-dir=$secrets_path) >> $outpath
    "$ROOT_GNO_PATH"/gnoland config init -config-path $config_path
    "$ROOT_GNO_PATH"/gnoland config set moniker "gnocore-$valname" -config-path $config_path
    "$ROOT_GNO_PATH"/gnoland config set p2p.pex false -config-path $config_path

    case "$1" in
      rpc)
        "$ROOT_GNO_PATH"/gnoland config set rpc.laddr tcp://0.0.0.0:26657 -config-path $config_path
        ;;
      sentry)
        "$ROOT_GNO_PATH"/gnoland config set p2p.pex true -config-path $config_path
        ;;
    esac
  done
}

# Read -o argument if present
# Loop through all arguments
for ((i=1; i<=$#; i++)); do
  current_arg="${@[$i]}"
  if [[ "$current_arg" == "-o" ]]; then
    next_index=$((i + 1))
    value="${@[$next_index]}"
    if [[ $next_index -le $# && -n "$value" && "$value" != -* ]]; then
      echo "setting dest folder to: $value"
      dest_folder="$value"
      outpath=$(printf "%s/%s" $dest_folder $outpath)
    else
      echo "Error: empty path for dest folder option: -o"
      exit 1
    fi
    break
  fi
done

# Use getopts with a single character to detect flags
while getopts ":r:v:s:o:h" option; do
  case "$option" in
    r|v|s)
      echo "opt: $option arg: $OPTARG ${node_type[$option]}"
      generateSecrets ${node_type[$option]} $OPTARG
      ;;
    o)
      # do nothing
      ;;
    h)
      show_help
      exit 0
      ;;
    *)
      echo "Unknown option: -$OPTARG"
      show_help
      exit 1
      ;;
  esac
done

# If no options are given, show help by default
if [ $OPTIND -eq 1 ]; then
  show_help
  exit 1
fi
