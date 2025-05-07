#!/bin/bash
CMD=""
POD_NAME=""
NODE=""
NODE_SSH_USER="ec2-user"
NAMESPACE="default"

function get_parameter() {
  while getopts "c:p:n:" opt "$@"; do
    case "$opt" in
      c) CMD="$OPTARG" ;;
      p) POD_NAME="$OPTARG" ;;
      n) NAMESPACE="$OPTARG" ;;
      *) echo "Usage: $0 -c <command> -p <pod> -n <namespace>"; exit 1 ;;
    esac
  done

  echo "Running command: $CMD"
  echo "POD: $POD_NAME"
  echo "Namesapce: $NAMESPACE"

  NODE=$(kubectl get po $POD_NAME -n ${NAMESPACE} -o jsonpath='{.spec.nodeName}')
  IMAGE=$(kubectl get po $POD_NAME -n ${NAMESPACE} -o jsonpath='{.spec.containers[0].image}')

  echo "Node: ${NODE}"
  echo "Image: ${IMAGE}"
}

function execute_command_in_container_namespace() {
  ssh ${NODE_SSH_USER}@${NODE} "bash -s" <<EOF
set -e

if command -v crictl &> /dev/null; then
    echo "command: crictl"
    CONTAINER_ID=\$(sudo crictl ps | grep ${POD_NAME} | awk '{print \$1}')
    PID=\$(sudo crictl inspect --output go-template --template '{{.info.pid}}' \$CONTAINER_ID)
else
    echo "command: ctr"
    CONTAINER_ID=\$(sudo ctr --namespace k8s.io containers list | grep ${POD_NAME} | awk '{print \$1}')
    PID=\$(sudo ctr --namespace k8s.io task ps \$CONTAINER_ID | awk 'NR==2 {print \$1}')
fi

echo "Using PID: \$PID"
sudo stdbuf -oL -eL nsenter -t \$PID -n ${CMD}
EOF
}

get_parameter "$@"
execute_command_in_container_namespace