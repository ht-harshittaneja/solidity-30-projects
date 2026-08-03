// Create a smart contract that logs user workouts and emits events when fitness goals are reached — like 10 workouts in a week or 500 total minutes. 
// Users log each session (type, duration, calories), and the contract tracks progress. 
// Events use *indexed* parameters to make it easy for frontends or off-chain tools to filter logs by user and milestone — just like a backend for a decentralized fitness tracker with achievement unlocks.

// # Concepts You'll Master
// 1. Events
// 2. logging data
// 3. Indexed parameters
// 4. emitting events

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.34;

contract ActivityTracker{
    mapping (address => uint) totalCount ;
    mapping (address => uint) totalDuration ;

    event WorkoutLogged(address indexed user,string workoutType,uint duration,uint calories);

    event GoalReached(address indexed user,string goal);

    function workoutDone(string memory _workoutType , uint _duration , uint _caloriesBurned) public {
        require(_duration > 0, "Duration must be greater than zero");
        require(_caloriesBurned > 0, "Calories must be greater than zero");

        emit WorkoutLogged(msg.sender ,_workoutType , _duration , _caloriesBurned);
        totalCount[msg.sender] +=1 ;
        totalDuration[msg.sender] += _duration ;

        if(totalCount[msg.sender]==10 || totalDuration[msg.sender]>=500){
            if( totalCount[msg.sender]==10  && totalDuration[msg.sender]>=500){
            emit GoalReached( msg.sender , " yes , finally 10 times + duration >=500 minutes");
            }
            else if (totalCount[msg.sender]==10){
            emit GoalReached( msg.sender , " yes , finally 10 times");
            }
            else {
            emit GoalReached( msg.sender , " yes , finally duration >=500 minutes");
            }
            totalCount[msg.sender] =0 ;
            totalDuration[msg.sender] =0;
        }
    }
}