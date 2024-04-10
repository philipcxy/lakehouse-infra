metadata description = 'Creates a container with Postgres dev service'

param appEnvName string
param location string = resourceGroup().location

param nessiePort int
param dbPort int

param dbContainerName string

param dbPasswordSecretName string
@secure()
param dbPasswordSecretValue string
param dbName string
param dbUser string

param fsName string
param fsVolumeName string
param fsVolumeMntPath string
param storageAccountName string

module appEnv '../modules/managed_container_env.bicep' = {
  name: 'app-environment-deployment'
  params: {
    location: location
    appEnvName: appEnvName
  }
}

module managedStorage '../modules/managed_storage.bicep' = {
  name: 'managed-storage-deployment'
  params: {
    managedEnvName: appEnvName
    fileShareName: fsName
    location: location
    storageAccountName: storageAccountName
  }
  dependsOn: [
    appEnv
  ]
}

module nessieDb '../modules/postgres_container_app.bicep' = {
  name: 'nessie-db'
  params: {
    containerEnvrionmentId: appEnv.outputs.id
    dbName: dbName
    dbPasswordSecretName: dbPasswordSecretName
    dbPasswordSecretValue: dbPasswordSecretValue
    dbUser: dbUser
    location: location
    resourceName: dbContainerName
    port: dbPort
    fileShareVolumeName: fsVolumeName
    mountPath: fsVolumeMntPath
    storageAccountName: storageAccountName
  }
  dependsOn: [
    appEnv
    managedStorage
  ]
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
    environmentId: appEnv.outputs.id
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
              value: 'jdbc:postgresql://${dbContainerName}:${dbPort}/${dbName}'
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
      ]
      scale: {
        minReplicas: 0
        maxReplicas: 1
        rules: null
      }
    }
  }
  dependsOn: [
    nessieDb
    appEnv
  ]
}
