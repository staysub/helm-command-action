2# Helm command action

This action executes any helm command supported, command FLAGS included
1. OCI registries : ***Supported***
2. Chartmuseum : ***Supported***
3. Should work for pretty much any other registry (if it doesn't, please open an issue)

## Usage

### `workflow.yml` Example

Place in a `.yml` file such as this one in your `.github/workflows`
folder. [Refer to the documentation on workflow YAML syntax here.](https://help.github.com1/en/articles/workflow-syntax-for-github-actions)

```yaml
name: Run helm dependency update and template in debug mode
on: push

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@master
      - uses: staysub/helm-command-action@master
        env:
          COMMANDS: "dependency update charts/my-chart-dir;template charts/my-chart-dir --debug"
          REGISTRY_URL: "https://registry.url"
          REGISTRY_USER: ${{ secrets.REGISTRY_USER }} #NOT required if you helm repo does not need authorization
          REGISTRY_PASSWORD: ${{ secrets.REGISTRY_PASSWORD }} #NOT required if you helm repo does not need authorization
```

```yaml
name: Run helm dependency update and template with stg values in debug mode using OCI registry
on: push

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@master
      - uses: staysub/helm-command-action@master
        env:
          COMMANDS: "dependency update charts/my-chart-dir;template charts/my-chart-dir --values charts/my-chart-dir/values-stg.yaml --debug"
          REGISTRY_URL: "europe-west1-docker.pkg.dev/my-project-id/my-image-registry/" #DO NOT add the oci protocol `oci://`
          REGISTRY_REPO_NAME: "my-oci-helm-repo"
          OCI_ENABLED_REGISTRY: 'True'  #required for all OCI registries
          REGISTRY_USER: ${{ secrets.REGISTRY_USER }}  #NOT required if you helm repo does not need authorization
          REGISTRY_PASSWORD: ${{ secrets.REGISTRY_PASSWORD }} #NOT required if you helm repo does not need authorization
```

### Configuration

The following settings must be passed as environment variables as shown in the example. Sensitive information,
especially `REGISTRY_USER` and `REGISTRY_PASSWORD`, should
be [set as encrypted secrets](https://help.github.com/en/articles/virtual-environments-for-github-actions#creating-and-using-secrets-encrypted-variables) —
otherwise, they'll be public to anyone browsing your repository.

| Key                            | Value                                                                                                          | Suggested Type | Required |
|--------------------------------|----------------------------------------------------------------------------------------------------------------|----------------|----------|
| `COMMANDS`          | Mutpile commands to be executed. Use `;` to seperate commands. Ommit `helm' at the begining of every command. https://helm.sh/docs/helm/ | `env`          | **Yes**  |
| `REGISTRY_URL`                 | Complete registry url. Avoid adding `oci://` protocol/prefix                                                   | `env`          | **Yes**  |
| `REGISTRY_REPO_NAME`           | Repo name. If emtpy a generic string will be used                                                              | `env`          | No       |
| `REGISTRY_USER`                | Username for registry                                                                                          | `secret`       | No       |
| `REGISTRY_PASSWORD`            | Password for registry                                                                                          | `secret`       | No       |
| `OCI_ENABLED_REGISTRY`         | Set to `True` if your registry is OCI based like (GCP artifact registry). Defaults is `False` if not provided. | `env`          | No       |

## Action versions

- master: helm3 v3.11.2

## License

This project is distributed under the [MIT license](LICENSE.md).
