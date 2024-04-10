param location string
param containerEnvrionmentId string
param resourceName string

param storageAccountName string
param fileShareVolumeName string
param mountPath string

@secure()
param dbPasswordSecretValue string
param dbPasswordSecretName string
param dbUser string
param dbName string
param port int

resource postgresDb 'Microsoft.App/containerApps@2023-11-02-preview' = {
  location: location
  name: resourceName
  properties: {
    configuration: {
      ingress: {
        external: false
        targetPort: port
        exposedPort: port
        transport: 'tcp'
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
    environmentId: containerEnvrionmentId
    template: {
      containers: [
        {
          image: 'mcr.microsoft.com/k8se/services/postgres:14'
          name: 'postgres-db'
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
              value: 'postgresql:/mnt/data/pgdata'
            }
            {
              name: 'POSTGRES_PASSWORD'
              secretRef: dbPasswordSecretName
            }
          ]
          volumeMounts: [
            {
              volumeName: fileShareVolumeName
              mountPath: mountPath
              subPath: dbName
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
      volumes: [
        {
          name: fileShareVolumeName
          storageName: storageAccountName
          storageType: 'AzureFile'
        }
      ]
    }
  }
}
