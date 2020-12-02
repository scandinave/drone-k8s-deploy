#!/usr/bin/env bash

cat PLUGIN_KUBECONFIG > ~/.kube/config

kubectl apply -f PLUGIN PLUGIN_YAML
