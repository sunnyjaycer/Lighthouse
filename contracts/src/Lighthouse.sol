// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./Token.sol";

import {
    ISuperfluid,
    ISuperToken,
    SuperAppBase,
    SuperAppDefinitions
} from "@superfluid-finance/ethereum-contracts/contracts/apps/SuperAppBase.sol";
import {
    IInstantDistributionAgreementV1
} from "@superfluid-finance/ethereum-contracts/contracts/interfaces/agreements/IInstantDistributionAgreementV1.sol";

import {IDAv1Library} from "@superfluid-finance/ethereum-contracts/contracts/apps/IDAv1Library.sol";

contract Lighthouse {
    string public name;
    address public immutable tokenAddress;
    address public factoryAddress;

    mapping(address => bool) public isAdmin;
    mapping(address => uint256) public pointsBalanceOf;

    event TokenWhitelistAdded(string indexed name, address _whitelisted);

    // Superfluid Info
    using IDAv1Library for IDAv1Library.InitData;
    IDAv1Library.InitData public idaV1;

    uint32 public constant INDEX_ID = 0;
    ISuperToken public superRewardToken;

    modifier onlyAllowed() {
        require(
            msg.sender == factoryAddress || isAdmin[msg.sender],
            "UNAUTHORIZED"
        );
        _;
    }

    constructor(
        address _initialAdmin,
        string memory _name,
        string memory _tokenName,
        string memory _tokenSymbol,
        uint8 _tokenDecimals,
        ISuperfluid _host,
        ISuperToken _superRewardToken
    ) {
        name = _name;
        isAdmin[_initialAdmin] = true;
        factoryAddress = msg.sender;
        Token token = new Token(_tokenName, _tokenSymbol, _tokenDecimals);
        tokenAddress = address(token);

        // Ensure _spreaderToken is indeed a super token
        require(address(_host) == _superRewardToken.getHost(),"!superToken"); 

        superRewardToken = _superRewardToken;

        idaV1 = IDAv1Library.InitData(
            _host,
            IInstantDistributionAgreementV1(
                address(_host.getAgreementClass(keccak256("org.superfluid-finance.agreements.InstantDistributionAgreement.v1")))
            )
        );

        idaV1.createIndex(superRewardToken, INDEX_ID);

    }

    function addPointsTo(address receiver, uint256 amount) public onlyAllowed {
        Token(tokenAddress).mint(receiver, amount);

        // Get current units msg.sender holds
        (,,uint256 currentUnitsHeld,) = idaV1.getSubscription(
            superRewardToken,   
            address(this),   
            INDEX_ID,        
            receiver       
        );

        // Update to current amount + points amount
        idaV1.updateSubscriptionUnits(
            superRewardToken,
            INDEX_ID,
            receiver,
            uint128(currentUnitsHeld + amount)
        );

    }

    function slashPoints(address _from, uint256 _amount) public onlyAllowed {
        // TODO: add an event if necessary.
        Token(tokenAddress).slash(_from, _amount);

        // Get current units msg.sender holds
        (,,uint256 currentUnitsHeld,) = idaV1.getSubscription(
            superRewardToken,   
            address(this),   
            INDEX_ID,        
            _from       
        );

        // Update to current amount - 1 (reverts if currentUnitsHeld - 1 < 0, so basically if currentUnitsHeld = 0)
        idaV1.updateSubscriptionUnits(
            superRewardToken,
            INDEX_ID,
            _from,
            uint128(currentUnitsHeld - _amount)
        );
    }

    // Distributes out the entire Super Token balance of the contract to the NTT holders
    function distribute() public {
        uint256 superRewardTokenBalance = superRewardToken.balanceOf(address(this));

        (uint256 actualDistributionAmount,) = idaV1.calculateDistribution(
            superRewardToken,
            address(this), 
            INDEX_ID, 
            superRewardTokenBalance
        );

        idaV1.distribute(superRewardToken, INDEX_ID, actualDistributionAmount);
    }

    function makeAdmin(address _newAdmin) public onlyAllowed {
        isAdmin[_newAdmin] = true;
    }

    function addToTokenWhitelist(address _whitelisted) public onlyAllowed {
        Token(tokenAddress).addToWhitelist(_whitelisted);
        emit TokenWhitelistAdded(name, _whitelisted);
    }
}
