#!/bin/bash

set -e

mc alias set minio http://minio:9000 ${MINIO_ROOT_USER} ${MINIO_ROOT_PASSWORD}

if ! mc ls minio/${MINIO_BUCKET_NAME} >/dev/null 2>&1; then
    echo "Creating ${MINIO_BUCKET_NAME} bucket..."
    mc mb minio/${MINIO_BUCKET_NAME}
    echo "${MINIO_BUCKET_NAME} bucket created successfully"
else
    echo "${MINIO_BUCKET_NAME} bucket already exists"
fi

echo "Setting ${MINIO_BUCKET_NAME} custom policy"

# This policy accepts anonymous objects downloads but not anonymous BucketList
cat > /tmp/policy.json <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {"AWS": ["*"]},
      "Action": ["s3:GetObject"],
      "Resource": ["arn:aws:s3:::${MINIO_BUCKET_NAME}/*"]
    }
  ]
}
EOF

mc anonymous set-json /tmp/policy.json minio/${MINIO_BUCKET_NAME}

echo "Verifying bucket policy..."
mc anonymous get minio/${MINIO_BUCKET_NAME}

echo "Bucket initialization completed successfully."