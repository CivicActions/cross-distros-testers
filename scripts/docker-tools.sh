#!/usr/bin/env bash

echo "Installing all stable releases of Docker Compose"
TAGS=$(git ls-remote https://github.com/docker/compose | grep refs/tags | grep -oP '[0-9]+\.[0-9][0-9]+\.[0-9]+$' | sort -n)
for COMPOSE_VERSION in $TAGS; do
  FILE="/usr/local/bin/docker-compose-${COMPOSE_VERSION}"
  if [ ! -f "${FILE}" ]; then
    echo "Fetching Docker Compose version ${COMPOSE_VERSION} to ${FILE}"
    curl -L "https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o "${FILE}"
    # Occasionally the tag will be created but there won't be a release yet so check we have an executable.
    if [[ "$(file --brief --mime-type ${FILE})" == "application/x-executable" ]]; then
      LATEST="${FILE}"
    else
      rm "${FILE}"
    fi
  fi
done
sudo chmod a+x /usr/local/bin/docker-compose-*
if [ -f "${LATEST}" ]; then
  echo "Symlinking most recent stable Docker Compose version: ${LATEST}"
  ln -sfT "${LATEST}" /usr/local/bin/docker-compose
fi