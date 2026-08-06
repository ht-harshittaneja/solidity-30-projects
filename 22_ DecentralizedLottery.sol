// Build a fair and random lottery! 
// You'll learn how to use external services like Chainlink VRF to generate random numbers. 
// It's like a lottery on the blockchain, demonstrating how to use external randomness.

// # Concepts you will master
// 1. Chainlink VRF
// 2. random number generation
// 3. lottery logic

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.34;

interface IVRFCoordinator {
    function requestRandomWords(
        bytes32 keyHash,
        uint64 subscriptionId,
        uint16 requestConfirmations,
        uint32 callbackGasLimit,
        uint32 numWords
    ) external returns (uint256 requestId);
}

contract DecentralizedLottery {

    uint256 private nextTicket = 1;
    uint256 private totalTickets = 100;
    uint256 private ticketsSold = 0;

    uint256 public winningAmount = 60 ether;
    uint256 public ticketPrice = 2 ether;

    uint256 public deadline = block.timestamp + 30 days;

    address public organizer;

    uint256 public requestId;
    uint256 public randomNumber;

    bool public claimed;

    bytes32 private keyHash = 0x8f3d7c4a1e95b2f6c8d91a7e43f0b6cd52e1a9f4873bc6d0fa21e85c9d74ab3f;
    uint64 private subscriptionId = 123566;
    uint16 private requestConfirmations = 3;
    uint32 private callbackGasLimit = 100000;
    uint32 private numWords = 1;

    IVRFCoordinator public coordinator;

    mapping(address => uint256) private tickets;
    mapping(uint256 => address) private owners;

    event Buys(uint256 indexed ticketNumber, address indexed user);

    modifier onlyOrganizer() {
        require(msg.sender == organizer, "NOT ORGANIZER");
        _;
    }

    constructor(address _coordinator) {
        require(_coordinator != address(0), "INVALID ADDRESS");

        organizer = msg.sender;
        coordinator = IVRFCoordinator(_coordinator);
    }

    function buyLotteryTicket() external payable {
        require(block.timestamp < deadline, "TIME OVER");
        require(msg.value == ticketPrice, "INVALID TICKET PRICE");
        require(nextTicket <= totalTickets, "NO TICKETS LEFT");
        require(tickets[msg.sender] == 0, "ALREADY PURCHASED");

        tickets[msg.sender] = nextTicket;
        owners[nextTicket] = msg.sender;

        emit Buys(nextTicket, msg.sender);

        nextTicket++;
        ticketsSold++;
    }

    function myTicketId() external view returns(uint256){
        return tickets[msg.sender];
    }

    function deposit() external payable onlyOrganizer {}

    function withdraw() external onlyOrganizer {
        require(address(this).balance > winningAmount, "INSUFFICIENT BALANCE");
        uint256 amount = address(this).balance - winningAmount;
        (bool success,) = payable(msg.sender).call{value: amount}("");
        require(success, "TRANSFER FAILED");
    }

    function generateRandom() external onlyOrganizer {
        require(block.timestamp >= deadline, "LOTTERY STILL ACTIVE");
        requestId = coordinator.requestRandomWords(
            keyHash,
            subscriptionId,
            requestConfirmations,
            callbackGasLimit,
            numWords
        );
    }

    // Simulated callback
    // In a real Chainlink contract, VRF Coordinator calls this.
    function fulfillRandom(uint256 _randomNumber) external onlyOrganizer {
        randomNumber = _randomNumber;
    }

    function winner() public view returns(uint256){
        require(ticketsSold > 0, "No tickets sold");
        require(randomNumber != 0, "WINNER NOT DECLARED");
        return (randomNumber % ticketsSold) + 1;
    }

    function getLotteryMoney() external {
        uint256 winnerId = winner();
        require(!claimed, "ALREADY CLAIMED");
        require(owners[winnerId] == msg.sender, "NOT WINNER");
        require(address(this).balance >= winningAmount, "INSUFFICIENT BALANCE");

        claimed = true;

        (bool success,) = payable(msg.sender).call{value: winningAmount}("");
        require(success, "TRANSFER FAILED");
    }
}