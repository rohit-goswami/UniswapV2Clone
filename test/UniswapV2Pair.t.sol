// SPDX-License-Identifier: Unlicense

pragma solidity 0.8.17;

import "lib/forge-std/src/Test.sol";
import "../src/UniswapV2Factory.sol";
import "../src/UniswapV2Pair.sol";
import "./mocks/ERC20Mintable.sol";


contract UniswapV2PairTest is Test {
    ERC20Mintable token0;
    ERC20Mintable token1;

    UniswapV2Pair pair;
   // TestUser testUser;

    function setUp() public {
      //  testUser = new TestUser();

        token0 = new ERC20Mintable("Token A", "TOK-A");
        token1 = new ERC20Mintable("Token B", "TOK-B");

        UniswapV2Factory factory = new UniswapV2Factory();
        address pairAddress = factory.createPair(address(token0), address(token1));

       pair = UniswapV2Pair(pairAddress);

        token0.mint(10 ether, address(this));
        token1.mint(10 ether, address(this));

     //   token0.mint(10 ether, address(testUser));
     //   token1.mint(10 ether, address(testUser));
    }

    function assertReserves(uint112 expectedReserve0, uint112 expectedReserve1) internal {
        (uint112 reserve0, uint112 reserve1, ) = pair.getReserves();
        assertEq(reserve0, expectedReserve0, "unexpected reserve0");
        assertEq(reserve1, expectedReserve1, "unexpected reserve1");
    }

    // test for providing initial liquidity 
    function testMintBootstrap() public {
        token0.transfer(address(pair), 1 ether);
        token1.transfer(address(pair), 1 ether);

        pair.mint(address(this));

        assertEq(pair.balanceOf(address(this)), 1 ether - 1000);
        assertReserves(1 ether, 1 ether);
        assertEq(pair.totalSupply(), 1 ether);

    }

    function testMintWhenTheresLiquidity() public {
        token0.transfer(address(pair), 1 ether);
        token1.transfer(address(pair), 1 ether);

        pair.mint(address(this));

        // vm.warp(37);

        token0.transfer(address(pair), 2 ether);
        token1.transfer(address(pair), 2 ether);

        pair.mint(address(this));

        assertEq(pair.balanceOf(address(this)), 3 ether - 1000);
        assertEq(pair.totalSupply(), 3 ether);
        assertReserves(3 ether, 3 ether);
    }

    function testMintUnbalanced() public {
        token0.transfer(address(pair), 1 ether);
        token1.transfer(address(pair), 1 ether);

        pair.mint(address(this));

        assertEq(pair.balanceOf(address(this)), 1 ether - 1000);
        assertReserves(1 ether, 1 ether);

        token0.transfer(address(pair), 2 ether);
        token1.transfer(address(pair), 1 ether);

        pair.mint(address(this));
        assertEq(pair.balanceOf(address(this)), 2 ether - 1000);
        assertReserves(2 ether, 3 ether);
    }



// test for removing liquidity
// removing liquidity means burning of LP-tokens in exchange for propotional amount of underlying liquidity
// Amount of token returned to liquidity provided is calculated like Amount = Reserve_token * (BalanceOfLP / TotalSupplyOfLP) 

function testBurn() public {
    token0.transfer(address(pair), 1 ether);
    token1.transfer(address(pair), 1 ether);

    pair.mint(address(this));

    uint256 liquidity = pair.balanceOf(address(this));
    pair.transfer(address(this), liquidity);

    pair.burn(address(this));

    assertEq(pair.balanceOf(address(this)), 0);
    assertReserves(1000, 1000);
    assertEq(pair.totalSupply(), 1000);
    assertEq(token0.balanceOf(address(this)), 10 ether - 1000);
    assertEq(token1.balanceOf(address(this)), 10 ether - 1000); 

}

// will continue in next session !! 
/*
contract TestUser {
    function provideLiquidity(
        address pairAddress_,
        address token0Address_,
        address token1Address_, 
        uint256 amount0_,
        uint256 amount1_
    ) public {
        ERC20(token0Address_).transfer(pairAddress_, amount0_);
        ERC20(token1Address_).transfer(pairAddress_, amount1_);

        UniswapV2Pair(pairAddress_).mint();
    }

    function withdrawLiquidity(address pairAddress_) public {
       // UniswapV2Pair(pairAddress_).burn();
    }
} */

}
