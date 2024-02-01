// SPDX-Licence-Identifier: MIT
pragma solidity ^0.8.18;

import {DecentralizedStableCoin} from "./DecentralizedStablecoin.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

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

contract DSCEngine is ReentrancyGuard {
    //////////////////
    // Errors    //
    /////////////////
    error DSCEngine__NeedsMoreThanZero();
    error DSCEngine_TokenAddressesAndPriceFeedAddressesMustBeSameLength();
    error DSCEngine__NotAllowedToken();
    error DSCEngine__TransferFailed();

    ////////////////////////
    // State Variables    //
    ////////////////////////
    uint256 private constant ADDITIONAL_FEED_PRECISION = 1e10;
    uint256 private constant PRECISION = 1e18;

    mapping(address token => address priceFeed) private s_priceFeeds;
    mapping(address user => mapping(address token => uint256 amount)) private s_collateralDeposited;
    mapping(address user => uint256 amountDscMinted) private s_DscMinted;
    address[] private s_collateralTokens;

    DecentralizedStableCoin private immutable i_dsc;

    ////////////////////////
    // Events    //
    ////////////////////////
    event CollateralDeposited(address indexed user, address indexed token, uint256 indexed amount);

    //////////////////
    // Modifiers    //
    /////////////////
    modifier moreThanZero(uint256 amount) {
        if (amount == 0) {
            revert DSCEngine__NeedsMoreThanZero();
        }
        _;
    }

    modifier isAllowedToken(address token) {
        if (s_priceFeeds[token] == address(0)) {
            revert DSCEngine__NotAllowedToken();
        }
        _;
    }

    //////////////////
    // Functions   //
    /////////////////
    constructor(address[] memory tokenAddresses, address[] memory priceFeedAddresses, address dscAddress) {
        // USD Price Feeds
        if (tokenAddresses.length != priceFeedAddresses.length) {
            revert DSCEngine_TokenAddressesAndPriceFeedAddressesMustBeSameLength();
        }

        // For example, ETH / USD, BTC / USD, etc
        for (uint256 i = 0; i < tokenAddresses.length; i++) {
            s_priceFeeds[tokenAddresses[i]] = priceFeedAddresses[i];
            s_collateralTokens.push(tokenAddresses[i]);
        }
        i_dsc = DecentralizedStableCoin(dscAddress);
    }

    //////////////////////////
    // External Functions   //
    /////////////////////////

    function depsositCollateralAndMintDsc() external {}

    /**
     *
     * @param tokenCollateralAddress The address of the token to deposit as collateral
     * @param amountCollateral The amount of collateral to deposit
     */
    function depositCollateral(address tokenCollateralAddress, uint256 amountCollateral)
        external
        moreThanZero(amountCollateral)
        isAllowedToken(tokenCollateralAddress)
        nonReentrant
    {
        s_collateralDeposited[msg.sender][tokenCollateralAddress] += amountCollateral;
        emit CollateralDeposited(msg.sender, tokenCollateralAddress, amountCollateral);
        bool success = IERC20(tokenCollateralAddress).transferFrom(msg.sender, address(this), amountCollateral);
        if (!success) {
            revert DSCEngine__TransferFailed();
        }
    }

    function redeemCollateralForDsc() external {}

    function redeemCollateral() external {}

    // function mintDsc(uint256 amountDscToMint) external moreThanZero(amountDscToMint) nonReentrant {
    //     s_DscMinted[msg.sender] += amountDscToMint;

    //     revertIfHealthFactorIsBroken(msg.sender);
    // }

    /**
     *
     * @param amountDscToMint the amount of dsc to mint
     * @notice they must have more collateral value than the minimiun threshold
     */
    function mintDsc(uint256 amountDscToMint) external moreThanZero(amountDscToMint) nonReentrant {
        s_DscMinted[msg.sender] += amountDscToMint;
        // if they minted too much
        _revertIfHealthFactorIsBroken(msg.sender);
    }

    function burnDsc() external {}

    function liquidate() external {}

    function getHealthFactor() external view {}

    /////////////////////////////////////////
    /// Private & Internal View Functions //
    ////////////////////////////////////////

    function _getAccountInformation(address user)
        private
        view
        returns (uint256 totalDscMinted, uint256 collateralValueInUsd)
    {
        totalDscMinted = s_DscMinted[user];
        collateralValueInUsd = getAccountCollateralValue(user);
    }

    /**
     * Returns how close to liquidaion a user is
     * If a user goes below 1, then they can get liquidated
     */
    function _healthFactor(address user) private view returns (uint256) {
        // get total dsc minted
        // get total collateral VALUE
        (uint256 totalDscMinted, uint256 collteralValueInUsd) = _getAccountInformation(user);
    }

    function _revertIfHealthFactorIsBroken(address user) internal view {
        // 1. check health factor (do they have enough collateral)
        // 2. revert if they dont have enough collateral
    }

    /////////////////////////////////////////
    /// Public & External View Functions  //
    ////////////////////////////////////////

    function getAccountCollateralValue(address user) public view returns (uint256 totalCollateralValueInUsd) {
        // loop through each collateral token, get the amount they have deposited, and map it to
        // the price, to get the USD value
        for (uint256 i = 0; i < s_collateralTokens.length; i++) {
            address token = s_collateralTokens[i];
            uint256 amount = s_collateralDeposited[user][token];
            totalCollateralValueInUsd += getUsdValue(token, amount);
        }
        return totalCollateralValueInUsd;
    }

    function getUsdValue(address token, uint256 amount) public view returns (uint256) {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(s_priceFeeds[token]);
        (, int256 price,,,) = priceFeed.latestRoundData();
        // 1 ETH = $1000
        // retruned value from chainlink will be 1000 * 1e8
        return ((uint256(price) * ADDITIONAL_FEED_PRECISION) * amount) / PRECISION;
    }
}
