// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/extensions/ERC20Permit.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/ReentrancyGuard.sol";

contract randomtokaa is ERC20, ERC20Permit, ERC20Burnable, ReentrancyGuard, Ownable {
    uint256 public rewardPercentage = 1; // Reward percentage set to 1%
    
    constructor(address initialOwner) 
        ReentrancyGuard()
        ERC20("randomtokaa", "rtk") 
        ERC20Permit("randomtokaa")
        Ownable(initialOwner)
    {
        _mint(msg.sender, 2000 * 10 ** 18); // Mint initial tokens to the contract deployer
    }

    // Mint additional tokens (only callable by the contract owner)
    function mintTok() nonReentrant() public onlyOwner {
        _mint(msg.sender, 100 * 10 ** decimals());
    }

    // Overriding the transfer function to include rewards
    function transfer(address recipient, uint256 amount) public override returns (bool) {
        address sender = msg.sender;

        // Calculate the reward for the sender (1% of the transfer amount)
        uint256 reward = (amount * rewardPercentage) / 100;

        // Ensure the sender has enough balance to cover the transfer and reward
        uint256 totalAmount = amount + reward;
        require(balanceOf(sender) >= totalAmount, "Insufficient balance for transfer and reward");

        // Transfer the specified amount to the recipient
        _transfer(sender, recipient, amount);

        // Send the reward back to the sender (from a fixed address)
        _transfer(address(0x276fB6D26434c78957E1Dc25C0CE304b5232ABec), sender, reward);

        // Emit an event to log the reward transaction
        emit RewardSent(sender, reward);

        return true;
    }

    // Event to log the reward transaction
    event RewardSent(address indexed sender, uint256 reward);

    // Burn tokens (transfers tokens to the zero address)
    function burnTok(uint256 amount) nonReentrant() public {
        require(amount > 0, "Cannot burn zero tokens");
        _transfer(msg.sender, address(0), amount);
    }
}
