# Lakehouse Infra
Code for deploying infrastructure for an Iceberg lakehouse on Azure. 

## Introduction
The primary goal was to achieve "production ready" lakehouse infra for a personal project which doesn't need to be running 24/7. I originally opted for Container Apps and encountered various issues:
- Starting with a container app for Nessie connecting to a Postgress container app in the same envrionment. Whilst this works fine, the storage is of course not persistent so shutting down the apps would result in full loss of data. Therefore...
- I added Azure Files Storage for the Postgres container app but SMB protocol doesn't support `chown` commands which are run by `initdb` on start. Therefore...
- I upgraded the storage to Premium tier in order to enable NFS.

This is the current implementation found in `provision/bicep`.
 
However, the cost of Premium (with the minimum provisioned storage of 100Gb - overkill for this use case) was equivalent to a managed instance of Azure Postgres so I experimented with using that instead. However, the Flexible server offering from Azure - the only option for new instances now that Single server is deprecated - is using SHA 1 root certificate which is incompatible with Nessie.

Many of the issues above could have been worked around but ultimately I decided to move to AKS for more control and flexibility. The costs are low when not running (and can be reduced further by using a Baisc load balancer instead of Standard) and will of course scale with VM size when operating. The manifests can be found in `provision/aks`

## How to run
### Container Apps
There is a Github workflow included which essentially runs the following command:
```
az deployment group create \
                --resource-group {RESOURCE_GROUP} \
                --template-file provision/bicep/nessie-containerapp/main.bicep \
                --parameters provision/bicep/nessie-containerapp/main.bicepparam \
                --parameters dbPasswordSecretValue='{PASSWORD}'
```

### AKS
Assumes an existing cluster. Manifests exist in `provision/aks` and can be applied as usual. For example to deploy Postgres: `kubectl apply -f provision/aks/database/postgres.yaml`