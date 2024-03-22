#!/usr/bin/env bash

# This script is adapted from https://github.com/MinaProtocol/mina/blob/develop/src/app/rosetta/download-missing-blocks.sh
# It is used to populate a postgres database with missing precomputed archiveDB blocks

# Function to display usage information
usage() {
    echo "Usage: $0 <subcommand> [options]"
    echo "Subcommands:"
    echo "  audit           Check database health"
    echo "  single-run      Check database health and recover it if broken"
    echo "  daemon          Run as a daemon checking health every 10 minutes"
    echo ""
    echo "Options:"
    echo "  --help          Show this help message"
    echo ""
    echo "Example:"
    echo "  $0 audit"
    echo "  $0 single-run"
    echo "  $0 daemon"
}

if [ -z "$DB_USERNAME" ]; then
    echo "The DB_USERNAME environment variable is not set or is empty."
    exit 1
fi

if [ -z "$PGPASSWORD" ]; then
    echo "The PGPASSWORD environment variable is not set or is empty."
    exit 1
fi

if [ -z "$DB_HOST" ]; then
    echo "The DB_HOST environment variable is not set or is empty."
    exit 1
fi

if [ -z "$DB_PORT" ]; then
    echo "The DB_PORT environment variable is not set or is empty."
    exit 1
fi

if [ -z "$DB_NAME" ]; then
    echo "The DB_NAME environment variable is not set or is empty."
    exit 1
fi

if [ -z "$PRECOMPUTED_BLOCKS_URL" ]; then
    echo "The PRECOMPUTED_BLOCKS_URL environment variable is not set or is empty."
    exit 1
fi

if [ -z "$MISSING_BLOCKS_AUDITOR" ]; then
    echo -e "The MISSING_BLOCKS_AUDITOR environment variable is not set or is empty. Defaulting to \033[31mmissing-block-auditor\e[m."
    MISSING_BLOCKS_AUDITOR=missing-blocks-auditor
fi

PG_CONN=postgres://${DB_USERNAME}:${PGPASSWORD}@${DB_HOST}:${DB_PORT}/${DB_NAME}

jq_parent_json() {
   jq -rs 'map(select(.metadata.parent_hash != null and .metadata.parent_height != null)) | "\(.[0].metadata.parent_height)-\(.[0].metadata.parent_hash).json"'
}

jq_parent_hash() {
   jq -rs 'map(select(.metadata.parent_hash != null and .metadata.parent_height != null)) | .[0].metadata.parent_hash'
}

populate_db() {
   mina-archive-blocks --precomputed --archive-uri "${1}" "${2}" | jq -rs '"[BOOTSTRAP] Populated database with block: \(.[-1].message)"'
   rm "${2}"
}

download_block() {
    echo "Downloading ${1} block"
    curl -sO "${PRECOMPUTED_BLOCKS_URL}/${1}"
}

HASH='map(select(.metadata.parent_hash != null and .metadata.parent_height != null)) | .[0].metadata.parent_hash'
# Bootstrap finds every missing state hash in the database and imports them from the o1labs bucket of .json blocks
bootstrap() {
  echo "[BOOTSTRAP] Top 10 blocks before bootstrapping the archiveDB:"
  psql "${PG_CONN}" -c "SELECT state_hash,height FROM blocks ORDER BY height DESC LIMIT 10"
  echo "[BOOTSTRAP] Restoring blocks individually from ${PRECOMPUTED_BLOCKS_URL}..."

  until [[ "$PARENT" == "null" ]] ; do
    PARENT_FILE="${MINA_NETWORK}-$($MISSING_BLOCKS_AUDITOR --archive-uri $PG_CONN | jq_parent_json)"
    download_block "${PARENT_FILE}"
    populate_db "$PG_CONN" "$PARENT_FILE"
    PARENT="$($MISSING_BLOCKS_AUDITOR --archive-uri $PG_CONN | jq_parent_hash)"
  done

  echo "[BOOTSTRAP] Top 10 blocks in bootstrapped archiveDB:"
  psql "${PG_CONN}" -c "SELECT state_hash,height FROM blocks ORDER BY height DESC LIMIT 10"
  echo "[BOOTSTRAP] This Archive node is synced with no missing blocks back to genesis!"

  echo "[BOOTSTRAP] Checking again in 60 minutes..."
  sleep 3000
}

main() {

  # Check if at least one argument is provided
  if [ $# -lt 1 ]; then
    usage
    exit 1
  fi
  
  # Parse argument
  subcommand="$1"
  shift

  # Check for help option
  if [ "$subcommand" = "--help" ]; then
    usage
    exit 0
  fi

  # Wait until there is a block missing
  PARENT=null
  case "$subcommand" in
    audit)
      echo "Running in audit mode"
      PARENT="$($MISSING_BLOCKS_AUDITOR --archive-uri $PG_CONN | jq_parent_hash)"
      echo "[BOOTSTRAP] $($MISSING_BLOCKS_AUDITOR --archive-uri $PG_CONN | jq -rs .[].message)"
      [[ "$PARENT" != "null" ]] && echo "Some blocks are missing" && exit 0
      echo "[RESOLUTION] This Archive node is synced with no missing blocks back to genesis!"
      exit 0
      ;;
    single-run)
      echo "Running in single-run mode"
      PARENT="$($MISSING_BLOCKS_AUDITOR --archive-uri $PG_CONN | jq_parent_hash)"
      echo "[BOOTSTRAP] $($MISSING_BLOCKS_AUDITOR --archive-uri $PG_CONN | jq -rs .[].message)"
      [[ "$PARENT" != "null" ]] && echo "[BOOTSTRAP] Some blocks are missing, moving to recovery logic..." && bootstrap
      ;; 
    daemon)
      echo "Running in daemon mode"
      while true; do # Test once every 10 minutes forever, take an hour off when bootstrap completes
        PARENT="$($MISSING_BLOCKS_AUDITOR --archive-uri $PG_CONN | jq_parent_hash)"
        echo "[BOOTSTRAP] $($MISSING_BLOCKS_AUDITOR --archive-uri $PG_CONN | jq -rs .[].message)"
        [[ "$PARENT" != "null" ]] && echo "[BOOTSTRAP] Some blocks are missing, moving to recovery logic..." && bootstrap
        sleep 600 # Wait for the daemon to catchup and start downloading new blocks
      done
      echo "[RESOLUTION] This Archive node is synced with no missing blocks back to genesis!"
      ;;
    *)
      usage
      exit 1
      ;;
  esac
}

main "$@"
