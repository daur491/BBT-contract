const moment = require('moment-timezone');
const BigNumber = require('bignumber.js');
const DATE_FORMAT = 'DD.MM.YYYY HH:mm:ss';

//set EST timezone by default
moment.tz.setDefault("America/New_York");

const tokenDecimals = 18;
const crowdsaleStartDate = '01.03.2018 00:00:00';
module.exports = {
    token: {
        name: "Best Buy Token",
        symbol: "BBT",
        decimals: tokenDecimals
    },
    crowdsale: {
        startDate: convertToUnixTimestampInSeconds(crowdsaleStartDate),
        endDate: convertToUnixTimestampInSeconds(calculateEndDate(crowdsaleStartDate)),
        wallet: '0xdec98a7a34b68c7ba1d342f12069f9c44eeb4be4',
    }
};



/**
 *
 * @param date formatted date string
 * @returns {string}
 */
function convertToUnixTimestampInSeconds(date) {
    return (moment(date, DATE_FORMAT).valueOf()/1000).toFixed(0);
}

function convertToBigNumber(amount, decimals) {
    const value = Math.floor(parseFloat(amount) * Math.pow(10, decimals));
    return new BigNumber(value);
}

function calculateEndDate(_startDate) {
    const startDate = moment(_startDate, DATE_FORMAT);
    const endDate = moment(startDate).add(1000, 'days').add(1, 'day');
    return endDate.format(DATE_FORMAT);
}
