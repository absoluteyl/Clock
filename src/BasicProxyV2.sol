// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.17;

import { BasicProxy } from "./BasicProxy.sol";

contract BasicProxyV2 is BasicProxy {
  // First slot is the address of the current implementation

  function upgradeTo(address _newImplementation) external {
    __Proxy_init(_newImplementation);
  }

  function upgradeToAndCall(address _newImplementation, bytes memory data) external {
    __Proxy_init(_newImplementation);
    (bool success, ) = _newImplementation.delegatecall(data);
    require(success);
  }

}
