// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract FundIt {
    error NotOwner();
    error NotEnoughFund();
    error TimeLockNotExpired();
    error MustSendETH();
    error WithdrawAmountZero();
    address public /* immutable */ iOwner;
    mapping(address => uint256) private addressToAmountFunded;
    mapping(address => uint256) private depositIndex;
    address[] public funders;
    mapping(address => uint256) private firstDepositTime;
    uint256 public constant LOCK_DURATION = 30 days;

    constructor() {
        iOwner = msg.sender;
    }

    function fund() public payable {
        if (msg.value == 0) revert MustSendETH();

        if (addressToAmountFunded[msg.sender] == 0) {
            funders.push(msg.sender); // only first time!
            firstDepositTime[msg.sender] = block.timestamp;
        }
        addressToAmountFunded[msg.sender] += msg.value;

        depositIndex[msg.sender]++;
    }
    /*
        function _onlyOwner() internal view {
            if (msg.sender != iOwner) revert NotOwner();
        }

        modifier onlyOwner() {
            _onlyOwner();
            _;
        }


    */
    /*
        modifier onlyOwner() {
            // require(msg.sender == owner);
            if (msg.sender != iOwner) revert NotOwner();
            _;
        }
        */

    function withdrawSpecific(uint256 amount) public {
        if (amount == 0) revert WithdrawAmountZero();
        if (addressToAmountFunded[msg.sender] < amount) {
            revert NotEnoughFund();
        }

        // ← NEW: time check!
        if (block.timestamp < firstDepositTime[msg.sender] + LOCK_DURATION) {
            revert TimeLockNotExpired();
        }

        addressToAmountFunded[msg.sender] -= amount;
        (bool callSuccess,) = payable(msg.sender).call{value: amount}("");
        require(callSuccess, "Call failed");
    }

    function getaddressToAmountFunded(address user) public view returns (uint256) {
        return addressToAmountFunded[user];
    }

    function getFirstDepositTime(address user) public view returns (uint256) {
        return firstDepositTime[user];
    }

    fallback() external payable {
        fund();
    }

    receive() external payable {
        fund();
    }
}
