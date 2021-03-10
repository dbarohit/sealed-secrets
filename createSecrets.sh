#!/usr/bin/env bash

# create secret directory
secretFile=$1
secretDir=/tmp/k8s/secrets
mkdir -p "$secretDir"
while
# shellcheck disable=SC2162
read  key value
do
   echo "$key" "$value"
   # Generate plain text file containing secrets
   echo -n "$value" > "$secretDir/$key.txt"
   kubectl delete secret "$key-secret"
   kubectl create secret generic "$key-secret" --from-file="$secretDir/$key.txt"
   kubectl get secret "$key-secret" -o yaml > "$secretDir/$key-secret-base64.yaml"
   kubeseal --scope cluster-wide --cert "mycert.pem" --format yaml < "$secretDir/$key-secret-base64.yaml" > "$secretDir/$key-secret-sealed-minikube.yaml"
done < "$secretFile"
