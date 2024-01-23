// SPDX-Licence-Identifier: MIT
pragma solidity ^0.8.18;

/**
 * @title DSCEngine
 * @author Josh T
 *
 * The system is designed to be as minimal as possible, and have the tokens maintain a 1 token = $1 peg
 * This stable coin has the properties
 * - Exogenous Collateral
 * - Dollar Pegged
 * - Algorithmically Stable
 *
 * Our DSC system should always be "over collateralized". at no point, should the value of all collateral <= to the $ backed value of all the DSC
 *
 * It is similar to DAI if DAI had no governance, no fees, and was only backed by WETH and WBTC.
 * @notice This contract is the ore of the DSC System. It handles all the logic for minting and redeeming DSC as well as depositing and withdrawing colateral
 * @notice this contract is VERY loosely based on the MakerDAO DSS (DAI) system
 */
contract DSCEngine {
    function depsositCollateralAndMintDsc() external {}

    function depositCollateral() external {}

    function redeemCollateralForDsc() external {}

    function redeemCollateral() external {}

    function burnDsc() external {}

    function liquidate() external {}

    function getHealthFactor() external view {}
}
