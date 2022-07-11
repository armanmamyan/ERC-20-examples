// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

contract VestingTimelock is Ownable, Pausable {
  using SafeMath for uint256;
  using SafeERC20 for IERC20;

  IERC20 private _token;

  mapping (address => uint256) private _balances;
  mapping (address => uint256) private _claims;

  uint256 private _totalBalance;
  uint256 private _totalClaimed;

  uint256 private _startTime;
  uint256 private _endTime;

  event Claimed(address indexed to, uint256 value, uint256 progress);

  constructor (IERC20 token_, uint256 startTime_, uint256 endTime_) public {
      require(endTime_ > currentTime(), "VestingTimelock: end before current time");
      require(endTime_ > startTime_, "VestingTimelock: end before start time");

      _token = token_;
      _endTime = endTime_;
      _startTime = startTime_;
      if (_startTime == 0)
        _startTime = currentTime();
  }


  /**************************
   View Functions
   **************************/

  function token() public view virtual returns (IERC20) {
      return _token;
  }

  function currentTime() public view virtual returns (uint256) {
    // solhint-disable-next-line not-rely-on-time
    return block.timestamp;
  }

  function totalBalance() public view virtual returns (uint256) {
      return _totalBalance;
  }

  function totalClaimed() public view virtual returns (uint256) {
      return _totalClaimed;
  }

  function totalVested() public view virtual returns (uint256) {
      return totalBalance().mul(getProgress()).div(1e18);
  }

  function totalAvailable() public view virtual returns (uint256) {
      return totalVested().sub(totalClaimed());
  }

  function startTime() public view virtual returns (uint256) {
      return _startTime;
  }

  function endTime() public view virtual returns (uint256) {
      return _endTime;
  }

  function getProgress() public view returns (uint256) {
    if (currentTime() > _endTime)
      return 1e18;
    else if (currentTime() < _startTime)
      return 0;
    else
      return currentTime().sub(_startTime).mul(1e18).div(_endTime.sub(_startTime));
  }

  function balanceOf(address account) public view virtual returns (uint256) {
      return _balances[account];
  }

  function claimedOf(address account) public view virtual returns (uint256) {
      return _claims[account];
  }

  function vestedOf(address account) public view virtual returns (uint256) {
      return _balances[account].mul(getProgress()).div(1e18);
  }

  function availableOf(address account) public view virtual returns (uint256) {
      return vestedOf(account).sub(claimedOf(account));
  }


  /**************************
   Public Functions
   **************************/

  function claim() public virtual whenNotPaused {
      uint256 amount = availableOf(msg.sender);
      require(amount > 0, "VestingTimelock: no tokens vested yet");

      _claims[msg.sender] = _claims[msg.sender].add(amount);
      _totalClaimed = _totalClaimed.add(amount);

      token().safeTransfer(msg.sender, amount);

      emit Claimed(msg.sender, amount, getProgress());
  }

  /**************************
   Owner Functions
   **************************/

  function pause() public virtual onlyOwner {
    _pause();
  }

  function unpause() public virtual onlyOwner {
    unpause();
  }

  function recover() public virtual onlyOwner {
    token().safeTransfer(msg.sender, token().balanceOf(address(this)));
  }

  function replaceAddress(address account1, address account2) external onlyOwner {
    require(_balances[account1] > 0, "replacement address has no balance");
    require(_balances[account2] == 0, "replacement address has balance");

    _balances[account2] = _balances[account1];
    _claims[account2] = _claims[account1];

    _balances[account1] = 0;
    _claims[account1] = 0;
  }

  function setClaimed(address account, uint256 value) external onlyOwner {
    require(value <= _balances[account], "balance cannot be less than claimed");
    _totalClaimed = _totalClaimed.add(value).sub(_claims[account]);
    _claims[account] = value;
  }

  function setBalance(address account, uint256 value) external onlyOwner {
    require(value >= _claims[account], "balance cannot be less than claimed");
    _totalBalance = _totalBalance.add(value).sub(_balances[account]);
    _balances[account] = value;
  }

  function setBalances(address[] calldata recipients, uint256[] calldata values) external onlyOwner {
    require(recipients.length > 0 && recipients.length == values.length, "values and recipient parameters have different lengths or their length is zero");

    for (uint256 i = 0; i < recipients.length; i++) {
      _totalBalance = _totalBalance.add(values[i]).sub(_balances[recipients[i]]);
      _balances[recipients[i]] = values[i];
    }
  }

  function addBalances(address[] calldata recipients, uint256[] calldata values) external onlyOwner {
    require(recipients.length > 0 && recipients.length == values.length, "values and recipient parameters have different lengths or their length is zero");

    for (uint256 i = 0; i < recipients.length; i++) {
      _totalBalance = _totalBalance.add(values[i]);
      _balances[recipients[i]] = _balances[recipients[i]].add(values[i]);
    }
  }

  function setClaims(address[] calldata recipients, uint256[] calldata values) external onlyOwner {
    require(recipients.length > 0 && recipients.length == values.length, "values and recipient parameters have different lengths or their length is zero");

    for (uint256 i = 0; i < recipients.length; i++) {
      _totalClaimed = _totalClaimed.add(values[i]);
      _claims[recipients[i]] = values[i];
    }
  }
}