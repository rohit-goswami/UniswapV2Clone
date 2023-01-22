// SPDX-License-Identifier: Unlicense

pragma solidity 0.8.17;

import "./UniswapV2Pair.sol";
import "./Interfaces/IUniswapV2Factory.sol";

contract UniswapV2Factory is IUniswapV2Factory {
    mapping(address => mapping(address => address)) public pairs;
    address[] public allPairs;

    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function createPair(address tokenA, address tokenB) public  returns (address pair) {
        require(tokenA != tokenB, "Identical Addresses");
        (address token0, address token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), "zero_address");
        require(pairs[token0][token1] == address(0), "pair already exists");

        bytes memory bytecode = type(UniswapV2Pair).creationCode;
        bytes32 salt = keccak256(abi.encodePacked(token0, token1)); 
        assembly {
            pair := create2(
                0, // wei sent with the current call
                add(bytecode,32), // actual code starts after skipping the first 32 bytes
                mload(bytecode),  // load the size of code contained in the first 32 bytes
                salt // salt from function arguments
                )
        }

        IUniswapV2Pair(pair).initialize(token0, token1);
        pairs[token0][token1] = pair;
        pairs[token1][token0] = pair; // populate mapping in reverse direction

        allPairs.push(pair);

        emit PairCreated(token0, token1, pair, allPairs.length);
    }
}