pragma solidity 0.8.17;

import "lib/forge-std/src/Test.sol";
import "../src/UniswapV2Factory.sol";
import "../src/UniswapV2Pair.sol";
import "./mocks/ERC20Mintable.sol";


contract UniswapV2FactoryTest is Test {
    UniswapV2Factory factory;

    ERC20Mintable token0;
    ERC20Mintable token1;
    ERC20Mintable token2;
    ERC20Mintable token3;

    function setUp() public {
        factory = new UniswapV2Factory();

        token0 = new ERC20Mintable("Token A", "TKNA");
        token1 = new ERC20Mintable("Token B", "TKNB");
        token2 = new ERC20Mintable("Token C", "TKNC");
        token3 = new ERC20Mintable("Token D", "TKND");

    }

    function encodeError(string memory error) internal pure returns (bytes memory encoded) {
        encoded = abi.encodeWithSignature(error);
    }

    function testCreatePair() public {
        address pairAddress = factory.createPair(
            address(token1),
            address(token0)
        );

        UniswapV2Pair pair = UniswapV2Pair(pairAddress);
        assertEq(pair.token0(), address(token0));
        assertEq(pair.token1(), address(token1));
    }


    function testCreatePairZeroAddress() public {
        vm.expectRevert(encodeError("ZeroAddress()"));
        factory.createPair(address(0), address(token0));
       
        vm.expectRevert(encodeError("ZeroAddress()"));
        factory.createPair(address(token1), address(0));
        
        
    }

//     function testCreatePairPairExists() public {
//         factory.createPair(address(token1), address(token0));

     
//         factory.createPair(address(token1), address(token0));
//            vm.expectRevert(encodeError("PairExists()"));
//     }

//     function testCreatePairIdenticalTokens() public {
        
//         factory.createPair(address(token0), address(token0));
//         vm.expectRevert(encodeError("IdenticalAddresses()"));
//     }
}