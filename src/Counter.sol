// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

interface VLSRouter {
    function multicall(uint256 deadline, bytes[] calldata data) external payable returns (bytes[] memory results);
    function deployer() external view returns(address);

    /// @notice Swaps `amountIn` of one token for as much as possible of another token
    /// @dev Setting `amountIn` to 0 will cause the contract to look up its own balance,
    /// and swap the entire amount, enabling contracts to send tokens before calling this function.
    /// @param params The parameters necessary for the swap, encoded as `ExactInputSingleParams` in calldata
    /// @return amountOut The amount of the received token
    function exactInputSingle(typer.ExactInputSingleParams calldata params) external payable returns (uint256 amountOut);

}
interface Token{
    function balanceOf(address _address) external view returns(uint);
    function symbol() external view returns(string memory);
    
}
interface PositionManager{
    function mint(typer.MintParams calldata params) external payable returns (bytes memory result);
    function multicall(bytes[] calldata data) external payable returns (bytes[] memory results);
}
library typer {
    struct ExactInputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 amountIn;
        uint256 amountOutMinimum;
        uint160 sqrtPriceLimitX96;
    }
    struct MintParams {
        address token0;
        address token1;
        uint24 fee;
        int24 tickLower;
        int24 tickUpper;
        uint256 amount0Desired;
        uint256 amount1Desired;
        uint256 amount0Min;
        uint256 amount1Min;
        address recipient;
        uint256 deadline;
    }
}
contract Counter {
    uint256 public number;
    VLSRouter public vlsRouter;
    PositionManager public positionManager;
    constructor(
        address _routerAddress,
        address _managerAddress
    ) {
        vlsRouter = VLSRouter(_routerAddress);
        positionManager = PositionManager(_managerAddress);
    }
    function retBal() view public returns(address) {
        
        return vlsRouter.deployer();
    }
    function getSymbol(address _tokenAddress) view public returns(string memory){
        return Token(_tokenAddress).symbol();
    }
    function getBalance(address _tokenAddress, address _userAddress) view public returns(uint){
        return Token(_tokenAddress).balanceOf(_userAddress);
    }
    function rere(bytes[] calldata naa) pure public returns(bytes[] calldata){
        return naa;
    }
    function multiMinter(bytes[] calldata data) payable public returns (bytes[] memory results){
        return positionManager.multicall(data);
    }
    function minter(typer.MintParams calldata data) payable public returns (bytes memory results){
        return positionManager.mint(data);
    }
    function multi(uint256 _deadline, bytes[] calldata _data) public payable returns (bytes[] memory){
        return vlsRouter.multicall{value: msg.value}(_deadline, _data);
    }
    function exa(typer.ExactInputSingleParams calldata params) public payable returns (uint256) {
        return vlsRouter.exactInputSingle{value: msg.value}(params);
    }

    function setNumber(uint256 newNumber) public {
        number = newNumber;
    }

    function increment() public {
        number++;
    }
}
