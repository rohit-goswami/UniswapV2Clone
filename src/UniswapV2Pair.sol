pragma solidity 0.8.17;

import "solmate/tokens/ERC20.sol";
import "./libraries/Math.sol";
import "./libraries/UQ112x112.sol";
import "src/Interfaces/IUniswapV2Pair.sol";


interface IERC20 {
    function balanceOf(address) external returns (uint256);

    function transfer(address to, uint256 amount) external;
}

error InsufficientLiquidityMinted();
error InsufficientLiquidityBurned();
error TransferFailed();
error AlreadyInitialized();
error BalanceOverflow();

contract UniswapV2Pair is IUniswapV2Pair, ERC20, Math {
    using UQ112x112 for uint224;
    uint256 public constant MINIMUM_LIQUIDITY = 1000;

    address public token0;
    address public token1;

    // variables to track reserves in pools
    uint112 private reserve0;
    uint112 private reserve1;
    uint32 private blockTimestampLast;
    uint256 public price0CumulativeLast;
    uint256 public price1CumulativeLast;

    event Burn(address indexed sender, uint256 amount0, uint256 amount1, address to);
    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Sync(uint112 reserve0, uint112 reserve1);

    constructor() ERC20("UniswapV2 Pair", "UNIV2", 18) {}

    //called once byt the factory at the time of deployment

    function initialize(address token0_, address token1_) public {
        if(token0 != address(0) || token1 != address(0)) revert AlreadyInitialized();

        token0 = token0_;
        token1 = token1_;
    } 

    // low-level function for depositing new liquidity
    function mint(address to) public returns (uint liquidity) {
        (uint112 reserve0_, uint112 reserve1_, ) = getReserves();
        uint256 balance0 = IERC20(token0).balanceOf(address(this));
        uint256 balance1 = IERC20(token1).balanceOf(address(this));
        uint256 amount0 = balance0 - reserve0;
        uint256 amount1 = balance1 - reserve1;


        if (totalSupply == 0 ) {
            liquidity = Math.sqrt(amount0 * amount1) - MINIMUM_LIQUIDITY; // subtracting MINIMUM_LIQUIDITY protects from making one token price too expensive
            _mint(address(0), MINIMUM_LIQUIDITY); //permanently lock the first MINIMUM_LIQUIDITY tokens
        } else {
            liquidity = Math.min(
                (amount0 * totalSupply ) / reserve0_,
                (amount1 * totalSupply ) / reserve1_
            ); // you can choose either of the token but choosing minimum of two will protect from price manipultion.
        }

        if(liquidity <= 0) revert InsufficientLiquidityMinted();
        _mint(to, liquidity);
        _update(balance0, balance1, reserve0_, reserve1_);
        emit Mint(msg.sender, amount0, amount1);
    }


    function burn(address to) public returns (uint amount0, uint amount1) {
        uint256 balance0 = IERC20(token0).balanceOf(address(this));
        uint256 balance1 = IERC20(token1).balanceOf(address(this));
        uint256 liquidity = balanceOf[address(this)];

        amount0 = (liquidity * balance0 ) / totalSupply;
        amount1 = (liquidity * balance1 ) / totalSupply;

        if(amount0 == 0 || amount1 == 0) revert InsufficientLiquidityBurned();

        _burn(address(this), liquidity);

        _safeTransfer(token0, to, amount0);
        _safeTransfer(token1, to, amount1);

        balance0 = IERC20(token0).balanceOf(address(this));
        balance1 = IERC20(token1).balanceOf(address(this));

        (uint112 reserve0_, uint112 reserve1_, ) = getReserves();

        _update(balance0, balance1, reserve0_, reserve1_);
        emit Burn(msg.sender, amount0, amount1, to);

            }
    function getReserves() public view returns ( uint112, uint112, uint32) {
        return (reserve0, reserve1, blockTimestampLast);
    }
    // update reserves and, on the first call per block, price accumulators
    function _update(uint256 balance0, uint256 balance1, uint112 reserve0_, uint112 reserve1_) private {
        if(balance0 > type(uint112).max || balance1 > type(uint112).max ) revert BalanceOverflow();

        unchecked {
            uint32 timeElapsed = uint32(block.timestamp) - blockTimestampLast; 

            if(timeElapsed > 0 && reserve0_ > 0 && reserve1_ > 0) {
                price0CumulativeLast += uint(UQ112x112.encode(reserve1_).uqdiv(reserve0_)) *timeElapsed;
                price1CumulativeLast += uint(UQ112x112.encode(reserve0_).uqdiv(reserve1_)) * timeElapsed;
            }

        }

        reserve0 = uint112(balance0); 
        reserve1 = uint112(balance1);
        blockTimestampLast = uint32(block.timestamp);
        emit Sync(reserve0, reserve1);
    }
    
    function _safeTransfer(address token, address to, uint256 value) private {
       (bool success, bytes memory data ) =  token.call(
            abi.encodeWithSignature("transfer(address, uint256)", to, value)
        );

        if(!success || (data.length !=0 && !abi.decode(data, (bool)))) revert TransferFailed();
    }
}
