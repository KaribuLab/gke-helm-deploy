#!/bin/bash
PROJECT_ID="$1"
REGION="$2"
CLUSTER_NAME="$3"
credentials_json="$4"
CHART_PATH="$5"
CHART_NAME="$6"
CHART_VALUES="$7"
KUBERNETES_NAMESPACE="$8"
CHART_SET_VALUES="$9"
WORKDIR=$(pwd)
CREDENTIALS_JSON_PATH="${WORKDIR}/credentials.json"
VALUES_DEPLOY_YAML_PATH="${WORKDIR}/values.deploy.yaml"
echo "Working directory: ${WORKDIR}"
if [ -d "${CHART_PATH}" ]; then
    echo "Chart path exists: ${CHART_PATH}"
else
    echo "Chart path does not exist: ${CHART_PATH}"
    exit 1
fi
echo "Deploying to GKE cluster ${CLUSTER_NAME} in project ${PROJECT_ID} in region ${REGION}"
echo "Using chart ${CHART_NAME} in path ${CHART_PATH} with values:"
echo "------------------------------------------------------------------------"
echo "${CHART_VALUES}"
echo "------------------------------------------------------------------------"
echo "Using namespace: ${KUBERNETES_NAMESPACE}"
echo "$CHART_VALUES" > ${VALUES_DEPLOY_YAML_PATH}
gcloud config set disable_prompts true > /dev/null 2>&1 # Disable prompts
if [ -n "$credentials_json" ]; then
    echo "Authenticating with JSON key..."
    echo "$credentials_json" > ${CREDENTIALS_JSON_PATH}
    gcloud auth activate-service-account --key-file=${CREDENTIALS_JSON_PATH} > /dev/null 2>&1 # Authenticate with the service account
else
    echo "Skipping JSON auth (assuming OIDC authentication is already in place)..." # Skip JSON auth if OIDC authentication is already in place
fi
gcloud config set project ${PROJECT_ID} > /dev/null 2>&1 # Set the project ID
gcloud container clusters get-credentials ${CLUSTER_NAME} --region=${REGION} > /dev/null 2>&1 # Set the cluster and region
kubectl config set-context --current --namespace=${KUBERNETES_NAMESPACE} > /dev/null 2>&1 # Set the namespace
installed_chart=$( helm list | grep ${CHART_NAME} | awk '{print $1}' ) # Check if the chart is already deployed
if [ -z "$installed_chart" ]; then
    if [ -z "$CHART_SET_VALUES" ]; then
        echo "Installing chart: ${CHART_NAME}"
        helm install ${CHART_NAME} ${CHART_PATH} -f ${VALUES_DEPLOY_YAML_PATH} # Install the chart
    else
        echo "Installing chart with extra values: ${CHART_NAME}"
        helm install ${CHART_NAME} ${CHART_PATH} -f ${VALUES_DEPLOY_YAML_PATH} --set ${CHART_SET_VALUES} # Install the chart
    fi
else
    if [ -z "$CHART_SET_VALUES" ]; then
        echo "Upgrading chart: ${CHART_NAME}"
        helm upgrade ${CHART_NAME} ${CHART_PATH} -f ${VALUES_DEPLOY_YAML_PATH} # Upgrade the chart
    else
        echo "Upgrading chart with extra values: ${CHART_NAME}"
        helm upgrade ${CHART_NAME} ${CHART_PATH} -f ${VALUES_DEPLOY_YAML_PATH} --set ${CHART_SET_VALUES} # Upgrade the chart
    fi
fi
if [ -n "$credentials_json" ]; then
    rm -rf ${CREDENTIALS_JSON_PATH} # Clean up
fi
if [ -n "$CHART_VALUES" ]; then
    rm -rf ${VALUES_DEPLOY_YAML_PATH} # Clean up
fi
chart_revision=$( helm list --deployed | grep ${CHART_NAME} | awk '{print $3}' ) # Check if the chart is already deployed
echo "chart_revision=$chart_revision" >> $GITHUB_OUTPUT
