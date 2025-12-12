// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./WorldToken.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract System {

    WorldToken public token;

    AggregatorV3Interface internal Gold_PriceFeed;
    AggregatorV3Interface internal ETH_PriceFeed;
    AggregatorV3Interface internal BTC_PriceFeed;
    
    mapping(address => uint256) public ethCollateral;
    mapping(address => uint256) public mintedTokens;

    uint256 public constant COLLATERAL_RATIO = 200;
 
    constructor(address _tokenAddress) {
        Gold_PriceFeed = AggregatorV3Interface (0xC5981F461d74c46eB4b0CF3f4Ec79f025573B0Ea);
        BTC_PriceFeed  = AggregatorV3Interface (0x1b44F3514812d835EB1BDB0acB33d3fA3351Ee43);
        ETH_PriceFeed  = AggregatorV3Interface (0x694AA1769357215DE4FAC081bf1f309aDC325306);
        token = WorldToken(_tokenAddress);
    }

    function depositETH() external payable {
        require(msg.value > 0, "ETH required");
        ethCollateral[msg.sender] += msg.value;
    }

    function getPrice(AggregatorV3Interface feed) public view returns (uint256) {
        (, int256 price, , , ) = feed.latestRoundData();
        return uint256(price) * 1e10;
    }

    function tokenPrice() public view returns(uint256) {
         uint256 goldPrice = getPrice(Gold_PriceFeed);
         uint256 ethPrice  = getPrice(ETH_PriceFeed);
         uint256 btcPrice  = getPrice(BTC_PriceFeed);

         return (goldPrice + ethPrice + btcPrice) / 20000;
    }

    function mintToken(uint256 amount) external { 
        uint256 ethPrice = getPrice(ETH_PriceFeed);
        uint256 collateralValueUSD = (ethCollateral[msg.sender] * ethPrice) / 1e18;

        require(collateralValueUSD > 0, "There is no colleteral");

        uint256 currentTokenPrice = tokenPrice();
        uint256 debtValueUSD = (mintedTokens[msg.sender] + amount) * currentTokenPrice / 1e18;

        if (debtValueUSD > 0) {
            require((collateralValueUSD * 100) / debtValueUSD >= COLLATERAL_RATIO, "Insuffucient Colleteral");
        }

        mintedTokens[msg.sender] += amount;
        token.mint(msg.sender, amount);
    
    }

    function burnToken(uint256 amount) external { 
        require(mintedTokens[msg.sender] >= amount, "Unsufficient debt");

        token.transferFrom(msg.sender, address(this), amount);
        token.burn(address(this), amount);
        mintedTokens[msg.sender] -= amount;

        uint256 currentTokenPrice = tokenPrice();
        uint256 ethPrice = getPrice(ETH_PriceFeed);

        uint256 debtValueUSD = (amount * currentTokenPrice) / 1e18;
        uint256 ethToReturn =  (debtValueUSD * 1e18) / ethPrice;

        require(ethCollateral[msg.sender] >= ethToReturn, "Collateral error");
        ethCollateral[msg.sender] -= ethToReturn;
        payable(msg.sender).transfer(ethToReturn);


    }

    

}