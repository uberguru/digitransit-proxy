#!/bin/bash
# Set these environment variables
#DOCKER_TAG=
#DOCKER_USER=
#DOCKER_AUTH=

set -o errexit -o nounset -o xtrace

ORG=${ORG:-uberguru}
DOCKER_TAG=${TRAVIS_COMMIT:-latest}
DOCKER_IMAGE=$ORG/digitransit-proxy:$DOCKER_TAG
LATEST_IMAGE=$ORG/digitransit-proxy:latest
PROD_IMAGE=$ORG/digitransit-proxy:prod

echo Building digitransit-proxy: $DOCKER_IMAGE

docker build  --tag=$DOCKER_IMAGE -f Dockerfile .

if [ "${TRAVIS_PULL_REQUEST}" == "false" ]; then
  docker login -u ${DOCKER_USER} -p ${DOCKER_AUTH}
  if [ "$TRAVIS_TAG" ];then
    echo "processing release $TRAVIS_TAG"
    #release do not rebuild, just tag
    docker pull $DOCKER_IMAGE
    docker tag ${DOCKER_IMAGE} ${PROD_IMAGE}
    docker push ${PROD_IMAGE}
  else
    echo "processing master build $TRAVIS_COMMIT"
    test/test.sh
    docker build  --tag=$DOCKER_IMAGE -f Dockerfile .
    docker push ${DOCKER_IMAGE}
    docker tag ${DOCKER_IMAGE} ${LATEST_IMAGE}
    docker push ${LATEST_IMAGE}
  fi
else
  echo "processing pr $TRAVIS_PULL_REQUEST"
  test/test.sh
  docker build  --tag=$DOCKER_IMAGE -f Dockerfile .
fi

echo Build completed
