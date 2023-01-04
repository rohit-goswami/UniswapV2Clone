pragma solidity 0.8.17;


interface IERC20 {
    function balanceof(address) external returns (uint256);

    function transfer(address to, uint256 amount) external;
}

