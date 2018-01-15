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
contract DayPriceTest {

    // amount of raised money in wei
    uint256 public weiRaised;

    // how much tokens can be sold during the day
    uint public dailyLimit = 200000 ether;

    uint public initRate = 10000 * (10 ** 18);
    uint public lastRate = initRate;

    uint public lastDay = 0;

    uint[] dailyPercents = new uint[](8);

    uint teamTokens = 10000000 ether;

    uint startTime;
    
    uint percentPrecisionMultiplier = 100;


    /**
     * event for token purchase logging
     * @param purchaser who paid for the tokens
     * @param beneficiary who got the tokens
     * @param value weis paid for purchase
     * @param amount amount of tokens purchased
     */
    event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);


    function DayPriceTest(uint _startTime) {
        startTime = _startTime;


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
    }

    function calculateAmountOfTokens(uint weiAmount) public returns(uint) {
//        uint currentDay = (now - startTime) / 1 days;
//        if(currentDay > lastDay) {
//            updateTodayRate(currentDay);
//            lastDay = currentDay;
//        }
        uint amount = weiAmount * lastRate / (10**18);
        return amount;
    }

    //    function getTodayRate(uint currentDay) pure public returns(uint) { //replace to internal
    //        uint lastIndex = 0;
    //        for(uint i = 0; i < dailyPercents.length/2; i++) {
    //            if (currentDay >= dailyPercents[2*i]) {
    //                lastIndex = i;
    //            } else {
    //                break;
    //            }
    //        }
    //
    //        uint newRate = initRate;
    //        for(uint j = lastIndex; j >= 0; j--) {
    //            if (j == lastIndex) {
    //                newRate = newRate * ( (1 - dailyPercents[2*j+1]/1000) ** (currentDay - dailyPercents[2*j]) );
    //            } else {
    //                newRate = newRate * ( (1 - dailyPercents[2*j+1]/1000) ** (dailyPercents[2*j]) );
    //            }
    //        }
    //
    //        return newRate;
    //    }


    function updateTodayRate(uint currentDay) public { //public only for test purposes; return internal after tests

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
