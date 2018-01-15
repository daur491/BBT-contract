module.exports = {
    // See <http://truffleframework.com/docs/advanced/configuration>
    // to customize your Truffle configuration!
    networks: {
        development: {
            host: "localhost",
            port: 8545,
            network_id: "*", // Match any network id,
            gas: 4600000
        },
        kovan: {
            host: 'localhost',
            port: 8545,
            network_id: 42,
            gas: 4700000,
            gasPrice: 20000000000
        },
        rinkeby: {
            host: "localhost", // Connect to geth on the specified
            port: 8545,
            network_id: 4,
            gas: 4612388,
            gasPrice: 20000000000
        },
        solc: {
            optimizer: {
                enabled: true,
                runs: 200
            }
        },
        migrations_directory: './migrations'
    }
};
