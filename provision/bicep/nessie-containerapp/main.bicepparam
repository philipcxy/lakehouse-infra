using './main.bicep'
param dbPasswordSecretName = 'db-password'
param dbPasswordSecretValue = ''
param appEnvName = 'nessie-app-env'
param nessiePort = 19120
param dbPort = 5432
param dbContainerName = 'nessie-db'
param dbName = 'nessie'
param dbUser = 'nessie_user'
