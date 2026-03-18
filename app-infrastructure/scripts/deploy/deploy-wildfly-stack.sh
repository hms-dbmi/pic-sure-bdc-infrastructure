#!/bin/bash

# Orchestrates sequential deployment of all containers on the wildfly host.
# Wildfly, PSAMA, and Dictionary share the same EC2 instance and must not
# deploy in parallel — concurrent systemd/D-Bus operations cause failures.
#
# S3 downloads and image loading happen inside each individual deploy script.
# This script simply calls them one at a time to guarantee only one process
# talks to systemd at any point.

deploy_wildfly=false
deploy_psama=false
deploy_dictionary=false

while [[ $# -gt 0 ]]; do
  case $1 in
    --deploy_wildfly)
      deploy_wildfly=true
      shift
      ;;
    --deploy_psama)
      deploy_psama=true
      shift
      ;;
    --deploy_dictionary)
      deploy_dictionary=true
      shift
      ;;
    --stack_s3_bucket)
      stack_s3_bucket="$2"
      shift 2
      ;;
    --target_stack)
      target_stack="$2"
      shift 2
      ;;
    --dataset_s3_object_key)
      dataset_s3_object_key="$2"
      shift 2
      ;;
    --enable_debug)
      enable_debug="$2"
      shift 2
      ;;
    --spring_profile)
      spring_profile="$2"
      shift 2
      ;;
    *)
      echo "Unknown argument: $1"
      exit 1
      ;;
  esac
done

if [[ -z "$stack_s3_bucket" || -z "$target_stack" ]]; then
  echo "Error: --stack_s3_bucket and --target_stack are required."
  exit 1
fi

failed=false

if [[ "$deploy_wildfly" == "true" ]]; then
  echo "=== Deploying wildfly ==="
  /opt/picsure/deploy-wildfly.sh \
    --stack_s3_bucket "$stack_s3_bucket" \
    --target_stack "$target_stack" \
    ${dataset_s3_object_key:+--dataset_s3_object_key "$dataset_s3_object_key"} || failed=true
fi

if [[ "$deploy_psama" == "true" ]]; then
  echo "=== Deploying psama ==="
  /opt/picsure/deploy-psama.sh \
    --stack_s3_bucket "$stack_s3_bucket" \
    --target_stack "$target_stack" \
    ${dataset_s3_object_key:+--dataset_s3_object_key "$dataset_s3_object_key"} \
    ${enable_debug:+--enable_debug "$enable_debug"} \
    ${spring_profile:+--spring_profile "$spring_profile"} || failed=true
fi

if [[ "$deploy_dictionary" == "true" ]]; then
  echo "=== Deploying dictionary ==="
  /opt/picsure/deploy-dictionary.sh \
    --stack_s3_bucket "$stack_s3_bucket" \
    --target_stack "$target_stack" || failed=true
fi

if [[ "$failed" == "true" ]]; then
  echo "ERROR: One or more container deployments failed."
  exit 1
fi

echo "=== All wildfly-host deployments complete ==="
