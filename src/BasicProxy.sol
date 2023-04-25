// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.17;

import { Proxy } from "./Proxy.sol";

contract BasicProxy is Proxy {
  // First slot is the address of the current implementation
  address public implementation;

  function __Proxy_init(address _implementation) public {
    implementation = _implementation;
  }

  fallback() external {
    _delegate(implementation);
  }
}
