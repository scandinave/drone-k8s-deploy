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

kubectl apply -f "${PLUGIN_YAML}"
