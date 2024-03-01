// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "algebra-core/libraries/TickMath.sol";
import "src/WhitelistAlgebraPlugin.sol";
import "src/utils.sol";
import "./BasePluginTest.sol";

contract WhitelistPluginTest is BasePluginTest {
    WhitelistAlgebraPlugin wlp;

    function getPlugin(IAlgebraPool) internal override returns (address) {
        wlp = new WhitelistAlgebraPlugin(address(pool));
        return address(wlp);
    }

    function setUp() public {
        initialize();
    }

    function test_whitelist() public {
        assertFalse(wlp.isWhitelisted(address(this)));
        wlp.whitelist(address(this));
        assertTrue(wlp.isWhitelisted(address(this)));
    }

    function test_RevertWhen_nonAdminCallsWhitelist() public {
        assertFalse(wlp.isWhitelisted(address(this)));
        vm.prank(address(2));
        vm.expectRevert(WhitelistAlgebraPlugin.onlyAdministratorAllowed.selector);
        wlp.whitelist(address(this));
    }

    function test_RevertWhen_NonWhitelistedAddressAttemptAction() public {
        address user = user1;
        uint256 initialBalance0 = token0.balanceOf(user);
        uint256 initialBalance1 = token1.balanceOf(user);
        int24 minTick = _minTick();
        int24 maxTick = _maxTick();

        (uint256 liquidity,,,,) = pool.positions(getKeyForPosition(user, minTick, maxTick));
        assertEq(liquidity, 0);

        assertFalse(wlp.isWhitelisted(user));
        vm.expectRevert(WhitelistAlgebraPlugin.onlyWhitelistedAllowed.selector);
        pool.mint(address(this), user, minTick, maxTick, 10 ** 18, abi.encode(address(this)));
        vm.expectRevert(WhitelistAlgebraPlugin.onlyWhitelistedAllowed.selector);
        pool.swap(user, true, 10, TickMath.MIN_SQRT_RATIO + 1, abi.encode(address(this)));
        vm.expectRevert(WhitelistAlgebraPlugin.onlyWhitelistedAllowed.selector);
        pool.flash(user, 10, 10, abi.encode(user, 10, 10));

        assertEq(token0.balanceOf(user), initialBalance0);
        assertEq(token1.balanceOf(user), initialBalance1);
        (liquidity,,,,) = pool.positions(getKeyForPosition(user, minTick, maxTick));
        assertEq(liquidity, 0);
    }

    function test_whitelistedAddressCanPerformActions() public {
        address user = user1;
        uint256 initialBalance0 = token0.balanceOf(user);
        uint256 initialBalance1 = token1.balanceOf(user);
        (uint256 liquidity,,,,) = pool.positions(getKeyForPosition(user, _minTick(), _maxTick()));
        assertEq(liquidity, 0);

        wlp.whitelist(user);
        pool.mint(user, user, _minTick(), _maxTick(), 10 ** 18, abi.encode(user));
        pool.swap(user, true, 10, TickMath.MIN_SQRT_RATIO + 1, abi.encode(user));
        pool.flash(user, 10, 10, abi.encode(user, 10, 10));

        assertNotEq(token0.balanceOf(user), initialBalance0);
        assertNotEq(token1.balanceOf(user), initialBalance1);
        (liquidity,,,,) = pool.positions(getKeyForPosition(user, _minTick(), _maxTick()));
        assertNotEq(liquidity, 0);
    }
}
