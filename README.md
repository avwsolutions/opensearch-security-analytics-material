# Demo material for Meetup talk about OpenSearch Security Analytics

This repo contains all material that is discussed in the Meetup about OpenSearch SIEM with Fluent Bit on Kubernetes.

Some notes to keep in mind.

**Note: This setup is only for demo purposes and is NOT DESIGNED FOR PRODUCTION USE**
**Note: For simplicity we use the default credentials this is STRONGLY NOT ADVISABLE FOR PRODUCTION USE**

## Architecture design

Below an overview of the architecture design and main components used.

<img src="https://raw.githubusercontent.com/avwsolutions/opensearch-security-analytics-material/architecture-opensearch-dataprepper-fluentbit-stack.png" alt="Architecture Overview">

Main components are:
- Opster OpenSearch Operator
- OpenSearch + OpenSearch Dashboards
- OpenSearch Data Prepper
- Fluent Bit

Let's call it the **Opensearch-Dataprepper-Fluentbit** stack :)

## Steps to deploy the platform on GKE for evaluation

### 01 - Create your Kubernetes cluster with Terraform

Prereqs:
- Ensure you have a *project* available on Google Cloud to use.
- Ensure that you have enabled the Kubernetes API (for GKE) on Google Cloud.
- Optionally change the deployment region and zone in the *provider.tf*.

```
cd gke-terraform-example
./prepare_gcloud.sh playground-s-11-c6973de1
terraform init
terraform plan
terraform apply
```

When the cluster deployment is ready, let's set the *kubectl* configuration.

```
./kubectl_gcloud.sh playground-s-11-c6973de1
```

Check if everything is working as expected.

```
kubectl get nodes
```

### 02 - Deploy the sysctl-conf-loader

Prereqs:
- Kubectl API connection is setup

Before we can deploy an OpenSearch cluster we need to set *vm.max_map_count=262144*.  For this demo setup we use an privileged DaemonSet called *sysctl-conf-loader*.  Let's deploy this.

```
cd sysctl-conf-loader
./deploy_loader.sh
```

Check with if the pods are *Running* ok  and logs don't contain errors.

```
kubectl get pods -w
```

After all pods  are ok, grep the public IP address, go to **http://<public-ip>:5601** and login with *admin/admin*. Please update the password asap. If things are not working well, please check the potential bug.

```
kubectl get svc | grep 5601
kubectl logs ds/sysctl-conf-loader
```

### 03 - Deploy OpenSearch components

Prereqs:
- Sysctl conf loader is running to increase the map count.

Let's start deploying the Opster OpenSearch Operator. After a this we can create our sandbox cluster called *sandbox-security-analytics*.
Give it a try!

```
cd opensearch-operator
./deploy_operator.sh
./create_cluster.sh
```

Check with if the pods are *Running* ok and logs don't contain errors.

```
kubectl get pods -w
kubectl logs sts/sandbox-security-analytics-nodes
kubectl logs deploy/sandbox-security-analytics-dashboards
```

### 04 - Deploy Data Prepper

Prereqs:
- Running and available OpenSearch cluster.
- IF you changed the password, this must be updated in the **sandbox-ingest-dataprepper.yaml**.

Ready to get started with Data Prepper? Did you already successfully logged into OpenSearch dashboards? Give this a try first, other continue.

```
cd data-prepper
./deploy_dataprepper.sh
```

Check with if the pods are *Running* ok and logs don't contain errors.

```
kubectl get pods -w
kubectl logs deploy/data-prepper
```

### 05 - Deploy COS Auditd Fluent-Bit collector

Prereqs:
- Running and available Data Prepper with OpenSearch backend.
- IF you changed the password, you have to use the new password for injecting the index template.

Ready to get started with your first Fluent Bit? Let's continue.

```
cd fluent-bit/cos-auditd-ds
kubectl cp logs-template.json sandbox-security-analytics-nodes-0:/tmp
kubectl exec sandbox-security-analytics-nodes-0 -it -- bash
 curl -XPUT -ku admin -H 'Content-Type: application/json' https://localhost:9200/_index_template/logs-fluentd -d@/tmp/logs-template.json
 exit
./create_auditd_ds.sh
```

Check with if the pods are *Running* ok and logs don't contain errors.

```
kubectl get pods -w -n cos-auditd
kubectl logs ds/cos-auditd-logging -n cos-auditd
```

### 06 - Deploy K8S Fluent-Bit collector

Prereqs:
- Running and available Data Prepper with OpenSearch backend.

Ready to get started with your first Fluent Bit? Let's continue. If  needed you can update the *values.yaml*.

```
cd fluent-bit/k8s-logs-ds
./create_k8s_ds.sh
```

Check with if the pods are *Running* ok and logs don't contain errors.

```
kubectl get pods -w
kubectl logs ds/fluent-bit
```

### 07 - Finalize OS Dashboards configuration

You have the setup up and running. Check with *Dev Tools* if indices are created (logs-auditd, logs-node, logs-k8s) and _doccount is increasing.
If you want to use *Discover*, you may have to add three *Index Patterns* in *OS Dashboards Configuration*.

Now it's time to play around with Log and Security Analytics using OpenSearch!!!