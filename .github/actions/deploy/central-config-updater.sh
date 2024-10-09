#!/usr/bin/env bash

set -ex

readonly IMAGE_TAG_PATH=${IMAGE_TAG_PATH:-".microservice.image.tag"}
readonly VALUES_YAML_FILE=$COUNTRY-$STAGE/applications/$APP_PATH/$APP/values.yaml

if [[ -n ${TAG} && ${TAG} == "latest" ]]; then
  echo "ERROR: setting TAG to 'latest' is prohibited for security reasons."
  exit 1
fi

curl -sf -u carepaybot:$BITBUCKET_APP_PASSWORD \
  --request GET \
  --url "https://api.bitbucket.org/2.0/repositories/carepaydev/central-configs/src/HEAD/${VALUES_YAML_FILE}" \
  --header 'Accept: application/json' > values.yaml

if [[ $(yq "${IMAGE_TAG_PATH}" values.yaml ) != ${TAG} ]]; then
  yq -i "${IMAGE_TAG_PATH} = \"$TAG\"" values.yaml

  curl  -sf -u carepaybot:$BITBUCKET_APP_PASSWORD \
    https://api.bitbucket.org/2.0/repositories/carepaydev/central-configs/src?author=carepaybot%20%3Cadmin%40carepay.com%3E \
    -F message="$APP $COUNTRY-$STAGE to $TAG [skip ci]" \
    -F ${VALUES_YAML_FILE}=@values.yaml

  echo "Config ${VALUES_YAML_FILE} updated with new tag: ${TAG}"
  MANIFEST="$(aws --region eu-west-1 ecr batch-get-image --repository-name $APP --image-ids imageTag=$TAG --o json | jq -r '.images[0].imageManifest')"
  if [ -n "$MANIFEST" ]; then
    aws --region eu-west-1 ecr put-image --repository-name $APP --image-tag $COUNTRY-$STAGE-$TAG --image-manifest "$MANIFEST"
  fi
else
  echo "No changes detected"
fi

exit 0

