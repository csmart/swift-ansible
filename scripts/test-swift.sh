#!/bin/bash
VIP=${1:-203.0.113.111}
export ST_AUTH=https://${VIP}/auth/v1.0
export ST_KEY="testing"
export ST_USER="test:tester"
CONTAINER="test-${RANDOM}${RANDOM}"
TEST_FILE="${CONTAINER}.file"

if [[ ! -e "/tmp/${TEST_FILE}" ]] ; then
  dd if=/dev/urandom of="/tmp/${TEST_FILE}" bs=1M count=1
fi

echo testing VIP "${VIP}"

echo create container..
swift --insecure post "${CONTAINER}"
echo upload test file..
swift --insecure upload "${CONTAINER}" /tmp/"${TEST_FILE}"
echo list container..
swift --insecure list "${CONTAINER}"
echo delete container..
swift --insecure delete "${CONTAINER}"
