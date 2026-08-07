// Build a system for lending and borrowing digital assets. 
// You'll learn how to calculate interest and manage collateral, demonstrating core DeFi concepts. 
// It's like a digital bank for crypto, showing how to create lending and borrowing platforms.

// # Concepts you will master
// 1. Lending/borrowing
// 2. interest calculations
// 3. collateral

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.34;

contract LendingPool {
    address public owner =msg.sender ;
    modifier onlyOwner() {
        require(owner == msg.sender ,"NOT A VALID OWNER");
        _;
    }
    struct Depositer{
        uint256 balance ;
        uint256 time ;
    }

    struct Borrower {
        uint256 amount ;
        uint256 time ;
        uint256 collateral;
    }

    mapping(address => Depositer) deposited ;
    mapping(address => Borrower) borrowed ;

    uint256 public loanRate = 10 ; // Simple Interest
    uint256 public depositRate = 5 ; //Simple Interest
    uint256 secondsToYears = 365*24*60*60 ;

    function loanInterest() public view returns(uint256){
        require(borrowed[msg.sender].amount > 0 ,"NO LOAN EXISTS");
        uint256 duration = block.timestamp - borrowed[msg.sender].time ;
        return borrowed[msg.sender].amount*loanRate*duration /(100 * secondsToYears);
    }

    function depositInterest() public view returns(uint256){
        require(deposited[msg.sender].balance >0 ,"ZERO BALANCE");
        uint256 duration = block.timestamp - deposited[msg.sender].time ;
        return deposited[msg.sender].balance*depositRate*duration /(100 * secondsToYears);
    }

    function balanceOf() public view returns(uint256){
        uint256 interest = depositInterest() ;
        return deposited[msg.sender].balance + interest;
    }

    function deposit() payable external {
        require(msg.value>0 , "VALUE SHOULD BE MORE THAN 0");
        if (deposited[msg.sender].balance > 0) {

        uint256 interest = depositInterest();

        deposited[msg.sender].balance += interest;
    }

    deposited[msg.sender].balance += msg.value;
    deposited[msg.sender].time = block.timestamp;
    }

    function withdraw() external {
        uint256 netAmount = balanceOf();
        require(address(this).balance >= netAmount ,"INSUFFICIENT FUNDS");
        delete deposited[msg.sender] ;

        (bool success , ) = payable(msg.sender).call{value:netAmount}("");
        require(success,"TRANSACTION FAILED");
    }

    function repayAmount() public view returns(uint256){
        uint256 interest = loanInterest();
        return borrowed[msg.sender].amount + interest ;
    }

    function repayLoan() payable external{
        require(msg.value == repayAmount(),"VALUE SHOULD BE REPAY AMOUNT " );
        uint256 collateralAmount = borrowed[msg.sender].collateral ;

        delete borrowed[msg.sender];

        require(address(this).balance >= collateralAmount ,"INSUFFICIENT FUNDS");
        (bool success , ) = payable(msg.sender).call{value:collateralAmount}("");
        require(success,"TRANSACTION FAILED");
    }

    function depositCollateral() payable external{
        require(msg.value>0 , "VALUE SHOULD BE MORE THAN 0");
        borrowed[msg.sender].collateral += msg.value;
    }

    function getLoan(uint256 _amount) external {
        require(_amount > 0,"AMOUNT SHOULD BE MORE THAN 0");
        require(borrowed[msg.sender].collateral >0 ,"NO COLLATERAl");
        require(borrowed[msg.sender].amount ==0 ,"ALREADY HAVING 1 LOAN");
        require(borrowed[msg.sender].collateral >= _amount*2 ,"INSUFFICIENT COLLATERAL");
        borrowed[msg.sender].amount= _amount;
        borrowed[msg.sender].time = block.timestamp;
        require(address(this).balance >= _amount, "POOL HAS NO FUNDS");

        (bool success,) = payable(msg.sender).call{value:_amount}("");
        require(success, "TRANSFER FAILED");
    }

    function depositOwner() payable external onlyOwner {
    }

    function withdrawOwner(uint256 _amount) external onlyOwner {
        require(address(this).balance >= _amount ,"INSUFFICIENT CONTRACT BALANCE");
        (bool success , ) = payable(msg.sender).call{value : _amount}("");
        require(success ,"TRANSACTION FAILED");
    }
}