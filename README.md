# GKE Helm Deploy

GitHub Action used to deploy in GKE using Helm

## Inputs

## `project_id`

**Required** Google Cloud Project ID.

## `region`

**Required** Google Cloud region.

## `cluster_name`

**Required** Google Cloud Kubernetes cluster name.

## Outputs

## `chart_revision`

Helm chart revision.

## Example usage

uses: actions/hello-world-docker-action@v2
with:
  project_id:
  region:
  cluster_name:
  credentials_json: ${{ secrets.CREDENTIALS_JSON }}
  chart_path: "."
  chart_name:
  chart_values: 
  namespace: "default"

## Development

### Local Testing

```shell
docker build -t karibu/gke-helm-deploy .
```

```shell
PROJECT_ID="your-gcp-project-id"
REGION="us-central1"
CLUSTER_NAME="your-gke-cluster-name"
CREDENTIALS_FILE=$( cat credentials.json )
CHART_PATH="."
CHART_NAME="your-chart"
CHART_VALUES=$( cat values.yaml )
KUBERNETES_NAMESPACE="default"
docker run -it --rm karibu/gke-helm-deploy $PROJECT_ID $REGION $CLUSTER_NAME "$CREDENTIALS_JSON" $CHART_PATH $CHART_NAME $CHART_VALUES $KUBERNETES_NAMESPACE
```