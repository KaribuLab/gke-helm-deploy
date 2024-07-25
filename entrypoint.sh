#!/bin/bash
PROJECT_ID="$1"
REGION="$2"
CLUSTER_NAME="$3"
credentials_json="$4"
CHART_PATH="$5"
CHART_NAME="$6"
CHART_VALUES="$7"
KUBERNETES_NAMESPACE="$8"
WORKDIR=/home/gke
CREDENTIALS_JSON_PATH="${WORKDIR}/credentials.json"
VALUES_DEPLOY_YAML_PATH="${WORKDIR}/values.deploy.yaml"
echo "Deploying to GKE cluster ${CLUSTER_NAME} in project ${PROJECT_ID} in region ${REGION}"
echo "Using chart ${CHART_NAME} in path ${CHART_PATH} with values:"
echo "------------------------------------------------------------------------"
echo "${CHART_VALUES}"
echo "------------------------------------------------------------------------"
echo "Using namespace: ${KUBERNETES_NAMESPACE}"
echo "$credentials_json" > ${CREDENTIALS_JSON_PATH}
echo "$CHART_VALUES" > ${VALUES_DEPLOY_YAML_PATH}
gcloud config set disable_prompts true > /dev/null 2>&1 # Disable prompts
gcloud auth activate-service-account --key-file=${CREDENTIALS_JSON_PATH} > /dev/null 2>&1 # Authenticate with the service account
gcloud config set project ${PROJECT_ID} > /dev/null 2>&1 # Set the project ID
gcloud container clusters get-credentials ${CLUSTER_NAME} --region=${REGION} > /dev/null 2>&1 # Set the cluster and region
kubectl config set-context --current --namespace=${KUBERNETES_NAMESPACE} # Set the namespace
installed_chart=$( helm list | grep ${CHART_NAME} | awk '{print $1}' ) # Check if the chart is already deployed
if [ -z "$installed_chart" ]; then
    echo "Installing chart: ${CHART_NAME}"
    helm install ${CHART_NAME} ${CHART_PATH} -f ${VALUES_DEPLOY_YAML_PATH} # Install the chart
else
    echo "Upgrading chart: ${CHART_NAME}"
    helm upgrade ${CHART_NAME} ${CHART_PATH} -f ${VALUES_DEPLOY_YAML_PATH} # Upgrade the chart
fi
rm -rf ${CREDENTIALS_JSON_PATH} # Clean up
rm -rf ${VALUES_DEPLOY_YAML_PATH} # Clean up
chart_revision=$( helm list --deployed | grep ${CHART_NAME} | awk '{print $3}' ) # Check if the chart is already deployed
echo "chart_revision=$chart_revision" >> $GITHUB_OUTPUT
