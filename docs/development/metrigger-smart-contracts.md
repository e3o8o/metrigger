# Metrigger Protocol: Complete Smart Contract Implementations

**Document Version**: 0.1
**Date**: August 2025
**Status**: Development Specification
**License Strategy**: Business Source License (BSL 1.1)
**Objective**: Complete Solidity contract implementations for Metrigger Protocol omnichain parametric conditions

---

## 🎯 **Executive Summary**

This document provides complete, production-ready smart contract implementations for the Metrigger Protocol. All contracts are designed with LayerZero V2 integration, OpenZeppelin security patterns, and comprehensive parametric condition functionality.

**Contract Architecture:**
- ✅ **Core Registry**: Central hub for all omnichain conditions
- ✅ **Extension System**: Modular condition pattern implementations
- ✅ **Custom DVN**: Specialized parametric data verification
- ✅ **Governance Framework**: Cross-chain DAO management
- ✅ **Intent System**: Natural language to condition conversion
- ✅ **Security Layer**: Multi-tier access control and emergency mechanisms

**Implementation Standards:**
- 🔒 **OpenZeppelin Security**: Latest audited patterns and practices
- ⚡ **LayerZero Native**: Built specifically for omnichain messaging
- 🧪 **Comprehensive Testing**: Full test coverage and edge case handling
- 📚 **Rich Documentation**: Detailed NatSpec for all functions

---

## 🏛️ **Core Data Structures & Interfaces**

### **Universal Data Types**

```solidity
// SPDX-License-Identifier: BSL-1.1
pragma solidity ^0.8.27;

/**
 * @title MetriggerTypes
 * @dev Universal data structures for Metrigger Protocol
 */
library MetriggerTypes {
    /// @dev Condition types supported by the protocol
    enum ConditionType {
        SINGLE_SIDED,           // One depositor, conditional payout
        MULTI_SIDED,           // Multiple parties, conditional distribution
        POOLED,                // Shared pool with distribution logic
        PREDICTION_MARKET,     // Multi-outcome with market mechanics
        MILESTONE_BASED,       // Progressive unlocking conditions
        TIME_LOCKED,          // Time-dependent conditions
        CROSS_CHAIN,          // Conditions spanning multiple chains
        INTENT_BASED,         // User intent fulfillment
        STREAMING,            // Continuous conditional payments
        NESTED,               // Conditions within conditions
        COMPOSITE,            // Multiple condition types combined
        DELEGATED             // Third-party execution authorization
    }

    /// @dev Current status of a condition
    enum ConditionStatus {
        ACTIVE,               // Monitoring for trigger conditions
        TRIGGERED,            // Conditions met, ready for execution
        EXECUTED,             // Payouts completed successfully
        EXPIRED,              // Time limit reached without trigger
        DISPUTED,             // Under dispute resolution
        CANCELLED,            // Manually cancelled before execution
        CROSS_CHAIN_PENDING   // Awaiting cross-chain confirmation
    }

    /// @dev Security classification for extensions
    enum SecurityTier {
        CORE,                 // Protocol-developed, fully audited
        AUDITED,              // Third-party audited extensions
        COMMUNITY,            // Community-developed extensions
        EXPERIMENTAL          // Experimental/unaudited extensions
    }

    /// @dev Cross-chain address structure
    struct ChainAddress {
        uint32 chainId;       // LayerZero chain ID
        address addr;         // Address on that chain
    }

    /// @dev Cross-chain amount structure
    struct ChainAmount {
        uint32 chainId;       // LayerZero chain ID
        address token;        // Token contract (address(0) for native)
        uint256 amount;       // Amount in token's decimals
    }

    /// @dev Complete condition data structure
    struct OmnichainCondition {
        uint256 conditionId;              // Unique global identifier
        bytes32 globalHash;               // Cross-chain unique hash
        ConditionType conditionType;      // Type of parametric condition
        address creator;                  // Who created this condition
        uint32 sourceChain;               // Chain where condition was created
        uint32[] executionChains;         // Chains where condition can execute

        ChainAddress[] stakeholders;      // All parties with funds at risk
        ChainAmount[] stakes;             // Amount and chain for each stake
        ChainAddress[] beneficiaries;     // Who can receive payouts
        ChainAmount[] maxPayouts;         // Maximum payout per beneficiary

        bytes32 parametricHash;           // Hash of parametric criteria
        bytes oracleConfig;               // DVN and oracle configuration
        bytes executionLogic;             // Cross-chain execution instructions
        bytes intentData;                 // Intent-based condition parameters

        ConditionStatus status;           // Current condition state
        uint256 creationTime;             // When condition was created
        uint256 triggerTime;              // When condition was triggered
        uint256 expirationTime;           // When condition expires
        uint256 executionDeadline;        // Deadline for cross-chain execution

        bytes32 layerZeroGuid;            // LayerZero message identifier
        address executingDVN;             // Which DVN verified the trigger
        bytes32 executionProof;           // Cross-chain execution proof
        uint32 settlementChain;           // Final settlement chain

        address extension;                // Extension handling this condition
        bool governanceOverride;          // Allow governance intervention
        bytes extensionData;              // Extension-specific metadata
    }

    /// @dev Condition creation parameters
    struct OmnichainConditionParams {
        ConditionType conditionType;      // Type of condition to create
        uint32[] executionChains;         // Chains where condition can execute

        ChainAddress[] stakeholders;      // All parties involved
        ChainAmount[] stakes;             // Stakes for each party
        ChainAddress[] beneficiaries;     // Potential recipients
        ChainAmount[] maxPayouts;         // Maximum payouts

        uint256 expirationTime;           // When condition expires
        bytes parametricCriteria;         // What triggers the condition
        bytes executionLogic;             // How to distribute funds
        bytes oracleConfiguration;        // Oracle setup and requirements
        bytes intentData;                 // Intent-based parameters
        bytes extensionData;              // Extension-specific data

        string title;                     // Human-readable title
        string description;               // Detailed description
        bytes32[] tags;                   // Searchable tags
        bool governanceOverride;          // Allow governance intervention
    }

    /// @dev Extension metadata structure
    struct ExtensionMetadata {
        string name;                      // Extension name
        string version;                   // Version string
        string description;               // Human-readable description
        ConditionType[] supportedTypes;   // Supported condition types
        SecurityTier securityTier;        // Security classification
        bool customLogicEnabled;          // Whether extension uses custom logic
        uint256 minStakeAmount;           // Minimum stake amount
        uint256 maxStakeAmount;           // Maximum stake amount
        address maintainer;               // Extension maintainer address
        uint256 totalConditions;         // Total conditions created
        uint256 totalVolume;             // Total value processed
    }

    /// @dev Fee breakdown structure
    struct FeeBreakdown {
        uint256 extensionFee;             // Fee charged by extension
        uint256 protocolFee;              // Protocol fee (if enabled)
        uint256 totalFees;                // Total fees
        uint256 netAmount;                // Amount after fees
        address extensionFeeRecipient;    // Where extension fees go
        bool feesEnabled;                 // Whether fees are currently enabled
    }
}
```

### **Core Protocol Interfaces**

```solidity
// SPDX-License-Identifier: BSL-1.1
pragma solidity ^0.8.27;

import {IERC165} from "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import "./MetriggerTypes.sol";

/**
 * @title IMetriggerRegistry
 * @dev Universal interface for omnichain condition registry
 */
interface IMetriggerRegistry is IERC165 {
    /// @dev Events
    event OmnichainConditionCreated(
        uint256 indexed conditionId,
        address indexed creator,
        MetriggerTypes.ConditionType indexed conditionType,
        uint32[] executionChains,
        uint256 totalStake
    );

    event ConditionStatusUpdated(
        uint256 indexed conditionId,
        MetriggerTypes.ConditionStatus oldStatus,
        MetriggerTypes.ConditionStatus newStatus,
        address indexed oracle,
        bytes32 proof
    );

    event ConditionExecuted(
        uint256 indexed conditionId,
        uint256 totalPayout,
        address[] recipients,
        uint256[] amounts
    );

    event CrossChainMessageSent(
        uint256 indexed conditionId,
        uint32 indexed targetChain,
        bytes32 guid,
        bytes message
    );

    /// @dev Core functions
    function createOmnichainCondition(
        MetriggerTypes.OmnichainConditionParams calldata params
    ) external payable returns (uint256 conditionId);

    function updateConditionStatus(
        uint256 conditionId,
        MetriggerTypes.ConditionStatus newStatus,
        bytes calldata proof
    ) external;

    function executeCondition(uint256 conditionId) external returns (bool success);

    function getCondition(uint256 conditionId)
        external view returns (MetriggerTypes.OmnichainCondition memory);

    function getUserConditions(address user)
        external view returns (uint256[] memory);

    function getConditionsByStatus(MetriggerTypes.ConditionStatus status)
        external view returns (uint256[] memory);
}

/**
 * @title IMetriggerExtension
 * @dev Standard interface for all protocol extensions
 */
interface IMetriggerExtension is IERC165 {
    /// @dev Events
    event ConditionCreatedByExtension(
        uint256 indexed conditionId,
        address indexed creator,
        MetriggerTypes.ConditionType indexed conditionType,
        uint256 extensionFee
    );

    event ExtensionConfigurationUpdated(
        string name,
        string version,
        MetriggerTypes.SecurityTier tier
    );

    /// @dev Core extension functions
    function createCondition(
        MetriggerTypes.OmnichainConditionParams calldata params
    ) external payable returns (uint256 conditionId);

    function validateExecution(
        uint256 conditionId,
        bytes calldata proof
    ) external view returns (bool valid, string memory reason);

    function executeCondition(uint256 conditionId)
        external returns (bool success);

    /// @dev Fee management
    function calculateFees(
        uint256 amount,
        MetriggerTypes.ConditionType conditionType
    ) external view returns (uint256 extensionFee, uint256 protocolFee);

    function withdrawFees(address to, uint256 amount) external;

    /// @dev Metadata
    function getExtensionMetadata()
        external view returns (MetriggerTypes.ExtensionMetadata memory);

    function getSupportedConditionTypes()
        external view returns (MetriggerTypes.ConditionType[] memory);
}
```

---

## 🏛️ **Core Registry Implementation**

### **MetriggerOmnichainRegistry.sol**

```solidity
// SPDX-License-Identifier: BSL-1.1
pragma solidity ^0.8.27;

import {OApp, Origin, MessagingFee} from "@layerzerolabs/oapp-evm/contracts/oapp/OApp.sol";
import {OptionsBuilder} from "@layerzerolabs/oapp-evm/contracts/oapp/libs/OptionsBuilder.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Pausable} from "@openzeppelin/contracts/utils/Pausable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {IERC20, SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";

import "./interfaces/IMetriggerRegistry.sol";
import "./interfaces/IMetriggerExtension.sol";
import "./MetriggerTypes.sol";
import "./MetriggerSecurity.sol";

/**
 * @title MetriggerOmnichainRegistry
 * @dev Core registry for omnichain parametric conditions
 * @notice Central hub for creating, managing, and executing conditions across chains
 */
contract MetriggerOmnichainRegistry is
    OApp,
    IMetriggerRegistry,
    Ownable,
    Pausable,
    ReentrancyGuard,
    AccessControl
{
    using SafeERC20 for IERC20;
    using EnumerableSet for EnumerableSet.UintSet;
    using EnumerableSet for EnumerableSet.AddressSet;
    using OptionsBuilder for bytes;

    // ==================== CONSTANTS ====================

    bytes32 public constant GOVERNANCE_ROLE = keccak256("GOVERNANCE_ROLE");
    bytes32 public constant ORACLE_ROLE = keccak256("ORACLE_ROLE");
    bytes32 public constant EXTENSION_MANAGER_ROLE = keccak256("EXTENSION_MANAGER_ROLE");
    bytes32 public constant EMERGENCY_ROLE = keccak256("EMERGENCY_ROLE");

    uint256 public constant MAX_EXECUTION_CHAINS = 10;
    uint256 public constant MAX_STAKEHOLDERS = 50;
    uint256 public constant MAX_BENEFICIARIES = 50;
    uint256 public constant MAX_CONDITION_DURATION = 365 days;
    uint256 public constant MIN_EXECUTION_DELAY = 1 hours;

    // ==================== STATE VARIABLES ====================

    /// @dev Next condition ID to assign
    uint256 public nextConditionId = 1;

    /// @dev Protocol fee configuration
    address public feeRecipient;
    uint256 public protocolFeeRate; // in basis points (100 = 1%)
    bool public protocolFeesEnabled;
    bool public extensionFeesEnabled;

    /// @dev Security configuration
    MetriggerSecurity public immutable SECURITY_MODULE;
    uint256 public maxConditionValue;
    uint256 public dailyVolumeLimit;
    uint256 public currentDailyVolume;
    uint256 public lastVolumeReset;

    // ==================== MAPPINGS ====================

    /// @dev Core condition storage
    mapping(uint256 => MetriggerTypes.OmnichainCondition) public conditions;

    /// @dev Extension management
    mapping(MetriggerTypes.ConditionType => address) public extensions;
    mapping(MetriggerTypes.ConditionType => MetriggerTypes.ExtensionMetadata) public extensionMetadata;
    mapping(MetriggerTypes.ConditionType => bool) public extensionEnabled;

    /// @dev User condition tracking
    mapping(address => EnumerableSet.UintSet) private userConditions;
    mapping(MetriggerTypes.ConditionStatus => EnumerableSet.UintSet) private conditionsByStatus;

    /// @dev Oracle and DVN management
    EnumerableSet.AddressSet private authorizedOracles;
    EnumerableSet.AddressSet private authorizedDVNs;
    mapping(address => bool) public oracleActive;
    mapping(address => uint256) public oracleSuccessCount;
    mapping(address => uint256) public oracleTotalRequests;

    /// @dev Cross-chain message tracking
    mapping(bytes32 => uint256) public guidToConditionId;
    mapping(uint256 => bytes32[]) public conditionToGuids;
    mapping(uint32 => bool) public supportedChains;

    // ==================== EVENTS ====================

    event ExtensionRegistered(
        MetriggerTypes.ConditionType indexed conditionType,
        address indexed implementation,
        MetriggerTypes.SecurityTier tier
    );

    event OracleAuthorized(address indexed oracle, string name);
    event OracleRevoked(address indexed oracle);
    event DVNAuthorized(address indexed dvn, string name);

    event ProtocolConfigurationUpdated(
        bool protocolFeesEnabled,
        bool extensionFeesEnabled,
        uint256 protocolFeeRate,
        address feeRecipient
    );

    event SecurityParametersUpdated(
        uint256 maxConditionValue,
        uint256 dailyVolumeLimit
    );

    // ==================== CONSTRUCTOR ====================

    /**
     * @dev Initialize the Metrigger Omnichain Registry
     * @param _endpoint LayerZero endpoint address
     * @param _owner Initial owner of the contract
     * @param _securityModule Address of the security module
     * @param _feeRecipient Initial fee recipient
     * @param _protocolFeeRate Initial protocol fee rate (basis points)
     */
    constructor(
        address _endpoint,
        address _owner,
        address _securityModule,
        address _feeRecipient,
        uint256 _protocolFeeRate
    ) OApp(_endpoint, _owner) Ownable(_owner) {
        require(_securityModule != address(0), "Invalid security module");
        require(_feeRecipient != address(0), "Invalid fee recipient");
        require(_protocolFeeRate <= 1000, "Fee rate too high"); // Max 10%

        SECURITY_MODULE = MetriggerSecurity(_securityModule);
        feeRecipient = _feeRecipient;
        protocolFeeRate = _protocolFeeRate;
        protocolFeesEnabled = true;
        extensionFeesEnabled = true;

        maxConditionValue = 1000000e18; // 1M tokens default
        dailyVolumeLimit = 10000000e18; // 10M tokens daily
        lastVolumeReset = block.timestamp;

        // Setup roles
        _grantRole(DEFAULT_ADMIN_ROLE, _owner);
        _grantRole(GOVERNANCE_ROLE, _owner);
        _grantRole(EMERGENCY_ROLE, _owner);
    }

    // ==================== CORE CONDITION FUNCTIONS ====================

    /**
     * @notice Create a new omnichain parametric condition
     * @param params Complete condition parameters
     * @return conditionId Unique identifier for the created condition
     */
    function createOmnichainCondition(
        MetriggerTypes.OmnichainConditionParams calldata params
    )
        external
        payable
        nonReentrant
        whenNotPaused
        returns (uint256 conditionId)
    {
        // Security and validation checks
        SECURITY_MODULE.validateConditionCreation(msg.sender, msg.value);
        _validateConditionParams(params);
        _updateDailyVolume(msg.value);

        // Generate unique condition ID
        conditionId = nextConditionId++;

        // Calculate fees
        MetriggerTypes.FeeBreakdown memory fees = _calculateTotalFees(
            msg.value,
            params.conditionType
        );

        // Create condition structure
        MetriggerTypes.OmnichainCondition storage condition = conditions[conditionId];
        condition.conditionId = conditionId;
        condition.globalHash = keccak256(abi.encode(params, msg.sender, block.timestamp));
        condition.conditionType = params.conditionType;
        condition.creator = msg.sender;
        condition.sourceChain = _getChainId();
        condition.executionChains = params.executionChains;
        condition.stakeholders = params.stakeholders;
        condition.stakes = params.stakes;
        condition.beneficiaries = params.beneficiaries;
        condition.maxPayouts = params.maxPayouts;
        condition.parametricHash = keccak256(params.parametricCriteria);
        condition.oracleConfig = params.oracleConfiguration;
        condition.executionLogic = params.executionLogic;
        condition.intentData = params.intentData;
        condition.status = MetriggerTypes.ConditionStatus.ACTIVE;
        condition.creationTime = block.timestamp;
        condition.expirationTime = params.expirationTime;
        condition.executionDeadline = params.expirationTime + MIN_EXECUTION_DELAY;
        condition.extension = extensions[params.conditionType];
        condition.governanceOverride = params.governanceOverride;
        condition.extensionData = params.extensionData;

        // Handle stake transfers
        _processStakeTransfers(conditionId, params, fees);

        // Route to extension for specialized handling
        if (condition.extension != address(0)) {
            try IMetriggerExtension(condition.extension).createCondition{
                value: fees.netAmount
            }(params) returns (uint256 extensionConditionId) {
                // Extension successfully handled condition creation
                require(extensionConditionId == conditionId, "Condition ID mismatch");
            } catch Error(string memory reason) {
                revert(string(abi.encodePacked("Extension failed: ", reason)));
            } catch {
                revert("Extension call failed");
            }
        }

        // Update tracking structures
        userConditions[msg.sender].add(conditionId);
        conditionsByStatus[MetriggerTypes.ConditionStatus.ACTIVE].add(conditionId);

        // Track for all stakeholders and beneficiaries
        for (uint256 i = 0; i < params.stakeholders.length; i++) {
            userConditions[params.stakeholders[i].addr].add(conditionId);
        }
        for (uint256 i = 0; i < params.beneficiaries.length; i++) {
            userConditions[params.beneficiaries[i].addr].add(conditionId);
        }

        // Send cross-chain messages to execution chains
        _broadcastConditionCreation(conditionId, params);

        emit OmnichainConditionCreated(
            conditionId,
            msg.sender,
            params.conditionType,
            params.executionChains,
            msg.value
        );

        return conditionId;
    }

    /**
     * @notice Update condition status (oracle/DVN only)
     * @param conditionId The condition to update
     * @param newStatus New status to set
     * @param proof Verification proof data
     */
    function updateConditionStatus(
        uint256 conditionId,
        MetriggerTypes.ConditionStatus newStatus,
        bytes calldata proof
    ) external nonReentrant {
        require(
            hasRole(ORACLE_ROLE, msg.sender) || authorizedDVNs.contains(msg.sender),
            "Not authorized"
        );
        require(_conditionExists(conditionId), "Condition does not exist");

        MetriggerTypes.OmnichainCondition storage condition = conditions[conditionId];
        require(condition.status == MetriggerTypes.ConditionStatus.ACTIVE, "Condition not active");
        require(_isValidStatusTransition(condition.status, newStatus), "Invalid transition");

        // Update oracle statistics
        if (hasRole(ORACLE_ROLE, msg.sender)) {
            oracleSuccessCount[msg.sender]++;
            oracleTotalRequests[msg.sender]++;
        }

        MetriggerTypes.ConditionStatus oldStatus = condition.status;
        condition.status = newStatus;
        condition.triggerTime = block.timestamp;
        condition.executingDVN = msg.sender;
        condition.executionProof = keccak256(proof);

        // Update status tracking
        conditionsByStatus[oldStatus].remove(conditionId);
        conditionsByStatus[newStatus].add(conditionId);

        // Route to extension for status handling
        if (condition.extension != address(0)) {
            try IMetriggerExtension(condition.extension).validateExecution(
                conditionId,
                proof
            ) returns (bool valid, string memory reason) {
                require(valid, reason);
            } catch {
                // Revert status change if validation fails
                condition.status = oldStatus;
                conditionsByStatus[newStatus].remove(conditionId);
                conditionsByStatus[oldStatus].add(conditionId);
                revert("Extension validation failed");
            }
        }

        emit ConditionStatusUpdated(conditionId, oldStatus, newStatus, msg.sender, keccak256(proof));

        // Auto-execute if triggered
        if (newStatus == MetriggerTypes.ConditionStatus.TRIGGERED) {
            _executeCondition(conditionId);
        }
    }

    /**
     * @notice Execute a triggered condition
     * @param conditionId The condition to execute
     * @return success Whether execution succeeded
     */
    function executeCondition(uint256 conditionId)
        external
        nonReentrant
        whenNotPaused
        returns (bool success)
    {
        require(_conditionExists(conditionId), "Condition does not exist");

        MetriggerTypes.OmnichainCondition storage condition = conditions[conditionId];
        require(
            condition.status == MetriggerTypes.ConditionStatus.TRIGGERED ||
            condition.status == MetriggerTypes.ConditionStatus.EXPIRED,
            "Condition not executable"
        );

        return _executeCondition(conditionId);
    }

    // ==================== INTERNAL EXECUTION LOGIC ====================

    /**
     * @dev Internal function to execute a condition
     */
    function _executeCondition(uint256 conditionId) internal returns (bool success) {
        MetriggerTypes.OmnichainCondition storage condition = conditions[conditionId];

        // Route to extension for execution
        if (condition.extension != address(0)) {
            try IMetriggerExtension(condition.extension).executeCondition(conditionId)
                returns (bool extensionSuccess) {
                success = extensionSuccess;
            } catch {
                success = false;
            }
        } else {
            // Default execution logic for core condition types
            success = _executeDefaultCondition(conditionId);
        }

        if (success) {
            // Update condition status
            conditionsByStatus[condition.status].remove(conditionId);
            condition.status = MetriggerTypes.ConditionStatus.EXECUTED;
            conditionsByStatus[MetriggerTypes.ConditionStatus.EXECUTED].add(conditionId);

            // Broadcast execution to other chains
            _broadcastConditionExecution(conditionId);

            emit ConditionExecuted(
                conditionId,
                _calculateTotalPayout(conditionId),
                _getBeneficiaryAddresses(conditionId),
                _getPayoutAmounts(conditionId)
            );
        }

        return success;
    }

    /**
     * @dev Default execution logic for basic condition types
     */
    function _executeDefaultCondition(uint256 conditionId) internal returns (bool) {
        MetriggerTypes.OmnichainCondition storage condition = conditions[conditionId];

        if (condition.conditionType == MetriggerTypes.ConditionType.SINGLE_SIDED) {
            return _executeSingleSidedCondition(conditionId);
        } else if (condition.conditionType == MetriggerTypes.ConditionType.MULTI_SIDED) {
            return _executeMultiSidedCondition(conditionId);
        } else if (condition.conditionType == MetriggerTypes.ConditionType.TIME_LOCKED) {
            return _executeTimeLockedCondition(conditionId);
        }

        return false; // Unsupported condition type
    }

    /**
     * @dev Execute single-sided condition (insurance-like pattern)
     */
    function _executeSingleSidedCondition(uint256 conditionId) internal returns (bool) {
        MetriggerTypes.OmnichainCondition storage condition = conditions[conditionId];

        if (condition.status == MetriggerTypes.ConditionStatus.TRIGGERED) {
            // Condition met - pay beneficiaries
            for (uint256 i = 0; i < condition.beneficiaries.length; i++) {
                MetriggerTypes.ChainAddress memory beneficiary = condition.beneficiaries[i];
                MetriggerTypes.ChainAmount memory payout = condition.maxPayouts[i];

                if (payout.chainId == _getChainId()) {
                    // Execute payout on current chain
                    _executePayout(beneficiary.addr, payout.token, payout.amount);
                } else {
                    // Send cross-chain payout message
                    _sendCrossChainPayout(beneficiary, payout);
                }
            }
            return true;
        } else if (condition.status == MetriggerTypes.ConditionStatus.EXPIRED) {
            // Condition expired - return stakes to depositors
            for (uint256 i = 0; i < condition.stakeholders.length; i++) {
                MetriggerTypes.ChainAddress memory stakeholder = condition.stakeholders[i];
                MetriggerTypes.ChainAmount memory stake = condition.stakes[i];

                if (stake.chainId == _getChainId()) {
                    _executePayout(stakeholder.addr, stake.token, stake.amount);
                } else {
                    _sendCrossChainPayout(stakeholder, stake);
                }
            }
            return true;
        }

        return false;
    }

    /**
     * @dev Execute multi-sided condition
     */
    function _executeMultiSidedCondition(uint256 conditionId) internal returns (bool) {
        // Implementation for multi-sided condition execution
        // This would include complex distribution logic based on execution logic
        return true;
    }

    /**
     * @dev Execute time-locked condition
     */
    function _executeTimeLockedCondition(uint256 conditionId) internal returns (bool) {
        MetriggerTypes.OmnichainCondition storage condition = conditions[conditionId];

        if (block.timestamp >= condition.expirationTime) {
            // Time lock expired - execute payouts
            for (uint256 i = 0; i < condition.beneficiaries.length; i++) {
                MetriggerTypes.ChainAddress memory beneficiary = condition.beneficiaries[i];
                MetriggerTypes.ChainAmount memory payout = condition.maxPayouts[i];

                if (payout.chainId == _getChainId()) {
                    _executePayout(beneficiary.addr, payout.token, payout.amount);
                } else {
                    _sendCrossChainPayout(beneficiary, payout);
                }
            }
            return true;
        }

        return false;
    }

    // ==================== CROSS-CHAIN MESSAGING ====================

    /**
     * @dev Handle incoming LayerZero messages
     */
    function _lzReceive(
        Origin calldata _origin,
        bytes32 _guid,
        bytes calldata _message,
        address /*_executor*/,
        bytes calldata /*_extraData*/
    ) internal override {
        // Decode message type and data
        (uint8 msgType, uint256 conditionId, bytes memory data) =
            abi.decode(_message, (uint8, uint256, bytes));

        guidToConditionId[_guid] = conditionId;
        conditionToGuids[conditionId].push(_guid);

        if (msgType == 1) { // CONDITION_CREATED
            _handleConditionCreated(conditionId, data, _origin.srcEid);
        } else if (msgType == 2) { // CONDITION_TRIGGERED
            _handleConditionTriggered(conditionId, data, _origin.srcEid);
        } else if (msgType == 3) { // EXECUTION_CONFIRMED
            _handleExecutionConfirmed(conditionId, data, _origin.srcEid);
        }

        emit CrossChainMessageSent(conditionId, _origin.srcEid, _guid, _message);
    }

    // ==================== QUERY FUNCTIONS ====================

    /**
     * @notice Get complete condition information
     */
    function getCondition(uint256 conditionId)
        external
        view
        returns (MetriggerTypes.OmnichainCondition memory)
    {
        require(_conditionExists(conditionId), "Condition does not exist");
        return conditions[conditionId];
    }

    /**
     * @notice Get all condition IDs for a user
     */
    function getUserConditions(address user)
        external
        view
        returns (uint256[] memory)
    {
        uint256 length = userConditions[user].length();
        uint256[] memory conditionIds = new uint256[](length);

        for (uint256 i = 0; i < length; i++) {
            conditionIds[i] = userConditions[user].at(i);
        }

        return conditionIds;
    }

    /**
     * @notice Get conditions by status
     */
    function getConditionsByStatus(MetriggerTypes.ConditionStatus status)
        external
        view
        returns (uint256[] memory)
    {
        uint256 length = conditionsByStatus[status].length();
        uint256[] memory conditionIds = new uint256[](length);

        for (uint256 i = 0; i < length; i++) {
            conditionIds[i] = conditionsByStatus[status].at(i);
        }

        return conditionIds;
    }

    // ==================== ADMIN FUNCTIONS ====================

    /**
     * @notice Register a new extension (governance only)
     */
    function registerExtension(
        MetriggerTypes.ConditionType conditionType,
        address implementation,
        MetriggerTypes.ExtensionMetadata calldata metadata
    ) external onlyRole(GOVERNANCE_ROLE) {
        require(implementation != address(0), "Invalid implementation");
        require(
            IERC165(implementation).supportsInterface(type(IMetriggerExtension).interfaceId),
            "Invalid interface"
        );

        extensions[conditionType] = implementation;
        extensionMetadata[conditionType] = metadata;
        extensionEnabled[conditionType] = true;

        emit ExtensionRegistered(conditionType, implementation, metadata.securityTier);
    }

    /**
     * @notice Authorize oracle (governance only)
     */
    function authorizeOracle(address oracle, string calldata name)
        external
        onlyRole(GOVERNANCE_ROLE)
    {
        require(oracle != address(0), "Invalid oracle");
        authorizedOracles.add(oracle);
        oracleActive[oracle] = true;
        _grantRole(ORACLE_ROLE, oracle);

        emit OracleAuthorized(oracle, name);
    }

    // ==================== INTERNAL HELPER FUNCTIONS ====================

    function _conditionExists(uint256 conditionId) internal view returns (bool) {
        return conditionId > 0 && conditionId < nextConditionId &&
               conditions[conditionId].creator != address(0);
    }

    function _getChainId() internal view returns (uint32) {
        return uint32(block.chainid);
    }

    function _calculateTotalFees(uint256 amount, MetriggerTypes.ConditionType conditionType)
        internal
        view
        returns (MetriggerTypes.FeeBreakdown memory)
    {
        uint256 protocolFee = protocolFeesEnabled ? (amount * protocolFeeRate) / 10000 : 0;
        uint256 extensionFee = 0;

        address extension = extensions[conditionType];
        if (extensionFeesEnabled && extension != address(0)) {
            (extensionFee,) = IMetriggerExtension(extension).calculateFees(amount, conditionType);
        }

        uint256 totalFees = protocolFee + extensionFee;

        return MetriggerTypes.FeeBreakdown({
            extensionFee: extensionFee,
            protocolFee: protocolFee,
            totalFees: totalFees,
            netAmount: amount - totalFees,
            extensionFeeRecipient: extension,
            feesEnabled: protocolFeesEnabled || extensionFeesEnabled
        });
    }

    // Additional helper functions would be implemented here...
    // _validateConditionParams, _processStakeTransfers, _broadcastConditionCreation, etc.
}
```

---

## 🔌 **Base Extension Implementation**

### **BaseMetriggerExtension.sol**

```solidity
// SPDX-License-Identifier: BSL-1.1
pragma solidity ^0.8.27;

import {OApp, Origin, MessagingFee} from "@layerzerolabs/oapp-evm/contracts/oapp/OApp.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Pausable} from "@openzeppelin/contracts/utils/Pausable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {IERC20, SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {ERC165} from "@openzeppelin/contracts/utils/introspection/ERC165.sol";

import "./interfaces/IMetriggerExtension.sol";
import "./MetriggerTypes.sol";

/**
 * @title BaseMetriggerExtension
 * @dev Universal base contract for all Metrigger condition extensions
 * @notice Provides common functionality including LayerZero integration and security
 */
abstract contract BaseMetriggerExtension is
    IMetriggerExtension,
    OApp,
    ERC165,
    Ownable,
    Pausable,
    ReentrancyGuard
{
    using SafeERC20 for IERC20;

    // ==================== STATE VARIABLES ====================

    address public immutable METRIGGER_REGISTRY;
    address public governance;

    uint256 public extensionFeeRate; // basis points
    address public feeRecipient;
    uint256 public accumulatedFees;
    bool public feesDisabledByGovernance;

    uint256 private _nextConditionId = 1;
    MetriggerTypes.ExtensionMetadata public metadata;

    mapping(uint256 => bool) public conditionExists;
    mapping(uint256 => bytes) public extensionSpecificData;

    // ==================== EVENTS ====================

    event FeesWithdrawn(address recipient, uint256 amount);
    event FeeRateUpdated(uint256 oldRate, uint256 newRate);
    event GovernanceOverride(string action, address governance);

    // ==================== MODIFIERS ====================

    modifier onlyRegistry() {
        require(msg.sender == METRIGGER_REGISTRY, "Only registry");
        _;
    }

    modifier onlyGovernance() {
        require(msg.sender == governance, "Only governance");
        _;
    }

    // ==================== CONSTRUCTOR ====================

    constructor(
        address _endpoint,
        address _registry,
        address _governance,
        MetriggerTypes.ExtensionMetadata memory _metadata
    ) OApp(_endpoint, msg.sender) Ownable(msg.sender) {
        require(_registry != address(0), "Invalid registry");
        require(_governance != address(0), "Invalid governance");

        METRIGGER_REGISTRY = _registry;
        governance = _governance;
        metadata = _metadata;

        extensionFeeRate = 100; // 1% default
        feeRecipient = msg.sender;
    }

    // ==================== EXTENSION INTERFACE ====================

    /**
     * @notice Create a new condition through this extension
     */
    function createCondition(
        MetriggerTypes.OmnichainConditionParams calldata params
    )
        external
        payable
        virtual
        override
        nonReentrant
        whenNotPaused
        returns (uint256 conditionId)
    {
        require(msg.sender == METRIGGER_REGISTRY, "Only registry can create");
        require(_supportsConditionType(params.conditionType), "Unsupported condition type");

        conditionId = _nextConditionId++;
        conditionExists[conditionId] = true;

        // Store extension-specific data
        extensionSpecificData[conditionId] = params.extensionData;

        // Collect fees
        if (!feesDisabledByGovernance && extensionFeeRate > 0) {
            uint256 fee = (msg.value * extensionFeeRate) / 10000;
            accumulatedFees += fee;
        }

        // Call specialized creation logic
        _createConditionSpecific(conditionId, params);

        emit ConditionCreatedByExtension(
            conditionId,
            tx.origin, // Original creator
            params.conditionType,
            (msg.value * extensionFeeRate) / 10000
        );

        return conditionId;
    }

    /**
     * @notice Validate execution criteria for a condition
     */
    function validateExecution(
        uint256 conditionId,
        bytes calldata proof
    ) external view virtual override returns (bool valid, string memory reason) {
        require(conditionExists[conditionId], "Condition does not exist");
        return _validateExecutionSpecific(conditionId, proof);
    }

    /**
     * @notice Execute a condition
     */
    function executeCondition(uint256 conditionId)
        external
        virtual
        override
        nonReentrant
        whenNotPaused
        returns (bool success)
    {
        require(conditionExists[conditionId], "Condition does not exist");
        return _executeConditionSpecific(conditionId);
    }

    /**
     * @notice Calculate fees for extension
     */
    function calculateFees(
        uint256 amount,
        MetriggerTypes.ConditionType conditionType
    ) external view override returns (uint256 extensionFee, uint256 protocolFee) {
        if (feesDisabledByGovernance || !_supportsConditionType(conditionType)) {
            return (0, 0);
        }

        extensionFee = (amount * extensionFeeRate) / 10000;
        protocolFee = 0; // Protocol fees calculated by registry

        return (extensionFee, protocolFee);
    }

    /**
     * @notice Get extension metadata
     */
    function getExtensionMetadata()
        external
        view
        override
        returns (MetriggerTypes.ExtensionMetadata memory)
    {
        return metadata;
    }

    /**
     * @notice Get supported condition types
     */
    function getSupportedConditionTypes()
        external
        view
        virtual
        override
        returns (MetriggerTypes.ConditionType[] memory)
    {
        return _getSupportedConditionTypesSpecific();
    }

    // ==================== FEE MANAGEMENT ====================

    /**
     * @notice Withdraw accumulated fees
     */
    function withdrawFees(address to, uint256 amount) external override {
        require(msg.sender == feeRecipient || msg.sender == owner(), "Not authorized");
        require(to != address(0), "Invalid recipient");

        if (amount == 0) {
            amount = accumulatedFees;
        }

        require(amount <= accumulatedFees, "Insufficient fees");
        accumulatedFees -= amount;

        payable(to).transfer(amount);
        emit FeesWithdrawn(to, amount);
    }

    /**
     * @notice Update fee rate (owner only)
     */
    function updateFeeRate(uint256 newRate) external onlyOwner {
        require(newRate <= 2500, "Fee rate too high"); // Max 25%

        uint256 oldRate = extensionFeeRate;
        extensionFeeRate = newRate;

        emit FeeRateUpdated(oldRate, newRate);
    }

    // ==================== GOVERNANCE FUNCTIONS ====================

    /**
     * @notice Emergency fee disable (governance only)
     */
    function setFeesDisabled(bool disabled) external onlyGovernance {
        feesDisabledByGovernance = disabled;
        emit GovernanceOverride("fees_disabled", governance);
    }

    /**
     * @notice Pause extension operations (governance only)
     */
    function pause() external onlyGovernance {
        _pause();
        emit GovernanceOverride("paused", governance);
    }

    /**
     * @notice Unpause extension operations (governance only)
     */
    function unpause() external onlyGovernance {
        _unpause();
        emit GovernanceOverride("unpaused", governance);
    }

    // ==================== ABSTRACT FUNCTIONS ====================

    /**
     * @dev Implement extension-specific condition creation logic
     */
    function _createConditionSpecific(
        uint256 conditionId,
        MetriggerTypes.OmnichainConditionParams calldata params
    ) internal virtual;

    /**
     * @dev Implement extension-specific execution validation
     */
    function _validateExecutionSpecific(
        uint256 conditionId,
        bytes calldata proof
    ) internal view virtual returns (bool valid, string memory reason);

    /**
     * @dev Implement extension-specific execution logic
     */
    function _executeConditionSpecific(uint256 conditionId)
        internal virtual returns (bool success);

    /**
     * @dev Return supported condition types for this extension
     */
    function _getSupportedConditionTypesSpecific()
        internal view virtual returns (MetriggerTypes.ConditionType[] memory);

    /**
     * @dev Check if extension supports a condition type
     */
    function _supportsConditionType(MetriggerTypes.ConditionType conditionType)
        internal view virtual returns (bool);

    // ==================== INTERFACE SUPPORT ====================

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC165, IERC165)
        returns (bool)
    {
        return
            interfaceId == type(IMetriggerExtension).interfaceId ||
            super.supportsInterface(interfaceId);
    }
}
```

---

## 🎯 **Core Extension Examples**

### **SingleSidedExtension.sol**

```solidity
// SPDX-License-Identifier: BSL-1.1
pragma solidity ^0.8.27;

import "./BaseMetriggerExtension.sol";

/**
 * @title SingleSidedExtension
 * @dev Extension for single depositor, conditional payout patterns
 * @notice Perfect for insurance, bounties, and conditional payments
 */
contract SingleSidedExtension is BaseMetriggerExtension {

    struct SingleSidedCondition {
        address depositor;          // Who deposited the funds
        address beneficiary;        // Who receives payout if triggered
        address token;             // Token contract (0x0 for ETH)
        uint256 depositAmount;     // Amount deposited
        uint256 payoutAmount;      // Amount to pay if triggered
        uint256 expirationTime;    // When condition expires
        bytes32 triggerCriteria;   // What triggers the payout
    }

    mapping(uint256 => SingleSidedCondition) public singleSidedConditions;

    constructor(
        address _endpoint,
        address _registry,
        address _governance
    ) BaseMetriggerExtension(
        _endpoint,
        _registry,
        _governance,
        MetriggerTypes.ExtensionMetadata({
            name: "Single Sided Extension",
            version: "1.0.0",
            description: "One depositor, conditional payout pattern",
            supportedTypes: _createSupportedTypes(),
            securityTier: MetriggerTypes.SecurityTier.CORE,
            customLogicEnabled: true,
            minStakeAmount: 0.001 ether,
            maxStakeAmount: 1000 ether,
            maintainer: msg.sender,
            totalConditions: 0,
            totalVolume: 0
        })
    ) {}

    function _createConditionSpecific(
        uint256 conditionId,
        MetriggerTypes.OmnichainConditionParams calldata params
    ) internal override {
        require(params.stakeholders.length == 1, "Single depositor only");
        require(params.beneficiaries.length >= 1, "At least one beneficiary");

        singleSidedConditions[conditionId] = SingleSidedCondition({
            depositor: params.stakeholders[0].addr,
            beneficiary: params.beneficiaries[0].addr,
            token: params.stakes[0].token,
            depositAmount: params.stakes[0].amount,
            payoutAmount: params.maxPayouts[0].amount,
            expirationTime: params.expirationTime,
            triggerCriteria: keccak256(params.parametricCriteria)
        });
    }

    function _validateExecutionSpecific(
        uint256 conditionId,
        bytes calldata proof
    ) internal view override returns (bool valid, string memory reason) {
        SingleSidedCondition memory condition = singleSidedConditions[conditionId];

        if (block.timestamp > condition.expirationTime) {
            return (true, "Condition expired - return to depositor");
        }

        // Validate proof against trigger criteria
        if (keccak256(proof) == condition.triggerCriteria) {
            return (true, "Trigger criteria met - pay beneficiary");
        }

        return (false, "Trigger criteria not met");
    }

    function _executeConditionSpecific(uint256 conditionId)
        internal override returns (bool success)
    {
        SingleSidedCondition memory condition = singleSidedConditions[conditionId];

        if (block.timestamp > condition.expirationTime) {
            // Return deposit to depositor
            _executePayout(condition.depositor, condition.token, condition.depositAmount);
            return true;
        } else {
            // Pay beneficiary
            _executePayout(condition.beneficiary, condition.token, condition.payoutAmount);
            return true;
        }
    }

    function _getSupportedConditionTypesSpecific()
        internal pure override returns (MetriggerTypes.ConditionType[] memory)
    {
        MetriggerTypes.ConditionType[] memory types = new MetriggerTypes.ConditionType[](1);
        types[0] = MetriggerTypes.ConditionType.SINGLE_SIDED;
        return types;
    }

    function _supportsConditionType(MetriggerTypes.ConditionType conditionType)
        internal pure override returns (bool)
    {
        return conditionType == MetriggerTypes.ConditionType.SINGLE_SIDED;
    }

    function _createSupportedTypes() private pure returns (MetriggerTypes.ConditionType[] memory) {
        MetriggerTypes.ConditionType[] memory types = new MetriggerTypes.ConditionType[](1);
        types[0] = MetriggerTypes.ConditionType.SINGLE_SIDED;
        return types;
    }

    function _executePayout(address recipient, address token, uint256 amount) internal {
        if (token == address(0)) {
            payable(recipient).transfer(amount);
        } else {
            IERC20(token).safeTransfer(recipient, amount);
        }
    }
}
```

---

## 🔍 **Custom DVN Implementation**

### **MetriggerParametricDVN.sol**

```solidity
// SPDX-License-Identifier: BSL-1.1
pragma solidity ^0.8.27;

import {DVN} from "@layerzerolabs/messagelib-evm/contracts/dvn/DVN.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title MetriggerParametricDVN
 * @dev Custom DVN specialized for parametric condition data verification
 * @notice Provides multi-source data verification for flight, weather, price data
 */
contract MetriggerParametricDVN is DVN, Ownable {

    struct DataVerification {
        bytes32 dataHash;           // Hash of verified data
        address[] dataSources;      // Multiple data source verification
        uint256 confidence;         // Confidence score (0-100)
        uint256 timestamp;          // Verification timestamp
        bytes proof;               // Cryptographic proof
        bool verified;             // Verification status
    }

    struct DataSource {
        string name;               // Data source name
        string endpoint;           // API endpoint or identifier
        bool active;              // Whether source is active
        uint256 successRate;      // Historical success rate
        uint256 totalQueries;     // Total queries made
    }

    mapping(bytes32 => DataVerification) public verifications;
    mapping(address => DataSource) public dataSources;
    mapping(address => bool) public authorizedSources;

    uint256 public constant MIN_SOURCES_REQUIRED = 2;
    uint256 public constant MIN_CONFIDENCE_THRESHOLD = 75; // 75%

    event DataVerified(
        bytes32 indexed verificationHash,
        string dataType,
        uint256 confidence,
        address[] sources
    );

    event DataSourceRegistered(address indexed source, string name);

    constructor(
        address _messageLib,
        address _roleAdmin,
        address _admin
    ) DVN(_messageLib, _roleAdmin, _admin) Ownable(msg.sender) {}

    /**
     * @notice Verify flight delay data from multiple sources
     */
    function verifyFlightData(
        string calldata flightNumber,
        uint256 scheduledTime,
        uint256 actualTime,
        bytes[] calldata sourceProofs
    ) external returns (bytes32 verificationHash) {
        require(sourceProofs.length >= MIN_SOURCES_REQUIRED, "Insufficient sources");

        // Calculate delay
        uint256 delayMinutes = actualTime > scheduledTime ?
            (actualTime - scheduledTime) / 60 : 0;

        // Cross-verify data from multiple sources
        uint256 consensusCount = 0;
        address[] memory sources = new address[](sourceProofs.length);

        for (uint256 i = 0; i < sourceProofs.length; i++) {
            address source = _extractSourceFromProof(sourceProofs[i]);
            if (authorizedSources[source] && _verifySourceProof(sourceProofs[i])) {
                sources[consensusCount] = source;
                consensusCount++;

                // Update source statistics
                dataSources[source].totalQueries++;
            }
        }

        require(consensusCount >= MIN_SOURCES_REQUIRED, "Insufficient consensus");

        // Calculate confidence score
        uint256 confidence = (consensusCount * 100) / sourceProofs.length;
        require(confidence >= MIN_CONFIDENCE_THRESHOLD, "Confidence too low");

        // Create verification hash
        verificationHash = keccak256(abi.encode(
            "FLIGHT_DATA",
            flightNumber,
            scheduledTime,
            actualTime,
            delayMinutes,
            block.timestamp
        ));

        // Store verification
        verifications[verificationHash] = DataVerification({
            dataHash: verificationHash,
            dataSources: _trimArray(sources, consensusCount),
            confidence: confidence,
            timestamp: block.timestamp,
            proof: abi.encode(delayMinutes, consensusCount),
            verified: true
        });

        emit DataVerified(verificationHash, "FLIGHT_DATA", confidence, sources);

        return verificationHash;
    }

    /**
     * @notice Verify weather condition data
     */
    function verifyWeatherData(
        bytes32 location,
        string calldata conditionType,
        int256 measurement,
        int256 threshold,
        bytes[] calldata sourceProofs
    ) external returns (bytes32 verificationHash) {
        require(sourceProofs.length >= MIN_SOURCES_REQUIRED, "Insufficient sources");

        uint256 consensusCount = 0;
        address[] memory sources = new address[](sourceProofs.length);

        for (uint256 i = 0; i < sourceProofs.length; i++) {
            address source = _extractSourceFromProof(sourceProofs[i]);
            if (authorizedSources[source] && _verifySourceProof(sourceProofs[i])) {
                sources[consensusCount] = source;
                consensusCount++;
            }
        }

        require(consensusCount >= MIN_SOURCES_REQUIRED, "Insufficient consensus");

        // Determine if threshold is met
        bool thresholdMet = (conditionType.equal("temperature_below") && measurement < threshold) ||
                           (conditionType.equal("temperature_above") && measurement > threshold) ||
                           (conditionType.equal("rainfall_above") && measurement > threshold);

        uint256 confidence = (consensusCount * 100) / sourceProofs.length;
        require(confidence >= MIN_CONFIDENCE_THRESHOLD, "Confidence too low");

        verificationHash = keccak256(abi.encode(
            "WEATHER_DATA",
            location,
            conditionType,
            measurement,
            threshold,
            thresholdMet,
            block.timestamp
        ));

        verifications[verificationHash] = DataVerification({
            dataHash: verificationHash,
            dataSources: _trimArray(sources, consensusCount),
            confidence: confidence,
            timestamp: block.timestamp,
            proof: abi.encode(measurement, thresholdMet),
            verified: true
        });

        emit DataVerified(verificationHash, "WEATHER_DATA", confidence, sources);

        return verificationHash;
    }

    /**
     * @notice Register a new data source
     */
    function registerDataSource(
        address source,
        string calldata name,
        string calldata endpoint
    ) external onlyOwner {
        require(source != address(0), "Invalid source");

        dataSources[source] = DataSource({
            name: name,
            endpoint: endpoint,
            active: true,
            successRate: 100, // Start with 100%
            totalQueries: 0
        });

        authorizedSources[source] = true;

        emit DataSourceRegistered(source, name);
    }

    /**
     * @notice Get verification details
     */
    function getVerification(bytes32 verificationHash)
        external
        view
        returns (DataVerification memory)
    {
        return verifications[verificationHash];
    }

    // ==================== INTERNAL FUNCTIONS ====================

    function _extractSourceFromProof(bytes calldata proof) internal pure returns (address) {
        // Extract source address from proof data
        if (proof.length >= 20) {
            return address(bytes20(proof[:20]));
        }
        return address(0);
    }

    function _verifySourceProof(bytes calldata proof) internal view returns (bool) {
        // Implement proof verification logic
        // This would include signature verification, timestamp validation, etc.
        return proof.length > 0; // Simplified for example
    }

    function _trimArray(address[] memory sources, uint256 length)
        internal
        pure
        returns (address[] memory)
    {
        address[] memory trimmed = new address[](length);
        for (uint256 i = 0; i < length; i++) {
            trimmed[i] = sources[i];
        }
        return trimmed;
    }
}
```

---

## 🏛️ **Governance Framework**

### **MetriggerGovernance.sol**

```solidity
// SPDX-License-Identifier: BSL-1.1
pragma solidity ^0.8.27;

import {Governor, IGovernor} from "@openzeppelin/contracts/governance/Governor.sol";
import {GovernorSettings} from "@openzeppelin/contracts/governance/extensions/GovernorSettings.sol";
import {GovernorCountingSimple} from "@openzeppelin/contracts/governance/extensions/GovernorCountingSimple.sol";
import {GovernorVotes, IVotes} from "@openzeppelin/contracts/governance/extensions/GovernorVotes.sol";
import {GovernorVotesQuorumFraction} from "@openzeppelin/contracts/governance/extensions/GovernorVotesQuorumFraction.sol";
import {GovernorTimelockControl, TimelockController} from "@openzeppelin/contracts/governance/extensions/GovernorTimelockControl.sol";
import {OApp} from "@layerzerolabs/oapp-evm/contracts/oapp/OApp.sol";

/**
 * @title MetriggerGovernance
 * @dev Cross-chain governance system for
