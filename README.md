# Lakehouse Infra

This repository contains infrastructure-as-code (IaC) and supporting resources for deploying and managing a data lakehouse architecture.

## Features

- Automated provisioning of cloud resources
- Modular and reusable infrastructure components
- Support for data lake and data warehouse integration
- Security best practices and monitoring

## Project Structure

```
provision
├── aks/              # Kubernetes definitions and helm chart values
├───── database/      # Generic Postgres deployment (used for Nessie)
├───── helm-values/   # Helm values for different charts
├───── nessie/        # Nessie (Iceberg catalog). Depends on postgres deployment OLD DEPLOYMENT METHOD
├───── spark/         # spark related deployments for a cluster running Spark Connect
├───── storage/       # Volumes and claims to remote (persistent) storage
├───── trader/        # Application deployment (and website)
├── bicep/            # Various resources for a pure PaaS Azure Nessie deployment. Dropped in favour of AKS now.
└── README.md
```

## License

This project is licensed under the MIT License.
