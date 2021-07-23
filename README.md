# drone-k8s-deploy
Drone plugin deploying k8s deployment into a namespace.
This plugin enforces the use of a namespace, and an authentification method file for security.

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

The only provider tested if Keycloak, but this plugin should work with other provider.

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
      oidc_username: <user_id>
      oidc_password: <user_secret>
```

For this method to work, you also need a proper keycloak and k8s cluster configured. 

##### K8S configuration

You need to edit the `/etc/kubernetes/manifests/kube-apiserver.yaml` and add the following line to the
`spec.containers.command.kube-apiserver` section of the manifest:

```yaml
    - --oidc-issuer-url=<url_of_id_provider>
    - --oidc-client-id=<client_id>
    - --oidc-username-claim=preferred_username
    - --oidc-username-prefix="oidc:"
    - --oidc-groups-claim=groups
    - --oidc-groups-prefix="oidc:"
```

As you can see, Kubernetes supports RBAC for users and groups.

You also need to define a `Role/ClusterRole` and `RoleBinding\ClusterRoleBinging` to allow `user` or `group` to make actions
on the cluster.

For example, we can create the following `ClusterRoleBinding` that uses the default Role `cluster-admin` to grant to a group,
the full control on the cluster.

```yaml
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: oidc-cluster-admin
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- apiGroup: rbac.authorization.k8s.io
  kind: Group
  name: "\"oidc:\"cluster-admin"
```

Note the prefix `\"oidc:\"` add to the name that need to correspond to the value : `--oidc-groups-prefix="oidc:"`

##### Keycloak configuration

Create a new `Public` Client inside your Realm. Kubernetes does not seem to handle `Confidential` as of now.
Direct Access Grant must be enabled to allow Drone to connect directly on your behalf without browser login prompt.

If you want groups authorizations, you also need to add a mappers with the following value: 

* client ID: <your-client-id>
* Multivalued: true
* Token Claim Names : groups
* Claim JSON Type: String
* Add to ID token : On # Kubernetes use ID Token
* Add to Access token : On
* Add to userinfo: On

Next you need to create client roles. For example, to grant a user full access to all the cluster, you can create a role
with the following properties :

* Role Name: cluster-admin
* Description : Role that grant full access to the K8S cluster
* Composite: Off

Finally, you need to give this role to a user and pass this user credential to the drone plugin, to be able to deploy
to the cluster.

#### Delete deployment
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

The config.yaml file must use a namespace authorized by clusterRoleBinding

## License

MIT
