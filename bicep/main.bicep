param webAppName string = 'bluestem'
param sku string = 'B1' // The SKU of App Service Plan
param linuxFxVersion string = 'node|14-lts' // The runtime stack of web app
param location string = resourceGroup().location // Location for all resources

param serverRepositoryUrl string = 'https://github.com/BacHoCuuPikachu/Bluestem'
param serverBranch string = 'main'

param clientRepositoryUrl string = 'https://github.com/BacHoCuuPikachu/Bluestem-Client'
param clientBranch string = 'main'

var storageAccountName = toLower('storage${webAppName}')
var appServicePlanName = toLower('AppServicePlan-${webAppName}')
var webSiteName = toLower('wapp-${webAppName}')
var serverName = toLower('server-${webAppName}')
var webLocation = 'westeurope'

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-06-01' = {
  name: storageAccountName
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
  properties: {
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: true
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Allow'
    }
    supportsHttpsTrafficOnly: true
    encryption: {
      keySource: 'Microsoft.Storage'
      services: {
        blob: {
          keyType: 'Account'
          enabled: true
        }
      }
    }
    accessTier: 'Hot'
  }
}

resource appServicePlan 'Microsoft.Web/serverfarms@2020-06-01' = {
  name: appServicePlanName
  location: location
  properties: {
    reserved: true
  }
  sku: {
    name: sku
  }
  kind: 'linux'
}

resource serverService 'Microsoft.Web/sites@2020-06-01' = {
  name: serverName
  location: location
  properties: {
    serverFarmId: appServicePlan.id
    siteConfig: {
      linuxFxVersion: linuxFxVersion
      ftpsState: 'AllAllowed'
      appSettings: [
        {
          name: 'AZURE_STORAGE_CONNECTION_STRING'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccountName};AccountKey=${listKeys(storageAccount.id, storageAccount.apiVersion).keys[0].value};EndpointSuffix=core.windows.net'
        }
      ]
    }
  }
}

resource serverSourceControls 'Microsoft.Web/sites/sourcecontrols@2021-01-01' = {
  parent: serverService
  name: 'web'
  properties: {
    repoUrl: serverRepositoryUrl
    branch: serverBranch
    isManualIntegration: true
  }
}

resource appService 'Microsoft.Web/staticSites@2021-03-01' = {
  name: webSiteName
  location: webLocation
  sku: {
    name: 'free'
    tier: 'free'
  }
  properties: {
    allowConfigFileUpdates: true
    stagingEnvironmentPolicy: 'Enabled'
    repositoryUrl: clientRepositoryUrl
    branch: clientBranch
    buildProperties: {
      appBuildCommand: 'npm run build'
      outputLocation: 'build'
      skipGithubActionWorkflowGeneration: true
    }
  }
}
