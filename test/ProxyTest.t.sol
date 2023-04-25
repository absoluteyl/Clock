// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.17;

import { Test } from "forge-std/Test.sol";
import { Clock } from "../src/Clock.sol";
import { ClockV2 } from "../src/ClockV2.sol";
import { BasicProxy } from "../src/BasicProxy.sol";
import { BasicProxyV2 } from "../src/BasicProxyV2.sol";

contract ProxyTest is Test {

  Clock public clock;
  Clock public clockProxy;
  ClockV2 public clock2;
  ClockV2 public clockProxy2;
  BasicProxy public proxy;
  BasicProxyV2 public proxy2;
  uint256 public alarm1Time;
  uint256 public alarm2Time;

  function setUp() public {
    // 1. set up clock with custom alarm1 time
    alarm1Time = block.timestamp + 60;
    clock = new Clock();
    clock.__Clock_init(alarm1Time);
    // 2. set up proxy
    proxy = new BasicProxy();
    proxy.__Proxy_init(address(clock));
    clockProxy = Clock(address(proxy));
  }

  // 確保所有對 proxy 的 call 都會 delegate call 去 Clock
  // 對 proxy call getTimestamp
  // 對 proxy call setAlarm1 來設定 proxy 中 alarm1 的值
  function testProxy() public {
    // clock can only be initialized once
    vm.expectRevert("already initialized");
    clock.__Clock_init(alarm1Time);

    //  clockProxy.getTimestamp should be equal to block.timestamp
    assertEq(clockProxy.getTimestamp(), block.timestamp, "timestamp should be equal to block.timestamp");

    // clock.alarm1 should be equal to alarm1Time
    assertEq(clock.alarm1(), alarm1Time, "alarm1 should be equal to alarm1Time");
    // clockProxy.alarm1 should be equal to 0
    assertEq(clockProxy.alarm1(), 0, "alarm1 should be equal to 0");

    // set alarm1Time to alarm1
    clockProxy.setAlarm1(alarm1Time);

    // clockProxy.alarm1 should be equal to alarm1Time
    assertEq(clockProxy.alarm1(), alarm1Time, "alarm1 should be equal to alarm1Time");

    // START UPGRADE PROCESS
    // Initialize BasicProxyV2 with upgradeTo function
    proxy2 = new BasicProxyV2();
    proxy2.__Proxy_init(address(clock));

    // Initialize ClockV2
    uint256 newAlarm1Time = block.timestamp + 120;
    clock2 = new ClockV2();
    clock2.__Clock_init(newAlarm1Time);

    // Upgrade to ClockV2
    proxy2.upgradeTo(address(clock2));
    clockProxy2 = ClockV2(address(proxy2));
    // END UPGRADE PROCESS

    // call clockProxy.getTimestamp
    assertEq(clockProxy2.getTimestamp(), block.timestamp, "timestamp should be equal to block.timestamp");

    // call clock.alarm1
    assertEq(clock.alarm1(), alarm1Time, "alarm1 should be equal to alarm1Time");
    // call clock.alarm2
    assertEq(clock.alarm2(), 0, "alarm2 should be equal to 0");

    // call clock2.alarm1
    assertEq(clock2.alarm1(), newAlarm1Time, "alarm1 should be equal to alarm1Time");
    // call clock2.alarm2
    assertEq(clock2.alarm2(), 0, "alarm2 should be equal to 0");

    // call clockProxy.alarm1
    assertEq(clockProxy.alarm1(), alarm1Time, "alarm1 should be equal to alarm1Time");
    // call clockProxy.alarm2
    assertEq(clockProxy.alarm2(), 0, "alarm2 should be equal to 0");

    // call clockProxy2.alarm1
    assertEq(clockProxy2.alarm1(), 0, "alarm1 should be equal to 0");
    // call clockProxy2.alarm2
    assertEq(clockProxy2.alarm2(), 0, "alarm1 should be equal to 0");

    // call clockProxy2.setAlarm1
    clockProxy2.setAlarm1(newAlarm1Time);
    // call clockProxy2.setAlarm2
    alarm2Time = block.timestamp + 300;
    clockProxy2.setAlarm2(alarm2Time);

    // call clock.alarm1
    assertEq(clock.alarm1(), alarm1Time, "alarm1 should be equal to alarm1Time");
    // call clock.alarm2
    assertEq(clock.alarm2(), 0, "alarm2 should be equal to 0");

    // call clock2.alarm1
    assertEq(clock2.alarm1(), newAlarm1Time, "alarm1 should be equal to alarm1Time");
    // call clock2.alarm2
    assertEq(clock2.alarm2(), 0, "alarm2 should be equal to 0");

    // call clockProxy.alarm1
    assertEq(clockProxy.alarm1(), alarm1Time, "alarm1 should be equal to alarm1Time");
    // call clockProxy.alarm2
    assertEq(clockProxy.alarm2(), 0, "alarm2 should be equal to 0");

    // Alarm values of clockProxy2 should be updated.
    // call clockProxy2.alarm1
    assertEq(clockProxy2.alarm1(), newAlarm1Time, "alarm1 should be equal to newAlarm1Time");
    // call clockProxy2.alarm2
    assertEq(clockProxy2.alarm2(), alarm2Time, "alarm2 should be equal to alarm2Time");
  }
}
