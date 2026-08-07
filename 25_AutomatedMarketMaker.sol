// Build a system for trading tokens automatically. 
// You'll learn how to create liquidity pools and implement the constant product formula, demonstrating AMM logic. 
// It's like a digital exchange for tokens, showing how to create automated markets.

// # Concepts you will master
// 1. AMM logic
// 2. constant product formula
// 3. liquidity pools

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.34;

interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);

    function transferFrom(address sender,address recipient,uint256 amount) external returns (bool);

    function balanceOf(address account) external view returns (uint256);
}


contract AutomatedMarketMaker {

    IERC20 public usdc;
    address public owner;

    uint256 public product;

    constructor(address _usdc){
        usdc = IERC20(_usdc);
        owner = msg.sender;
    }

    mapping(address => uint256) public liquidity;

    function addLiquidity(uint256 usdcAmount) external payable {

        require(msg.value > 0, "ZERO ETH");
        require(usdcAmount > 0, "ZERO USDC");

        // Maintain ratio after first deposit
        if(product != 0){
            require(
                msg.value * usdc.balanceOf(address(this))
                ==
                usdcAmount * address(this).balance,
                "WRONG RATIO"
            );
        }

        bool success = usdc.transferFrom(msg.sender,address(this),usdcAmount);
        require(success, "USDC TRANSFER FAILED");

        liquidity[msg.sender] += msg.value;

        product =address(this).balance * usdc.balanceOf(address(this));
    }

    function swapEthForUsdc() external payable {
        require(msg.value > 0, "ZERO ETH");
        uint256 oldEth = address(this).balance - msg.value;
        uint256 oldUsdc = usdc.balanceOf(address(this));

        uint256 k = oldEth * oldUsdc;

        uint256 newEth = oldEth + msg.value;

        uint256 newUsdc = k / newEth;

        uint256 usdcOut = oldUsdc - newUsdc;

        bool success = usdc.transfer(msg.sender,usdcOut);
        require(success, "TRANSFER FAILED");

        product =address(this).balance * usdc.balanceOf(address(this));
    }

    function swapUsdcForEth(uint256 usdcIn) external {
        require(usdcIn > 0, "ZERO USDC");

        uint256 oldEth = address(this).balance;
        uint256 oldUsdc = usdc.balanceOf(address(this));

        bool success = usdc.transferFrom(msg.sender,address(this),usdcIn);
        require(success, "TRANSFER FAILED");

        uint256 newUsdc = oldUsdc + usdcIn;

        uint256 k = oldEth * oldUsdc;

        uint256 newEth = k / newUsdc;

        uint256 ethOut = oldEth - newEth;

        (bool sent,) = payable(msg.sender).call{value: ethOut}("");
        require(sent, "ETH TRANSFER FAILED");

        product =address(this).balance *usdc.balanceOf(address(this));
    }

    function ethReserve() public view returns(uint256){
        return address(this).balance;
    }

    function usdcReserve() public view returns(uint256){
        return usdc.balanceOf(address(this));
    }
}