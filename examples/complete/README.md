# Complete CloudQuery Example (Infrastructure + Helm)

The configuration in this directory create complete setup of CloudQuery on top of GKE, CloudSQL and helm charts installed.

## Usage

Create the resources:

```
terraform init
terraform plan
terraform apply

gcloud container clusters get-credentials cloudquery-complete-example --zone us-east1 --project cq-playground

# This should print helpers from the helm
helm get notes cloudquery-complete-example --namespace cloudquery

# exec into cloudquery-admin pod
kubectl exec -it deployment/cloudquery-complete-example-admin -n cloudquery -- /bin/sh

# kickoff cronjob
kubectl create job --from=cronjob/cloudquery-complete-example-cron cloudquery-complete-example-cron -n cloudquery

# uninstall cloudquery
helm uninstall cloudquery-complete-example -n cloudquery

```



Destroy the resources:

```
terraform destroy
```
