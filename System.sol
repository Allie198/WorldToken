// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract ETHPrice {

    AggregatorV3Interface internal Gold_PriceFeed;
    AggregatorV3Interface internal ETH_PriceFeed;
    AggregatorV3Interface internal BTC_PriceFeed;


    constructor() {
        Gold_PriceFeed = AggregatorV3Interface(0xC5981F461d74c46eB4b0CF3f4Ec79f025573B0Ea);
        BTC_PriceFeed = AggregatorV3Interface (0x1b44F3514812d835EB1BDB0acB33d3fA3351Ee43);
        ETH_PriceFeed = AggregatorV3Interface (0x694AA1769357215DE4FAC081bf1f309aDC325306);
    }

    function getLatestGoldPrice() public view returns (int256) {
        (
            /* uint80 roundID */,
            int256 price,
            /*uint startedAt*/,
            /*uint timeStamp*/,
            /*uint80 answeredInRound*/
            
        ) = Gold_PriceFeed.latestRoundData();
        
            return price;
    }

    function getLatestETHPrice() public view returns (int256) {
        (
            /* uint80 roundID */,
            int256 price,
            /*uint startedAt*/,
            /*uint timeStamp*/,
            /*uint80 answeredInRound*/
            
        ) = ETH_PriceFeed.latestRoundData();
        
            return price;
    }

    function getLatestBTCPrice() public view returns (int256) {
        (
            /* uint80 roundID */,
            int256 price,
            /*uint startedAt*/,
            /*uint timeStamp*/,
            /*uint80 answeredInRound*/
            
        ) = BTC_PriceFeed.latestRoundData();
        
            return price;
    }

    function mintToken(uint256 amountToMint) external { 
           int256 goldPrice = getLatestGoldPrice();
           int256 ethPrice = getLatestETHPrice();
           int256 btcPrice = getLatestBTCPrice();
    }

    

}