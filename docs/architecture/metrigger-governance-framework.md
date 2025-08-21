# Metrigger Protocol: Cross-Chain Governance Framework

**Document Version**: 0.1
**Date**: August 2025
**Status**: Governance Architecture Specification
**License Strategy**: Business Source License (BSL 1.1)
**Objective**: Define the comprehensive cross-chain governance system for Metrigger Protocol using LayerZero omnichain messaging

---

## 🎯 **Executive Summary**

The Metrigger Governance Framework establishes a **revolutionary cross-chain DAO architecture** that enables coordinated decision-making across all supported blockchains. Built on LayerZero's proven omnichain messaging, the governance system ensures that protocol parameters, security measures, and strategic decisions can be managed consistently across the entire ecosystem.

**Core Governance Principles:**
- ✅ **Omnichain Sovereignty**: Single governance token works across all chains
- ✅ **Unified Decision Making**: Votes from any chain count toward global decisions
- ✅ **Consistent Execution**: Proposals execute simultaneously across target chains
- ✅ **Emergency Response**: Rapid cross-chain emergency actions when needed
- ✅ **Decentralized Control**: No single chain or entity controls the protocol
- ✅ **Transparent Operations**: All governance actions are publicly verifiable

**Key Innovation**: The first truly omnichain governance system where token holders can participate from any supported chain while maintaining unified protocol control.

---

## 🏛️ **Governance Token Architecture**

### **MTR Token - Omnichain Governance Token**

The Metrigger (MTR) token serves as the universal governance token across all supported chains, implemented as a LayerZero OFT (Omnichain Fungible Token).

```solidity
/**
 * @title MetriggerGovernanceToken (MTR)
 * @dev Omnichain governance token with cross-chain voting power
 */
contract MetriggerGovernanceToken is OFT, Votes {
    // Total supply: 1,000,000,000 MTR
    uint256 public constant TOTAL_SUPPLY = 1_000_000_000e18;

    // Voting power snapshots for cross-chain proposals
    mapping(uint256 => mapping(address => uint256)) private _votingPowerSnapshots;
    mapping(uint256 => uint256) private _totalSupplySnapshots;

    struct CrossChainBalance {
        mapping(uint32 => uint256) chainBalances;  // Balance per LayerZero chain
        uint256 totalBalance;                      // Total across all chains
        uint256 lastUpdateTime;                    // Last balance sync time
    }

    mapping(address => CrossChainBalance) private _crossChainBalances;
}
```

### **Token Distribution Strategy**

```typescript
interface TokenDistribution {
  // Foundation allocation (40% - 400M MTR)
  foundation: {
    amount: "400000000",
    vestingPeriod: "4 years",
    cliffPeriod: "1 year",
    purpose: "Protocol development, partnerships, treasury"
  };

  // Community allocation (30% - 300M MTR)
  community: {
    amount: "300000000",
    distribution: [
      { type: "airdrop", amount: "50000000", criteria: "Early users, developers" },
      { type: "liquidity_mining", amount: "100000000", duration: "2 years" },
      { type: "grants", amount: "75000000", purpose: "Extension development" },
      { type: "dao_treasury", amount: "75000000", purpose: "Community initiatives" }
    ]
  };

  // Team allocation (20% - 200M MTR)
  team: {
    amount: "200000000",
    vestingPeriod: "4 years",
    cliffPeriod: "1 year"
  };

  // Investors allocation (10% - 100M MTR)
  investors: {
    amount: "100000000",
    vestingPeriod: "3 years",
    cliffPeriod: "6 months"
  };
}
```

---

## 🗳️ **Cross-Chain Voting Mechanisms**

### **Unified Voting Power Calculation**

The governance system aggregates voting power across all chains to ensure fair and accurate representation.

```solidity
/**
 * @title MetriggerVotingPowerAggregator
 * @dev Calculates unified voting power across all chains
 */
contract MetriggerVotingPowerAggregator is OApp {
    struct VotingPowerSnapshot {
        mapping(uint32 => uint256) chainPowers;    // Voting power per chain
        uint256 totalPower;                        // Total voting power
        uint256 blockNumber;                       // Snapshot block
        bool finalized;                           // Snapshot complete
    }

    mapping(uint256 => mapping(address => VotingPowerSnapshot)) public snapshots;

    /**
     * @notice Create voting power snapshot across all chains
     * @param proposalId Proposal identifier
     * @param voter Address to snapshot
     */
    function createCrossChainSnapshot(
        uint256 proposalId,
        address voter
    ) external {
        // Request voting power from all active chains
        uint32[] memory activeChains = getActiveChains();

        for (uint256 i = 0; i < activeChains.length; i++) {
            _requestVotingPower(proposalId, voter, activeChains[i]);
        }
    }

    /**
     * @notice Aggregate voting power once all chains respond
     */
    function finalizeSnapshot(uint256 proposalId, address voter) external {
        VotingPowerSnapshot storage snapshot = snapshots[proposalId][voter];
        require(!snapshot.finalized, "Already finalized");

        uint256 totalPower = 0;
        uint32[] memory chains = getActiveChains();

        for (uint256 i = 0; i < chains.length; i++) {
            totalPower += snapshot.chainPowers[chains[i]];
        }

        snapshot.totalPower = totalPower;
        snapshot.finalized = true;
        snapshot.blockNumber = block.number;

        emit VotingPowerFinalized(proposalId, voter, totalPower);
    }
}
```

### **Cross-Chain Proposal System**

```solidity
/**
 * @title MetriggerOmnichainGovernor
 * @dev Cross-chain governance with LayerZero messaging
 */
contract MetriggerOmnichainGovernor is Governor, OApp {
    enum ProposalType {
        PARAMETER_UPDATE,        // Protocol parameter changes
        EXTENSION_APPROVAL,      // New extension approvals
        DVN_AUTHORIZATION,       // DVN management
        TREASURY_ALLOCATION,     // Treasury fund allocation
        EMERGENCY_ACTION,        // Emergency protocol actions
        CHAIN_EXPANSION,         // New chain integrations
        FEE_STRUCTURE_UPDATE     // Fee model changes
    }

    struct OmnichainProposal {
        uint256 id;
        address proposer;
        ProposalType proposalType;
        uint32[] targetChains;           // Chains where proposal executes
        bytes[] executionData;           // Execution data per chain
        uint256 forVotes;
        uint256 againstVotes;
        uint256 abstainVotes;
        uint256 totalVotingPower;        // Snapshot of total power
        ProposalStatus status;
        uint256 creationTime;
        uint256 votingStartTime;
        uint256 votingEndTime;
        uint256 executionDelay;
        string description;
        mapping(address => VoteRecord) votes;
    }

    struct VoteRecord {
        bool hasVoted;
        uint8 support;                   // 0=against, 1=for, 2=abstain
        uint256 weight;                  // Cross-chain voting power
        uint32 sourceChain;              // Chain where vote was cast
        string reason;
    }

    // Core governance parameters
    uint256 public constant VOTING_DELAY = 1 days;
    uint256 public constant VOTING_PERIOD = 7 days;
    uint256 public constant EXECUTION_DELAY = 2 days;
    uint256 public constant PROPOSAL_THRESHOLD = 1000000e18; // 1M MTR
    uint256 public constant QUORUM_PERCENTAGE = 10; // 10% of total supply

    /**
     * @notice Create cross-chain governance proposal
     */
    function proposeOmnichain(
        uint32[] memory targetChains,
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        string memory description,
        ProposalType proposalType
    ) external returns (uint256 proposalId) {
        // Validate proposer has sufficient cross-chain voting power
        uint256 proposerPower = getVotingPower(msg.sender, block.number - 1);
        require(proposerPower >= PROPOSAL_THRESHOLD, "Insufficient voting power");

        // Generate proposal ID and create proposal
        proposalId = hashProposal(targets, values, calldatas, keccak256(bytes(description)));

        OmnichainProposal storage proposal = proposals[proposalId];
        proposal.id = proposalId;
        proposal.proposer = msg.sender;
        proposal.proposalType = proposalType;
        proposal.targetChains = targetChains;
        proposal.executionData = calldatas;
        proposal.status = ProposalStatus.PENDING;
        proposal.creationTime = block.timestamp;
        proposal.votingStartTime = block.timestamp + VOTING_DELAY;
        proposal.votingEndTime = proposal.votingStartTime + VOTING_PERIOD;
        proposal.executionDelay = EXECUTION_DELAY;
        proposal.description = description;

        // Broadcast proposal to all governance-enabled chains
        _broadcastProposalCreation(proposalId, targetChains);

        emit ProposalCreated(proposalId, msg.sender, targetChains, description);
        return proposalId;
    }

    /**
     * @notice Cast vote from any supported chain
     */
    function castVoteOmnichain(
        uint256 proposalId,
        uint8 support,
        string calldata reason
    ) external returns (uint256 weight) {
        OmnichainProposal storage proposal = proposals[proposalId];
        require(proposal.status == ProposalStatus.ACTIVE, "Proposal not active");
        require(block.timestamp >= proposal.votingStartTime, "Voting not started");
        require(block.timestamp <= proposal.votingEndTime, "Voting ended");
        require(!proposal.votes[msg.sender].hasVoted, "Already voted");

        // Get voter's cross-chain voting power at proposal snapshot
        weight = getCrossChainVotingPower(msg.sender, proposalId);
        require(weight > 0, "No voting power");

        // Record vote
        proposal.votes[msg.sender] = VoteRecord({
            hasVoted: true,
            support: support,
            weight: weight,
            sourceChain: getCurrentChainId(),
            reason: reason
        });

        // Update vote tallies
        if (support == 0) {
            proposal.againstVotes += weight;
        } else if (support == 1) {
            proposal.forVotes += weight;
        } else {
            proposal.abstainVotes += weight;
        }

        // Broadcast vote to other chains for transparency
        _broadcastVote(proposalId, msg.sender, support, weight);

        emit VoteCast(msg.sender, proposalId, support, weight, reason);
        return weight;
    }

    /**
     * @notice Execute successful proposal across target chains
     */
    function executeOmnichain(uint256 proposalId) external payable {
        OmnichainProposal storage proposal = proposals[proposalId];
        require(proposal.status == ProposalStatus.SUCCEEDED, "Proposal not succeeded");
        require(
            block.timestamp >= proposal.votingEndTime + proposal.executionDelay,
            "Execution delay not met"
        );

        proposal.status = ProposalStatus.EXECUTING;

        // Execute on each target chain via LayerZero
        for (uint256 i = 0; i < proposal.targetChains.length; i++) {
            bytes memory message = abi.encode(
                MessageType.GOVERNANCE_EXECUTION,
                proposalId,
                proposal.executionData[i]
            );

            _lzSend(
                proposal.targetChains[i],
                message,
                _buildOptions(proposal.targetChains[i]),
                MessagingFee(msg.value / proposal.targetChains.length, 0),
                payable(msg.sender)
            );
        }

        proposal.status = ProposalStatus.EXECUTED;
        emit ProposalExecuted(proposalId, proposal.targetChains);
    }
}
```

---

## ⚙️ **Parameter Management System**

### **Global Protocol Parameters**

The governance system manages critical protocol parameters across all chains through a unified parameter management contract.

```typescript
interface GlobalParameters {
  // Protocol fee structure
  fees: {
    protocolFeeRate: number;        // Basis points (e.g., 150 = 1.5%)
    maxExtensionFee: number;        // Maximum extension fee
    feeRecipient: string;           // Multi-chain fee recipient
    feeDistribution: ChainDistribution[];
  };

  // Condition parameters
  conditions: {
    maxConditionDuration: number;   // Maximum condition lifetime
    minStakeAmount: string;         // Minimum stake per condition
    maxConditionValue: string;      // Maximum value per condition
    disputeWindow: number;          // Dispute resolution window
  };

  // Security parameters
  security: {
    emergencyPauseEnabled: boolean;
    maxDailyVolume: string;
    rateLimitWindow: number;
    requiredDVNConfirmations: number;
    blacklistSyncEnabled: boolean;
  };

  // Oracle and DVN settings
  oracles: {
    minOracleSources: number;
    dataConfidenceThreshold: number;
    oracleTimeoutPeriod: number;
    dvnSlashingEnabled: boolean;
  };
}
```

### **Parameter Update Workflow**

```solidity
/**
 * @title MetriggerParameterManager
 * @dev Cross-chain parameter synchronization system
 */
contract MetriggerParameterManager is OApp, AccessControl {
    bytes32 public constant GOVERNANCE_ROLE = keccak256("GOVERNANCE_ROLE");
    bytes32 public constant PARAMETER_ADMIN_ROLE = keccak256("PARAMETER_ADMIN_ROLE");

    struct ParameterUpdate {
        bytes32 parameterKey;
        bytes newValue;
        uint32[] targetChains;
        uint256 effectiveTime;
        bool executed;
        uint256 proposalId;
    }

    mapping(bytes32 => ParameterUpdate) public pendingUpdates;
    mapping(bytes32 => bytes) public currentParameters;

    // Standard parameter keys
    bytes32 public constant PROTOCOL_FEE_RATE = keccak256("PROTOCOL_FEE_RATE");
    bytes32 public constant MAX_CONDITION_DURATION = keccak256("MAX_CONDITION_DURATION");
    bytes32 public constant MIN_STAKE_AMOUNT = keccak256("MIN_STAKE_AMOUNT");
    bytes32 public constant EMERGENCY_PAUSE_ENABLED = keccak256("EMERGENCY_PAUSE_ENABLED");

    /**
     * @notice Update parameter across multiple chains (governance only)
     */
    function updateGlobalParameter(
        bytes32 parameterKey,
        bytes calldata newValue,
        uint32[] calldata targetChains,
        uint256 effectiveDelay
    ) external onlyRole(GOVERNANCE_ROLE) {
        bytes32 updateId = keccak256(abi.encode(parameterKey, newValue, block.timestamp));

        pendingUpdates[updateId] = ParameterUpdate({
            parameterKey: parameterKey,
            newValue: newValue,
            targetChains: targetChains,
            effectiveTime: block.timestamp + effectiveDelay,
            executed: false,
            proposalId: 0 // Set by governance if needed
        });

        emit ParameterUpdateScheduled(updateId, parameterKey, effectiveDelay);
    }

    /**
     * @notice Execute parameter update when effective time is reached
     */
    function executeParameterUpdate(bytes32 updateId) external {
        ParameterUpdate storage update = pendingUpdates[updateId];
        require(block.timestamp >= update.effectiveTime, "Not yet effective");
        require(!update.executed, "Already executed");

        // Update local parameter
        currentParameters[update.parameterKey] = update.newValue;
        update.executed = true;

        // Broadcast to target chains
        for (uint256 i = 0; i < update.targetChains.length; i++) {
            _lzSend(
                update.targetChains[i],
                abi.encode(
                    MessageType.PARAMETER_UPDATE,
                    update.parameterKey,
                    update.newValue
                ),
                _getDefaultOptions(),
                MessagingFee(0, 0),
                payable(msg.sender)
            );
        }

        emit ParameterUpdated(updateId, update.parameterKey, update.newValue);
    }
}
```

---

## 🚨 **Emergency Governance System**

### **Multi-Signature Emergency Council**

For critical security issues that require immediate action, the protocol implements a multi-signature emergency council with limited powers.

```solidity
/**
 * @title MetriggerEmergencyCouncil
 * @dev Multi-signature emergency response system
 */
contract MetriggerEmergencyCouncil is Multisig, OApp {
    struct EmergencyAction {
        bytes32 actionId;
        EmergencyActionType actionType;
        uint32[] targetChains;
        bytes actionData;
        uint256 requiredSignatures;
        uint256 currentSignatures;
        mapping(address => bool) signatures;
        bool executed;
        uint256 creationTime;
        uint256 expirationTime;
    }

    enum EmergencyActionType {
        PAUSE_PROTOCOL,
        UNPAUSE_PROTOCOL,
        BLACKLIST_ADDRESS,
        EMERGENCY_WITHDRAW,
        DVN_OVERRIDE,
        PARAMETER_FREEZE
    }

    address[] public councilMembers;
    uint256 public constant COUNCIL_SIZE = 7;
    uint256 public constant EMERGENCY_THRESHOLD = 4; // 4 of 7 signatures
    uint256 public constant ACTION_EXPIRY = 24 hours;

    mapping(bytes32 => EmergencyAction) public emergencyActions;

    /**
     * @notice Initiate emergency action (council member only)
     */
    function initiateEmergencyAction(
        EmergencyActionType actionType,
        uint32[] calldata targetChains,
        bytes calldata actionData,
        string calldata reason
    ) external onlyCouncilMember returns (bytes32 actionId) {
        actionId = keccak256(abi.encode(
            actionType,
            targetChains,
            actionData,
            block.timestamp,
            msg.sender
        ));

        EmergencyAction storage action = emergencyActions[actionId];
        action.actionId = actionId;
        action.actionType = actionType;
        action.targetChains = targetChains;
        action.actionData = actionData;
        action.requiredSignatures = EMERGENCY_THRESHOLD;
        action.currentSignatures = 1;
        action.signatures[msg.sender] = true;
        action.creationTime = block.timestamp;
        action.expirationTime = block.timestamp + ACTION_EXPIRY;

        emit EmergencyActionInitiated(actionId, actionType, msg.sender, reason);
        return actionId;
    }

    /**
     * @notice Sign emergency action (council member only)
     */
    function signEmergencyAction(
        bytes32 actionId,
        string calldata reason
    ) external onlyCouncilMember {
        EmergencyAction storage action = emergencyActions[actionId];
        require(block.timestamp <= action.expirationTime, "Action expired");
        require(!action.signatures[msg.sender], "Already signed");
        require(!action.executed, "Already executed");

        action.signatures[msg.sender] = true;
        action.currentSignatures++;

        emit EmergencyActionSigned(actionId, msg.sender, action.currentSignatures);

        // Auto-execute if threshold met
        if (action.currentSignatures >= action.requiredSignatures) {
            _executeEmergencyAction(actionId);
        }
    }

    /**
     * @notice Execute emergency action once threshold is met
     */
    function _executeEmergencyAction(bytes32 actionId) internal {
        EmergencyAction storage action = emergencyActions[actionId];
        require(action.currentSignatures >= action.requiredSignatures, "Insufficient signatures");
        require(!action.executed, "Already executed");

        action.executed = true;

        // Execute across target chains
        for (uint256 i = 0; i < action.targetChains.length; i++) {
            _lzSend(
                action.targetChains[i],
                abi.encode(
                    MessageType.EMERGENCY_ACTION,
                    action.actionType,
                    action.actionData
                ),
                _getEmergencyOptions(),
                MessagingFee(0, 0),
                payable(address(this))
            );
        }

        emit EmergencyActionExecuted(actionId, action.actionType);
    }
}
```

---

## 🏗️ **Governance Integration Architecture**

### **Integration with Existing Governance Systems**

The Metrigger governance framework is designed to integrate seamlessly with existing DAO frameworks like Aragon OSx while adding omnichain capabilities.

```typescript
interface GovernanceIntegration {
  // Aragon OSx integration
  aragon: {
    pluginAddress: string;
    daoAddress: string;
    votingSettings: {
      minDuration: number;
      minParticipation: number;
      supportThreshold: number;
    };
    crossChainEnabled: boolean;
  };

  // Snapshot integration
  snapshot: {
    spaceId: string;
    strategies: SnapshotStrategy[];
    crossChainBalanceAggregation: boolean;
  };

  // Tally integration
  tally: {
    governorAddress: string;
    proposalCreationEnabled: boolean;
    crossChainVotingEnabled: boolean;
  };
}

class MetriggerGovernanceAdapter {
  /**
   * Integrate with Aragon OSx for enhanced DAO functionality
   */
  async setupAragonIntegration(config: AragonConfig): Promise<void> {
    // Deploy Metrigger plugin for Aragon
    const plugin = await this.deployAragonPlugin(config);

    // Configure cross-chain voting
    await this.configureCrossChainVoting(plugin, config.chains);

    // Setup parameter synchronization
    await this.setupParameterSync(plugin);
  }

  /**
   * Integrate with Snapshot for off-chain voting
   */
  async setupSnapshotIntegration(spaceId: string): Promise<void> {
    // Configure cross-chain balance strategies
    const strategies = await this.createCrossChainStrategies();

    // Setup automated proposal mirroring
    await this.setupSnapshotMirroring(spaceId, strategies);
  }
}
```

---

## 📊 **Governance Analytics & Monitoring**

### **Governance Health Metrics**

```typescript
interface GovernanceMetrics {
  // Participation metrics
  participation: {
    totalActiveVoters: number;
    averageParticipationRate: number;
    crossChainParticipation: ChainParticipation[];
    voterRetention: number;
  };

  // Proposal metrics
  proposals: {
    totalProposals: number;
    successRate: number;
    averageVotingPeriod: number;
    executionSuccess: number;
    crossChainExecutionLatency: number;
  };

  // Security metrics
  security: {
    emergencyActionsTriggered: number;
    councilResponseTime: number;
    protocolPauseEvents: number;
    parameterOverrides: number;
  };

  // Token metrics
  token: {
    distributionHealth: TokenDistribution;
    stakingRatio: number;
    crossChainDistribution: ChainDistribution[];
    governanceTokenVelocity: number;
  };
}
```

### **Real-Time Governance Dashboard**

```typescript
class GovernanceDashboard {
  private metrics: GovernanceMetrics;
  private eventStream: EventEmitter;

  /**
   * Initialize real-time governance monitoring
   */
  async initialize(): Promise<void> {
    // Setup cross-chain event listeners
    await this.setupEventListeners();

    // Initialize metrics collection
    await this.initializeMetricsCollection();

    // Start real-time updates
    this.startRealTimeUpdates();
  }

  /**
   * Generate governance health report
   */
  async generateHealthReport(): Promise<GovernanceHealthReport> {
    return {
      overallHealth: this.calculateOverallHealth(),
      participationTrends: await this.analyzeParticipation(),
      crossChainEfficiency: await this.analyzeCrossChainPerformance(),
      securityStatus: await this.assessSecurityMetrics(),
      recommendations: this.generateRecommendations()
    };
  }

  /**
   * Monitor for governance anomalies
   */
  private monitorAnomalies(): void {
    // Unusual voting patterns
    this.detectUnusualVotingPatterns();

    // Cross-chain synchronization issues
    this.monitorSynchronizationHealth();

    // Emergency action triggers
    this.trackEmergencyActions();
  }
}
```

---

## 🚀 **Implementation Roadmap**

### **Phase 1: Core Governance (Month 1-2)**
- ✅ Deploy MTR token as LayerZero OFT
- ✅ Implement basic cross-chain voting
- ✅ Create parameter management system
- ✅ Setup emergency council
- ✅ Deploy on testnet chains

### **Phase 2: Advanced Features (Month 3-4)**
- ✅ Integrate with Aragon OSx
- ✅ Implement Snapshot integration
- ✅ Advanced voting mechanisms (quadratic, conviction)
- ✅ Governance analytics dashboard
- ✅ Cross-chain execution optimization

### **Phase 3: Production Launch (Month 5-6)**
- ✅ Mainnet deployment across all chains
- ✅ Security audits and formal verification
- ✅ Community governance transition
- ✅ Token distribution events
- ✅ Full documentation and tutorials

### **Phase 4: Ecosystem Growth (Month 7-12)**
- ✅ Third-party governance integrations
- ✅ Advanced delegation mechanisms
- ✅ Governance incentive programs
- ✅ Cross-protocol governance partnerships
- ✅ Mobile governance applications

---

## 📄 **Conclusion**

### **Revolutionary Governance Architecture**

The Metrigger Governance Framework establishes the **first truly omnichain governance system**, enabling unified decision-making across all supported blockchains while maintaining security, transparency, and decentralization.

### **Key Benefits**

1. **Unified Participation**: Token holders can participate from any supported chain
2. **Consistent Execution**: Decisions execute simultaneously across all target chains
3. **Emergency Response**: Multi-signature council for critical security issues
4. **Parameter Synchronization**: Global protocol parameters managed consistently
5. **Integration Friendly**: Works with existing governance frameworks like Aragon

### **Implementation Readiness**

The governance framework is designed for immediate implementation with:
- Complete architectural specifications
- Security-first design principles
- Integration with proven systems (LayerZero, Aragon)
- Comprehensive monitoring and analytics
- Clear migration and upgrade paths

The system positions Metrigger as the definitive solution for omnichain governance, enabling protocols to manage global operations through a single, unified system.

---

**Document Status**: Architecture Complete
**Next Document**: `metrigger-sdk-specification.md`
**Implementation Ready**: Q1 2025
**Integration Partners**: LayerZero, Aragon OSx, Snapshot
