// Build an upgradeable subscription manager for a SaaS-like dApp. 
// The proxy contract stores user subscription info (like plans, renewals, and expiry dates), while the logic for managing subscriptions—adding plans, upgrading users, pausing accounts—lives in an external logic contract. 
// When it's time to add new features or fix bugs, you simply deploy a new logic contract and point the proxy to it using `delegatecall`, without migrating any data. 
// This simulates how real-world apps push updates without asking users to reinstall. 
// You'll learn how to architect upgrade-safe contracts using the proxy pattern and `delegatecall`, separating storage from logic for long-term maintainability.

// # Concepts you will master
// 1. Upgradeable contracts
// 2. proxy pattern
// 3. delegate call for upgrades

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.34;

contract SubscriptionProxy {

    struct SubscriptionPlan {
        string name;
        uint256 duration;
        uint256 allowedUsers;
    }

    struct UserSubscription {
        uint256 planId;
        uint256 expiryDate;
        bool paused;
    }

    mapping(uint256 => SubscriptionPlan) public plans;
    mapping(address => UserSubscription) public subscriptions;

    address public implementation;
    address public owner;

    constructor(address _implementation) {
        owner = msg.sender;
        implementation = _implementation;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "NOT OWNER");
        _;
    }

    function upgradeImplementation(address _newImplementation) public onlyOwner {
        implementation = _newImplementation;
    }

    fallback() external payable {
        (bool success,) = implementation.delegatecall(msg.data);
        require(success, "DELEGATECALL FAILED");
    }
}

contract SubscriptionLogicV1 {

    struct SubscriptionPlan {
        string name;
        uint256 duration;
        uint256 allowedUsers;
    }

    struct UserSubscription {
        uint256 planId;
        uint256 expiryDate;
        bool paused;
    }

    mapping(uint256 => SubscriptionPlan) public plans;
    mapping(address => UserSubscription) public subscriptions;

    address public implementation;
    address public owner;

    function initialize() public {
        plans[1] = SubscriptionPlan("Silver",90 days,2);
        plans[2] = SubscriptionPlan("Gold",180 days,2);
        plans[3] = SubscriptionPlan("Platinum",200 days,4);
        plans[4] = SubscriptionPlan("Diamond",300 days,6);
    }

    string[4] public availableSubscriptions = ["1- Silver", "2- Gold" ,"3- Platinium","4- Diamond"];

    function selectPlan(uint256 _planId) public {
        require(_planId<5 && _planId>0 ,"INVALID PLAN ID");
        subscriptions[msg.sender]=UserSubscription(_planId,plans[_planId].duration + block.timestamp ,false);
    }

    function pauseSubscription() public {
        require(subscriptions[msg.sender].expiryDate > block.timestamp,"Already expired");
        subscriptions[msg.sender].expiryDate -= block.timestamp ;
        subscriptions[msg.sender].paused = true ;
    }

    function reumeSubscription() public {
        subscriptions[msg.sender].expiryDate += block.timestamp ;
        subscriptions[msg.sender].paused = false ;
    }

    function getPlan(uint256 _planId) public view returns(SubscriptionPlan memory){
        require(_planId<5 && _planId>0 ,"INVALID PLAN ID");
        return plans[_planId];
    }

    function mySubscription() public view returns(UserSubscription memory){
        return subscriptions[msg.sender] ;
    }
}