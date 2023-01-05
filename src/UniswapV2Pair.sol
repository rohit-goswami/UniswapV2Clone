pragma solidity 0.8.17;

import "solmate/tokens/ERC20.sol";
import "./libraries/Math.sol";


interface IERC20 {
    function balanceof(address) external returns (uint256);

    function transfer(address to, uint256 amount) external;
}

error InsufficientLiquidityMinted();
error InsufficientLiquidityBurned();
error TransferFailed();

contract UniswapV2Pair is ERC20, Math {
    uint256 public constant MINIMUM_LIQUIDITY = 1000;

    address public token0;
    address public token1;

    // variables to track reserves in pools
    uint112 private reserve0;
    uint112 private reserve1;

    event Burn(address indexed sender, uint256 amount0, uint256 amount1);
    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Sync(uint112 reserve0, uint112 reserve1);

    constructor(address token0_, address token1_) ERC20("UniswapV2 Pair", "UNIV2", 18) {
        token0 = token0_;
        token1 = token1_;
    }

    // low-level function for depositing new liquidity
    function mint() public {
        (uint256 _reserve0, uint256 _reserve1, ) = getReserves();
        uint256 balance0 = IERC20(token0).balanceOf(address(this));
        uint256 balance1 = IERC20(token1).balanceOf(address(this));
        uint256 amount0 = balance0 - reserve0;
        uint256 amount1 = balance1 - reserve1;

        uint256 liquidity;

        if (totalSupply == 0 ) {
            liquidity = Math.sqrt(amount0 * amount1) - MINIMUM_LIQUIDITY; // subtracting MINIMUM_LIQUIDITY protects from making one token price too expensive
            _mint(address(0), MINIMUM_LIQUIDITY); //permanently lock the first MINIMUM_LIQUIDITY tokens
        } else {
            liquidity = Math.min(
                (amount0 * totalSupply ) / _reserve0,
                (amount1 * totalSupply ) / _reserve1
            ); // you can choose either of the token but choosing minimum of two will protect from price manipultion.
        }

        if(liquidity <= 0) revert InsufficientLiquidityMinted();
        _mint(msg.sender. liquidity);
        _update(balance0, balance1);
        emit Mint(msg.sender, amount0, amount1);
    }

    function getReserves() public view returns ( uint256, uint256, uint32) {
        return (reserve0, reserve1, 0);
    }

}
