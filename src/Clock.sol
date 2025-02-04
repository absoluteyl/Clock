// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.17;

contract Clock {
  address public owner;
  uint256 public alarm1;
  uint256 public alarm2;
  bool  public initialized;

  function __Clock_init(uint256 _alarm1) public {
    require(!initialized, "already initialized");
    initialized = true;
    owner = msg.sender;
    alarm1 = _alarm1;
  }

  function setAlarm1(uint256 _timestamp) public {
    alarm1 = _timestamp;
  }

  function getTimestamp() public view returns(uint256) {
    return block.timestamp;
  }

  function changeOwner(address _newOwner) public {
    owner = _newOwner;
  }
}
