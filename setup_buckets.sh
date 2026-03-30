#!/bin/bash
# setup_buckets.sh - Creates the required buckets in MinIO

MINIO_URL="http://localhost:9000"
MINIO_USER="minioadmin"
MINIO_PASS="minioadmin"
ALIAS="local_minio"

echo "⏳ Waiting for MinIO to start at ${MINIO_URL}..."

# Wait loop up to 60 seconds ensuring MinIO is ready
for i in {1..30}; do
  if podman run --rm --network host quay.io/minio/mc alias set ${ALIAS} ${MINIO_URL} ${MINIO_USER} ${MINIO_PASS} >/dev/null 2>&1; then
    echo "✅ MinIO is up and 'mc' configured!"
    break
  fi
  echo "MinIO not ready yet... sleeping 3s ($i/30)"
  sleep 3
done

echo "📦 Creating buckets..."
for BUCKET in landing processing curated; do
    echo "Creating bucket: ${BUCKET}"
    podman run --rm --network host quay.io/minio/mc mb ${ALIAS}/${BUCKET} --ignore-existing
done

echo "✅ Buckets setup complete!"
podman run --rm --network host quay.io/minio/mc ls ${ALIAS}
