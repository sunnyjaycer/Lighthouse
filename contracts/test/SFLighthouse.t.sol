// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// import "forge-std/Test.sol";
import "../src/LighthouseFactory.sol";
import "../src/Lighthouse.sol";
import "../src/interfaces/IToken.sol";

import {
    ISuperfluid,
    ISuperToken
} from "@superfluid-finance/ethereum-contracts/contracts/apps/SuperAppBase.sol";

import {
    SuperfluidTester,
    Superfluid,
    ConstantFlowAgreementV1,
    CFAv1Library,
    SuperTokenFactory
} from "./SuperfluidTester.sol";

import {MySuperToken} from "../src/MySuperToken.sol";
import {IMySuperToken} from "../src/IMySuperToken.sol";


contract LighthouseTest is SuperfluidTester {
    Lighthouse lighthouse;
    address constant alice = address(0xbabe);
    address constant bob = address(0xb0b);
    address constant gasTank = address(0xbaadf00d);

    address tokenAddress;
    IMySuperToken superRewardToken;

    constructor() SuperfluidTester(alice) {} // assumes alice to be an "admin" of some sorts

    function setUp() public {

        // Become admin
        vm.startPrank(alice);

        // Deploy MySuperToken
        superRewardToken = IMySuperToken(address(new MySuperToken()));

        // Upgrade MySuperToken with the SuperTokenFactory
        sf.superTokenFactory.initializeCustomSuperToken(address(superRewardToken));

        // initialize MySuperToken
        superRewardToken.initialize("Super Reward Token", "SMT", 0);

        vm.stopPrank();

        lighthouse = new Lighthouse(
            address(this),
            "Uniswap",
            "Uniswap points",
            "UNI",
            18,
            sf.host,
            ISuperToken(superRewardToken)
        );
        tokenAddress = lighthouse.tokenAddress();
    }

    // @frens this shows the basic Superfluid IDA capability to distribute the superRewardToken
    //        proportionately on the basis of points possessed by each account
    function testBasicDistribution() public {
        lighthouse.makeAdmin(alice);
        assertTrue(lighthouse.isAdmin(alice));

        // Alice and Bob subscribe to the Lighthouse's IDA Index. Basically allows the distributed tokens to reach their wallets
        hoax(alice);
        sf.host.callAgreement(
            sf.ida,
            abi.encodeCall(
                sf.ida.approveSubscription,
                (
                    superRewardToken,
                    address(lighthouse),
                    0,
                    new bytes(0) // ctx placeholder
                )
            ),
            new bytes(0)
        );

        hoax(bob);
        sf.host.callAgreement(
            sf.ida,
            abi.encodeCall(
                sf.ida.approveSubscription,
                (
                    superRewardToken,
                    address(lighthouse),
                    0,
                    new bytes(0) // ctx placeholder
                )
            ),
            new bytes(0)
        );

        // Alice now has 100 points 
        lighthouse.addPointsTo(alice, 25);
        assertEq(IToken(tokenAddress).balanceOf(alice), 25);
        // and 100 distribution units!!
        (,,uint256 currentUnitsHeldAlice,) = sf.ida.getSubscription(
            superRewardToken,   
            address(lighthouse),   
            0,        
            alice       
        );
        assertEq(currentUnitsHeldAlice,25);

        // Bob now has 100 points
        lighthouse.addPointsTo(bob, 75);
        assertEq(IToken(tokenAddress).balanceOf(bob), 75);
        // and 100 distribution units!!
        (,,uint256 currentUnitsHeldBob,) = sf.ida.getSubscription(
            superRewardToken,   
            address(lighthouse),   
            0,        
            bob       
        );
        assertEq(currentUnitsHeldBob,75);

        // Putting 10,000 Super Reward Tokens into the Lighthouse
        hoax(alice);
        superRewardToken.mint(alice, 10000);
        hoax(alice);
        superRewardToken.transfer(address(lighthouse), 10000);

        // // Distributing them out
        lighthouse.distribute();

        // Alice gained 1/4 of the 10000
        assertEq(
            superRewardToken.balanceOf(alice),
            2500
        );

        // // Bob gained 3/4 of the 10000
        assertEq(
            superRewardToken.balanceOf(bob),
            7500
        );

    }

}
