// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.4;

import {AlgebraPlugin, IAlgebraPlugin} from "./base/AlgebraPlugin.sol";
import {IAlgebraPool} from "algebra-core/interfaces/IAlgebraPool.sol";
import {IAlgebraFactory} from "algebra-core/interfaces/IAlgebraFactory.sol";
import {PoolInteraction} from "./libraries/PoolInteraction.sol";
import {PluginConfig, Plugins} from "./types/PluginConfig.sol";

contract WhitelistAlgebraPlugin is AlgebraPlugin {
    error onlyPoolAllowed();
    error onlyAdministratorAllowed();
    error onlyWhitelistedAllowed();

    event Whitelisted(address indexed _address);
    event Unwhitelisted(address indexed _address);

    IAlgebraFactory public immutable factory;

    bytes32 public constant WHITELIST_ALGEBRA_ADMINISTRATOR = keccak256("WHITELIST_ALGEBRA_ADMINISTRATOR");

    PluginConfig private constant _defaultPluginConfig = PluginConfig.wrap(
        uint8(Plugins.BEFORE_POSITION_MODIFY_FLAG | Plugins.BEFORE_SWAP_FLAG | Plugins.BEFORE_FLASH_FLAG)
    );

    /// @notice the Algebra Integral pool
    IAlgebraPool public immutable pool;

    mapping(address => bool) public isWhitelisted;

    modifier onlyPool() {
        _checkOnlyPool();
        _;
    }

    modifier onlyAdministrator() {
        if (!factory.hasRoleOrOwner(WHITELIST_ALGEBRA_ADMINISTRATOR, msg.sender)) revert onlyAdministratorAllowed();
        _;
    }

    constructor(address _pool) {
        pool = IAlgebraPool(_pool);
        factory = IAlgebraFactory(pool.factory());
    }

    function defaultPluginConfig() external pure override returns (uint8 pluginConfig) {
        return _defaultPluginConfig.unwrap();
    }

    /// @inheritdoc IAlgebraPlugin
    function beforeInitialize(address, uint160) external onlyPool returns (bytes4) {
        PoolInteraction.changePluginConfigIfNeeded(pool, _defaultPluginConfig);
        return IAlgebraPlugin.beforeInitialize.selector;
    }

    function _checkOnlyPool() internal view {
        if (msg.sender != address(pool)) revert onlyPoolAllowed();
    }

    function whitelist(address _address) external onlyAdministrator {
        isWhitelisted[_address] = true;
        emit Whitelisted(_address);
    }

    function unwhitelist(address _address) external onlyAdministrator {
        isWhitelisted[_address] = false;
        emit Unwhitelisted(_address);
    }

    /// @inheritdoc IAlgebraPlugin
    function beforeSwap(address, address receipient, bool, int256, uint160, bool, bytes calldata)
        external
        view
        override
        returns (bytes4)
    {
        if (!isWhitelisted[receipient]) revert onlyWhitelistedAllowed();
        return IAlgebraPlugin.beforeSwap.selector;
    }

    /// @inheritdoc IAlgebraPlugin
    function beforeFlash(address, address receipient, uint256, uint256, bytes calldata)
        external
        view
        override
        returns (bytes4)
    {
        if (!isWhitelisted[receipient]) revert onlyWhitelistedAllowed();
        return IAlgebraPlugin.beforeFlash.selector;
    }

    /// @inheritdoc IAlgebraPlugin
    function beforeModifyPosition(address, address receipient, int24, int24, int128, bytes calldata)
        external
        view
        override
        returns (bytes4)
    {
        if (!isWhitelisted[receipient]) revert onlyWhitelistedAllowed();
        return IAlgebraPlugin.beforeModifyPosition.selector;
    }
}
