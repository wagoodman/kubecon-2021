# Kubecon 2021 - Syft, Grype, and Tekton

From the Cloud Native Security Conference 2021 talk ["Not-So-Fantastic Leaks, and Where to Find Them In Containers"](https://cloudnativesecurityconna21.sched.com/event/mBn2/not-so-fantastic-leaks-and-where-to-find-them-in-containers-alex-goodman-anchore?iframe=no).

This repo contains a [Tekton](https://tekton.dev/) pipeline and related tasks to build, validate, and publish a container image of a [sample application](https://github.com/wagoodman/count-goober). 

The main concept behind this pipeline is to build your image and perform all validations before publishing to your registry. Validations are typically much faster to perform on an SBOM generated from your image rather than continually operating on the image for each validation. Additionally, this means you get an SBOM of your container image that you can publish at the end of your pipeline.

Image building is done with [Kaniko](https://github.com/GoogleContainerTools/kaniko), SBOM generation and secrets scanning with [Syft](https://github.com/anchore/syft), vulnerability scanning with [Grype](https://github.com/anchore/syft), container image publishing with [Skopeo](https://github.com/containers/skopeo), and SBOM attachment and publishing with [Cosign](https://github.com/sigstore/cosign).


## Getting started

You will need:
- A kubernetes cluster (1.20+ preferred)


If you plan to publish to a registry, then you will need to set the following environment variables on your host:
- `CONTAINER_REGISTRY_SERVER` (e.g. 'https://ghcr.io')
- `CONTAINER_REGISTRY_USER`
- `CONTAINER_REGISTRY_PASSWORD`

## Usage

1. Install tekton:
    
    ```bash
    make install-tekton
    ```

2. Install pipeline and tasks
    ```bash
    make install
    ```

3. Run the pipeline for all scenarios (one run with quality gate failures, another run after remediations):
    ```bash
    make run-all-scenarios
    ```

If you want to follow along in the Tekton dashboard UI and you have a local Kubernetes cluster:

- Run a proxy:
    ```bash
    kubectl proxy
    ```

- Head to [`http://localhost:8001/api/v1/namespaces/tekton-pipelines/services/tekton-dashboard:http/proxy/#/pipelineruns`](http://localhost:8001/api/v1/namespaces/tekton-pipelines/services/tekton-dashboard:http/proxy/#/pipelineruns)


## Teardown

1. Uninstall tekton:
    
    ```bash
    make iunnstall-tekton
    ```