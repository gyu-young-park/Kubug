#!/bin/bash
CMD=""
POD_NAME=""

while getopts "c:p:" opt; do
  case "$opt" in
    c) CMD="$OPTARG" ;;
    p) POD_NAME="$OPTARG" ;;
    *) echo "Usage: $0 -c <command> -p <port>"; exit 1 ;;
  esac
done

echo "Running command: $CMD"
echo "POD: $POD_NAME"

POD_NAME="nginx"
NODE=$(kubectl get po $POD_NAME -o jsonpath='{.spec.nodeName}')
IMAGE=$(kubectl get po $POD_NAME -o jsonpath='{.spec.containers[0].image}')
CRI_CMD="crictl"
NODE_SSH_USER="ec2-user"

NETWORK_NS_ID=""
PID=""

ssh ${NODE_SSH_USER}@${NODE} "bash -s" <<EOF
set -e

if command -v crictl &> /dev/null; then
    echo "coomand: crictl"
    CONTAINER_ID=\$(sudo crictl ps | grep ${POD_NAME} | awk '{print \$1}')
    PID=\$(sudo crictl inspect --output go-template --template '{{.info.pid}}' \$CONTAINER_ID)
else
    echo "coomand: ctr"
    CONTAINER_ID=\$(sudo ctr --namespace k8s.io containers list | grep ${POD_NAME} | awk '{print \$1}')
    PID=\$(sudo ctr --namespace k8s.io task ps \$CONTAINER_ID | awk 'NR==2 {print \$1}')
fi

echo "Using PID: \$PID"
sudo nsenter -t \$PID -n ${CMD}
EOF
