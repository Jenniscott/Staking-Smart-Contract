// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import "./IERC20.sol";

event Staked(address indexed user, uint256 amount);
event Unstaked(address indexed user, uint256 amount);
event RewardClaimed(address indexed user, uint256 amount);

contract stake {
    IERC20 public token;
    address public owner;
    uint256 public duration;
    uint256 public rewardAmount;
    uint256 public startTime;
    uint256 public stakePool; 

    mapping(address => uint256) stakedBalance;
    mapping(address => uint256) lastUpdateTime;
    mapping(address => uint256) rewards; 
    
    constructor (address _token) {
        token = IERC20(_token);
        owner = msg.sender;
    }

    modifier ownerOnly() {
        require(msg.sender == owner, "Not Authorized Personnel");
        _;
    }

     function setRewardAmountAndDuration(uint256 _rewardAmount, uint256 _duration) external ownerOnly {
        require(_duration > 0, "duration cannot be set to zero");
        
        duration = _duration;
        rewardAmount = _rewardAmount;
        startTime = block.timestamp;
     }


    function stakeDeposit(uint256 _amount) external {
        require(msg.sender != address(0), "zero address detected");
        require(_amount > 0, "cannot stake zero value");
        require(block.timestamp <= startTime + duration, "Staking period has ended");
        require(token.allowance(msg.sender, address(this)) >= _amount, "Not enough allowance");
        rewardCalculation(msg.sender);

        stakedBalance[msg.sender] += _amount;
        stakePool += _amount;

        require(token.transferFrom(msg.sender, address(this), _amount), "Transfer failed");

        emit Staked(msg.sender, _amount);
    }

    function unstakeWithdraw(uint256 _amount) external  {
        require(msg.sender != address(0), "zero address detected");
        require(_amount > 0, "cannot withdraw zero value");
        require(stakedBalance[msg.sender] >= _amount);
        rewardCalculation(msg.sender);

        uint256 _userStakedBalance = stakedBalance[msg.sender];
        require(_userStakedBalance >= _amount, "You don't have up to that amount staked");

        stakedBalance[msg.sender] -= _amount;
        stakePool -= _amount;

        require(token.transfer(msg.sender, _amount), "Transfer failed");

        emit Unstaked(msg.sender, _amount);
    }

    function claim() external {
        rewardCalculation(msg.sender);
        uint256 reward = rewards[msg.sender];
        require(reward > 0, "no reward");
        rewards[msg.sender] = 0;

        require(token.transfer(msg.sender, reward), "Transfer failed");

        emit RewardClaimed(msg.sender, reward);
    } 

    function rewardCalculation(address account) internal {
        uint256 currentTime = block.timestamp;
        if (currentTime > startTime + duration) {
            currentTime = startTime + duration;
        }

        if (stakePool > 0) {
            uint256 timeElapsed = currentTime - lastUpdateTime[account];
            uint256 rewardRate = (rewardAmount * 1e18) / duration;
            rewards[account] += (stakedBalance[account] * timeElapsed * rewardRate) / stakePool;

        }

        lastUpdateTime[account] = currentTime;
    }

    function getContractBal() external view ownerOnly returns(uint256) {
        return token.balanceOf(address(this));
    }
}
