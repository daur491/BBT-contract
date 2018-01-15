"use strict";
const BestBuyToken = artifacts.require('BestBuyToken');
const SafeMath = artifacts.require('SafeMath');
const DailyLimitCrowdsale = artifacts.require('DailyLimitCrowdsale');
const tokenConfig = require('../contracts-params').token;
const crowdsaleConfig = require('../contracts-params').crowdsale;


module.exports = function(deployer, network, accounts) {

    deployer.deploy(SafeMath, {overwrite: false})
        .then(function() {
            return deployer.link(SafeMath, [BestBuyToken, DailyLimitCrowdsale]);
        })
        .then(function() {
            return deployer.deploy(BestBuyToken, tokenConfig.name, tokenConfig.symbol, tokenConfig.decimals);
        })
        .then(function() {
            return deployer.deploy(DailyLimitCrowdsale, BestBuyToken.address, crowdsaleConfig.startDate, crowdsaleConfig.endDate, crowdsaleConfig.wallet);
        })
        .then(function(crowdsaleContractInstance) {
            // allows crowdsale mint new tokens;
            console.log('SetMintAgent');
            return BestBuyToken.deployed().then((instance) => {
                return instance.setMintAgent(DailyLimitCrowdsale.address, true);
            });
        })
        .then(function() {
            return DailyLimitCrowdsale.deployed().then((instance) => {
                console.log('distrubuteTeamTokens');
                instance.distributeTeamTokens();
            });
        });
};
