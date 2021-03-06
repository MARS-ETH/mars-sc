// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract AggregatorV3Mock {
  int price;

  constructor(int _price){
    require(_price > 0);
    price = _price;
  }

  function decimals() external pure returns (uint8) {
    return 18;
  }
  function description() external pure returns (string memory) {
      return "AggregatorV3Mock";
  }
  function version() external pure returns (uint256) {
      return 3;
  }

  // getRoundData and latestRoundData should both raise "No data present"
  // if they do not have data to report, instead of returning unset values
  // which could be misinterpreted as actual reported values.
  function getRoundData(uint80 _roundId)
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    ) {
        return (_roundId,price,1,1,1);
    }
  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    ) {
        return (1,price,1,1,1);
    }

}
