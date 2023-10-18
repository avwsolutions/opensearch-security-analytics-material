helm repo add fluent https://fluent.github.io/helm-charts
helm repo update
helm upgrade --install --values values.yaml fluent-bit fluent/fluent-bit