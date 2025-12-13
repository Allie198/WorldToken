// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./WorldToken.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract System {

    WorldToken public token;

    address constant usdc = 0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238;

    AggregatorV3Interface internal Gold_PriceFeed;
    AggregatorV3Interface internal ETH_PriceFeed;
    AggregatorV3Interface internal BTC_PriceFeed;
    
    IERC20 public BTC_T;
    IERC20 public GOLD_T;


    mapping(address => uint256) public ethCollateral;
    mapping(address => uint256) public goldCollateral;
    mapping(address => uint256) public btcCollateral;

    mapping(address => uint256) public mintedTokens;

    uint256 public constant COLLATERAL_RATIO = 200;

    uint8 public immutable  GOLD_DECIMAL;
    uint8 public immutable  BTC_DECIMAL;
 
    constructor(address _tokenAddress, address btcToken, address goldToken) {
      
        Gold_PriceFeed = AggregatorV3Interface (0xC5981F461d74c46eB4b0CF3f4Ec79f025573B0Ea);
        BTC_PriceFeed  = AggregatorV3Interface (0x1b44F3514812d835EB1BDB0acB33d3fA3351Ee43);
        ETH_PriceFeed  = AggregatorV3Interface (0x694AA1769357215DE4FAC081bf1f309aDC325306);

        token = WorldToken(_tokenAddress);

        BTC_T = IERC20(btcToken);
        GOLD_T = IERC20(goldToken);

        BTC_DECIMAL =  6;
        GOLD_DECIMAL = 6;
 
    }

    function getPrice(AggregatorV3Interface feed) public view returns (uint256) {
        (, int256 price, , , ) = feed.latestRoundData();
        return uint256(price);
    }

    
    function _usdToToken(uint256 usd1e18, uint256 tokenPriceUsd, uint8 tokenDecimals) internal pure returns (uint256) {
        return (usd1e18 * (10 ** tokenDecimals)) / tokenPriceUsd;
    }

    function _usdToWei(uint256 usd1e18, uint256 ethPriceUsd) internal pure returns (uint256) {
        return (usd1e18 * 1e18) / ethPriceUsd;
    }

    function tokenPrice() public view returns(uint256) {
         uint256 goldPrice = getPrice(Gold_PriceFeed);
         uint256 ethPrice  = getPrice(ETH_PriceFeed);
         uint256 btcPrice  = getPrice(BTC_PriceFeed);

         return (goldPrice + ethPrice + btcPrice) / 20000;
    }


    function mintToken(uint256 amount) external payable{ 
        uint256 tokenPrice = tokenPrice();
        uint debt = (amount *  tokenPrice) / 1e18;

        uint256 requiredColUsd = (debt * COLLATERAL_RATIO) / 100;
        uint256 shareUsd = requiredColUsd / 3; 

        uint256 btcPriceUsd = getPrice(BTC_PriceFeed);
        uint256 goldPriceUsd = getPrice(Gold_PriceFeed);
        uint256 ethPriceUsd = getPrice(ETH_PriceFeed);

        uint256 btcAmt = _usdToToken(shareUsd, btcPriceUsd, BTC_DECIMAL);
        uint256 goldAmt = _usdToToken(shareUsd, goldPriceUsd, GOLD_DECIMAL);
        uint256 ethWei = _usdToWei(shareUsd, ethPriceUsd);

        require(msg.value >= ethWei, "Need more ethereum to transact");
        require(BTC_T.transferFrom(msg.sender, address(this), btcAmt), "Need more Bitcoin to transact");
        require(GOLD_T.transferFrom(msg.sender, address(this), goldAmt), "Need more Gold to transact");

        ethCollateral [msg.sender]  += ethWei;
        btcCollateral [msg.sender]  += btcAmt;
        goldCollateral[msg.sender] += goldAmt;
        
        mintedTokens[msg.sender] += amount;
        token.mint(msg.sender, amount);
    }

    function burnToken(uint256 amount) external { 
        require(mintedTokens[msg.sender] >= amount, "Unsufficient debt");
        require(token.transferFrom(msg.sender, address(this), amount),"Transaction failed");
        
        token.burn(address(this), amount);
        mintedTokens[msg.sender] -= amount;

        uint256 tokenPrice_ = tokenPrice();
        uint256 usdDebt = (amount * tokenPrice_) / 1e18;

        uint256 colUsd = (usdDebt * COLLATERAL_RATIO) / 100;
        uint256 shared = colUsd / 3;

        uint256 btcPrice  = getPrice(BTC_PriceFeed);
        uint256 ethPrice  = getPrice(ETH_PriceFeed);
        uint256 goldPrice = getPrice(Gold_PriceFeed);

        uint256 btcOut = _usdToToken(shared, btcPrice, BTC_DECIMAL);
        uint256 goldOut = _usdToToken(shared, goldPrice, GOLD_DECIMAL);

        uint256 ethOutWei = _usdToWei(shared, ethPrice);

        require(btcCollateral[msg.sender] >= btcOut, "BTC collateral is low");
        require(goldCollateral[msg.sender] >= goldOut, "Gold collateral is low");
        require(ethCollateral[msg.sender] >= ethOutWei, "ETH colateral is low ");

        btcCollateral[msg.sender] -= btcOut;
        ethCollateral[msg.sender] -= ethOutWei;
        goldCollateral[msg.sender] -= goldOut;

        require(BTC_T.transfer(msg.sender, btcOut), "BTC transfer faield");
        require(GOLD_T.transfer(msg.sender, goldOut), "Gold transfer faield");
        payable(msg.sender).transfer(ethOutWei);
    }

    

}
