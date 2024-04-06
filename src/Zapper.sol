// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { IERC20 } from "openzeppelin-contracts/contracts/interfaces/IERC20.sol";
import "openzeppelin-contracts/contracts/access/Ownable.sol";

interface VLSRouter {
	function multicall(
		uint256 deadline,
		bytes[] calldata data
	) external payable returns (bytes[] memory results);
	function deployer() external view returns (address);

	function exactInputSingle(
		typer.ExactInputSingleParams calldata params
	) external payable returns (uint256 amountOut);
}

interface PositionManager {
	function mint(
		typer.MintParams calldata params
	) external payable returns (bytes memory result);
function multicall(bytes[] calldata data) external payable returns (bytes[] memory results);
	function refundETH() external payable;
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
contract Zapper is Ownable {
	VLSRouter public vlsRouter;
	PositionManager public positionManager;
	address public WETH9;
	constructor (
		address _routerAddress,
		address _managerAddress,
		address _WETH9Address
	) Ownable(msg.sender) {
		vlsRouter = VLSRouter(_routerAddress);
		positionManager = PositionManager(_managerAddress);
		WETH9 = _WETH9Address;
	}

	function mint(
		address[] memory token,
		uint[] memory amount,
		uint24 fee,
		int24 tickLower,
		int24 tickUpper,
		address recipient,
		uint256 deadline
	) public payable {
		require(token.length == 2 && amount.length == 2, "length mismatched");

		bytes[] memory params;
		if (token[0] == WETH9 || token[1] == WETH9) {
			params = new bytes[](2);
			// refundETH
			params[1] = hex"12210e8a";
		}else {
			params = new bytes[](1);
		}
		

		// 88316456 = mint
		params[0] = abi.encodeWithSelector(hex"88316456", token[0],
			token[1],
			fee,
			tickLower,
			tickUpper,
			amount[0],
			amount[1],
			0,
			0,
			recipient,
			deadline
		);

		positionManager.multicall{value: msg.value}(params);

		
	}

	function multiSwap(
		uint256 _deadline,
		bytes[] calldata _data
	) external payable {

		vlsRouter.multicall{value: msg.value}(_deadline, _data);
	}

	function withdrawToken(address[] memory _address) public {
		for(uint i = 0; i < _address.length; i++){
			if (_address[i] != WETH9) {
				IERC20 token = IERC20(_address[i]);
				
				uint balance = token.balanceOf(address(this));
				if (balance > 0) token.transfer(msg.sender, balance);
				balance = token.balanceOf(address(this));
			}
		}
	}

	function withdrawEth() public payable {
		 if (address(this).balance > 0) {
				(bool success, ) = msg.sender.call{value: address(this).balance}("");
				require(success, "Failed to send Ether");
		 }
	}

	function approver(address _tokenAddress, address _to, uint value) public onlyOwner {
		IERC20(_tokenAddress).approve(address(_to), value);
	}

	function Zap(
		address fromToken,
		address token0,
		address token1,
		uint256 fullAmount,
		uint256 swapAmount,
		uint24 fee,
		int24 tickLower,
		int24 tickUpper,
		address recipient,
		uint256 deadline,
		bytes[] calldata swapParams
	) public payable {
	
	
		if (fromToken != WETH9) {
			IERC20(fromToken).transferFrom(msg.sender, address(this),	fullAmount);
		}

		if (fromToken == WETH9){
			this.multiSwap{value: swapAmount}(deadline, swapParams);
		} else {
			this.multiSwap(deadline, swapParams);
		}

		address[] memory lpPair = new address[](2);
		uint256[] memory pairAmount = new uint256[](2);
		lpPair[0] = token0;
		lpPair[1] = token1;

		for(uint i = 0; i < 2; i++) {
			if (lpPair[i] == WETH9) {
				pairAmount[i] = address(this).balance;
			} else {
				pairAmount[i] = IERC20(lpPair[i]).balanceOf(address(this));
			}
		}

		if(token0 == WETH9 || token1 == WETH9){
			this.mint{value: address(this).balance}(lpPair, pairAmount, fee, tickLower, tickUpper, recipient, deadline);
			withdrawEth();
		} else {
			this.mint(lpPair, pairAmount, fee, tickLower, tickUpper, recipient, deadline);
		}

		withdrawToken(lpPair);

		
	}

	fallback() external {
		emit fall("fall");
  }

	receive() external payable {
		emit rcv();
	}

	event fall(string memo);
	event rcv();
}
