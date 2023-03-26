2# Helm command action

This action executes any desired command you want after login in your registry
1. OCI registries : ***Supported***
2. Chartmusem : ***Supported***
3. Should work for pretty much any other registry (if it doesn't, please open an issue)

## Usage

### `workflow.yml` Example

Place in a `.yml` file such as this one in your `.github/workflows`
folder. [Refer to the documentation on workflow YAML syntax here.](https://help.github.com/en/articles/workflow-syntax-for-github-actions)

```yaml
name: Basic Build & Push ecs-exporter chart
on: push

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@master
      - uses: staysub/helm-push-action@master
        env:
          COMMANDS: |
                      helm template charts/my-chart-dir/.
          REGISTRY_URL: 'https://registry.url'
          REGISTRY_USER: ${{ secrets.REGISTRY_USER }} #NOT required if you helm repo does not need authorization
          REGISTRY_PASSWORD: ${{ secrets.REGISTRY_PASSWORD }} #NOT required if you helm repo does not need authorization
```

```yaml
name: Build & Push multiple charts in different directories & push all to OCI REGISTRY
on: push

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@master
      - uses: staysub/helm-push-action@master
        env:
          COMMANDS: 'parent-dir/sub-dir-with-chart:first-level-dir-with-chart:.dot-dir/my-chart-dir'
          REGISTRY_URL: 'europe-west1-docker.pkg.dev/my-project-id/my-image-registry/' #DO NOT add the oci protocol "oci://"
          REGISTRY_REPO_NAME: 'my-oci-helm-repo'
          OCI_ENABLED_REGISTRY: 'True'  #required for all OCI registries
          REGISTRY_USER: ${{ secrets.REGISTRY_USER }}  #NOT required if you helm repo does not need authorization
          REGISTRY_PASSWORD: ${{ secrets.REGISTRY_PASSWORD }} #NOT required if you helm repo does not need authorization
```

### Configuration

The following settings must be passed as environment variables as shown in the example. Sensitive information,
especially `REGISTRY_USER` and `REGISTRY_PASSWORD`, should
be [set as encrypted secrets](https://help.github.com/en/articles/virtual-environments-for-github-actions#creating-and-using-secrets-encrypted-variables) —
otherwise, they'll be public to anyone browsing your repository.

| Key                            | Value                                                                                                                                                        | Suggested Type | Required |
|--------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------|----------------|----------|
| `COMMANDS`          | One or more directories paths where Chart.yaml can be found. Paths are seperated by the character `:`                                                        | `env`          | **Yes**  |
| `REGISTRY_URL`                 | Complete registry url. Avoid adding `oci://` protocol/prefix                                                                                                 | `env`          | **Yes**  |
| `REGISTRY_REPO_NAME`           | Repo name. If emtpy a generic string will be used                                                                                                            | `env`          | No       |
| `REGISTRY_USER`                | Username for registry                                                                                                                                        | `secret`       | No       |
| `REGISTRY_PASSWORD`            | Password for registry                                                                                                                                        | `secret`       | No       |
| `OCI_ENABLED_REGISTRY`         | Set to `True` if your registry is OCI based like (GCP artifact registry). Defaults is `False` if not provided.                                               | `env`          | No       |
| `HELM_INSPECT_FLAGS`           | Combination of helm inspect supported flags. https://helm.sh/docs/helm/helm_inspect/      | `env`          | No       |
| `HELM_DEPENDENCY_UPDATE_FLAGS` | Combination of helm dependency update supported flags. https://helm.sh/docs/helm/dependency_update/ | `env`          | No       |
| `HELM_PACKAGE_FLAGS`           | Combination of helm package supported flags. https://helm.sh/docs/helm/helm_package/      | `env`          | No       |
| `HELM_PUSH_FLAGS`              | Combination of helm push supported flags. https://helm.sh/docs/helm/helm_push/          | `env`          | No       |

## Action versions

- master: helm3 v3.11.2

## License

This project is distributed under the [MIT license](LICENSE.md).
