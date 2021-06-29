# drone-k8s-deploy
Drone plugin deploying k8s deployment into a namespace.
This plugin enforces the use of a namespace, and a authentification method file for security.

Currently, authentification include :

* Kubeconfig file
* OIDC

## Configuration

The following parameters can be used to configure the plugin:

- `debug`: Enable debug mode that produce more logs. Default: false
- `kubeconfig`: The config file that contains the user access to a specific namespace.
- `yaml`: The deployment to apply to the cluster.
- `mode`: If mode is `delete`, the deployment if delete from the cluster. Otherwise, it is `apply`.
- `oidc_configuration`: The well_known endpoint to auto-configure OIDC client 
- `oidc_client_id`: ID of the target client used for authentification.
- `oidc_client_secret`: Secret of the target client used for authentification.
- `oidc_username`: The user that will authenticate
- `oidc_password`: The user password used to authenticate.

`kubeconfig` and `oidc_*` parameters are exclusifs. You need to use only one method of authentication at a time. 
Authentification with OIDC need a proper cluster configuration and a OIDC Client configured to allow Direct Access Grant
(aka: [Oauth2 Resource Owner Password Credential Grant](https://datatracker.ietf.org/doc/html/rfc6749#page-9))

### Drone configuration example

#### With kubeconfig
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

#### With OIDC
```yaml
pipeline:

docs:
    image: scandinave/drone-k8s-deploy
    pull: always
    settings:
      yaml: ./config.yaml
      oidc_configuration: <url_to_oidc_provider_well_known_endpoint>
      oidc_client_id: <client_id>
      oidc_client_secret: <client_secret>
      oidc_user_id: <user_id>
      oidc_user_secret: <user_secret>
```


Delete deployment
```yaml
pipeline:

  docs: 
    image: scandinave/drone-k8s-deploy
    pull: always
    settings:
      yaml: ./config.yaml
      kubeconfig:
        from_secret: kubeconfig
      mode: delete
```

The config.yaml file must use a namespace authorized by the kubeconfig

## License

MIT
