using './main.bicep'
param appEnvName = 'nessie-app-env'
param nessiePort = 19120
param dbPort = 5432
param dbContainerName = 'nessie-db'
param dbPasswordSecretName = 'db-password'
param dbPasswordSecretValue = ''
param dbName = 'nessie'
param dbUser = 'nessie_user'
param fsName = 'betting-db-storage'
param fsVolumeName = 'db-data'
param fsVolumeMntPath = '/mnt/data'
param storageAccountName = 'bettingdbdata'
