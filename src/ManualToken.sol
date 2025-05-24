// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract ManualToken {
    //

    mapping(address => uint256) private s_balances;

    function name() public pure returns (string memory) {
        return "Manual Token";
    }

    function symbol() public pure returns (string memory) {
        return "MTKN";
    }

    function totalSupply() public pure returns (uint256) {
        return 10000000 ether; //10jt
    }

    function decimals() public pure returns (uint8) {
        return 18;
    }

    function balanceOf(address _owner) public view returns (uint256) {
        return s_balances[_owner];
    }

    function transfer(address _to, uint256 amount) public {
        uint256 prevBalances = balanceOf(msg.sender) + balanceOf(_to);
        s_balances[msg.sender] -= amount;
        s_balances[_to] += amount;
        assert(prevBalances == balanceOf(msg.sender) + balanceOf(_to));
    }
}
