# GKE Helm Deploy

GitHub Action used to deploy in GKE using Helm

## Inputs

## `project_id`

**Required** Google Cloud Project ID.

## `region`

**Required** Google Cloud region.

## `cluster_name`

**Required** Google Cloud Kubernetes cluster name.

## `credentials_json`

**Required** Google Cloud service account JSON credentials

**Nota:** Este parámetro no es requerido si utilizas autenticación OIDC con `google-github-actions/auth`. Ver la sección de ejemplo con OIDC más abajo.

## `chart_path`

Helm Chart directory location (default `.`)

## `chart_name`

**Required** Chart name to be deployed

## `namespace`

Kubernetes namespace for Helm deployment (default `default`)

## `chart_set_values`

Helm deploy `--set` value arguments with comma separated (default ``).

Example:

```yaml
chart_set_values: tag=v0.1.1,app=gke-gateway-api-example
```

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
    namespace: ${{ secrets.GKE_NAMESPACE }}
    app: gke-gateway-api-example
    port: 1323
    healthPath: /health
  chart_set_values: tag=v0.1.1
```

## Ejemplo de uso con autenticación OIDC

```yaml
- id: 'auth'
  name: 'Authenticate to Google Cloud'
  uses: 'google-github-actions/auth@v3'
  with:
    token_format: 'access_token'
    workload_identity_provider: 'projects/123456789/locations/global/workloadIdentityPools/github-pool/providers/github-provider'
    service_account: 'github-sa@my-project.iam.gserviceaccount.com'

- uses: KaribuLab/gke-helm-deploy@v0.1.0
  with:
    project_id: ${{ secrets.GKE_PROJECT_ID }}
    region: ${{ secrets.GKE_REGION }}
    cluster_name: ${{ secrets.GKE_CLUSTER_NAME }}
    # credentials_json no es necesario cuando se usa OIDC
    chart_path: helm
    chart_name: gke-gateway-api-example
    chart_values: |
      image: karibu/gke-gateway-api-example
      namespace: ${{ secrets.GKE_NAMESPACE }}
      app: gke-gateway-api-example
      port: 1323
      healthPath: /health
    chart_set_values: tag=v0.1.1
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
CREDENTIALS_JSON=$( cat credentials.json )
CHART_PATH="helm"
CHART_NAME="your-chart"
CHART_VALUES=$( cat values.yaml )
KUBERNETES_NAMESPACE="default"
docker run -it --rm -v $(pwd):/helm  -w /helm -e GITHUB_OUTPUT=/tmp/.github.output \
  karibu/gke-helm-deploy \
  "${PROJECT_ID}" \
  "${REGION}" \
  "${CLUSTER_NAME}" \
  "${CREDENTIALS_JSON}" \
  "${CHART_PATH}" \
  "${CHART_NAME}" \
  "${CHART_VALUES}" \
  "${KUBERNETES_NAMESPACE}" \
  "tag=v0.1.1"
```