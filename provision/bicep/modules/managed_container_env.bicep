param appEnvName string
param location string

resource containerAppEnv 'Microsoft.App/managedEnvironments@2023-11-02-preview' = {
  name: appEnvName
  location: location
  properties: {}
}

output id string = containerAppEnv.id
