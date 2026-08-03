// Build a contract that uses another contract to do calculations. 
// You'll learn how contracts can talk to each other by calling functions of other contracts (using `address casting`). 
// It's like having one app ask another app to do some math, showing how to interact with other contracts.

// # Concepts You'll Master
// 1. Calling functions of another contract
// 2. address casting
// 3. imports

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.34;

contract Calculator {

    function addTwoNumbers(int num1 , int num2) public pure returns(int){
        return num1+num2 ;
    }

    function subtractTwoNumbers(int num1 , int num2) public pure returns(int){
        return num1-num2 ;
    }

    function multiplyTwoNumbers(int num1 , int num2) public pure returns(int){
        return num1*num2 ;
    }

    function divideByNumber(int num1 , int num2) public pure returns(int){
        require(num2 != 0, "Cannot divide by zero");
        return num1/num2 ;
    }

    function remainderOfNumber(int num1 , int num2) public pure returns(int){
        require(num2 != 0, "Cannot divide by zero to get remainder");
        return num1%num2 ;
    }
}

contract SmartCalculator{
    Calculator public cal ;
    constructor(address _calculator) {
        require(_calculator != address(0) , "enter valid address");
        cal = Calculator(_calculator);
    }

    function add(int num1 , int num2) public view returns(int){
        return cal.addTwoNumbers(num1, num2);
    }

    function subtract(int num1 , int num2) public view returns(int){
        return cal.subtractTwoNumbers(num1, num2);   
    }

    function multiply(int num1 , int num2) public view returns(int){
        return cal.multiplyTwoNumbers(num1, num2);
    }

    function divide(int num1 , int num2) public view returns(int){
        return cal.divideByNumber(num1, num2);
    }

    function remainder(int num1 , int num2) public view returns(int){
        return cal.remainderOfNumber(num1, num2);   
    }
}