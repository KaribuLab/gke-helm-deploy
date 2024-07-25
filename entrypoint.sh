#!/bin/bash
PROJECT_ID="$1"
REGION="$2"
CLUSTER_NAME="$3"
credentials_json="$4"
CHART_PATH="$5"
CHART_NAME="$6"
CHART_VALUES="$7"
KUBERNETES_NAMESPACE="$8"
echo "Deploying to GKE cluster ${CLUSTER_NAME} in project ${PROJECT_ID} in region ${REGION}"
echo "Using chart: ${CHART_NAME} in path ${CHART_PATH} with values ${CHART_VALUES}"
echo "Using namespace: ${KUBERNETES_NAMESPACE}"
echo "$credentials_json" > credentials.json
echo "$CHART_VALUES" > values.deploy.yaml
gcloud config set disable_prompts true
gcloud auth activate-service-account --key-file=credentials.json # Authenticate with the service account
gcloud config set project ${PROJECT_ID} # Set the project ID
gcloud container clusters get-credentials ${CLUSTER_NAME} --region=${REGION} # Set the cluster and region
kubectl config set-context --current --namespace=${KUBERNETES_NAMESPACE} # Set the namespace
installed_chart=$( helm list | grep ${CHART_NAME} | awk '{print $1}' ) # Check if the chart is already deployed
if [ -z "$installed_chart" ]; then
    echo "Installing chart: ${CHART_NAME}"
    helm install ${CHART_NAME} ${CHART_PATH} -f values.deploy.yaml # Install the chart
else
    echo "Upgrading chart: ${CHART_NAME}"
    helm upgrade ${CHART_NAME} ${CHART_PATH} -f values.deploy.yaml # Upgrade the chart
fi
chart_revision=$( helm list --deployed | grep ${CHART_NAME} | awk '{print $3}' ) # Check if the chart is already deployed
echo "chart_revision=$chart_revision" >> $GITHUB_OUTPUT
