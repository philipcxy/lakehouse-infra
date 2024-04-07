metadata description = 'Creates a container with Postgres dev service'

param appEnvName string = 'nessie-app-env'
param location string = resourceGroup().location

param nessiePort int = 19120
param dbPort int = 5432

param dbPasswordSecretName string = 'db-password'
@secure()
param dbPasswordSecretValue string
param dbName string = 'nessie'
param dbUser string = 'nessie_user'

resource containerAppEnv 'Microsoft.App/managedEnvironments@2023-11-02-preview' = {
  name: appEnvName
  location: location
  properties: {}
}

resource nessieCatalog 'Microsoft.App/containerApps@2023-11-02-preview' = {
  location: location
  name: 'nessie'
  properties: {
    configuration: {
      ingress: {
        external: true
        targetPort: nessiePort
        transport: 'auto'
        clientCertificateMode: 'accept'
        allowInsecure: false
        traffic: [
          {
            latestRevision: true
            weight: 100
          }
        ]
      }
      secrets: [
        {
          name: dbPasswordSecretName
          value: dbPasswordSecretValue
        }
      ]
    }
    managedEnvironmentId: containerAppEnv.id
    template: {
      containers: [
        {
          image: 'ghcr.io/projectnessie/nessie'
          name: 'nessie'
          env: [
            {
              name: 'NESSIE_VERSION_STORE_TYPE'
              value: 'JDBC'
            }
            {
              name: 'QUARKUS_DATASOURCE_JDBC_URL'
              value: 'jdbc:postgresql://localhost:${dbPort}/${dbName}'
            }
            {
              name: 'QUARKUS_DATASOURCE_USERNAME'
              value: dbUser
            }
            {
              name: 'QUARKUS_DATASOURCE_PASSWORD'
              secretRef: dbPasswordSecretName
            }
          ]
          resources: {
            cpu: json('0.25')
            memory: '0.5Gi'
          }
          probes: []
        }
        {
          image: 'mcr.microsoft.com/k8se/services/postgres:14'
          name: 'nessie-db'
          env: [
            {
              name: 'POSTGRES_USER'
              value: dbUser
            }
            {
              name: 'POSTGRES_DB'
              value: dbName
            }
            {
              name: 'PGDATA'
              value: '/mnt/data/pgdata'
            }
            {
              name: 'POSTGRES_PASSWORD'
              secretRef: dbPasswordSecretName
            }
          ]
          resources: {
            cpu: json('1')
            memory: '2Gi'
          }
        }
      ]
      scale: {
        minReplicas: 0
        maxReplicas: 1
        rules: null
      }
    }
  }
}
