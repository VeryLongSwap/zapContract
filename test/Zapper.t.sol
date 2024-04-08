// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Zapper, typer} from "../src/Zapper.sol";
import {IERC20} from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

contract ZapperTest is Test {
	Zapper public zapper;
	address public router = 0x506a777a65730D483f07089d1ecdFE947a8c3fEa;
	address public manager = 0x6Ceec9fA9269F0807797A9f05522fe70DB8d4f90;
	address public USDC = 0xA8CE8aee21bC2A48a5EF670afCc9274C7bbbC035;
	address public user = 0xA39144B3764BaF901bf1BF5a186504f2B48FAB96;
	address public WETH9 = 0xE9CC37904875B459Fa5D0FE37680d36F1ED55e38;
	address public USDT = 0x1E4a5963aBFD975d8c9021ce480b42188849D41d;


	function setUp() public {
		zapper = new Zapper(router, manager, WETH9);
		vm.startPrank(address(this));
		zapper.approver(USDC, router, 10000000000000000000000000);
		zapper.approver(WETH9, router, 10000000000000000000000000);
		zapper.approver(USDC, manager, 10000000000000000000000000);
		zapper.approver(WETH9, manager, 1000000000000000000000000);
		zapper.approver(USDT, router, 10000000000000000000000000);
		zapper.approver(USDT, manager, 10000000000000000000000000);
		vm.stopPrank();
		IERC20 usdc = IERC20(USDC);
		IERC20 weth9 = IERC20(WETH9);
		IERC20 usdt = IERC20(USDT);
		
		vm.startPrank(user);
		usdc.approve(address(zapper), 1000000000000000000000);
		weth9.approve(address(zapper), 10000000000000000000000000);
		usdt.approve(address(zapper), 10000000000000000000000000);
		vm.stopPrank();
		console.log("zapper:", address(zapper));

	}
	
	function testZapFromEth() public payable {
		uint beforeValue = IERC20(manager).balanceOf(user);
		bytes[] memory data = new bytes[](1);
		data[0] = hex"04e45aaf000000000000000000000000e9cc37904875b459fa5d0fe37680d36f1ed55e38000000000000000000000000a8ce8aee21bc2a48a5ef670afcc9274c7bbbc03500000000000000000000000000000000000000000000000000000000000009c40000000000000000000000005615deb798bb3e4dfa0139dfa1b3d433cc23b72f0000000000000000000000000000000000000000000000000011c37937e080000000000000000000000000000000000000000000000000000000000000ac46170000000000000000000000000000000000000000000000000000000000000000";
		vm.prank(user);
		zapper.zap{value: 0.01 ether}(WETH9, USDC, WETH9, 10000000000000000, 5000000000000000, 2500, 194300, 196400, user, 8712316318, data);
		uint afterValue = IERC20(manager).balanceOf(user);
		assertEq(beforeValue + 1, afterValue);
		assertEq(address(zapper).balance, 0);
		assertEq(IERC20(USDC).balanceOf(address(zapper)), 0);
		assertEq(IERC20(WETH9).balanceOf(address(zapper)), 0);
	}

	function testZapToEth() public payable {
		uint beforeValue = IERC20(manager).balanceOf(user);
		bytes[] memory data = new bytes[](2);
		data[0] = hex"04e45aaf000000000000000000000000a8ce8aee21bc2a48a5ef670afcc9274c7bbbc035000000000000000000000000e9cc37904875b459fa5d0fe37680d36f1ed55e3800000000000000000000000000000000000000000000000000000000000001f4000000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000009896800000000000000000000000000000000000000000000000000007840b6663cb810000000000000000000000000000000000000000000000000000000000000000";
		data[1] = hex"49404b7c0000000000000000000000000000000000000000000000000007840b6663cb810000000000000000000000005615deb798bb3e4dfa0139dfa1b3d433cc23b72f";
		vm.prank(user);
		zapper.zap(USDC, USDC, WETH9, 20000000, 10000000, 2500, 194300, 196400, user, 8712316318, data);
		uint afterValue = IERC20(manager).balanceOf(user);
		assertEq(beforeValue + 1, afterValue);
		assertEq(address(zapper).balance, 0);
		assertEq(IERC20(USDC).balanceOf(address(zapper)), 0);
		assertEq(IERC20(WETH9).balanceOf(address(zapper)), 0);
	}

	function testZapWithAnyToken() public payable {
		uint beforeValue = IERC20(manager).balanceOf(user);
		bytes[] memory data = new bytes[](1);
		data[0] = hex"b858183f000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000800000000000000000000000005615deb798bb3e4dfa0139dfa1b3d433cc23b72f00000000000000000000000000000000000000000000000000000000004c4b4000000000000000000000000000000000000000000000000000000000003503040000000000000000000000000000000000000000000000000000000000000042a8ce8aee21bc2a48a5ef670afcc9274c7bbbc0350001f4e9cc37904875b459fa5d0fe37680d36f1ed55e380009c41e4a5963abfd975d8c9021ce480b42188849d41d000000000000000000000000000000000000000000000000000000000000";
		vm.prank(user);
		zapper.zap(USDC, USDT, USDC, 10000000, 5000000, 500, -510, 530, user, 8712316318, data);
		uint afterValue = IERC20(manager).balanceOf(user);
		assertEq(beforeValue + 1, afterValue);
		assertEq(address(zapper).balance, 0);
		assertEq(IERC20(USDC).balanceOf(address(zapper)), 0);
		assertEq(IERC20(USDT).balanceOf(address(zapper)), 0);
	}
	function testZapToEth2() public payable {
		uint beforeValue = IERC20(manager).balanceOf(user);
		bytes[] memory data = new bytes[](1);
		data[0] = hex"5ae401dc0000000000000000000000000000000000000000000000000000000066128950000000000000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000040000000000000000000000000000000000000000000000000000000000000016000000000000000000000000000000000000000000000000000000000000000e404e45aaf000000000000000000000000a8ce8aee21bc2a48a5ef670afcc9274c7bbbc035000000000000000000000000e9cc37904875b459fa5d0fe37680d36f1ed55e3800000000000000000000000000000000000000000000000000000000000001f4000000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000004c4b4000000000000000000000000000000000000000000000000000046424708329db000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004449404b7c00000000000000000000000000000000000000000000000000046424708329db0000000000000000000000005615deb798bb3e4dfa0139dfa1b3d433cc23b72f00000000000000000000000000000000000000000000000000000000";
		vm.prank(user);
		zapper.zap(USDC, USDC, WETH9, 10000000, 5000000, 500, 194590, 195620, user, 1712490838, data);
		uint afterValue = IERC20(manager).balanceOf(user);
		assertEq(beforeValue + 1, afterValue);
		assertEq(address(zapper).balance, 0);
		assertEq(IERC20(USDC).balanceOf(address(zapper)), 0);
		assertEq(IERC20(USDT).balanceOf(address(zapper)), 0);
	}
}
