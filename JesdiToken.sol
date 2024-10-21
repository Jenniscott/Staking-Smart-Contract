// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol";

contract token is ERC20("Jesdi", "JSD") {
    address public owner;

    constructor() {
        owner = msg.sender;
        _mint(msg.sender, 100000e18);
    }

    function mint(uint _amount) external {
        _mint(msg.sender, _amount *1e18);
}
}
