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

```yaml
uses: KaribuLab/gke-helm-deploy@v0.1.0
  with:
    project_id: ${{ secrets.GKE_PROJECT_ID }}
    region: ${{ secrets.GKE_REGION }}
    cluster_name: ${{ secrets.GKE_CLUSTER_NAME }}
    credentials_json: ${{ secrets.GKE_CREDENTIALS }}
    chart_path: helm
    chart_name: gke-gateway-api-example
    chart_values: |
      image: karibu/gke-gateway-api-example
      tag: v0.1.1
      namespace: ${{ secrets.GKE_NAMESPACE }}
      app: gke-gateway-api-example
      port: 1323
      healthPath: /health
```

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