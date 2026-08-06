// Build a modular profile system for a Web3 game. 
// The core contract stores each player's basic profile (like name and avatar), but players can activate optional 'plugins' to add extra features like achievements, inventory management, battle stats, or social interactions. 
// Each plugin is a separate contract with its own logic, and the main contract uses `delegatecall` to execute plugin functions while keeping all data in the core profile. 
// This allows developers to add or upgrade features without redeploying the main contract—just like installing new add-ons in a game. 
// You'll learn how to use `delegatecall` safely, manage execution context, and organize external logic in a modular way.

// # Concepts you will master
// 1. delegatecall
// 2. code execution context
// 3. libraries

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.34;

contract Achievements {
   struct Profile {
    string name;
    string avatar;
    uint256 victories;
    uint256 rank;
    uint256 totalGames;
    uint256 kills;
    uint256 deaths;
    string[] weapons;
    }

    mapping(address => Profile) profiles;

    function totalVictories(uint256 _count) public {
        profiles[msg.sender].victories = _count;
    }

    function addRank(uint256 _rank) public {
         profiles[msg.sender].rank = _rank;
    }
}

contract Inventory{
    struct Profile {
    string name;
    string avatar;
    uint256 victories;
    uint256 rank;
    uint256 totalGames;
    uint256 kills;
    uint256 deaths;
    string[] weapons;
    }

    mapping(address => Profile) public profiles;

    string[6] public inventories = ["Sniper" ,"Knife" ,"AK47","Shield","Potion","Granade"];

    function addWeapon(uint256 _inventoryNumber) public{
        require(_inventoryNumber<6 ,"INVALID INVENTORY NUMBER");
        profiles[msg.sender].weapons.push(inventories[_inventoryNumber]);
    }
}

contract BattleStats{
    struct Profile {
    string name;
    string avatar;
    uint256 victories;
    uint256 rank;
    uint256 totalGames;
    uint256 kills;
    uint256 deaths;
    string[] weapons;
    }

    mapping(address => Profile) public profiles;
    

    function addBattleStats(uint256 _totalGames , uint256 _kills) public{
        require(_kills <= _totalGames, "Invalid stats");
        profiles[msg.sender].totalGames = _totalGames;
        profiles[msg.sender].kills = _kills;
        profiles[msg.sender].deaths = _totalGames - _kills;
    }

}

contract PluginStore{ 
    struct Profile {
    string name;
    string avatar;
    uint256 victories;
    uint256 rank;
    uint256 totalGames;
    uint256 kills;
    uint256 deaths;
    string[] weapons;
    }

    mapping(address => Profile) public profiles;

    string[6] public inventories = ["Sniper" ,"Knife" ,"AK47","Shield","Potion","Granade"];

    address public achievementPlugin;
    address public inventoryPlugin;
    address public battlePlugin;

    constructor(address _achievement, address _inventory, address _battle) { 
        achievementPlugin = _achievement; 
        inventoryPlugin = _inventory; 
        battlePlugin = _battle; 
    }

    function createProfle(string calldata _name , string calldata _avatar) public {
        profiles[msg.sender].name = _name;
        profiles[msg.sender].avatar =_avatar ;
    }

    function totalVictories(uint256 _count) public {
        (bool success , ) = achievementPlugin.delegatecall(abi.encodeWithSignature("totalVictories(uint256)",_count));
        require(success, "Delegatecall failed");
    }

    function addRank(uint256 _rank) public{
        (bool success , ) = achievementPlugin.delegatecall(abi.encodeWithSignature("addRank(uint256)",_rank));
        require(success, "Delegatecall failed");
    } 
    
    function addBattleStats(uint256 _totalGames , uint256 _kills) public{
        (bool success , ) = battlePlugin.delegatecall(abi.encodeWithSignature("addBattleStats(uint256,uint256)",_totalGames,_kills));
        require(success, "Delegatecall failed");
    }

    function addWeapon(uint256 _inventoryNumber) public{
        (bool success , ) = inventoryPlugin.delegatecall(abi.encodeWithSignature("addWeapon(uint256)" ,_inventoryNumber));
        require(success, "Delegatecall failed");
    }
} 