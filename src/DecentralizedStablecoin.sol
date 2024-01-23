// SPDX-Licence-Identifier: MIT
pragma solidity ^0.8.18;

// Layout of Contract:
// version
// imports
import {ERC20Burnable, ERC20} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";

// errors
// interfaces, libraries, contracts
// Type declarations
// State variables
// Events
// Modifiers
// Functions

// Layout of Functions:
// constructor
// receive function (if exists)
// fallback function (if exists)
// external
// public
// internal
// private
//

/**
 * @title DecentralizedStableCoin
 * @author Josh Tardioli
 * Collateral: Exogenous (ETH & BTC)
 * Minting: Algorithmic
 * Relative Stability: Pegged to USD
 *
 * This is the contract mean to be governed by DSCEngine. This contract is just the ERC20
 * implementation of our stablecoin system
 */
contract DecentralizedStablCoin is ERC20Burnable {
    constructor() ERC20("DecentralizedStableCoin", "DSC") {}
}
