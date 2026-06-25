extension radius

@description('The Radius environment to deploy into')
param environment string

@description('The Radius application name')
param application string

// ─── Database ─────────────────────────────────────────────────────────────────
resource database 'Radius.Data/postgreSqlDatabases@2025-08-01-preview' = {
  name: 'database'
  properties: {
    environment: environment
    application: application
  }
}

// ─── Reference Data Service ───────────────────────────────────────────────────
resource referenceData 'Radius.Compute/containers@2025-08-01-preview' = {
  name: 'reference-data'
  properties: {
    environment: environment
    application: application
    container: {
      image: 'ghcr.io/nicolejms/traderx/reference-data:latest'
      ports: {
        http: {
          containerPort: 18085
          protocol: 'TCP'
        }
      }
      env: {
        REFERENCE_DATA_SERVICE_PORT: '18085'
      }
    }
    connections: {
      database: {
        source: database.id
      }
    }
  }
}

// ─── Trade Feed (Socket.IO messaging) ─────────────────────────────────────────
resource tradeFeed 'Radius.Compute/containers@2025-08-01-preview' = {
  name: 'trade-feed'
  properties: {
    environment: environment
    application: application
    container: {
      image: 'ghcr.io/nicolejms/traderx/trade-feed:latest'
      ports: {
        http: {
          containerPort: 18086
          protocol: 'TCP'
        }
      }
      env: {
        TRADE_FEED_PORT: '18086'
      }
    }
  }
}

// ─── People Service ───────────────────────────────────────────────────────────
resource peopleService 'Radius.Compute/containers@2025-08-01-preview' = {
  name: 'people-service'
  properties: {
    environment: environment
    application: application
    container: {
      image: 'ghcr.io/nicolejms/traderx/people-service:latest'
      ports: {
        http: {
          containerPort: 18089
          protocol: 'TCP'
        }
      }
      env: {
        PEOPLE_SERVICE_PORT: '18089'
      }
    }
  }
}

// ─── Account Service ──────────────────────────────────────────────────────────
resource accountService 'Radius.Compute/containers@2025-08-01-preview' = {
  name: 'account-service'
  properties: {
    environment: environment
    application: application
    container: {
      image: 'ghcr.io/nicolejms/traderx/account-service:latest'
      ports: {
        http: {
          containerPort: 18088
          protocol: 'TCP'
        }
      }
      env: {
        ACCOUNT_SERVICE_PORT: '18088'
        DATABASE_TCP_PORT: '18082'
      }
    }
    connections: {
      database: {
        source: database.id
      }
      peopleService: {
        source: peopleService.id
      }
    }
  }
}

// ─── Position Service ─────────────────────────────────────────────────────────
resource positionService 'Radius.Compute/containers@2025-08-01-preview' = {
  name: 'position-service'
  properties: {
    environment: environment
    application: application
    container: {
      image: 'ghcr.io/nicolejms/traderx/position-service:latest'
      ports: {
        http: {
          containerPort: 18090
          protocol: 'TCP'
        }
      }
      env: {
        POSITION_SERVICE_PORT: '18090'
        DATABASE_TCP_PORT: '18082'
      }
    }
    connections: {
      database: {
        source: database.id
      }
    }
  }
}

// ─── Trade Processor ──────────────────────────────────────────────────────────
resource tradeProcessor 'Radius.Compute/containers@2025-08-01-preview' = {
  name: 'trade-processor'
  properties: {
    environment: environment
    application: application
    container: {
      image: 'ghcr.io/nicolejms/traderx/trade-processor:latest'
      ports: {
        http: {
          containerPort: 18091
          protocol: 'TCP'
        }
      }
      env: {
        TRADE_PROCESSOR_SERVICE_PORT: '18091'
        DATABASE_TCP_PORT: '18082'
      }
    }
    connections: {
      database: {
        source: database.id
      }
      tradeFeed: {
        source: tradeFeed.id
      }
    }
  }
}

// ─── Trade Service ────────────────────────────────────────────────────────────
resource tradeService 'Radius.Compute/containers@2025-08-01-preview' = {
  name: 'trade-service'
  properties: {
    environment: environment
    application: application
    container: {
      image: 'ghcr.io/nicolejms/traderx/trade-service:latest'
      ports: {
        http: {
          containerPort: 18092
          protocol: 'TCP'
        }
      }
      env: {
        TRADING_SERVICE_PORT: '18092'
      }
    }
    connections: {
      accountService: {
        source: accountService.id
      }
      referenceData: {
        source: referenceData.id
      }
      peopleService: {
        source: peopleService.id
      }
      tradeFeed: {
        source: tradeFeed.id
      }
    }
  }
}

// ─── Web Front End (Angular) ──────────────────────────────────────────────────
resource webFrontEnd 'Radius.Compute/containers@2025-08-01-preview' = {
  name: 'web-front-end'
  properties: {
    environment: environment
    application: application
    container: {
      image: 'ghcr.io/nicolejms/traderx/web-front-end-angular:latest'
      ports: {
        http: {
          containerPort: 18093
          protocol: 'TCP'
        }
      }
      env: {
        WEB_SERVICE_PORT: '18093'
      }
    }
    connections: {
      accountService: {
        source: accountService.id
      }
      referenceData: {
        source: referenceData.id
      }
      tradeService: {
        source: tradeService.id
      }
      positionService: {
        source: positionService.id
      }
      peopleService: {
        source: peopleService.id
      }
      tradeFeed: {
        source: tradeFeed.id
      }
    }
  }
}

// ─── Ingress Route ────────────────────────────────────────────────────────────
resource ingress 'Radius.Compute/routes@2025-05-01-preview' = {
  name: 'ingress'
  properties: {
    environment: environment
    application: application
  }
}
