#!/bin/zsh

ROOT_GNO_PATH="/Users/sergio/Documents/work work work/AiB/dev/src/forks/forked-gno/gno.land/build"
ROOT_GNO_PATH=${ROOT_GNO_PATH:-"."}

outpath=out.txt

declare -A node_type
node_type[r]="rpc"
node_type[s]="sentry"
node_type[v]="val"

# Help function
show_help() {
    echo "Usage: $0 [-r n] [-v n] [-s n] [-h]"
    echo "Options:"
    echo "  -r n  Generates secrets for n RPC nodes"
    echo "  -v n  Generates secrets for n Validator nodes."
    echo "  -s n  Generates secrets for n Sentry nodes."
    echo "  -h    Displays this help message."
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
    "$ROOT_GNO_PATH"/gnoland secrets init -data-dir $1"$i"/secrets
    echo "$1$i:" >> $outpath
    echo $("$ROOT_GNO_PATH"/gnoland secrets get validator_key.address -raw -data-dir=$1"$i"/secrets) >> $outpath
    echo $("$ROOT_GNO_PATH"/gnoland secrets get validator_key.pub_key -raw -data-dir=$1"$i"/secrets) >> $outpath
  done
}

# Use getopts with a single character to detect flags
while getopts ":r:v:s:h" option; do
  case "$option" in
    r|v|s)
      echo "opt: $option arg: $OPTARG ${node_type[$option]}"
      generateSecrets ${node_type[$option]} $OPTARG
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
