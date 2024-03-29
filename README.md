# Koalification.io Helm Charts Repository

Some missing/fixed helm charts we've created that made no sense to be contributed upstream.

## Charts

* [`atlantis`](./stable/atlantis/) - run [Atlantis](https://www.runatlantis.io/) in k8s
* [`cert-manager-umbrella`](./stable/cert-manager-umbrella/) - wraps [official helm chart](https://github.com/jetstack/cert-manager/tree/master/deploy/charts/cert-manager) and add CRD instllation.
* [`zalenium`](./stable/zalenium/) - install [Zalenium](https://opensource.zalando.com/zalenium/)

## Getting Started

### Install Helm

Get the latest [Helm release](https://github.com/kubernetes/helm#install).

### Add Helm chart repository:

```console
helm repo add koalificationio https://koalificationio.github.io/charts/
helm repo update
```

### Search fo available charts

```
helm search | grep koalificationio
```

### Install chart

```console
helm install --name <release-name> --namespace default koalificationio/<chart-name>
```

Check chart's `values.yaml` for available settings and documentation.

## Contributing

Fork, make changes, test them and bump chart version in `Chart.yaml`.

Submit pull request for review.
