# k8s-logging-challenge
## Install required tools
```bash
$ brew install terraform
$ brew install kubernetes-helm
$ brew install kubernetes-cli
$ brew install kubectx
$ brew install aws-iam-authenticator
```
## Depoy AWS EKS cluster using terrafrom

### Clone repo locally
```bash
$ git clone https://github.com/savealive/k8s-logging-challenge.git
$ cd k8s-logging-challenge
```
### Init Terraform config
```bash
$ terraform init

Initializing provider plugins...
- Checking for available provider plugins on https://releases.hashicorp.com...
- Downloading plugin for provider "aws" (2.3.0)...

The following providers do not have any version constraints in configuration,
so the latest version was installed.

To prevent automatic upgrades to new major versions that may contain breaking
changes, it is recommended to add version = "..." constraints to the
corresponding provider blocks in configuration, with the constraint strings
suggested below.

* provider.aws: version = "~> 2.3"

Terraform has been successfully initialized!
```
### Apply TF config
Specify the region you'd like to run your cluster (I used eu-central-1 (Frankfurt))
```bash
$ terraform apply
provider.aws.region
  The region where AWS operations will take place. Examples
  are us-east-1, us-west-2, etc.

  Default: us-east-1
  Enter a value: eu-central-1
  ...
  <OUTPUT OMITED>
Apply complete! Resources: 0 added, 0 changed, 0 destroyed.

Outputs:

config_map_aws_auth =

apiVersion: v1
kind: ConfigMap
metadata:
  name: aws-auth
  namespace: kube-system
data:
  mapRoles: |
    - rolearn: arn:aws:iam::011767806754:role/terraform-eks-kube-node
      username: system:node:{{EC2PrivateDNSName}}
      groups:
        - system:bootstrappers
        - system:nodes

kubeconfig =

apiVersion: v1
clusters:
- cluster:
    server: https://149C0F603E5F04A2E155935826CFC276.sk1.eu-central-1.eks.amazonaws.com
    certificate-authority-data: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUN5RENDQWJDZ0F3SUJBZ0lCQURBTkJna3Foa2lHOXcwQkFRc0ZBREFWTVJNd0VRWURWUVFERXdwcmRXSmwKY201bGRHVnpNQjRYRFRFNU1ETXlNakE1TURZek1Gb1hEVEk1TURNeE9UQTVNRFl6TUZvd0ZURVRNQkVHQTFVRQpBeE1LYTNWaVpYSnVaWFJsY3pDQ0FTSXdEUVlKS29aSWh2Y05BUUVCQlFBRGdnRVBBRENDQVFvQ2dnRUJBTFRpCmNyZjJ2VCtEMENYSWhKUkRLL05qZTRRcXdZbmtzL00rdnd6bXFYUGZsNlNuYjI0TG54VWZVYlF1ZFowVjVVcW0KaDdVNmJxUzRBamV5enVpdDNXZjlwbVUvRzhZRVZPd2dwWis5YVNyZlZWT2gyUXZGSWo5SG5xeXl0VTFGbFFnZgpQQnhSQW9HcC91bTlBRVdyK3lqZ1E5QXNGWk8rNUlrUjZTSm9Kdi9MRmdMdlN5a2xIK3VzcklPWjFIS2dhN2kvCktXZ0N3ZGdpeWp2d3p6QmxNSGRkeFpncHlZYndOcElFQm13NmNOcUxJTUp6V1NtdTd0Ukd2cWZOSmJBdytTOUcKbjh6eEowYTV1SEgzVVc2MUZLWS9YUXFoeVhZUnVrMHAzUjc0RTVLTWc5d0pVVUZ1aWdQNmg1YUlFQVVKZTBsYwpnakVYSTFNYkpTT2UvWGdzSVJrQ0F3RUFBYU1qTUNFd0RnWURWUjBQQVFIL0JBUURBZ0trTUE4R0ExVWRFd0VCCi93UUZNQU1CQWY4d0RRWUpLb1pJaHZjTkFRRUxCUUFEZ2dFQkFDNVZvalBaQnRUeEpiK3QyeDlvbUxWbi91bVIKZEVQYUVaSXZUQnNGUGlPZWh0U3JlRSsxNXByQWk4Tm1BR1hMQnQ1dnpzc0dpT3JJK01iZ0Zhcm9xZEk1WEhWaQozR1p0K21RM0ZQVHF2RGtUekJqM1FTQ0FpRzhmZFBBdzJ5SXF1MC81VktUVGlMRVhiZWlEbU5EY0t4eHduamdsCnhUeTV6QkR4NDY4L042bDVialRHYUFXMnAwS2JtWGJGRGVrVXNiQXFZYjhEd3RsMXBpQy9EdVE1UVNYNmdGcXcKV29TZ1VBWndvZE9oSm5ROUJST21UMUtpWGVuK3dISUx4OWRTcXpZTWdMWlVDbUdibUFESlBIRXBlSXM5TjBwNAo2TGFiVEtBRzhGV29kd09pNGFpVlJtaUNHdjBOQkhqaVJQbnBhVXlka0ZPaUUxQk9UVUpDd3c4aElyTT0KLS0tLS1FTkQgQ0VSVElGSUNBVEUtLS0tLQo=
  name: kubernetes
contexts:
- context:
    cluster: kubernetes
    user: aws
  name: aws
current-context: aws
kind: Config
preferences: {}
users:
- name: aws
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1alpha1
      command: aws-iam-authenticator
      args:
        - "token"
        - "-i"
        - "eks-cluster"
```
Copy contents of tf output config_map_aws_auth into config_map_aws_auth.yaml and contents of kubeconfig into ~/.kube/config

Once done run 
```bash
$ kubectl apply -f config_map_aws_auth.yaml
```
After this step "kubectl get node" should return at least something. 
```bash
$ kubectl get node
NAME                                         STATUS   ROLES    AGE   VERSION
ip-10-0-0-7.eu-central-1.compute.internal    Ready    <none>   1h    v1.11.5
ip-10-0-1-59.eu-central-1.compute.internal   Ready    <none>   1h    v1.11.5
```
## Setup Helm
### Create account and rbac roles
```bash
kubeclt apply -f helm-install/helm-rbac.yaml
```
### Init Tiller
```bash
helm init --history-max 200 --service-account tiller
$HELM_HOME has been configured at /Users/et0888/.helm.
Tiller (the Helm server-side component) has been installed into your Kubernetes Cluster.

Please note: by default, Tiller is deployed with an insecure 'allow unauthenticated users' policy.
To prevent this, run `helm init` with the --tiller-tls-verify flag.
For more information on securing your installation see: https://docs.helm.sh/using_helm/#securing-your-helm-installation
Happy Helming!
```
## ELK components
### Deploy Elasticsearch cluster
We're about to setup cluster with 1 client node, 3 master nodes and 1 data node.
```bash
$ helm install --name elk-stack --namespace elk-stack stable/elasticsearch -f charts-values/elasticsearch-values.yaml                           
NAME:   elk-stack
LAST DEPLOYED: Fri Mar 22 13:11:23 2019
NAMESPACE: elk-stack
STATUS: DEPLOYED

RESOURCES:
==> v1/ConfigMap
NAME                     DATA  AGE
elk-stack-elasticsearch  4     0s

==> v1/Pod(related)
NAME                                             READY  STATUS    RESTARTS  AGE
elk-stack-elasticsearch-client-546b99b6d4-5z6z8  0/1    Init:0/1  0         0s
elk-stack-elasticsearch-data-0                   0/1    Pending   0         0s
elk-stack-elasticsearch-master-0                 0/1    Pending   0         0s

==> v1/Service
NAME                               TYPE       CLUSTER-IP      EXTERNAL-IP  PORT(S)   AGE
elk-stack-elasticsearch-client     ClusterIP  172.20.113.196  <none>       9200/TCP  0s
elk-stack-elasticsearch-discovery  ClusterIP  None            <none>       9300/TCP  0s

==> v1/ServiceAccount
NAME                            SECRETS  AGE
elk-stack-elasticsearch-client  1        0s
elk-stack-elasticsearch-data    1        0s
elk-stack-elasticsearch-master  1        0s

==> v1beta1/Deployment
NAME                            READY  UP-TO-DATE  AVAILABLE  AGE
elk-stack-elasticsearch-client  0/1    1           0          0s

==> v1beta1/StatefulSet
NAME                            READY  AGE
elk-stack-elasticsearch-data    0/1    0s
elk-stack-elasticsearch-master  0/3    0s


NOTES:
The elasticsearch cluster has been installed.

Elasticsearch can be accessed:

  * Within your cluster, at the following DNS name at port 9200:

    elk-stack-elasticsearch-client.elk-stack.svc

  * From outside the cluster, run these commands in the same shell:

    export POD_NAME=$(kubectl get pods --namespace elk-stack -l "app=elasticsearch,component=client,release=elk-stack" -o jsonpath="{.items[0].metadata.name}")
    echo "Visit http://127.0.0.1:9200 to use Elasticsearch"
    kubectl port-forward --namespace elk-stack $POD_NAME 9200:9200
```
To check cluster status forward its port with "kubectl port-forward" and check Elasticsearch API
```bash
kubectl port-forward svc/elk-stack-elasticsearch-client 9200:9200
```
In another console check health using curl
```bash
curl -s 'localhost:9200/_cluster/health?pretty'
{
  "cluster_name": "elasticsearch-logging",
  "status": "yellow",
  "timed_out": false,
  "number_of_nodes": 5,
  "number_of_data_nodes": 1,
  "active_primary_shards": 6,
  "active_shards": 6,
  "relocating_shards": 0,
  "initializing_shards": 0,
  "unassigned_shards": 5,
  "delayed_unassigned_shards": 0,
  "number_of_pending_tasks": 0,
  "number_of_in_flight_fetch": 0,
  "task_max_waiting_in_queue_millis": 0,
  "active_shards_percent_as_number": 54.54545454545454
}
```
Disregard it's "yellow" status, it's because we have only one data node. In prod env we should have more than one data node.
For testing purposes it's also possible to change "number_of_replicas" to 0. Use following curl command:
```bash
# Update index settings:
$ curl -X PUT -H 'Content-Type: application/json' 'http://localhost:9200/logstash-2019.03.22/_settings' -d'
{
    "index" : {
        "number_of_replicas" : 0
    }
}'
# Now health status returns "green"
{
  "cluster_name" : "elasticsearch-logging",
  "status" : "green",
  "timed_out" : false,
  ...

# To apply it on index creation phase (overrides default number_of_replicas=2):
$ curl -XPOST -H 'Content-Type: application/json' 'http://localhost:9200/_template/all' -d'
{
  "template": "logstash*",
  "settings": {
    "number_of_replicas": 0
  }
}'
# Must return {"acknowledged":true}
# verify
$ curl -s 'localhost:9200/_template/all' | jq .
{
  "all": {
    "order": 0,
    "index_patterns": [
      "logstash*"
    ],
    "settings": {
      "index": {
        "number_of_replicas": "0"
      }
    },
    "mappings": {},
    "aliases": {}
  }
}
```

### Deploy Kibana
We don't configure external access and auth as it's just a simple example. 
```bash
 helm install --name kibana --namespace elk-stack stable/kibana -f charts-values/kibana-values.yaml
NAME:   kibana
LAST DEPLOYED: Fri Mar 22 15:42:53 2019
NAMESPACE: elk-stack
STATUS: DEPLOYED

RESOURCES:
==> v1/ConfigMap
NAME    DATA  AGE
kibana  1     0s

==> v1/Pod(related)
NAME                    READY  STATUS    RESTARTS  AGE
kibana-5855595bc-hpbmq  0/1    Init:0/1  0         0s

==> v1/Service
NAME    TYPE       CLUSTER-IP    EXTERNAL-IP  PORT(S)  AGE
kibana  ClusterIP  172.20.8.221  <none>       443/TCP  0s

==> v1beta1/Deployment
NAME    READY  UP-TO-DATE  AVAILABLE  AGE
kibana  0/1    1           0          0s


NOTES:
To verify that kibana has started, run:

  kubectl --namespace=elk-stack get pods -l "app=kibana"

Kibana can be accessed:

  * From outside the cluster, run these commands in the same shell:

    export POD_NAME=$(kubectl get pods --namespace elk-stack -l "app=kibana,release=kibana" -o jsonpath="{.items[0].metadata.name}")
    echo "Visit http://127.0.0.1:5601 to use Kibana"
    kubectl port-forward --namespace elk-stack $POD_NAME 5601:5601
```
Once started follow chart instructions and then open http://127.0.0.1:5601 in browser. 
## Deploy Fluent logging agent
It's very simple config which by default collects logs from cluster and running pods and sends then into ELK.
```bash
$ helm install --name fluentd --namespace elk-stack stable/fluentd-elasticsearch -f charts-values/fluentd-elastic-values.yaml
NAME:   fluentd
LAST DEPLOYED: Fri Mar 22 15:23:59 2019
NAMESPACE: elk-stack
STATUS: DEPLOYED

RESOURCES:
==> v1/ClusterRole
NAME                           AGE
fluentd-fluentd-elasticsearch  0s

==> v1/ClusterRoleBinding
NAME                           AGE
fluentd-fluentd-elasticsearch  0s

==> v1/ConfigMap
NAME                           DATA  AGE
fluentd-fluentd-elasticsearch  6     0s

==> v1/DaemonSet
NAME                           DESIRED  CURRENT  READY  UP-TO-DATE  AVAILABLE  NODE SELECTOR  AGE
fluentd-fluentd-elasticsearch  2        2        0      2           0          <none>         0s

==> v1/Pod(related)
NAME                                 READY  STATUS             RESTARTS  AGE
fluentd-fluentd-elasticsearch-ddf6n  0/1    ContainerCreating  0         0s
fluentd-fluentd-elasticsearch-h6pwx  0/1    ContainerCreating  0         0s

==> v1/ServiceAccount
NAME                           SECRETS  AGE
fluentd-fluentd-elasticsearch  1        0s


NOTES:
1. To verify that Fluentd has started, run:

  kubectl --namespace=elk-stack get pods -l "app.kubernetes.io/name=fluentd-elasticsearch,app.kubernetes.io/instance=fluentd"

THIS APPLICATION CAPTURES ALL CONSOLE OUTPUT AND FORWARDS IT TO elasticsearch . Anything that might be identifying,
including things like IP addresses, container images, and object names will NOT be anonymized.
```
Now we can check out logs in Kibana.