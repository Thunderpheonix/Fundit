# FundIt - Time-Locked Deposit Contract

A smart contract that allows users to deposit ETH with a time-lock mechanism, preventing early withdrawals for a set duration (30 days from first deposit).

## Features

- **Time-Locked Deposits**: Funds are locked for 30 days from the first deposit
- **Per-User Tracking**: Each user has their own balance and lock period
- **Partial Withdrawals**: Users can withdraw specific amounts after lock expires
- **Direct ETH Reception**: Supports direct ETH transfers via `fallback` and `receive`
- **Custom Errors**: Gas-efficient error handling

## How It Works

1. Users call `fund()` to deposit ETH
2. First deposit timestamp is recorded for the lock duration
3. After 30 days, users can withdraw any amount up to their balance
4. Multiple deposits don't reset the lock timer (based on first deposit)

## Contract Structure

### State Variables
- `iOwner`: Contract deployer address
- `addressToAmountFunded`: Tracks each user's deposit balance
- `firstDepositTime`: Timestamp of each user's first deposit
- `LOCK_DURATION`: 30 days (constant)

### Main Functions
- `fund()`: Deposit ETH (payable)
- `withdrawSpecific(uint256 amount)`: Withdraw after lock expires
- `getaddressToAmountFunded(address)`: View user balance
- `getFirstDepositTime(address)`: View user's lock start

### Custom Errors
- `NotEnoughFund`: Withdrawal amount exceeds balance
- `TimeLockNotExpired`: Attempting withdrawal before 30 days
- `MustSendETH`: Zero ETH deposit attempted
- `WithdrawAmountZero`: Zero ETH withdrawal attempted

## Testing

The contract includes 7 unit tests with ~85% code coverage.

```bash
# Run tests
forge test

# Run with verbose output
forge test -vv

# Check coverage
forge coverage
```

### Test Suite
- `testCanFund`: Verify successful deposits
- `testRevertEarlyWithdrawSpecificAmount`: Lock enforcement
- `testWithdrawAfterOneMonth`: Successful post-lock withdrawal
- `testWithdrawAfterOneMonthNotEnoughFund`: Insufficient balance protection
- `testRevertFundWithZeroETH`: Zero deposit protection
- `testRevertWithdrawZero`: Zero withdrawal protection
- `testFirstDepositTimeNotChanged`: Lock timer persistence

## Tech Stack

- **Solidity**: ^0.8.18
- **Foundry**: Testing and deployment framework

## Project Structure

FundIt/
├── src/
│ └── FundIt.sol # Main contract
├── test/
│ └── FundIt.t.sol # Test suite
└── foundry.toml # Foundry configuration


## Getting Started

### Prerequisites
- [Foundry](https://book.getfoundry.sh/getting-started/installation)

### Installation

```bash
git clone <your-repo-url>
cd FundIt
forge install
forge build
```

### Running Tests

```bash
forge test
```

## Security Considerations

- Follows Checks-Effects-Interactions pattern
- Uses custom errors for gas efficiency
- Private storage with explicit getters
- No owner withdrawal function (users control their funds)

## License

MIT

## Author

Built as part of my Web3 development journey, learning Solidity and Foundry.