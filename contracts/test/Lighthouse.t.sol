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
        superRewardToken.initialize("Super Mega Token", "SMT", 10000e18);

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

    function testMakeAdmin() public {
        lighthouse.makeAdmin(alice);

        assertTrue(lighthouse.isAdmin(alice));
    }

    function testFailMakeAdmin() public {
        hoax(alice);
        lighthouse.makeAdmin(bob);
    }

    function testAddPoints() public {
        lighthouse.addPointsTo(alice, 100);
        assertEq(IToken(tokenAddress).balanceOf(alice), 100);
    }

    function testFactoryAddPoints() public {
        address factoryAddr = lighthouse.factoryAddress();
        hoax(factoryAddr);
        lighthouse.addPointsTo(alice, 100);
        assertEq(IToken(tokenAddress).balanceOf(alice), 100);
    }

    function testFailAddPoints() public {
        hoax(alice);
        lighthouse.addPointsTo(bob, 100);
    }

    function testPointMint() public {
        uint256 initialSupply = IToken(tokenAddress).totalSupply();

        lighthouse.addPointsTo(alice, 100);

        uint256 finalSupply = IToken(tokenAddress).totalSupply();

        assertEq(finalSupply, initialSupply + 100);
    }

    function testPointTransferToWhitelist() public {
        lighthouse.addToTokenWhitelist(alice);

        lighthouse.addPointsTo(bob, 100);

        hoax(bob);
        IToken(tokenAddress).transfer(alice, 100);

        assertEq(IToken(tokenAddress).balanceOf(alice), 100);
    }

    function testFailPointTransferNotWhitelist() public {
        lighthouse.addPointsTo(bob, 100);

        hoax(bob);
        IToken(tokenAddress).transfer(alice, 100);
    }

    function testSlashing() public {
        lighthouse.addPointsTo(bob, 100);

        assertEq(IToken(tokenAddress).balanceOf(bob), 100);
        assertEq(IToken(tokenAddress).totalSupply(), 100);

        lighthouse.slashPoints(bob, 50);

        assertEq(IToken(tokenAddress).balanceOf(bob), 50);
        assertEq(IToken(tokenAddress).totalSupply(), 50);
    }
}
