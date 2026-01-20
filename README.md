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

## `chart_values_file`

Ruta al archivo de valores de Helm (values file). Si se proporciona, se utilizará en lugar de `chart_values` (default ``).

**Nota:** Si se proporciona `chart_values_file`, tendrá prioridad sobre `chart_values`.

Ejemplo:

```yaml
chart_values_file: helm/values.yaml
```

## `chart_set_values`

Helm deploy `--set` value arguments with comma separated (default ``).

Example:

```yaml
chart_set_values: tag=v0.1.1,app=gke-gateway-api-example
```

## `verbose`

Habilita el modo verbose para mostrar la salida de los comandos de `gcloud` y `kubectl` (default `false`).

Cuando está habilitado, se mostrará la salida completa de:
- `gcloud config set disable_prompts`
- `gcloud auth activate-service-account`
- `gcloud config set project`
- `gcloud container clusters get-credentials`
- `kubectl config set-context`

Example:

```yaml
verbose: "true"
```

## Outputs

## `chart_revision`

Helm chart revision.

## Example usage

```yaml
uses: KaribuLab/gke-helm-deploy@v0.8.0
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
  verbose: "false"  # Opcional: muestra la salida de comandos gcloud y kubectl
```

### Ejemplo usando archivo de valores

```yaml
uses: KaribuLab/gke-helm-deploy@v0.8.0
with:
  project_id: ${{ secrets.GKE_PROJECT_ID }}
  region: ${{ secrets.GKE_REGION }}
  cluster_name: ${{ secrets.GKE_CLUSTER_NAME }}
  credentials_json: ${{ secrets.GKE_CREDENTIALS }}
  chart_path: helm
  chart_name: gke-gateway-api-example
  chart_values_file: helm/values.yaml
  chart_set_values: tag=v0.1.1
  verbose: "false"  # Opcional: muestra la salida de comandos gcloud y kubectl
```

### Ejemplo con modo verbose habilitado

```yaml
uses: KaribuLab/gke-helm-deploy@v0.8.0
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
  verbose: "true"  # Muestra la salida completa de comandos gcloud y kubectl
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

- uses: KaribuLab/gke-helm-deploy@v0.8.0
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
    verbose: "false"  # Opcional: muestra la salida de comandos gcloud y kubectl
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
CHART_SET_VALUES="tag=v0.1.1"
CHART_VALUES_FILE=""
VERBOSE="false"  # Opcional: "true" para modo verbose
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
  "${CHART_SET_VALUES}" \
  "${CHART_VALUES_FILE}" \
  "${VERBOSE}"
```