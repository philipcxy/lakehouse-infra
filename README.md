# Lakehouse Infra
This repo is dedicated to the deployment of the different parts of the lakehouse.

## Nessie Container App
Deploys a container app consisting of 2 containers:
- Nessie catalog
    - REST Api for interacting with the catalog
- Postgres DB 
    - Stores the tracking data for the catalog