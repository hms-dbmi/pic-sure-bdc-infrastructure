#!/bin/bash
set -euo pipefail

# Orchestrates sequential deployment of all containers on the wildfly host.
# Gateway, Operations, Query, PSAMA, Dictionary, and Visualization share the
# same EC2 instance and must not deploy in parallel — concurrent
# systemd/D-Bus operations cause failures.
#
# S3 downloads and image loading happen inside each individual deploy script.
# This script simply calls them one at a time to guarantee only one process
# talks to systemd at any point.

deploy_gateway=false
deploy_operations=false
deploy_query=false
deploy_psama=false
deploy_dictionary=false
deploy_visualization=false
stack_s3_bucket=""
target_stack=""
dataset_s3_object_key=""
enable_debug=""
spring_profile=""
artifact_prefix=""
operations_artifact_etag=""
query_artifact_etag=""
psama_artifact_etag=""
gateway_artifact_etag=""

while [[ $# -gt 0 ]]; do
  case $1 in
    --deploy_gateway)
      deploy_gateway=true
      shift
      ;;
    --deploy_operations)
      deploy_operations=true
      shift
      ;;
    --deploy_query)
      deploy_query=true
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
    --deploy_visualization)
      deploy_visualization=true
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
    --artifact_prefix)
      artifact_prefix="$2"
      shift 2
      ;;
    --operations_artifact_etag)
      operations_artifact_etag="$2"
      shift 2
      ;;
    --query_artifact_etag)
      query_artifact_etag="$2"
      shift 2
      ;;
    --psama_artifact_etag)
      psama_artifact_etag="$2"
      shift 2
      ;;
    --gateway_artifact_etag)
      gateway_artifact_etag="$2"
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

artifact_prefix=${artifact_prefix:-${target_stack}/containers}

failed=false

if [[ "$deploy_operations" == "true" ]]; then
  echo "=== Deploying pic-sure-operations-service ==="
  /opt/picsure/deploy-operations.sh \
    --stack_s3_bucket "$stack_s3_bucket" \
    --target_stack "$target_stack" \
    --artifact_prefix "$artifact_prefix" \
    --artifact_etag "$operations_artifact_etag" || failed=true
fi

if [[ "$deploy_query" == "true" ]]; then
  echo "=== Deploying pic-sure-hpds-query-service ==="
  /opt/picsure/deploy-query.sh \
    --stack_s3_bucket "$stack_s3_bucket" \
    --target_stack "$target_stack" \
    --artifact_prefix "$artifact_prefix" \
    --artifact_etag "$query_artifact_etag" || failed=true
fi

if [[ "$deploy_psama" == "true" ]]; then
  echo "=== Deploying psama ==="
  /opt/picsure/deploy-psama.sh \
    --stack_s3_bucket "$stack_s3_bucket" \
    --target_stack "$target_stack" \
    --artifact_prefix "$artifact_prefix" \
    --artifact_etag "$psama_artifact_etag" \
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

if [[ "$deploy_visualization" == "true" ]]; then
  echo "=== Deploying visualization ==="
  /opt/picsure/deploy-visualization.sh \
    --stack_s3_bucket "$stack_s3_bucket" \
    --target_stack "$target_stack" || failed=true
fi

if [[ "$deploy_gateway" == "true" ]]; then
  echo "=== Deploying gateway ==="
  /opt/picsure/deploy-gateway.sh \
    --stack_s3_bucket "$stack_s3_bucket" \
    --target_stack "$target_stack" \
    --artifact_prefix "$artifact_prefix" \
    --artifact_etag "$gateway_artifact_etag" || failed=true
fi

if [[ "$failed" == "true" ]]; then
  echo "ERROR: One or more container deployments failed."
  exit 1
fi

echo "=== All picsure-host deployments complete ==="
