pragma solidity ^0.4.17;

import '../token/BestBuyToken.sol';
import '../math/SafeMath.sol';
import '../ownership/Ownable.sol';
import './DayLimit.sol';

/**
 * @title Crowdsale
 * @dev Crowdsale is a base contract for managing a token crowdsale.
 * Crowdsales have a start and end timestamps, where investors can make
 * token purchases and the crowdsale will assign them tokens based
 * on a token per ETH rate. Funds collected are forwarded to a wallet
 * as they arrive.
 */
contract DailyLimitCrowdsale is Ownable, DayLimit {
    using SafeMath for uint256;

    // The token being sold
    BestBuyToken public token;

    // start and end timestamps where investments are allowed (both inclusive)
    uint256 public startTime;
    uint256 public endTime;

    // address where funds are collected
    address public wallet;

    // amount of raised money in wei
    uint256 public weiRaised;

    // how much tokens can be sold during the day
    uint public constant dailyLimit = 200000 * (10**18);

    // exchange rate at the first day
    uint public constant initRate = 10000 * (10**18);

    // the last day index for which exchange rate was calculated
    uint public lastDay = 0;

    // last calculated rate
    uint public lastRate = initRate;


    // array stores data about % growth size and periods
    // 2*i index stores index of the day
    // 2*i+1 index stores % value
    uint[] dailyPercents = new uint[](8);

    uint constant percentPrecisionMultiplier = 100;

    // amount of tokens that goes to the team
    uint constant teamTokens = 10000000 * (10**18);

    // allow distribute team tokens only once
    bool teamTokensDistributed = false;


    /**
     * event for token purchase logging
     * @param purchaser who paid for the tokens
     * @param beneficiary who got the tokens
     * @param value weis paid for purchase
     * @param amount amount of tokens purchased
     */
    event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);


    function DailyLimitCrowdsale(BestBuyToken _token, uint256 _startTime, uint256 _endTime, address _wallet)
    Ownable()
    DayLimit(dailyLimit, _startTime) public {
        require(_endTime >= _startTime);
        require(_wallet != address(0));
        require(_token != address(0));

        token = BestBuyToken(_token);
        startTime = _startTime;
        endTime = _endTime;
        wallet = _wallet;

        setDailyPercents();
    }

    /**
     * method sets price growth strategy
     *
     *
     */

    function setDailyPercents() internal {
        // first value is day index
        dailyPercents.push(0);
        // second value in %
        // percentPrecisionMultiplier is needed to allow use float values of percents
        dailyPercents.push(2 * percentPrecisionMultiplier);

        dailyPercents.push(114);
        dailyPercents.push(3 * percentPrecisionMultiplier / 2);

        dailyPercents.push(269);
        dailyPercents.push(1 * percentPrecisionMultiplier);

        dailyPercents.push(502);
        dailyPercents.push(1 * percentPrecisionMultiplier / 2);

        dailyPercents.push(502);
        dailyPercents.push(1 * percentPrecisionMultiplier / 2);
    }

    function distributeTeamTokens() public onlyOwner {
        require(!teamTokensDistributed);
        token.mint(wallet, teamTokens);
    }

    // fallback function can be used to buy tokens
    function () external payable {
        buyTokens(msg.sender);
    }

    // low level token purchase function
    function buyTokens(address beneficiary) public payable {
        require(beneficiary != address(0));
        require(validPurchase());

        uint256 weiAmount = msg.value;

        // calculate token amount to be created
        uint256 tokens = calculateAmountOfTokens(weiAmount);

        // check if amount of tokens is under day dailyLimit
        require(underLimit(tokens));

        // update state
        weiRaised = weiRaised.add(weiAmount);

        token.mint(beneficiary, tokens);
        TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);

        forwardFunds();
    }

    // send ether to the fund collection wallet
    // override to create custom fund forwarding mechanisms
    function forwardFunds() internal {
        wallet.transfer(msg.value);
    }

    // @return true if the transaction can buy tokens
    function validPurchase() internal view returns (bool) {
        bool withinPeriod = now >= startTime && now <= endTime;
        bool nonZeroPurchase = msg.value != 0;
        return withinPeriod && nonZeroPurchase;
    }

    // @return true if crowdsale event has ended
    function hasEnded() public view returns (bool) {
        return now > endTime;
    }


    function calculateAmountOfTokens(uint weiAmount) internal returns(uint) {
        uint currentDay = (now - startTime) / 1 days;
        if(currentDay > lastDay) {
            updateTodayRate(currentDay);
            lastDay = currentDay;
        }
        return weiAmount.mul(lastRate) / (10**18);
    }


    function updateTodayRate(uint currentDay) internal {

        uint daysGap = currentDay - lastDay;

        uint newRate = lastRate;
        for (uint i = 1; i <= daysGap; i++) {
            uint dayPercent = getDayPercentGrowth(lastDay+i);
            newRate = newRate - (newRate * dayPercent/percentPrecisionMultiplier/100);
        }

        lastRate = newRate;
    }

    function getDayPercentGrowth(uint dayIndex) view internal returns(uint) {
        uint percent;
        for(uint i = 0; i < dailyPercents.length/2; i++) {
            if (dayIndex >= dailyPercents[2*i]) {
                percent = dailyPercents[2*i+1];
            } else {
                break;
            }
        }

        return percent;
    }


}
