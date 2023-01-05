pragma solidity 0.8.17;

import "forge-std/Test.sol";
import "../src/UniswapV2Pair.sol";
import "./mocks/ERC20Mintable.sol";


contract UniswapV2PairTest is Test {
    ERC20Mintable token0;
    ERC20Mintable token1;

    UniswapV2Pair pair;
    TestUser testUser;

    function setup() public {
        testUser = new TestUser();

        token0 = new ERC20Mintable("Token A", "TOK-A");
        token1 = new ERC20Mintable("Token B", "TOK-B");
        pair = new UniswapV2Pair(address(token0), address(token1)); 

        token0.mint(10, ether, address(this));
        token1.mint(10, ether, address(this));

        token0.mint(10, ether, address(testUser));
        token1.mint(10, ether, address(testUser));
    }

    function assertReserves(uint112 expectedReserve0, uint112 expetedReserve1) internal {
        (uint112 reserve0, uint12 reserve1, ) = pair.getReserves();
        assertEq(reserve0, expectedReserve0, "unexpected reserve0");
        assertEq(reserve1, expectedReserve1, "unexpected reserve1");
    }

    function testMintBootstrap() public {
        token0.transfer(address(pair), 1 ether);
        token1.transfer(address(pair), 1 ether);

        pair.mint();

        assertEq(pair.balanceOf(address(this)), 1 ether - 1000);
        assertReserves(1 ether, 1 ether);
        assertEq(pair.totalSupply(), 1 ether);

    }

    function testMintQWhenTheresLiquidity() public {
        token0.transfer(address(pair), 1 ether);
        token1.transfer(address(pair), 1 ether);

        pair.mint();

        vm.warp(37);

        token0.transfer(address(pair), 2 ether);
        token1.transfer(address(pair), 2 ether);

        pair.mint();

        assertEq(pair.balanceOf(address(this)), 3 ether - 1000);
        assertEq(pair.totalSupply(), 3 ether);
        assertReserves(3 ether, 3 ether);
    }

    function testMintUnbalanced() public {
        token0.transfer(address(pair), 1 ether);
        token1.trasnfer(address(pair), 1 ether);

        pair.mint();
        assertEq(pair.balanceOf(address(this)), 1 ether - 1000);
        assertReserves(1 ether, 1 ether);

        token0.transfer(address(pair), 2 ether);
        token1.transfer(address(pair), 1 ether);

        pair.mint();
        assertEq(pair.balanceOf(address(this)), 2 ether - 1000);
        assertReserves(3 ether, 2 ether);
    }
}

contract TestUser {
    function provideLiquidity(
        address pairAddress_,
        address token0Address_,
        address token1Address_, 
        uint256 amount0_,
        uint256 amount1_,
    ) public {
        ERC20(token0Address_).transfer(pairAddress_, amount0_);
        ERC20(token1Address_).transfer(pairAddress_, amount1_);

        UniswapV2Pair(pairAddress_).mint();
    }

    function withdrawLiquidity(address pairAddress_) public {
        UniswapV2Pair(pairAddress_).burn();
    }
}


