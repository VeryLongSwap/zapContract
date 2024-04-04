// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Counter, typer} from "../src/Counter.sol";


contract CounterTest is Test {

    Counter public counter;
    address public router = 0x506a777a65730D483f07089d1ecdFE947a8c3fEa;
    address public manager = 0x6Ceec9fA9269F0807797A9f05522fe70DB8d4f90;
    address public token = 0xA8CE8aee21bC2A48a5EF670afCc9274C7bbbC035;
    address public user = 0xA39144B3764BaF901bf1BF5a186504f2B48FAB96;
    bytes[] public dataForTestmultiSwapByEther;
    bytes[] public dataForTestmultiSwapByAnyToken;
    
    function setUp() public {
        counter = new Counter(router, manager);
        console.log("what is this", address(this));
        counter.setNumber(19);
        // exactInputSingle
        dataForTestmultiSwapByEther.push(hex"04e45aaf000000000000000000000000e9cc37904875b459fa5d0fe37680d36f1ed55e38000000000000000000000000a8ce8aee21bc2a48a5ef670afcc9274c7bbbc03500000000000000000000000000000000000000000000000000000000000001f4000000000000000000000000a39144b3764baf901bf1bf5a186504f2b48fab96000000000000000000000000000000000000000000000000002386f26fc1000000000000000000000000000000000000000000000000000000000000015a6ccd0000000000000000000000000000000000000000000000000000000000000000");
        // exactInputSingle
        dataForTestmultiSwapByAnyToken.push(hex"04e45aaf000000000000000000000000a8ce8aee21bc2a48a5ef670afcc9274c7bbbc035000000000000000000000000e9cc37904875b459fa5d0fe37680d36f1ed55e3800000000000000000000000000000000000000000000000000000000000009c40000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000098968000000000000000000000000000000000000000000000000000076f0a2ea24b380000000000000000000000000000000000000000000000000000000000000000");
        // unwrapWETH9
        dataForTestmultiSwapByAnyToken.push(hex"49404b7c00000000000000000000000000000000000000000000000000076f0a2ea24b38000000000000000000000000a39144b3764baf901bf1bf5a186504f2b48fab96");

    }
    function testSymbol() view public {
        assertEq(counter.getSymbol(0xA8CE8aee21bC2A48a5EF670afCc9274C7bbbC035), "USDC");
    }
    /*
    function testBalance() view public {
        assertEq(counter.getBalance(0xA8CE8aee21bC2A48a5EF670afCc9274C7bbbC035, address(this)), 100);
    }
    */
    function testmultiSwapByEther() payable public {
        uint _beforeValue = counter.getBalance(token, user);


        counter.multi{value: 0.01 ether}(9713124377, dataForTestmultiSwapByEther);

        uint _afterValue = counter.getBalance(token, user);
        assertGt(_afterValue, _beforeValue);
    }
    function testmultiSwapByAnyToken() public {
        uint _beforeValue = counter.getBalance(token, user);
        uint _beforeValueEth = address(user).balance;
        counter.multi(9713124377, dataForTestmultiSwapByAnyToken);

        uint _afterValue = counter.getBalance(token, user);
        uint _afterValueEth = address(user).balance;

        assertGt(_beforeValue, _afterValue);
        assertGt(_beforeValueEth, _afterValueEth);
    }
    /*
    function testNormalMint() public payable {
        counter.minter(typer.MintParams(
            0xA8CE8aee21bC2A48a5EF670afCc9274C7bbbC035,
            0xE9CC37904875B459Fa5D0FE37680d36F1ED55e38,
            2500,
            189100,
            199950,
            37526058,
            14827661716589198,
            6648675,
            522865188413126,
            0xA39144B3764BaF901bf1BF5a186504f2B48FAB96,
            1912215659
            ));
    }
    */
    function test_Increment() public {
        counter.increment();
        assertEq(counter.number(), 20);
    }

    function testFuzz_SetNumber(uint256 x) public {
        counter.setNumber(x);
        assertEq(counter.number(), x);
    }
}
