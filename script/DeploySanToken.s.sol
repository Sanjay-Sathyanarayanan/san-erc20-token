// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {SanToken} from "../src/SanToken.sol";

contract DeploySanToken is Script {
    uint256 public constant initialSupply = 1000 ether;

    function run() external returns (SanToken) {
        vm.startBroadcast();
        SanToken token = new SanToken(initialSupply);
        vm.stopBroadcast();
        return token;
    }
}
