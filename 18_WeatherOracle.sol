// Build a smart contract that retrieves live weather data using an oracle like Chainlink.
// You'll create a decentralized crop insurance contract where farmers can claim insurance if rainfall drops below a certain threshold during the growing season. 
// Since the Ethereum blockchain can't access real-world data on its own, you'll use an oracle to fetch off-chain weather information and trigger payouts automatically. 
// This project demonstrates how to securely integrate external data into your contract logic and highlights the power of real-world connectivity in smart contracts.

// # Concepts you will master
// 1. Interacting with oracles
// 2. fetching off-chain data

// Assuming there exist Weather oracle
// function getRainfall(string calldata city) external view returns (uint rainfallMM);
// Above function return rainfall in mm
// 0   -> No rain
// 5   -> Light rain
// 25  -> Moderate rain
// if below 5 , farmers can claim insurance 

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.34;

interface IWeatherOracle {
    function getRainfall(string calldata city) external view returns (uint256 rainfallMM);
}

contract CropInsurance{
    struct Farmer{
        uint256 insuranceNo ;
        uint256 amount ;  
        uint256 validity ;
        bool claimed ;
    }

    mapping(address => Farmer) insurances ;

    address owner ;
    uint256 count ;
    IWeatherOracle public oracle;
    uint256 public rainfallThreshold;

    constructor(address _oracle ,uint256 _threshold) {
        require(_oracle != address(0), "Invalid oracle");
        oracle = IWeatherOracle(_oracle);
        rainfallThreshold = _threshold;
        owner = msg.sender ;
        count =1;
    }

    modifier onlyOwner() {
        require(msg.sender== owner , "NOT A VALID OWNER");
        _;
    }

    uint256 public insuranceAmount = 50 ether;
    uint256 public deposit = 10 ether;

    function getInsurance() payable public {
        require(msg.value == deposit , "VALUE MUST BE EQUAL TO DEPOSIT");
        require(insurances[msg.sender].validity < block.timestamp || insurances[msg.sender].claimed,"Active insurance already exists");
        insurances[msg.sender] = Farmer(count , insuranceAmount , block.timestamp + 365 days , false);
        count++ ;
    }

    function claimInsurance(string calldata city) public {
        require(oracle.getRainfall(city) < rainfallThreshold , "RAINFALL IS ABOVE THRESHOLD");
        require(!insurances[msg.sender].claimed ,"INSURANCE ALREADY CLAIMED");
        require(block.timestamp < insurances[msg.sender].validity ,"INSURANCE VALIDTY OVER");
        require(address(this).balance >= insurances[msg.sender].amount,"Insufficient contract funds");
        insurances[msg.sender].claimed = true ;

        (bool success, )= payable(msg.sender).call{value:insurances[msg.sender].amount}("");
        require(success, "TRANSACTION FAILED");
    }

    function depositOwner() payable public onlyOwner{
    }

    function withdraw(uint256 _amount) public onlyOwner {
        require(address(this).balance >= _amount,"Insufficient contract funds");
        (bool success, )= payable(msg.sender).call{value:_amount}("");
        require(success, "TRANSACTION FAILED");
    }

    function updateRainfallThreshold(uint256 _newThreshold) public onlyOwner{
        rainfallThreshold = _newThreshold;
    }

    function updateOracle(address _newOracle) public onlyOwner{
        require(_newOracle != address(0), "Invalid oracle");
        oracle = IWeatherOracle(_newOracle);
    }

    function updateDeposit(uint256 _newDeposit) public onlyOwner {
        deposit = _newDeposit ;
    }

    function updateInsuranceAmount(uint256 _newInsuranceAmount) public onlyOwner {
        insuranceAmount = _newInsuranceAmount;
    }
}