// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {Counter} from "../src/Counter.sol";

contract Deploy is Script {
    address internal deployer;
    Counter internal counter;
    address public router = 0x506a777a65730D483f07089d1ecdFE947a8c3fEa;
    address public manager = 0x6Ceec9fA9269F0807797A9f05522fe70DB8d4f90;
    address public WETH9 = 0xE9CC37904875B459Fa5D0FE37680d36F1ED55e38;
    function setUp() public {
        (deployer, ) = deriveRememberKey(vm.envString("MNEMONIC"), 0);
    }

    function run() public {
        vm.startBroadcast(deployer);
        counter = new Counter(router, manager, WETH9);
        vm.stopBroadcast();
    }
}
