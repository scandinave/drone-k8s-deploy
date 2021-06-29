#!/usr/bin/env bash

function handle_error() {
  HAS_ERROR=$(echo "$1" | jq '.error')
  if [ "${HAS_ERROR}" != "null" ] ;
  then
      echo "OIDC Provider API return the following error"
      echo "$1"
      exit 1
  fi
}

function print_debug_message() {
  if [ "${PLUGIN_DEBUG}" == "true" ] ; then
    echo "$1"
  fi
}


if [ -z "${PLUGIN_KUBECONFIG}" ] &&  [ -z "${PLUGIN_OIDC_CONFIGURATION}" ] ;
then
  echo "You must either set a kube config secret or OIDC configuration"
  exit 1
fi

if [ -n "${PLUGIN_KUBECONFIG}" ] &&  [ -n "${PLUGIN_OIDC_CONFIGURATION}" ] ;
then
  echo "You can't use kubeconfig and oidc authentification at the same time"
  exit 1
fi

if [ -z "${PLUGIN_YAML}" ] ;
then
  echo "You must set a k8s yaml deployment file"
  exit 1
fi

kubectl_params=()

if [ -n "${PLUGIN_KUBECONFIG}" ] ;
then
  print_debug_message "Using kubeconfig authentification method."
  echo "${PLUGIN_KUBECONFIG}" > /plugin/config
  export KUBECONFIG=/plugin/config
else
  print_debug_message "Using OIDC authentification method."
  token_endpoint=$(curl -S -s "${PLUGIN_OIDC_CONFIGURATION}" | jq '.token_endpoint' | sed 's/"//g')
  print_debug_message "Token Endpoint ${token_endpoint} was found."
  token_response=$(curl -S -s  -X POST -H "Content-Type=application/x-www-form-urlencoded" --data-urlencode "client_id=${PLUGIN_OIDC_CLIENT_ID}" \
   --data-urlencode "client_secret=${PLUGIN_OIDC_CLIENT_SECRET}" --data-urlencode "username=${PLUGIN_OIDC_USERNAME}" \
   --data-urlencode "password=${PLUGIN_OIDC_PASSWORD}" \
   -d "grant_type=password" "${token_endpoint}")

  handle_error "${token_response}"
  token=$(echo "${token_response}" | jq '.access_token' | sed 's/"//g')

  print_debug_message "The provider return the following access token : ${token}"
  params+=(--token=${token})
fi

# Always delete before apply to recreate deployment
echo "Trying to delete a existing deployment..."
kubectl delete -f "${PLUGIN_YAML}" "${params[@]}"

if [ "${PLUGIN_MODE}" = "delete" ] ; then
  echo "Delete only mode activated. Stopping here"
fi

# Only apply if delete only mode is not set
if [ -z "${PLUGIN_MODE}" ] || [ "${PLUGIN_MODE}" != "delete" ] ; then
  echo "Applying the new deployment"
  kubectl apply -f "${PLUGIN_YAML}" "${params[@]}"
fi