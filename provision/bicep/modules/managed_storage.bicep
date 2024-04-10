param location string

param managedEnvName string

param storageAccountName string
param fileShareName string

resource fileStorageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
  }

  resource fileService 'fileServices' = {
    name: 'default'
    properties: {}

    resource fileShare 'shares' = {
      name: fileShareName
    }
  }
}

resource managedEnv 'Microsoft.App/managedEnvironments@2023-11-02-preview' existing = {
  name: managedEnvName
  resource managedStorage 'storages' = {
    name: storageAccountName
    properties: {
      azureFile: {
        accountName: storageAccountName
        accountKey: fileStorageAccount.listKeys().keys[0].value
        accessMode: 'ReadWrite'
        shareName: fileShareName
      }
    }
  }
}
