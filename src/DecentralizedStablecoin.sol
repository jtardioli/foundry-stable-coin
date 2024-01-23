// SPDX-Licence-Identifier: MIT
pragma solidity ^0.8.18;

// Layout of Contract:
// version
// imports
import {ERC20Burnable, ERC20} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

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
contract DecentralizedStablCoin is ERC20Burnable, Ownable {
    error DecentralizedStablCoin__MustBeMoreThanZero();
    error DecentralizedStablCoin__BurnExceedsBalance();
    error DecentralizedStablCoin__NotZeroAddress();

    constructor()
        ERC20("DecentralizedStableCoin", "DSC")
        Ownable(address(msg.sender))
    {}

    function burn(uint256 _amount) public override onlyOwner {
        uint256 balance = balanceOf(msg.sender);
        if (_amount <= 0) {
            revert DecentralizedStablCoin__MustBeMoreThanZero();
        }
        if (balance < _amount) {
            revert DecentralizedStablCoin__BurnExceedsBalance();
        }
        super.burn(_amount);
    }

    function mint(
        address _to,
        uint256 _amount
    ) external onlyOwner returns (bool) {
        if (_to == address(0)) {
            revert DecentralizedStablCoin__NotZeroAddress();
        }
        if (_amount <= 0) {
            revert DecentralizedStablCoin__MustBeMoreThanZero();
        }
        _mint(_to, _amount);
        return true;
    }
}
