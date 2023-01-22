//SPDX-License-Identifier: Unlicense

pragma solidity 0.8.17;

interface IUniswapV2Factory {
    function pairs(address tokenA, address tokenB) external view returns (address pair);

    function createPair(address tokenA, address tokenB) external returns (address pair);
}