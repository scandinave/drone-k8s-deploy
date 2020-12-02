# drone-k8s-deploy
Drone plugin deploying k8s deployment into a namespace.
This plugin enforces the use of a namespace, and a kubeconfig file for security.

## Configuration

The following parameters can be used to configure the plugin:

- `kubeconfig`: The config file that contains the user access to a specific namespace.
- `yaml`: The deployment to apply to the cluster.

### Drone configuration example

```yaml
pipeline:

  docs: 
    image: scandinave/drone-k8s-deploy
    pull: always
    settings:
      yaml: ./config.yaml
      kubeconfig:
        from_secret: kubeconfig
```

The config.yaml file must use a namespace authorized by the kubeconfig

## License

MIT
