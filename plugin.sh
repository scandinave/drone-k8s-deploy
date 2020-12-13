#!/usr/bin/env bash

if [ -z "${PLUGIN_KUBECONFIG}" ] ;
then
  echo "You must set a kube config secret"
  exit 1
fi

if [ -z "${PLUGIN_YAML}" ] ;
then
  echo "You must set a k8s yaml deployment file"
  exit 1
fi

echo "${PLUGIN_KUBECONFIG}" > /plugin/config

export KUBECONFIG=/plugin/config

# Always delete before apply to recreate deployment
echo "Trying to delete a existing deployment..."
kubectl delete -f "${PLUGIN_YAML}"
echo "Deletion done"

if [ "${PLUGIN_MODE}" != "delete" ] ; then
  echo "Delete only mode activated. Stopping here"
fi

# Only apply if delete only mode is not set
if [ -z "${PLUGIN_MODE}" ] || [ "${PLUGIN_MODE}" != "delete" ] ; then
  echo "Applying the new deployment"
  kubectl apply -f "${PLUGIN_YAML}"
fi