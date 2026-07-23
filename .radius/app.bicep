extension radius

param environment string

resource traderxApp 'Radius.Core/applications@2025-08-01-preview' = {
  name: 'traderx'
  properties: {
    environment: environment
  }
}

resource accountServiceImage 'Radius.Compute/containerImages@2025-08-01-preview' = {
  name: 'account-service-image'
  properties: {
    environment: environment
    application: traderxApp.id
    codeReference: 'templates/account-service-specfirst/Dockerfile'
    build: {
      source: 'git::https://github.com/nicolejms/traderX.git//templates/account-service-specfirst?ref=f60def6eff9b988141d59ae6ad864dfd5bc10ce6'
    }
  }
}

resource positionServiceImage 'Radius.Compute/containerImages@2025-08-01-preview' = {
  name: 'position-service-image'
  properties: {
    environment: environment
    application: traderxApp.id
    codeReference: 'templates/position-service-specfirst/Dockerfile'
    build: {
      source: 'git::https://github.com/nicolejms/traderX.git//templates/position-service-specfirst?ref=f60def6eff9b988141d59ae6ad864dfd5bc10ce6'
    }
  }
}

resource tradeProcessorImage 'Radius.Compute/containerImages@2025-08-01-preview' = {
  name: 'trade-processor-image'
  properties: {
    environment: environment
    application: traderxApp.id
    codeReference: 'templates/trade-processor-specfirst/Dockerfile'
    build: {
      source: 'git::https://github.com/nicolejms/traderX.git//templates/trade-processor-specfirst?ref=f60def6eff9b988141d59ae6ad864dfd5bc10ce6'
    }
  }
}

resource tradeServiceImage 'Radius.Compute/containerImages@2025-08-01-preview' = {
  name: 'trade-service-image'
  properties: {
    environment: environment
    application: traderxApp.id
    codeReference: 'templates/trade-service-specfirst/Dockerfile'
    build: {
      source: 'git::https://github.com/nicolejms/traderX.git//templates/trade-service-specfirst?ref=f60def6eff9b988141d59ae6ad864dfd5bc10ce6'
    }
  }
}

resource webFrontEndImage 'Radius.Compute/containerImages@2025-08-01-preview' = {
  name: 'web-front-end-image'
  properties: {
    environment: environment
    application: traderxApp.id
    codeReference: 'templates/web-front-end/angular/Dockerfile'
    build: {
      source: 'git::https://github.com/nicolejms/traderX.git//templates/web-front-end/angular?ref=f60def6eff9b988141d59ae6ad864dfd5bc10ce6'
    }
  }
}

resource accountServiceContainer 'Radius.Compute/containers@2025-08-01-preview' = {
  name: 'account-service'
  properties: {
    environment: environment
    application: traderxApp.id
    codeReference: 'templates/account-service-specfirst/Dockerfile'
    containers: {
      accountService: {
        image: accountServiceImage.properties.imageReference
        ports: {
          web: {
            containerPort: 18088
          }
        }
        env: {
          ACCOUNT_SERVICE_PORT: {
            value: '18088'
          }
          DATABASE_TCP_HOST: {
            value: 'database'
          }
          DATABASE_TCP_PORT: {
            value: '18082'
          }
          PEOPLE_SERVICE_HOST: {
            value: 'people-service'
          }
          CORS_ALLOWED_ORIGINS: {
            value: 'http://localhost:8080'
          }
        }
      }
    }
  }
}

resource positionServiceContainer 'Radius.Compute/containers@2025-08-01-preview' = {
  name: 'position-service'
  properties: {
    environment: environment
    application: traderxApp.id
    codeReference: 'templates/position-service-specfirst/Dockerfile'
    containers: {
      positionService: {
        image: positionServiceImage.properties.imageReference
        ports: {
          web: {
            containerPort: 18090
          }
        }
        env: {
          POSITION_SERVICE_PORT: {
            value: '18090'
          }
          DATABASE_TCP_HOST: {
            value: 'database'
          }
          DATABASE_TCP_PORT: {
            value: '18082'
          }
          CORS_ALLOWED_ORIGINS: {
            value: 'http://localhost:8080'
          }
        }
      }
    }
  }
}

resource tradeProcessorContainer 'Radius.Compute/containers@2025-08-01-preview' = {
  name: 'trade-processor'
  properties: {
    environment: environment
    application: traderxApp.id
    codeReference: 'templates/trade-processor-specfirst/Dockerfile'
    containers: {
      tradeProcessor: {
        image: tradeProcessorImage.properties.imageReference
        ports: {
          web: {
            containerPort: 18091
          }
        }
        env: {
          TRADE_PROCESSOR_SERVICE_PORT: {
            value: '18091'
          }
          DATABASE_TCP_HOST: {
            value: 'database'
          }
          DATABASE_TCP_PORT: {
            value: '18082'
          }
          TRADE_FEED_HOST: {
            value: 'trade-feed'
          }
          CORS_ALLOWED_ORIGINS: {
            value: 'http://localhost:8080'
          }
        }
      }
    }
  }
}

resource tradeServiceContainer 'Radius.Compute/containers@2025-08-01-preview' = {
  name: 'trade-service'
  properties: {
    environment: environment
    application: traderxApp.id
    codeReference: 'templates/trade-service-specfirst/Dockerfile'
    containers: {
      tradeService: {
        image: tradeServiceImage.properties.imageReference
        ports: {
          web: {
            containerPort: 18092
          }
        }
        env: {
          TRADING_SERVICE_PORT: {
            value: '18092'
          }
          ACCOUNT_SERVICE_HOST: {
            value: 'account-service'
          }
          REFERENCE_DATA_HOST: {
            value: 'reference-data'
          }
          PEOPLE_SERVICE_HOST: {
            value: 'people-service'
          }
          TRADE_FEED_HOST: {
            value: 'trade-feed'
          }
          CORS_ALLOWED_ORIGINS: {
            value: 'http://localhost:8080'
          }
        }
      }
    }
    connections: {
      accountservice: {
        source: accountServiceContainer.id
      }
      tradeprocessor: {
        source: tradeProcessorContainer.id
      }
    }
  }
}

resource webFrontEndContainer 'Radius.Compute/containers@2025-08-01-preview' = {
  name: 'web-front-end'
  properties: {
    environment: environment
    application: traderxApp.id
    codeReference: 'templates/web-front-end/angular/Dockerfile'
    containers: {
      webFrontEnd: {
        image: webFrontEndImage.properties.imageReference
        ports: {
          web: {
            containerPort: 18093
          }
        }
        env: {
          WEB_SERVICE_PORT: {
            value: '18093'
          }
        }
      }
    }
    connections: {
      accountservice: {
        source: accountServiceContainer.id
      }
      tradeservice: {
        source: tradeServiceContainer.id
      }
      positionservice: {
        source: positionServiceContainer.id
      }
    }
  }
}

resource webFrontEndRoute 'Radius.Compute/routes@2025-08-01-preview' = {
  name: 'web-front-end-route'
  properties: {
    environment: environment
    application: traderxApp.id
    rules: [
      {
        matches: [
          {
            httpPath: '/'
          }
        ]
        destinationContainer: {
          resourceId: webFrontEndContainer.id
          containerName: 'webFrontEnd'
          containerPort: 18093
        }
      }
    ]
  }
}
