// Build a smart bank that offers different types of deposit boxes — basic, premium, time-locked, etc. 
// Each box follows a common interface and supports ownership transfer.
// A central VaultManager contract interacts with all deposit boxes in a unified way, letting users store secrets and transfer ownership like handing over the key to a digital locker. 
// This teaches interface design, modularity, and how contracts communicate with each other safely.

// # Concepts you will master
// 1. Interfaces
// 2. Abstraction
// 3. Ownership Transfer
// 4. Contract-to-contract interaction

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.34;

interface IDepositBox {
    function storeSecret(string memory _secret) external;
    function transferOwnership(address newOwner) external;
    function getSecret() external view returns(string memory);
    function getBalance() external view returns(uint);
    function deposit(string memory _secret) external payable;
    function withdraw(string memory _secret, uint amount) external;
}

abstract contract BaseBox is IDepositBox {

    mapping(address => string) internal secret;
    mapping(address => uint) internal balances;

    modifier account() {
        require(bytes(secret[msg.sender]).length != 0, "ACCOUNT DOES NOT EXIST");
        _;
    }

    modifier validSecret(string memory _secret) {
        require(keccak256(bytes(secret[msg.sender])) == keccak256(bytes(_secret)), "INVALID SECRET");
        _;
    }

    function storeSecret(string memory _secret) public override {
        require(bytes(_secret).length > 0, "SECRET CANNOT BE EMPTY");
        secret[msg.sender] = _secret;
    }

    function transferOwnership(address newOwner) public override account {
        require(newOwner != address(0), "INVALID ADDRESS");
        require(bytes(secret[newOwner]).length == 0, "ACCOUNT ALREADY EXISTS");

        secret[newOwner] = secret[msg.sender];
        balances[newOwner] = balances[msg.sender];

        delete secret[msg.sender];
        delete balances[msg.sender];
    }

    function getSecret() public view override account returns(string memory) {
        return secret[msg.sender];
    }

    function getBalance() public view override returns(uint) {
        return balances[msg.sender];
    }

    function deposit(string memory _secret) public payable virtual override account validSecret(_secret) {
        balances[msg.sender] += msg.value;
    }

    function withdraw(string memory _secret, uint amount) public virtual override account validSecret(_secret) {
        require(balances[msg.sender] >= amount, "INSUFFICIENT BALANCE");

        balances[msg.sender] -= amount;

        (bool success,) = payable(msg.sender).call{value: amount}("");
        require(success, "TRANSFER FAILED");
    }
}

contract BasicBox is BaseBox {

    uint public limit = 10 ether;

    function withdraw(string memory _secret, uint amount) public override {
        require(amount <= limit, "LIMIT EXCEEDED");
        super.withdraw(_secret, amount);
    }
}

contract PremiumBox is BaseBox {

    uint public limit = 25 ether;

    function withdraw(string memory _secret, uint amount) public override {
        require(amount <= limit, "LIMIT EXCEEDED");
        super.withdraw(_secret, amount);
    }
}

contract TimeLockedBox is BaseBox {

    mapping(address => uint) public unlockTime;

    function deposit(string memory _secret) public payable override account validSecret(_secret) {
        super.deposit(_secret);
        unlockTime[msg.sender] = block.timestamp + 2 hours;
    }

    function withdraw(string memory _secret, uint amount) public override {
        require(block.timestamp >= unlockTime[msg.sender], "FUNDS ARE STILL LOCKED");
        super.withdraw(_secret, amount);
    }
}

contract VaultManager {

    IDepositBox public vault;

    constructor(address _vault) {
        vault = IDepositBox(_vault);
    }

    function storeSecret(string memory _secret) public {
        vault.storeSecret(_secret);
    }

    function deposit(string memory _secret) public payable {
        vault.deposit{value: msg.value}(_secret);
    }

    function withdraw(string memory _secret, uint amount) public {
        vault.withdraw(_secret, amount);
    }

    function transferOwnership(address newOwner) public {
        vault.transferOwnership(newOwner);
    }

    function mySecret() public view returns(string memory) {
        return vault.getSecret();
    }

    function myBalance() public view returns(uint) {
        return vault.getBalance();
    }
}