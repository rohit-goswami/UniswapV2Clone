// SPDX-License-Identifier: Unlicense 


pragma solidity 0.8.17;

interface IUniswapV2Pair {
    function mint(address) external returns (uint256);
    function burn(address) external returns (uint256, uint256);
   // function transferFrom(address, address, uint256) external returns (bool);
    function getReserves() external returns ( uint112, uint112, uint32);
    function initialize(address, address) external;
}