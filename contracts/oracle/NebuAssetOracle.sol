// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "./ChainlinkAggregatorV3Interface.sol";
import "../Ownable.sol";
import "./NebuPriceOracle.sol";

contract NebuAssetOracle is ChainlinkAggregatorV3Interface, Ownable {
    using SafeMath for uint;

    uint8 private decimals_;
    string private description_;
    NebuPriceOracle public baseOracle;

    address public asset;

    struct RoundData {
        uint80 roundId;
        int256 answer;
        uint256 startedAt;
        uint256 updatedAt;
        uint80 answeredInRound;
    }

    event ChainlinkSourceChanged(
        uint index,
        address newSource);

    constructor(
        uint8 _decimals,
        string memory _description,
        NebuPriceOracle _baseOracle,
        address _asset) {
        require(_asset != address(0), "QsElaTokenOracle: asset address is zero");
        decimals_ = _decimals;
        description_ = _description;
        baseOracle = _baseOracle;
        asset = _asset;
    }

    function decimals() external view returns (uint8) {
        return decimals_;
    }

    function description() external view returns (string memory) {
        return description_;
    }

    function version() external pure returns (uint256) {
        return 1;
    }

    function getRoundData(uint80 _roundId) public
    view
    returns (
        uint80 roundId,
        int256 answer,
        uint256 startedAt,
        uint256 updatedAt,
        uint80 answeredInRound
    ) {
        roundId = _roundId;
        (uint price, uint updateAt, ) = baseOracle.getPriceInfo(asset);
        startedAt = 0;
        updatedAt = updateAt;

        if (decimals_ < 18) {
            answer = int(price.div(10 ** (18 - uint(decimals_))));
        } else if (decimals_ > 18) {
            answer = int(price.mul(10 ** (uint(decimals_) - 18)));
        } else {
            answer = int(price);
        }

        answeredInRound = 0;
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
        return getRoundData(0);
    }

    function setBaseOracle(NebuPriceOracle _baseOracle) external onlyOwner {
        baseOracle = _baseOracle;
    }
}
