# Metrigger Protocol: Developer Integration Guide

**Document Version**: 0.1
**Date**: August 2025
**Status**: Complete Developer Integration Reference
**Target Audience**: Developers integrating Metrigger Protocol
**Prerequisites**: Basic knowledge of TypeScript, Web3, and smart contracts

---

## 🎯 **Quick Start Integration**

### **Installation**

```bash
# NPM
npm install @metrigger/sdk @metrigger/extensions @metrigger/cli

# Yarn
yarn add @metrigger/sdk @metrigger/extensions @metrigger/cli

# PNPM
pnpm add @metrigger/sdk @metrigger/extensions @metrigger/cli
```

### **Basic Setup (30 seconds)**

```typescript
import { MetriggerClient } from '@metrigger/sdk';

const metrigger = new MetriggerClient({
  privateKey: process.env.PRIVATE_KEY,
  defaultChain: 'base',
  rpcUrls: {
    base: process.env.BASE_RPC_URL,
    ethereum: process.env.ETHEREUM_RPC_URL
  }
});

// Create your first condition
const condition = await metrigger.createCondition({
  type: 'SINGLE_SIDED',
  trigger: { type: 'flight_delay', flight: 'BA245', threshold: 60 },
  stake: { amount: '50', token: 'USDC', chain: 'base' },
  payout: { amount: '500', token: 'USDC', recipient: userAddress }
});
```

---

## 📦 **Complete Import Reference**

### **Core SDK Imports**

```typescript
// === CORE CLIENT ===
import {
  MetriggerClient,           // Main protocol client
  IntentBuilder,             // Intent-based condition creation
  ConditionBuilder,          // Programmatic condition building
  ConditionMonitor,          // Real-time condition monitoring
  AnalyticsClient           // Protocol analytics and metrics
} from '@metrigger/sdk';

// === EXTENSION SYSTEM ===
import {
  ExtensionSDK,             // Extension development kit
  ExtensionDeployer,        // Multi-chain extension deployment
  BaseExtension,            // Base extension class
  SingleSidedExtension,     // Single depositor pattern
  MultiSidedExtension,      // Multi-party pattern
  PredictionMarketExtension // Market mechanics pattern
} from '@metrigger/sdk/extensions';

// === GOVERNANCE ===
import {
  GovernanceClient,         // Cross-chain governance
  ProposalBuilder,          // Governance proposal creation
  VotingClient             // Voting and delegation
} from '@metrigger/sdk/governance';

// === UTILITIES ===
import {
  ChainUtils,              // Cross-chain utilities
  GasEstimator,            // Gas optimization
  PriceOracle,             // Price feed integration
  EventIndexer,            // Event monitoring
  SecurityValidator        // Security checks
} from '@metrigger/sdk/utils';

// === TESTING FRAMEWORK ===
import {
  MetriggerTestFramework,   // Testing utilities
  MockOracle,              // Oracle mocking
  TestEnvironment,         // Test environment setup
  CrossChainTester         // Cross-chain testing
} from '@metrigger/sdk/testing';

// === TYPE DEFINITIONS ===
import type {
  ConditionType,           // All condition types
  ConditionStatus,         // Status enumeration
  OmnichainCondition,      // Condition data structure
  ParametricIntent,        // Intent interface
  ExtensionMetadata,       // Extension information
  CrossChainConfig         // LayerZero configuration
} from '@metrigger/sdk/types';
```

### **Chain-Specific Adapters**

```typescript
// === CHAIN ADAPTERS ===
import { EthereumAdapter } from '@metrigger/sdk/chains/ethereum';
import { BaseAdapter } from '@metrigger/sdk/chains/base';
import { ArbitrumAdapter } from '@metrigger/sdk/chains/arbitrum';
import { PolygonAdapter } from '@metrigger/sdk/chains/polygon';
import { OptimismAdapter } from '@metrigger/sdk/chains/optimism';
import { AvalancheAdapter } from '@metrigger/sdk/chains/avalanche';
import { BNBAdapter } from '@metrigger/sdk/chains/bnb';

// === ORACLE ADAPTERS ===
import { ChainlinkOracle } from '@metrigger/sdk/oracles/chainlink';
import { FlightDataOracle } from '@metrigger/sdk/oracles/flight';
import { WeatherOracle } from '@metrigger/sdk/oracles/weather';
import { CustomDVNOracle } from '@metrigger/sdk/oracles/custom-dvn';
```

---

## 🏗️ **Core Integration Patterns**

### **Pattern 1: Simple Condition Creation**

```typescript
import { MetriggerClient } from '@metrigger/sdk';

const client = new MetriggerClient({
  privateKey: process.env.PRIVATE_KEY,
  defaultChain: 'base'
});

// Direct condition creation
const condition1 = await client.createCondition({
  type: 'SINGLE_SIDED',
  stakeholder: userAddress,
  beneficiary: userAddress,
  amount: parseUnits('100', 6), // 100 USDC
  token: USDC_ADDRESS,
  criteria: encodeFlightDelay('BA245', 60) // 60 min delay threshold
});

// Using condition builder
const condition2 = await client.conditions
  .type('SINGLE_SIDED')
  .stakeholder(userAddress, parseUnits('100', 6))
  .beneficiary(recipientAddress)
  .criteria('flight_delay', { flight: 'BA245', threshold: 60 })
  .expiresIn('7 days')
  .create();

// Using intent builder (recommended)
const intent = client.intents.create();
const condition3 = await intent
  .describe("I want insurance if my flight BA245 is delayed more than 60 minutes")
  .stake("100 USDC on base")
  .payout("500 USDC to my ethereum address")
  .execute();
```

### **Pattern 2: Multi-Chain Deployment**

```typescript
import { MetriggerClient, ChainUtils } from '@metrigger/sdk';

const client = new MetriggerClient({
  networks: {
    base: { rpcUrl: process.env.BASE_RPC },
    ethereum: { rpcUrl: process.env.ETH_RPC },
    arbitrum: { rpcUrl: process.env.ARB_RPC }
  }
});

const omnichainCondition = await client.createOmnichainCondition({
  type: 'CROSS_CHAIN',
  sourceChain: 'base',
  executionChains: ['ethereum', 'arbitrum', 'base'],

  // Stake on Base
  stake: {
    amount: parseUnits('1000', 6),
    token: 'USDC',
    chain: 'base'
  },

  // Distribute across chains
  payouts: [
    { amount: parseUnits('300', 6), recipient: addr1, chain: 'ethereum' },
    { amount: parseUnits('400', 6), recipient: addr2, chain: 'arbitrum' },
    { amount: parseUnits('300', 6), recipient: addr3, chain: 'base' }
  ],

  // Weather trigger (global data)
  trigger: {
    type: 'weather',
    location: 'NYC',
    condition: 'temperature',
    threshold: -5, // Below -5°C
    duration: 24 // For 24 hours
  }
});
```

### **Pattern 3: Real-Time Monitoring**

```typescript
import { ConditionMonitor, AnalyticsClient } from '@metrigger/sdk';

// Monitor specific condition
const monitor = new ConditionMonitor(conditionId, {
  pollInterval: 30000, // 30 seconds
  chains: ['base', 'ethereum'],
  webhookUrl: 'https://your-app.com/webhook'
});

monitor.onStatusChange((update) => {
  console.log(`Condition ${update.conditionId} status: ${update.status}`);
  if (update.status === 'TRIGGERED') {
    // Handle condition trigger
    handleConditionTriggered(update);
  }
});

monitor.onExecution((result) => {
  console.log(`Execution complete: ${result.totalPayout} distributed`);
});

await monitor.start();

// Analytics client
const analytics = new AnalyticsClient(client);
// Get protocol-wide statistics
const stats = await analytics.getProtocolOverview();
// Get user-specific analytics
const userStats = await analytics.getUserAnalytics(userAddress);
```

### **Pattern 4: Extension Development**

```typescript
import { BaseExtension, ExtensionSDK } from '@metrigger/sdk/extensions';

class WeatherInsuranceExtension extends BaseExtension {
  async createCondition(params: WeatherConditionParams) {
    // Validate weather-specific parameters
    this.validateWeatherParams(params);

    // Create condition with weather oracle integration
    return super.createCondition({
      ...params,
      oracleConfig: this.weatherValidation(params.location, params.threshold)
    });
  }

  private validateWeatherParams(params: WeatherConditionParams) {
    if (!params.location) throw new Error('Weather location required');
    if (params.threshold === undefined) throw new Error('Temperature threshold required');
  }

  private weatherValidation = {
    oracle: 'weather-dvn',
    sources: ['openweathermap', 'weatherapi', 'noaa'],
    confidence: 85 // Minimum 85% confidence
  };
}

const extensionSDK = new ExtensionSDK();
await extensionSDK.deploy(WeatherInsuranceExtension, {
  chains: ['base', 'ethereum', 'polygon'],
  securityTier: 'COMMUNITY'
});
```

---

## 🎯 **Real-World Integration Examples**

### **1. Flight Insurance App (Complete Implementation)**

```typescript
import {
  MetriggerClient,
  IntentBuilder,
  ConditionMonitor,
  FlightDataOracle
} from '@metrigger/sdk';

class FlightInsuranceApp {
  private metrigger: MetriggerClient;
  private intentBuilder: IntentBuilder;
  private flightOracle: FlightDataOracle;

  constructor(config: AppConfig) {
    this.metrigger = new MetriggerClient({
      privateKey: config.privateKey,
      defaultChain: 'base',
      networks: config.networks,
      oracles: {
        flightData: {
          apiKey: config.aviationstackApiKey,
          provider: 'aviationstack'
        }
      }
    });

    this.intentBuilder = new IntentBuilder(this.metrigger);
    this.flightOracle = new FlightDataOracle(config.aviationstackApiKey);
  }

  async initialize() {
    await this.metrigger.connect();
  }

  /**
   * Create a flight insurance policy
   */
  async createPolicy(params: FlightInsuranceParams): Promise<InsurancePolicy> {
    // 1. Validate flight exists and get details
    const flightData = await this.flightOracle.getFlightInfo(params.flightNumber, params.date);
    if (!flightData) {
      throw new Error('Flight not found');
    }

    // 2. Calculate premium based on risk assessment
    const riskScore = await this.assessFlightRisk(flightData);
    const premium = await this.calculatePremium(params.coverage, riskScore);

    // 3. Create parametric condition using intents
    const condition = await this.intentBuilder
      .describe(`Flight insurance for ${params.flightNumber} on ${params.date}`)
      .trigger({
        type: 'flight_delay',
        flightNumber: params.flightNumber,
        date: params.date,
        delayThreshold: params.delayThreshold || 60,
        dataSource: 'aviationstack'
      })
      .stake({
        amount: premium,
        token: 'USDC',
        chain: 'base',
        from: params.customerAddress
      })
      .payout({
        amount: params.coverage,
        token: 'USDC',
        recipient: params.customerAddress,
        chain: params.payoutChain || 'base'
      })
      .expiresAt(new Date(flightData.scheduledDeparture).getTime() + 24 * 60 * 60 * 1000) // 24h after flight
      .create();

    // 4. Save policy to database
    const policy = await this.savePolicyToDatabase({
      conditionId: condition.conditionId,
      customerAddress: params.customerAddress,
      flightNumber: params.flightNumber,
      date: params.date,
      premium,
      coverage: params.coverage,
      status: 'ACTIVE'
    });

    // 5. Start monitoring the condition
    this.monitorPolicy(condition.conditionId, policy.id);

    return policy;
  }

  /**
   * Monitor insurance policy for automatic execution
   */
  private monitorPolicy(conditionId: number, policyId: string) {
    const monitor = new ConditionMonitor(conditionId);

    monitor.onStatusChange(async (update) => {
      await this.updatePolicyStatus(policyId, update.status);

      if (update.status === 'TRIGGERED') {
        await this.sendPushNotification(policyId, 'Your flight insurance has been triggered!');
      }
    });

    monitor.onExecution(async (result) => {
      if (result.success) {
        await this.updatePolicyStatus(policyId, 'PAID_OUT');
        await this.sendPushNotification(policyId,
          `Insurance payout of ${result.totalPayout} has been sent to your wallet.`);
      }
    });

    monitor.start();
  }

  /**
   * Get all policies for a user
   */
  async getUserPolicies(userAddress: string): Promise<InsurancePolicy[]> {
    // Get conditions from Metrigger
    const conditions = await this.metrigger.getUserConditions(userAddress);

    // Get policy details from database
    const policies = await this.database.policies.findMany({
      where: {
        customerAddress: userAddress,
        conditionId: { in: conditions.map(c => c.conditionId) }
      },
      include: {
        condition: true,
        payouts: true
      }
    });

    return policies.map(policy => ({
      ...policy,
      currentStatus: conditions.find(c => c.conditionId === policy.conditionId)?.status
    }));
  }

  /**
   * Manual claim process for edge cases
   */
  async claimPayout(policyId: string, proof: FlightDelayProof): Promise<ClaimResult> {
    const policy = await this.database.policies.findUnique({
      where: { id: policyId }
    });

    if (!policy) throw new Error('Policy not found');

    // Validate proof with oracle
    const isValid = await this.flightOracle.validateDelayProof(proof);
    if (!isValid) throw new Error('Invalid delay proof');

    // Execute condition manually with proof
    const result = await this.metrigger.executeCondition(policy.conditionId, {
      proof: JSON.stringify(proof)
    });

    return result;
  }

  private async assessFlightRisk(flightData: FlightData): Promise<number> {
    // Risk assessment algorithm based on historical data
    // Returns risk score 0-100
  }

  private async calculatePremium(coverage: number, riskScore: number): Promise<number> {
    // Premium calculation based on coverage and risk
    const basePremium = coverage * 0.05; // 5% of coverage
    const riskMultiplier = 1 + (riskScore / 100);
    return basePremium * riskMultiplier;
  }

  private async savePolicyToDatabase(policy: Partial<InsurancePolicy>) {
    // Save to database implementation
  }

  private async updatePolicyStatus(policyId: string, status: string) {
    // Update policy status in database
  }

  private async sendPushNotification(policyId: string, message: string) {
    // Send push notification to user
  }

  private async parseFlightData(rawData: any): Promise<FlightData> {
    // Parse and normalize flight data from API
  }
}

// Usage example
const app = new FlightInsuranceApp({
  privateKey: process.env.PRIVATE_KEY,
  aviationstackApiKey: process.env.AVIATIONSTACK_API_KEY,
  networks: { /* network config */ }
});

const policy = await app.createPolicy({
  customerAddress: '0x123...',
  flightNumber: 'BA245',
  date: '2025-03-15',
  coverage: parseUnits('500', 6), // $500 coverage
  delayThreshold: 60, // 60 minutes
  payoutChain: 'ethereum'
});
```

### **2. DeFi Yield Farming with Conditions**

```typescript
import { MetriggerClient, PriceOracle } from '@metrigger/sdk';

class ConditionalYieldFarm {
  private metrigger: MetriggerClient;
  private priceOracle: PriceOracle;

  constructor() {
    this.metrigger = new MetriggerClient({
      privateKey: process.env.PRIVATE_KEY,
      defaultChain: 'ethereum'
    });

    this.priceOracle = new PriceOracle(['chainlink', 'uniswap-v3']);
  }

  /**
   * Create stop-loss condition for DeFi position
   */
  async createStopLoss(params: StopLossParams): Promise<number> {
    const currentPrice = await this.priceOracle.getPrice(params.asset);

    return await this.metrigger.createCondition({
      type: 'SINGLE_SIDED',
      stakeholder: params.userAddress,
      beneficiary: params.userAddress,

      // Stake the LP tokens or assets
      stake: {
        amount: params.amount,
        token: params.assetAddress,
        chain: 'ethereum'
      },

      // Trigger when price drops below threshold
      trigger: {
        type: 'price_threshold',
        asset: params.asset,
        condition: 'below',
        threshold: params.stopLossPrice,
        oracle: 'chainlink'
      },

      // Execute sell order automatically
      execution: {
        action: 'swap',
        outputToken: 'USDC',
        minOutput: params.minOutput,
        dex: 'uniswap-v3'
      }
    });
  }

  /**
   * Create take-profit condition
   */
  async createTakeProfit(params: TakeProfitParams): Promise<number> {
    return await this.metrigger.createCondition({
      type: 'SINGLE_SIDED',
      stakeholder: params.userAddress,
      beneficiary: params.userAddress,

      trigger: {
        type: 'price_threshold',
        asset: params.asset,
        condition: 'above',
        threshold: params.takeProfitPrice,
        oracle: 'chainlink'
      },

      execution: {
        action: 'partial_sell',
        percentage: params.sellPercentage,
        outputToken: 'USDC'
      }
    });
  }

  /**
   * Create yield threshold condition
   */
  async createYieldThreshold(params: YieldParams): Promise<number> {
    return await this.metrigger.createCondition({
      type: 'TIME_LOCKED',

      trigger: {
        type: 'yield_threshold',
        protocol: params.yieldProtocol,
        asset: params.asset,
        minYield: params.minYieldAPR,
        duration: params.duration
      },

      execution: {
        action: 'rebalance',
        targetProtocol: params.fallbackProtocol
      }
    });
  }
}
```

### **3. Prediction Market Application**

```typescript
import { MetriggerClient, PredictionMarketExtension } from '@metrigger/sdk';

class PredictionMarketApp {
  private metrigger: MetriggerClient;
  private predictionMarket: PredictionMarketExtension;

  constructor() {
    this.metrigger = new MetriggerClient({ /* config */ });
    this.predictionMarket = new PredictionMarketExtension(this.metrigger);
  }

  /**
   * Create a sports betting market
   */
  async createSportsMarket(params: SportsMarketParams): Promise<MarketInfo> {
    return await this.predictionMarket.createCondition({
      type: 'PREDICTION_MARKET',

      // Market parameters
      question: `Who will win ${params.team1} vs ${params.team2}?`,
      outcomes: [params.team1, params.team2, 'Draw'],

      // Market timing
      bettingDeadline: params.gameStart,
      resolutionDeadline: params.gameEnd + 2 * 60 * 60 * 1000, // 2 hours after

      // Oracle configuration
      oracle: {
        type: 'sports_data',
        provider: 'espn',
        gameId: params.gameId
      },

      // Market mechanics
      minBet: parseUnits('1', 6), // $1 USDC
      maxBet: parseUnits('10000', 6), // $10k USDC
      feeRate: 200, // 2%
      liquidityPool: parseUnits('50000', 6) // $50k initial liquidity
    });
  }

  /**
   * Place a bet on a market
   */
  async placeBet(params: BetParams): Promise<BetInfo> {
    return await this.predictionMarket.placeBet({
      marketId: params.marketId,
      outcome: params.outcome,
      amount: params.amount,
      maxOdds: params.maxOdds, // Slippage protection
      bettor: params.bettorAddress
    });
  }

  /**
   * Get current market odds
   */
  async getMarketOdds(marketId: number): Promise<MarketOdds> {
    const market = await this.predictionMarket.getCondition(marketId);
    return this.predictionMarket.calculateOdds(market);
  }

  /**
   * Claim winnings from resolved market
   */
  async claimWinnings(marketId: number, userAddress: string): Promise<ClaimResult> {
    return await this.predictionMarket.claimWinnings(marketId, userAddress);
  }
}
```

---

## 🔧 **CLI Usage Examples**

### **Installation and Setup**

```bash
# Install CLI globally
npm install -g @metrigger/cli

# Initialize project
metrigger init my-project
cd my-project

# Configure networks
metrigger config set privateKey $PRIVATE_KEY
metrigger config set defaultChain base
metrigger config set rpcUrl.ethereum $ETH_RPC_URL
metrigger config set rpcUrl.base $BASE_RPC_URL
```

### **Creating Conditions via CLI**

```bash
# Simple flight insurance
metrigger create condition \
  --type single-sided \
  --trigger "flight_delay:BA245:60" \
  --stake "50 USDC on base" \
  --payout "500 USDC to 0x123..." \
  --expires "2025-03-16"

# Multi-chain prediction market
metrigger create prediction-market \
  --question "Will Bitcoin reach $100k by Dec 31, 2025?" \
  --outcomes "Yes,No" \
  --chains "ethereum,base,arbitrum" \
  --betting-deadline "2025-12-30" \
  --oracle "chainlink:BTC/USD"

# Weather insurance using intents
metrigger intent create \
  --describe "I want insurance if temperature in NYC drops below -10C for 48 hours" \
  --premium "100 USDC" \
  --coverage "1000 USDC"
```

### **Monitoring and Management**

```bash
# Monitor specific condition
metrigger monitor 12345 --webhook https://myapp.com/webhook

# Get user conditions
metrigger list conditions --user 0x123... --status active

# Get protocol statistics
metrigger stats protocol --timeframe 30d

# Check condition details
metrigger get condition 12345 --include-history
```

### **Governance Operations**

```bash
# Create governance proposal
metrigger governance propose \
  --title "Update protocol fee to 1.5%" \
  --description "Proposal to adjust fee structure" \
  --target-chains "ethereum,base" \
  --execution-data "0x..."

# Vote on proposal
metrigger governance vote 42 --support yes --reason "Lower fees benefit users"

# Check voting power
metrigger governance voting-power 0x123...
```

---

## ⚙️ **Advanced Configuration**

### **Complete Configuration Options**

```typescript
import { MetriggerClient } from '@metrigger/sdk';

const client = new MetriggerClient({
  // === BASIC CONFIGURATION ===
  privateKey: process.env.PRIVATE_KEY,
  defaultChain: 'base',

  // === NETWORK CONFIGURATION ===
  networks: {
    ethereum: {
      rpcUrl: process.env.ETHEREUM_RPC_URL,
      registryAddress: '0x...',
      confirmations: 6,
      gasPrice: 'fast',
      maxFeePerGas: parseUnits('50', 'gwei'),
      maxPriorityFeePerGas: parseUnits('2', 'gwei')
    },
    base: {
      rpcUrl: process.env.BASE_RPC_URL,
      registryAddress: '0x...',
      confirmations: 3,
      gasPrice: 'standard'
    },
    arbitrum: {
      rpcUrl: process.env.ARBITRUM_RPC_URL,
      registryAddress: '0x...',
      confirmations: 12
    }
  },

  // === LAYERZERO CONFIGURATION ===
  layerZero: {
    endpoints: {
      ethereum: '0x1a44076050125825900e736c501f859c50fE728c',
      base: '0x1a44076050125825900e736c501f859c50fE728c',
      arbitrum: '0x1a44076050125825900e736c501f859c50fE728c'
    },
    defaultGasLimit: 200000,
    nativeDropAmount: parseEther('0.01'),
    dvnConfig: {
      required: ['layerzero-labs-dvn', 'metrigger-parametric-dvn'],
      optional: ['chainlink-dvn'],
      threshold: 2
    },
    composerConfig: {
      enabled: true,
      maxExecutions: 3,
      executionDelay: 60000 // 1 minute
    }
  },

  // === ORACLE CONFIGURATION ===
  oracles: {
    chainlink: {
      enabled: true,
      networks: ['ethereum', 'base', 'arbitrum'],
      priceFeeds: {
        'BTC/USD': '0x...',
        'ETH/USD': '0x...',
        'USDC/USD': '0x...'
      }
    },
    flightData: {
      apiKey: process.env.AVIATIONSTACK_API_KEY,
      provider: 'aviationstack',
      rateLimiting: {
        requestsPerHour: 1000,
        burstLimit: 100
      }
    },
    weather: {
      apiKey: process.env.OPENWEATHER_API_KEY,
      provider: 'openweathermap',
      updateInterval: 300000 // 5 minutes
    },
    customDVN: {
      address: '0x...',
      requiredConfidence: 85,
      minSources: 2
    }
  },

  // === PERFORMANCE CONFIGURATION ===
  performance: {
    caching: {
      enabled: true,
      ttl: 300000, // 5 minutes
      maxSize: 1000
    },
    batching: {
      enabled: true,
      maxBatchSize: 50,
      batchTimeout: 10000 // 10 seconds
    },
    retries: {
      maxRetries: 3,
      backoffMultiplier: 2,
      initialDelay: 1000
    }
  },

  // === SECURITY CONFIGURATION ===
  security: {
    maxConditionValue: parseEther('1000000'), // 1M tokens
    rateLimiting: {
      conditionsPerHour: 100,
      conditionsPerDay: 1000
    },
    slippageProtection: {
      maxSlippage: 0.03, // 3%
      enabled: true
    },
    sanctions: {
      enabled: true,
      provider: 'chainalysis',
      apiKey: process.env.CHAINALYSIS_API_KEY
    }
  },

  // === MONITORING & ANALYTICS ===
  monitoring: {
    enabled: true,
    webhookUrl: process.env.WEBHOOK_URL,
    events: ['condition_created', 'condition_triggered', 'condition_executed'],
    metrics: {
      provider: 'datadog',
      apiKey: process.env.DATADOG_API_KEY
    }
  },

  // === DEVELOPMENT OPTIONS ===
  development: {
    debug: process.env.NODE_ENV === 'development',
    testnet: true,
    mockOracles: false,
    verboseLogging: true
  }
});
```

---

## 🔧 **Troubleshooting Guide**

### **Common Issues & Solutions**

#### **1. Connection Issues**
```typescript
// Problem: Cannot connect to LayerZero
// Solution: Check endpoint configuration
const client = new MetriggerClient({
  chains: {
    base: {
      rpcUrl: process.env.BASE_RPC_URL, // Ensure this is set
      layerZeroEndpoint: "0x1a44076050125825900e736c501f859c50fE728c"
    }
  }
});
```

#### **2. Gas Estimation Failures**
```typescript
// Problem: Gas estimation too low
// Solution: Set explicit gas limits
const condition = await client.createCondition({
  // ... other params
  gasConfig: {
    gasLimit: 500000, // Explicit gas limit
    maxFeePerGas: parseUnits('20', 'gwei'),
    maxPriorityFeePerGas: parseUnits('2', 'gwei')
  }
});
```

#### **3. Cross-Chain Message Delays**
```typescript
// Problem: Cross-chain messages taking too long
// Solution: Monitor with timeout handling
const monitor = new ConditionMonitor(conditionId);

monitor.onStatusChange(async (status) => {
  if (status === 'CROSS_CHAIN_PENDING') {
    // Set timeout for cross-chain operations
    setTimeout(() => {
      if (monitor.getCurrentStatus() === 'CROSS_CHAIN_PENDING') {
        console.warn('Cross-chain message delayed, checking DVN status...');
      }
    }, 60000); // 1 minute timeout
  }
});
```

#### **4. Oracle Data Validation Errors**
```typescript
// Problem: Oracle rejecting data
// Solution: Validate data format before submission
const validateFlightData = (flightData) => {
  if (!flightData.flightNumber || !flightData.scheduledDeparture) {
    throw new Error('Missing required flight data fields');
  }

  // Ensure proper date format
  const departureTime = new Date(flightData.scheduledDeparture);
  if (isNaN(departureTime.getTime())) {
    throw new Error('Invalid departure time format');
  }

  return true;
};
```

### **Debug Mode Configuration**

```typescript
// Enable detailed logging for debugging
const client = new MetriggerClient({
  debug: true,
  logLevel: 'verbose',
  enableTracing: true
});

// Access debug information
client.on('debug', (info) => {
  console.log('Debug Info:', info);
});

client.on('error', (error) => {
  console.error('Client Error:', error);
});
```

---

## 🎯 **Best Practices**

### **1. Security Best Practices**

```typescript
// ✅ Always validate user inputs
const validateConditionParams = (params) => {
  // Validate amounts
  if (params.stakeAmount <= 0) {
    throw new Error('Stake amount must be positive');
  }

  // Validate addresses
  if (!isAddress(params.beneficiary)) {
    throw new Error('Invalid beneficiary address');
  }

  // Validate expiration
  if (params.expirationTime <= Date.now()) {
    throw new Error('Expiration time must be in the future');
  }
};

// ✅ Use proper error handling
try {
  const condition = await client.createCondition(params);
  await condition.waitForConfirmation();
} catch (error) {
  if (error.code === 'INSUFFICIENT_FUNDS') {
    // Handle specific error types
    showInsufficientFundsDialog();
  } else {
    // Log unexpected errors
    console.error('Unexpected error:', error);
    showGenericErrorDialog();
  }
}
```

### **2. Performance Optimization**

```typescript
// ✅ Batch operations when possible
const batchCreateConditions = async (conditionsData) => {
  const batchSize = 10;
  const results = [];

  for (let i = 0; i < conditionsData.length; i += batchSize) {
    const batch = conditionsData.slice(i, i + batchSize);
    const batchPromises = batch.map(data => client.createCondition(data));
    const batchResults = await Promise.allSettled(batchPromises);
    results.push(...batchResults);
  }

  return results;
};

// ✅ Cache frequently accessed data
const conditionCache = new Map();

const getCachedCondition = async (conditionId) => {
  if (conditionCache.has(conditionId)) {
    const cached = conditionCache.get(conditionId);
    if (Date.now() - cached.timestamp < 60000) { // 1 minute cache
      return cached.data;
    }
  }

  const condition = await client.getCondition(conditionId);
  conditionCache.set(conditionId, {
    data: condition,
    timestamp: Date.now()
  });

  return condition;
};
```

### **3. Monitoring & Observability**

```typescript
// ✅ Implement comprehensive monitoring
class ProductionMonitoring {
  constructor(client) {
    this.client = client;
    this.metrics = {
      conditionsCreated: 0,
      conditionsExecuted: 0,
      failedTransactions: 0,
      averageExecutionTime: 0
    };

    this.setupEventListeners();
  }

  setupEventListeners() {
    this.client.on('conditionCreated', (event) => {
      this.metrics.conditionsCreated++;
      this.reportMetric('condition_created', 1);
    });

    this.client.on('conditionExecuted', (event) => {
      this.metrics.conditionsExecuted++;
      this.reportMetric('condition_executed', 1, {
        executionTime: event.executionTime,
        gasUsed: event.gasUsed
      });
    });

    this.client.on('error', (error) => {
      this.metrics.failedTransactions++;
      this.reportError(error);
    });
  }

  reportMetric(name, value, tags = {}) {
    // Send to your monitoring system (DataDog, Grafana, etc.)
    console.log(`Metric: ${name}`, { value, tags });
  }

  reportError(error) {
    // Send to error tracking (Sentry, Rollbar, etc.)
    console.error('Production Error:', error);
  }
}

const monitoring = new ProductionMonitoring(client);
```

### **4. Testing Strategies**

```typescript
// ✅ Comprehensive test coverage
describe('Metrigger Integration', () => {
  let testFramework;
  let mockClient;

  beforeEach(async () => {
    testFramework = new MetriggerTestFramework();
    await testFramework.setup();
    mockClient = testFramework.createMockClient();
  });

  afterEach(async () => {
    await testFramework.cleanup();
  });

  it('should handle oracle data correctly', async () => {
    // Mock oracle data
    await testFramework.mockOracleData('flight-data', {
      flightNumber: 'BA245',
      delayMinutes: 75,
      confidence: 95
    });

    // Create condition
    const condition = await mockClient.createCondition({
      type: 'ORACLE_VERIFIED',
      criteria: { delayThreshold: 60 }
    });

    // Verify condition triggers correctly
    await testFramework.simulateTime(3600); // 1 hour
    const status = await condition.getStatus();
    expect(status).toBe('TRIGGERED');
  });
});
```

---

## ❓ **Frequently Asked Questions**

### **Q: How do I handle failed cross-chain messages?**
```typescript
// A: Implement retry logic with exponential backoff
const retryWithBackoff = async (operation, maxRetries = 3) => {
  for (let i = 0; i < maxRetries; i++) {
    try {
      return await operation();
    } catch (error) {
      if (i === maxRetries - 1) throw error;

      const delay = Math.pow(2, i) * 1000; // Exponential backoff
      await new Promise(resolve => setTimeout(resolve, delay));
    }
  }
};

const condition = await retryWithBackoff(() =>
  client.createCondition(params)
);
```

### **Q: How do I estimate fees before creating conditions?**
```typescript
// A: Use the fee estimation API
const estimate = await client.estimateFees({
  conditionType: 'SINGLE_SIDED',
  stakeAmount: parseEther('100'),
  targetChains: ['base', 'ethereum', 'arbitrum']
});

console.log('Estimated costs:', {
  protocolFee: formatEther(estimate.protocolFee),
  extensionFee: formatEther(estimate.extensionFee),
  gasFees: formatEther(estimate.gasFees),
  total: formatEther(estimate.total)
});
```

### **Q: Can I use Metrigger with existing smart contracts?**
```typescript
// A: Yes, through the Composer pattern
import { Composer } from '@metrigger/sdk';

const composer = new Composer(client);

// Trigger external contract after condition execution
await composer.addAction({
  target: '0xYourContract...',
  calldata: encodeFunctionData({
    abi: yourContractAbi,
    functionName: 'onConditionExecuted',
    args: [conditionId, executionResult]
  })
});
```

### **Q: How do I handle different token decimals across chains?**
```typescript
// A: Use the built-in token utilities
import { TokenUtils } from '@metrigger/sdk';

const tokenUtils = new TokenUtils();

// Normalize amounts across chains
const normalizedAmount = await tokenUtils.normalizeAmount({
  token: 'USDC',
  amount: '100',
  fromChain: 'ethereum',
  toChain: 'base'
});

const condition = await client.createCondition({
  stakeAmount: normalizedAmount.toString(),
  // ... other params
});
```

### **Q: How do I implement custom oracle logic?**
```typescript
// A: Create a custom DVN integration
class CustomWeatherDVN {
  constructor(client) {
    this.client = client;
    this.weatherApi = new WeatherAPI();
  }

  async verifyWeatherCondition(location, condition, threshold) {
    // Get data from multiple sources
    const sources = await Promise.all([
      this.weatherApi.getCurrentWeather(location),
      this.getBackupWeatherData(location),
      this.getSatelliteData(location)
    ]);

    // Consensus verification
    const consensus = this.calculateConsensus(sources);

    // Submit to Metrigger DVN
    return await this.client.submitDVNVerification({
      dataHash: this.hashWeatherData(consensus),
      confidence: consensus.confidence,
      proof: consensus.proof
    });
  }
}
```

---

## 📚 **Additional Resources**

### **Documentation Links**
- [Core Protocol Specification](../architecture/metrigger-protocol-v0.md)
- [LayerZero Integration](../architecture/metrigger-layerzero-architecture.md)
- [Smart Contract Reference](../development/metrigger-smart-contracts.md)
- [Extension Development](../development/metrigger-extensions-v0.md)
- [SDK Reference](../development/metrigger-sdk-specification.md)

### **Community & Support**
- **Discord**: [discord.gg/metrigger](https://discord.gg/metrigger)
- **GitHub**: [github.com/metrigger/protocol](https://github.com/metrigger/protocol)
- **Documentation**: [docs.metrigger.co](https://docs.metrigger.co)
- **Blog**: [blog.metrigger.co](https://blog.metrigger.co)

### **Developer Tools**
- **Metrigger Explorer**: View and debug conditions across chains
- **Testnet Faucet**: Get test tokens for development
- **SDK Playground**: Interactive SDK testing environment
- **Extension Marketplace**: Discover and publish extensions

---

## 📄 **Conclusion**

### **Integration Summary**

This guide has covered everything needed to integrate Metrigger Protocol into your application:

✅ **Quick Setup**: 30-second installation and basic configuration
✅ **Core Patterns**: Universal integration patterns for all use cases
✅ **Real-World Examples**: Complete implementations for insurance, DeFi, and prediction markets
✅ **Advanced Features**: Cross-chain deployment, monitoring, and governance
✅ **Production Readiness**: Security, performance, and debugging best practices
✅ **Troubleshooting**: Solutions to common integration challenges

### **Next Steps**

1. **Start Building**: Use the quick start template to create your first condition
2. **Join Community**: Connect with other developers in Discord
3. **Explore Examples**: Check out the GitHub repository for more examples
4. **Stay Updated**: Follow the blog for protocol updates and new features

### **Remember**

Metrigger Protocol is designed to be **developer-first** - if you encounter any issues or need additional features, the community and core team are here to help. The protocol grows stronger with each integration and use case you build.

**Happy building! 🚀**

---

*This guide is maintained by the Metrigger core team and community. For updates and contributions, visit our GitHub repository.*

### **Environment Variables Setup**

```bash
# .env file template
# === CORE CONFIGURATION ===
PRIVATE_KEY=0x...
DEFAULT_CHAIN=base
METRIGGER_API_KEY=your_api_key_here
LAYERZERO_ENDPOINT=https://api.layerzero.network

# === CHAIN CONFIGURATIONS ===
ETHEREUM_RPC_URL=https://mainnet.infura.io/v3/YOUR_PROJECT_ID
BASE_RPC_URL=https://mainnet.base.org
ARBITRUM_RPC_URL=https://arb1.arbitrum.io/rpc
POLYGON_RPC_URL=https://polygon-rpc.com

# === ORACLE CONFIGURATIONS ===
CHAINLINK_API_KEY=your_chainlink_key
AVIATIONSTACK_API_KEY=your_aviation_key
WEATHER_API_KEY=your_weather_key

# === MONITORING ===
ENABLE_ANALYTICS=true
WEBHOOK_URL=https://your-app.com/webhooks/metrigger

# === DEVELOPMENT ===
LOG_LEVEL=info
ENABLE_DEBUG=false
TEST_MODE=false
