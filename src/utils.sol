// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts/utils/math/SignedSafeMath.sol";

using Math for uint;

function encodeSqrtPrice(uint reserve1, uint reserve0) pure returns (uint160) {
  return uint160((reserve1 / reserve0).sqrt() * (2**96));
}

function getMinTick(int24 tickSpacing) pure returns (int24) {
  return int24(SignedSafeMath.div(-887272, tickSpacing) * tickSpacing);
}

function getMaxTick(int24 tickSpacing) pure returns (int24) {
  return int24(SignedSafeMath.div(887272, tickSpacing) * tickSpacing);
}