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

param virtualNetworkName string = 'vnet1'
param virtualNetwork_CIDR string = '10.200.0.0/16'
param subnet1Name string = 'Subnet1'
param subnet2Name string = 'Subnet2'
param subnet1_CIDR string = '10.200.1.0/24'
param subnet2_CIDR string = '10.200.2.0/24'
var privateDNSZoneName = 'privatelink.azurewebsites.net'

param privateEndpointName string = 'PrivateEndpoint1'
param privateLinkConnectionName string = 'PrivateEndpointLink1'

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2020-06-01' = {
  name: virtualNetworkName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        virtualNetwork_CIDR
      ]
    }
  }
}

resource subnet1 'Microsoft.Network/virtualNetworks/subnets@2020-06-01' = {
  parent: virtualNetwork
  name: subnet1Name
  properties: {
    addressPrefix: subnet1_CIDR
    privateEndpointNetworkPolicies: 'Disabled'
    networkSecurityGroup: {
      properties: {
        securityRules: [
          {
            properties: {
              direction: 'Inbound'
              protocol: '*'
              access: 'Allow'
            }
          }
          {
            properties: {
              direction: 'Outbound'
              protocol: '*'
              access: 'Allow'
            }
          }
        ]
      }
    }
  }
}

resource subnet2 'Microsoft.Network/virtualNetworks/subnets@2020-06-01' = {
  parent: virtualNetwork
  name: subnet2Name
  dependsOn: [
    subnet1
  ]
  properties: {
    addressPrefix: subnet2_CIDR
    delegations: [
      {
        name: 'delegation'
        properties: {
          serviceName: 'Microsoft.Web/serverfarms'
        }
      }
    ]
    privateEndpointNetworkPolicies: 'Enabled'
    networkSecurityGroup: {
      properties: {
        securityRules: [
          {
            properties: {
              direction: 'Inbound'
              protocol: '*'
              access: 'Allow'
            }
          }
          {
            properties: {
              direction: 'Outbound'
              protocol: '*'
              access: 'Allow'
            }
          }
        ]
      }
    }
  }
}

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
      appCommandLine: 'pm2 start npm -- start'
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

resource appService 'Microsoft.Web/sites@2020-06-01' = {
  name: webSiteName
  location: location
  properties: {
    serverFarmId: appServicePlan.id
    siteConfig: {
      appCommandLine: 'pm2 start npm -- start'
      linuxFxVersion: linuxFxVersion
      ftpsState: 'AllAllowed'
      cors: {
        allowedOrigins: [
          'https://server-bluestem.azurewebsites.net/'
        ]
      }
    }
  }
}

resource clientNetworkConfig 'Microsoft.Web/sites/networkConfig@2020-06-01' = {
  parent: appService
  name: 'virtualNetwork'
  properties: {
    subnetResourceId: resourceId('Microsoft.Network/virtualNetworks/subnets',virtualNetwork.name ,subnet2Name)
  }
}

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2020-06-01' = {
  name: privateEndpointName
  location: location
  properties: {
    subnet: {
      id: resourceId('Microsoft.Network/virtualNetworks/subnets',virtualNetwork.name ,subnet1Name)
    }
    privateLinkServiceConnections: [
      {
        name: privateLinkConnectionName
        properties: {
          privateLinkServiceId: serverService.id
          groupIds: [
            'sites'
          ]
        }
      }
    ]
  }
}

resource privateDnsZones 'Microsoft.Network/privateDnsZones@2018-09-01' = {
  name: privateDNSZoneName
  location: 'global'
  dependsOn: [
    virtualNetwork
  ]
}

resource privateDnsZoneLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2018-09-01' = {
  parent: privateDnsZones
  name: '${privateDnsZones.name}-link'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: virtualNetwork.id
    }
  }
}

resource privateDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2020-03-01' = {
  parent: privateEndpoint
  name: 'dnsgroupname'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config1'
        properties: {
          privateDnsZoneId: privateDnsZones.id
        }
      }
    ]
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

resource clientSourceControls 'Microsoft.Web/sites/sourcecontrols@2021-01-01' = {
  parent: appService
  name: 'web'
  properties: {
    repoUrl: clientRepositoryUrl
    branch: clientBranch
    isManualIntegration: true
  }
}
