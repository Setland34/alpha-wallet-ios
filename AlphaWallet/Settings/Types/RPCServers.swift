// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import web3swift
import BigInt

// swiftlint:disable type_body_length
enum RPCServer: Hashable, CaseIterable {
    case main
    case kovan
    case ropsten
    case rinkeby
    case poa
    case sokol
    case classic
    //As of 20210601, `.callisto` doesn't eth_blockNumber because their endpoint requires including `"params": []` in the payload even if it's empty and we don't.
    //As of 20210601, `.callisto` doesn't support eth_call according to https://testnet-explorer.callisto.network/eth-rpc-api-docs
    case callisto
    case xDai
    case goerli
    case artis_sigma1
    case artis_tau1
    case binance_smart_chain
    case binance_smart_chain_testnet
    case heco
    case heco_testnet
    case fantom
    case fantom_testnet
    case avalanche
    case avalanche_testnet
    case polygon
    case mumbai_testnet
    case optimistic
    case optimisticKovan
    case custom(CustomRPC)

    private enum EtherscanCompatibleType {
        case etherscan
        case blockscout
        case unknown
    }

    //Using this property avoids direct reference to `.main`, which could be a sign of a possible crash — i.e. using `.main` when it is disabled by the user
    static var forResolvingEns: RPCServer {
        .main
    }

    var chainID: Int {
        switch self {
        case .main: return 1
        case .kovan: return 42
        case .ropsten: return 3
        case .rinkeby: return 4
        case .poa: return 99
        case .sokol: return 77
        case .classic: return 61
        case .callisto: return 104729
        case .xDai: return 100
        case .goerli: return 5
        case .artis_sigma1: return 246529
        case .artis_tau1: return 246785
        case .binance_smart_chain: return 56
        case .binance_smart_chain_testnet: return 97
        case .heco: return 128
        case .heco_testnet: return 256
        case .custom(let custom):
            return custom.chainID
        case .fantom: return 250
        case .fantom_testnet: return 0xfa2
        case .avalanche: return 0xa86a
        case .avalanche_testnet: return 0xa869
        case .polygon: return 137
        case .mumbai_testnet: return 80001
        case .optimistic: return 10
        case .optimisticKovan: return 69
        }
    }

    var name: String {
        switch self {
        case .main: return "Ethereum"
        case .kovan: return "Kovan"
        case .ropsten: return "Ropsten"
        case .rinkeby: return "Rinkeby"
        case .poa: return "POA Network"
        case .sokol: return "Sokol"
        case .classic: return "Ethereum Classic"
        case .callisto: return "Callisto"
        case .xDai: return "xDai"
        case .goerli: return "Goerli"
        case .artis_sigma1: return "ARTIS sigma1"
        case .artis_tau1: return "ARTIS tau1"
        case .binance_smart_chain: return "Binance (BSC)"
        case .binance_smart_chain_testnet: return "Binance (BSC) Testnet"
        case .heco: return "Heco"
        case .heco_testnet: return "Heco Testnet"
        case .custom(let custom): return custom.name
        case .fantom: return "Fantom Opera"
        case .fantom_testnet: return "Fantom Testnet"
        case .avalanche: return "Avalanche Mainnet C-Chain"
        case .avalanche_testnet: return "Avalanche FUJI C-Chain"
        case .polygon: return "Polygon Mainnet"
        case .mumbai_testnet: return "Mumbai Testnet"
        case .optimistic: return "Optimistic Ethereum"
        case .optimisticKovan: return "Optimistic Kovan"
        }
    }

    var isTestnet: Bool {
        switch self {
        case .xDai, .classic, .main, .poa, .callisto, .binance_smart_chain, .artis_sigma1, .heco, .fantom, .avalanche, .polygon, .optimistic:
            return false
        case .kovan, .ropsten, .rinkeby, .sokol, .goerli, .artis_tau1, .binance_smart_chain_testnet, .custom, .heco_testnet, .fantom_testnet, .avalanche_testnet, .mumbai_testnet, .optimisticKovan:
            return true
        }
    }

    var etherscanURLForGeneralTransactionHistory: URL? {
        switch self {
        case .main, .ropsten, .rinkeby, .kovan, .poa, .classic, .goerli, .xDai, .artis_sigma1, .artis_tau1, .polygon, .binance_smart_chain, .binance_smart_chain_testnet, .sokol, .callisto, .optimistic, .optimisticKovan:
            return etherscanApiRoot.appendingQueryString("module=account&action=txlist")
        case .heco: return nil
        case .heco_testnet: return nil
        case .custom: return nil
        case .fantom: return nil
        case .fantom_testnet: return nil
        case .avalanche: return nil
        case .avalanche_testnet: return nil
        case .mumbai_testnet: return nil
        }
    }

    ///etherscan-compatible erc20 transaction event APIs
    ///The fetch ERC20 transactions endpoint from Etherscan returns only ERC20 token transactions but the Blockscout version also includes ERC721 transactions too (so it's likely other types that it can detect will be returned too); thus we should check the token type rather than assume that they are all ERC20
    var etherscanURLForTokenTransactionHistory: URL? {
        switch etherscanCompatibleType {
        case .etherscan, .blockscout:
            return etherscanApiRoot.appendingQueryString("module=account&action=tokentx")
        case .unknown:
            return nil
        }
    }

    var etherscanWebpageRoot: URL? {
        let urlString: String? = {
            switch self {
            case .main: return "https://cn.etherscan.com"
            case .ropsten: return "https://ropsten.etherscan.io"
            case .rinkeby: return "https://rinkeby.etherscan.io"
            case .kovan: return "https://kovan.etherscan.io"
            case .goerli: return "https://goerli.etherscan.io"
            case .heco_testnet: return "https://scan-testnet.hecochain.com"
            case .heco: return "https://scan.hecochain.com"
            case .fantom: return "https://ftmscan.com"
            case .xDai: return "https://blockscout.com/poa/dai"
            case .poa: return "https://blockscout.com/poa/core"
            case .sokol: return "https://blockscout.com/poa/sokol"
            case .classic: return "https://blockscout.com/etc/mainnet"
            case .callisto: return "https://blockscout.com/callisto/mainnet"
            case .artis_sigma1: return "https://explorer.sigma1.artis.network"
            case .artis_tau1: return "https://explorer.tau1.artis.network"
            case .binance_smart_chain: return "https://bscscan.com"
            case .binance_smart_chain_testnet: return "https://testnet.bscscan.com"
            case .polygon: return "https://explorer-mainnet.maticvigil.com"
            case .mumbai_testnet: return "https://explorer-mumbai.maticvigil.com"
            case .optimistic: return "https://optimistic.etherscan.io"
            case .optimisticKovan: return "https://kovan-optimistic.etherscan.io"
            case .custom: return nil
            case .fantom_testnet, .avalanche, .avalanche_testnet:
                return nil
            }
        }()
        return urlString.flatMap { URL(string: $0) }
    }

    var etherscanApiRoot: URL {
        let urlString: String = {
            switch self {
            case .main: return "https://api-cn.etherscan.com/api"
            case .kovan: return "https://api-kovan.etherscan.io/api"
            case .ropsten: return "https://api-ropsten.etherscan.io/api"
            case .rinkeby: return "https://api-rinkeby.etherscan.io/api"
            case .goerli: return "https://api-goerli.etherscan.io/api"
            case .classic: return "https://blockscout.com/etc/mainnet/api"
            case .callisto: return "https://explorer.callisto.network/api"
            case .poa: return "https://blockscout.com/poa/core/api"
            case .xDai: return "https://blockscout.com/poa/dai/api"
            case .sokol: return "https://blockscout.com/poa/sokol/api"
            case .artis_sigma1: return "https://explorer.sigma1.artis.network/api"
            case .artis_tau1: return "https://explorer.tau1.artis.network/api"
            case .binance_smart_chain: return "https://api.bscscan.com/api"
            case .binance_smart_chain_testnet: return "https://api-testnet.bscscan.com/api"
            case .heco_testnet: return "https://api-testnet.hecoinfo.com/api"
            case .heco: return "https://api.hecoinfo.com/api"
            case .custom: return "" // Enable? make optional
            case .fantom: return "https://api.ftmscan.com/api"
            //TODO fix etherscan-compatible API endpoint
            case .fantom_testnet: return "https://explorer.testnet.fantom.network/tx/api"
            //TODO fix etherscan-compatible API endpoint
            case .avalanche: return "https://cchain.explorer.avax.network/tx/api"
            //TODO fix etherscan-compatible API endpoint
            case .avalanche_testnet: return "https://cchain.explorer.avax-test.network/tx/api"
            case .polygon: return "https://explorer-mainnet.maticvigil.com/api/v2"
            case .mumbai_testnet: return "https://explorer-mumbai.maticvigil.com/api/v2"
            case .optimistic: return "https://api-optimistic.etherscan.io/api"
            case .optimisticKovan: return "https://api-kovan-optimistic.etherscan.io/api"
            }
        }()
        return URL(string: urlString)!
    }

    //If Etherscan, action=tokentx for ERC20 and action=tokennfttx for ERC721. If Blockscout-compatible, action=tokentx includes both ERC20 and ERC721. tokennfttx is not supported.
    var etherscanURLForERC721TransactionHistory: URL? {
        switch etherscanCompatibleType {
        case .etherscan:
            return etherscanApiRoot.appendingQueryString("module=account&action=tokennfttx")
        case .blockscout:
            return etherscanApiRoot.appendingQueryString("module=account&action=tokentx")
        case .unknown:
            return nil
        }
    }

    private var etherscanCompatibleType: EtherscanCompatibleType {
        switch self {
        case .main, .ropsten, .rinkeby, .kovan, .goerli, .fantom, .heco, .heco_testnet, .optimistic, .optimisticKovan:
            return .etherscan
        case .poa, .sokol, .classic, .xDai, .artis_sigma1, .artis_tau1, .binance_smart_chain, .binance_smart_chain_testnet, .polygon, .mumbai_testnet, .callisto:
            return .blockscout
        case .custom, .fantom_testnet, .avalanche, .avalanche_testnet:
            return .unknown
        }
    }

    func getEtherscanURLForGeneralTransactionHistory(for address: AlphaWallet.Address, startBlock: Int?) -> URL? {
         etherscanURLForGeneralTransactionHistory.flatMap {
             let url = $0.appendingQueryString("address=\(address.eip55String)&apikey=\(Constants.Credentials.etherscanKey)")
             if let startBlock = startBlock {
                 return url?.appendingQueryString("startBlock=\(startBlock)")
             } else {
                 return url
             }
         }
    }

    func getEtherscanURLForTokenTransactionHistory(for address: AlphaWallet.Address, startBlock: Int?) -> URL? {
        etherscanURLForTokenTransactionHistory.flatMap {
            let url = $0.appendingQueryString("address=\(address.eip55String)&apikey=\(Constants.Credentials.etherscanKey)")
            if let startBlock = startBlock {
                return url?.appendingQueryString("startBlock=\(startBlock)")
            } else {
                return url
            }
        }
    }

    func getEtherscanURLForERC721TransactionHistory(for address: AlphaWallet.Address, startBlock: Int?) -> URL? {
        etherscanURLForERC721TransactionHistory.flatMap {
            let url = $0.appendingQueryString("address=\(address.eip55String)&apikey=\(Constants.Credentials.etherscanKey)")
            if let startBlock = startBlock {
                return url?.appendingQueryString("startBlock=\(startBlock)")
            } else {
                return url
            }
        }
    }

    //Can't use https://blockscout.com/poa/dai/address/ even though it ultimately redirects there because blockscout (tested on 20190620), blockscout.com is only able to show that URL after the address has been searched (with the ?q= URL)
    func etherscanContractDetailsWebPageURL(for address: AlphaWallet.Address) -> URL? {
        switch etherscanCompatibleType {
        case .etherscan:
            return etherscanWebpageRoot?.appendingPathComponent("address").appendingPathComponent(address.eip55String)
        case .blockscout:
            return etherscanWebpageRoot?.appendingPathComponent("search").appendingQueryString("q=\(address.eip55String)")
        case .unknown:
            return nil
        }
    }

    //We assume that only Etherscan supports this and only for Ethereum mainnet: The token page instead of contract page
    //TODO check if other Etherscan networks can support this
    //TODO check if Blockscout can support this
    func etherscanTokenDetailsWebPageURL(for address: AlphaWallet.Address) -> URL? {
        switch self {
        case .main:
            return etherscanWebpageRoot?.appendingPathComponent("token").appendingPathComponent(address.eip55String)
        case .ropsten, .rinkeby, .kovan, .xDai, .goerli, .poa, .sokol, .classic, .callisto, .artis_sigma1, .artis_tau1, .binance_smart_chain, .binance_smart_chain_testnet, .custom, .heco, .heco_testnet, .fantom, .fantom_testnet, .avalanche, .avalanche_testnet, .polygon, .mumbai_testnet, .optimistic, .optimisticKovan:
            return etherscanContractDetailsWebPageURL(for: address)
        }
    }

    var priceID: AlphaWallet.Address {
        switch self {
        case .main, .ropsten, .rinkeby, .kovan, .sokol, .custom, .xDai, .goerli, .artis_sigma1, .artis_tau1, .binance_smart_chain, .binance_smart_chain_testnet, .heco, .heco_testnet, .fantom, .fantom_testnet, .avalanche, .avalanche_testnet, .polygon, .mumbai_testnet, .optimistic, .optimisticKovan:
            return AlphaWallet.Address(string: "0x000000000000000000000000000000000000003c")!
        case .poa:
            return AlphaWallet.Address(string: "0x00000000000000000000000000000000000000AC")!
        case .classic:
            return AlphaWallet.Address(string: "0x000000000000000000000000000000000000003D")!
        case .callisto:
            return AlphaWallet.Address(string: "0x0000000000000000000000000000000000000334")!
        }
    }

    var displayName: String {
        if isTestnet {
            return "\(name) (\(R.string.localizable.settingsNetworkTestLabelTitle()))"
        } else {
            return name
        }
    }

    var symbol: String {
        switch self {
        case .main: return "ETH"
        case .classic: return "ETC"
        case .callisto: return "CLO"
        case .kovan, .ropsten, .rinkeby: return "ETH"
        case .poa, .sokol: return "POA"
        case .xDai: return "xDai"
        case .goerli: return "ETH"
        case .artis_sigma1, .artis_tau1: return "ATS"
        case .binance_smart_chain, .binance_smart_chain_testnet: return "BNB"
        case .heco, .heco_testnet: return "HT"
        case .custom(let custom): return custom.symbol
        case .fantom, .fantom_testnet: return "FTM"
        case .avalanche, .avalanche_testnet: return "AVAX"
        case .polygon, .mumbai_testnet: return "MATIC"
        case .optimistic: return "ETH"
        case .optimisticKovan: return "ETH"
        }
    }

    var cryptoCurrencyName: String {
        switch self {
        case .main, .classic, .callisto, .kovan, .ropsten, .rinkeby, .poa, .sokol, .goerli, .custom, .optimistic, .optimisticKovan:
            return "Ether"
        case .xDai:
            return "xDai"
        case .binance_smart_chain, .binance_smart_chain_testnet:
            return "BNB"
        case .artis_sigma1, .artis_tau1:
            return "ATS"
        case .heco, .heco_testnet:
            return "HT"
        case .fantom, .fantom_testnet:
            return "FTM"
        case .avalanche, .avalanche_testnet: return "AVAX"
        case .polygon, .mumbai_testnet: return "MATIC"
        }
    }

    var decimals: Int {
        return 18
    }

    var web3Network: Networks {
        switch self {
        case .main: return .Mainnet
        case .kovan: return .Kovan
        case .ropsten: return .Ropsten
        case .rinkeby: return .Rinkeby
        case .poa, .sokol, .classic, .callisto, .xDai, .goerli, .artis_sigma1, .artis_tau1, .binance_smart_chain, .binance_smart_chain_testnet, .heco, .heco_testnet, .fantom, .fantom_testnet, .avalanche, .custom, .avalanche_testnet, .polygon, .mumbai_testnet, .optimistic, .optimisticKovan:
            return .Custom(networkID: BigUInt(chainID))
        }
    }

    var magicLinkPrefix: URL {
        let urlString = "https://\(magicLinkHost)/"
        return URL(string: urlString)!
    }

    var magicLinkHost: String {
        switch self {
        case .main:
            return Constants.mainnetMagicLinkHost
        case .kovan:
            return Constants.kovanMagicLinkHost
        case .ropsten:
            return Constants.ropstenMagicLinkHost
        case .rinkeby:
            return Constants.rinkebyMagicLinkHost
        case .poa:
            return Constants.poaMagicLinkHost
        case .sokol:
            return Constants.sokolMagicLinkHost
        case .classic:
            return Constants.classicMagicLinkHost
        case .callisto:
            return Constants.callistoMagicLinkHost
        case .goerli:
            return Constants.goerliMagicLinkHost
        case .xDai:
            return Constants.xDaiMagicLinkHost
        case .artis_sigma1:
            return Constants.artisSigma1MagicLinkHost
        case .artis_tau1:
            return Constants.artisTau1MagicLinkHost
        case .binance_smart_chain:
            return Constants.binanceMagicLinkHost
        case .binance_smart_chain_testnet:
            return Constants.binanceTestMagicLinkHost
        case .custom:
            return Constants.customMagicLinkHost
        case .heco:
            return Constants.hecoMagicLinkHost
        case .heco_testnet:
            return Constants.hecoTestMagicLinkHost
        case .fantom:
            return Constants.fantomMagicLinkHost
        case .fantom_testnet:
            return Constants.fantomTestMagicLinkHost
        case .avalanche:
            return Constants.avalancheMagicLinkHost
        case .avalanche_testnet:
            return Constants.avalancheTestMagicLinkHost
        case .polygon:
            return Constants.maticMagicLinkHost
        case .mumbai_testnet:
            return Constants.mumbaiTestMagicLinkHost
        case .optimistic:
            return Constants.optimisticMagicLinkHost
        case .optimisticKovan:
            return Constants.optimisticTestMagicLinkHost
        }
    }

    var rpcURL: URL {
        let urlString: String = {
            switch self {
            case .main: return "https://mainnet.infura.io/v3/\(Constants.Credentials.infuraKey)"
            case .classic: return "https://www.ethercluster.com/etc"
            case .callisto: return "https://explorer.callisto.network/api/eth-rpc" //TODO Add endpoint
            case .kovan: return "https://kovan.infura.io/v3/\(Constants.Credentials.infuraKey)"
            case .ropsten: return "https://ropsten.infura.io/v3/\(Constants.Credentials.infuraKey)"
            case .rinkeby: return "https://rinkeby.infura.io/v3/\(Constants.Credentials.infuraKey)"
            case .poa: return "https://core.poa.network"
            case .sokol: return "https://sokol.poa.network"
            case .goerli: return "https://goerli.infura.io/v3/\(Constants.Credentials.infuraKey)"
            case .xDai: return "https://dai.poa.network"
            case .artis_sigma1: return "https://rpc.sigma1.artis.network"
            case .artis_tau1: return "https://rpc.tau1.artis.network"
            case .binance_smart_chain: return "https://bsc-dataseed1.binance.org:443"
            case .binance_smart_chain_testnet: return "https://data-seed-prebsc-1-s1.binance.org:8545"
            case .heco: return "https://http-mainnet.hecochain.com"
            case .heco_testnet: return "https://http-testnet.hecochain.com"
            case .custom(let custom): return custom.endpoint
            case .fantom: return "https://rpcapi.fantom.network"
            case .fantom_testnet: return "https://rpc.testnet.fantom.network/"
            case .avalanche: return "https://api.avax.network/ext/bc/C/rpc"
            case .avalanche_testnet: return "https://api.avax-test.network/ext/bc/C/rpc"
            case .polygon: return "https://rpc-mainnet.maticvigil.com/"
            case .mumbai_testnet: return "https://rpc-mumbai.maticvigil.com/"
            case .optimistic: return "https://mainnet.optimism.io"
            case .optimisticKovan: return "https://kovan.optimism.io"
            }
        }()
        return URL(string: urlString)!
    }

    var transactionInfoEndpoints: URL {
        let urlString: String = {
            switch self {
            case .main, .kovan, .ropsten, .rinkeby, .goerli, .classic, .poa, .xDai, .sokol, .artis_sigma1, .artis_tau1, .binance_smart_chain, .binance_smart_chain_testnet, .fantom, .polygon, .heco, .heco_testnet, .callisto, .optimistic, .optimisticKovan:
                return etherscanApiRoot.absoluteString
            case .custom: return "" // Enable? make optional
            case .fantom_testnet: return "https://explorer.testnet.fantom.network/tx/"
            case .avalanche: return "https://cchain.explorer.avax.network/tx/"
            case .avalanche_testnet: return "https://cchain.explorer.avax-test.network/tx/"
            case .mumbai_testnet: return "https://explorer-mumbai.maticvigil.com/tx/"
            }
        }()
        return URL(string: urlString)!
    }

    var ensRegistrarContract: AlphaWallet.Address {
        switch self {
        case .main: return Constants.ENSRegistrarAddress
        case .ropsten: return Constants.ENSRegistrarRopsten
        case .rinkeby: return Constants.ENSRegistrarRinkeby
        case .goerli: return Constants.ENSRegistrarGoerli
        case .xDai, .kovan, .poa, .sokol, .classic, .callisto, .artis_sigma1, .artis_tau1, .binance_smart_chain, .binance_smart_chain_testnet, .custom, .heco, .heco_testnet, .fantom, .fantom_testnet, .avalanche, .avalanche_testnet, .polygon, .mumbai_testnet, .optimistic, .optimisticKovan:
            return Constants.ENSRegistrarAddress
        }
    }

    var networkRequestsQueuePriority: Operation.QueuePriority {
        switch self {
        case .main, .xDai:
            return .normal
        case .kovan, .ropsten, .rinkeby, .poa, .sokol, .classic, .callisto, .goerli, .artis_sigma1, .artis_tau1, .binance_smart_chain, .binance_smart_chain_testnet, .custom, .heco, .heco_testnet, .fantom, .fantom_testnet, .avalanche, .avalanche_testnet, .polygon, .mumbai_testnet, .optimistic, .optimisticKovan:
            return .low
        }
    }

    var blockChainName: String {
        switch self {
        case .xDai:
            return R.string.localizable.blockchainXDAI()
        case .artis_sigma1:
            return R.string.localizable.blockchainARTISSigma1()
        case .artis_tau1:
            return R.string.localizable.blockchainARTISTau1()
        case .binance_smart_chain:
            return R.string.localizable.blockchainBinance()
        case .binance_smart_chain_testnet:
            return R.string.localizable.blockchainBinanceTest()
        case .heco:
            return R.string.localizable.blockchainHeco()
        case .heco_testnet:
            return R.string.localizable.blockchainHecoTest()
        case .main, .rinkeby, .ropsten, .custom, .callisto, .classic, .kovan, .sokol, .poa, .goerli:
            return R.string.localizable.blockchainEthereum()
        case .fantom:
            return R.string.localizable.blockchainFantom()
        case .fantom_testnet:
            return R.string.localizable.blockchainFantomTest()
        case .avalanche:
            return R.string.localizable.blockchainAvalanche()
        case .avalanche_testnet:
            return R.string.localizable.blockchainAvalancheTest()
        case .polygon:
            return R.string.localizable.blockchainPolygon()
        case .mumbai_testnet:
            return R.string.localizable.blockchainMumbai()
        case .optimistic:
            return R.string.localizable.blockchainOptimistic()
        case .optimisticKovan:
            return R.string.localizable.blockchainOptimisticKovan()
        }
    }

    var blockChainNameColor: UIColor {
        switch self {
        case .main: return .init(red: 41, green: 134, blue: 175)
        case .classic: return .init(red: 55, green: 137, blue: 55)
        case .callisto: return .init(red: 88, green: 56, blue: 163)
        case .kovan: return .init(red: 112, green: 87, blue: 141)
        case .ropsten, .custom: return .init(red: 255, green: 74, blue: 141)
        case .rinkeby: return .init(red: 246, green: 195, blue: 67)
        case .poa: return .init(red: 88, green: 56, blue: 163)
        case .sokol: return .init(red: 107, green: 53, blue: 162)
        case .goerli: return .init(red: 187, green: 174, blue: 154)
        case .xDai: return .init(red: 253, green: 176, blue: 61)
        case .artis_sigma1: return .init(red: 83, green: 162, blue: 113)
        case .artis_tau1: return .init(red: 255, green: 117, blue: 153)
        case .binance_smart_chain, .binance_smart_chain_testnet: return .init(red: 255, green: 211, blue: 0)
        case .heco, .heco_testnet: return .init(hex: "1253FC")
        case .fantom: return .red
        case .fantom_testnet: return .red
        case .avalanche: return .red
        case .avalanche_testnet: return .red
        case .polygon: return .red
        case .mumbai_testnet: return .red
        case .optimistic: return .red
        case .optimisticKovan: return .red
        }
    }

    var transactionDataCoordinatorType: SingleChainTransactionDataCoordinator.Type {
        switch self {
        case .main, .classic, .callisto, .kovan, .ropsten, .custom, .rinkeby, .poa, .sokol, .goerli, .xDai, .artis_sigma1, .binance_smart_chain, .binance_smart_chain_testnet, .artis_tau1, .heco, .heco_testnet, .fantom, .fantom_testnet, .avalanche, .avalanche_testnet, .polygon, .mumbai_testnet, .optimistic, .optimisticKovan:
            return SingleChainTransactionEtherscanDataCoordinator.self
        }
    }

    var iconImage: UIImage? {
        switch self {
        case .main:
            return R.image.eth()
        case .xDai:
            return R.image.xDai()
        case .poa:
            return R.image.tokenPoa()
        case  .classic:
            return R.image.tokenEtc()
        case .callisto:
            return R.image.tokenCallisto()
        case .artis_sigma1:
            return R.image.tokenArtis()
        case .binance_smart_chain:
            return R.image.tokenBnb()
        case .kovan, .ropsten, .rinkeby, .sokol, .goerli, .artis_tau1, .binance_smart_chain_testnet, .custom:
            return nil
        case .heco:
            return R.image.hthecoMainnet()
        case .heco_testnet:
            return R.image.hthecoTestnet()
        case .fantom, .fantom_testnet:
            return R.image.iconsTokensFantom()
        case .avalanche, .avalanche_testnet:
            return R.image.iconsTokensAvalanche()
        case .polygon:
            return R.image.iconsTokensPolygon()
        case .mumbai_testnet:
            return nil
        case .optimistic:
            return nil
        case .optimisticKovan:
            return nil
        }
    }

    init(name: String) {
        self = {
            switch name {
            case RPCServer.main.name: return .main
            case RPCServer.classic.name: return .classic
            case RPCServer.callisto.name: return .callisto
            case RPCServer.kovan.name: return .kovan
            case RPCServer.ropsten.name: return .ropsten
            case RPCServer.rinkeby.name: return .rinkeby
            case RPCServer.poa.name: return .poa
            case RPCServer.sokol.name: return .sokol
            case RPCServer.xDai.name: return .xDai
            case RPCServer.goerli.name: return .goerli
            case RPCServer.artis_sigma1.name: return .artis_sigma1
            case RPCServer.artis_tau1.name: return .artis_tau1
            case RPCServer.binance_smart_chain.name: return .binance_smart_chain
            case RPCServer.binance_smart_chain_testnet.name: return .binance_smart_chain_testnet
            case RPCServer.heco.name: return .heco
            case RPCServer.heco_testnet.name: return .heco_testnet
            case RPCServer.fantom.name: return .fantom
            case RPCServer.fantom_testnet.name: return .fantom_testnet
            case RPCServer.avalanche.name: return .avalanche
            case RPCServer.avalanche_testnet.name: return .avalanche_testnet
            case RPCServer.polygon.name: return .polygon
            case RPCServer.mumbai_testnet.name: return .mumbai_testnet
            case RPCServer.optimistic.name: return .optimistic
            case RPCServer.optimisticKovan.name: return .optimisticKovan
            default: return .main
            }
        }()
    }

    init(chainID: Int) {
        self = {
            switch chainID {
            case RPCServer.main.chainID: return .main
            case RPCServer.classic.chainID: return .classic
            case RPCServer.callisto.chainID: return .callisto
            case RPCServer.kovan.chainID: return .kovan
            case RPCServer.ropsten.chainID: return .ropsten
            case RPCServer.rinkeby.chainID: return .rinkeby
            case RPCServer.poa.chainID: return .poa
            case RPCServer.sokol.chainID: return .sokol
            case RPCServer.xDai.chainID: return .xDai
            case RPCServer.goerli.chainID: return .goerli
            case RPCServer.artis_sigma1.chainID: return .artis_sigma1
            case RPCServer.artis_tau1.chainID: return .artis_tau1
            case RPCServer.binance_smart_chain.chainID: return .binance_smart_chain
            case RPCServer.binance_smart_chain_testnet.chainID: return .binance_smart_chain_testnet
            case RPCServer.heco.chainID: return .heco
            case RPCServer.heco_testnet.chainID: return .heco_testnet
            case RPCServer.fantom.chainID: return .fantom
            case RPCServer.fantom_testnet.chainID: return .fantom_testnet
            case RPCServer.avalanche.chainID: return .avalanche
            case RPCServer.avalanche_testnet.chainID: return .avalanche_testnet
            case RPCServer.polygon.chainID: return .polygon
            case RPCServer.mumbai_testnet.chainID: return .mumbai_testnet
            case RPCServer.optimistic.chainID: return .optimistic
            case RPCServer.optimisticKovan.chainID: return .optimisticKovan
            default: return .main
            }
        }()
    }

    init?(withMagicLinkHost magicLinkHost: String) {
        var server: RPCServer? = {
            switch magicLinkHost {
            case RPCServer.main.magicLinkHost: return .main
            case RPCServer.classic.magicLinkHost: return .classic
            case RPCServer.callisto.magicLinkHost: return .callisto
            case RPCServer.kovan.magicLinkHost: return .kovan
            case RPCServer.ropsten.magicLinkHost: return .ropsten
            case RPCServer.rinkeby.magicLinkHost: return .rinkeby
            case RPCServer.poa.magicLinkHost: return .poa
            case RPCServer.sokol.magicLinkHost: return .sokol
            case RPCServer.xDai.magicLinkHost: return .xDai
            case RPCServer.goerli.magicLinkHost: return .goerli
            case RPCServer.artis_sigma1.magicLinkHost: return .artis_sigma1
            case RPCServer.artis_tau1.magicLinkHost: return .artis_tau1
            case RPCServer.binance_smart_chain.magicLinkHost: return .binance_smart_chain
            case RPCServer.binance_smart_chain_testnet.magicLinkHost: return .binance_smart_chain_testnet
            case RPCServer.heco.magicLinkHost: return .heco
            case RPCServer.heco_testnet.magicLinkHost: return .heco_testnet
            case RPCServer.fantom.magicLinkHost: return .fantom
            case RPCServer.fantom_testnet.magicLinkHost: return .fantom_testnet
            case RPCServer.avalanche.magicLinkHost: return .avalanche
            case RPCServer.avalanche_testnet.magicLinkHost: return .avalanche_testnet
            case RPCServer.polygon.magicLinkHost: return .polygon
            case RPCServer.mumbai_testnet.magicLinkHost: return .mumbai_testnet
            case RPCServer.optimistic.magicLinkHost: return .optimistic
            case RPCServer.optimisticKovan.magicLinkHost: return .optimisticKovan
            default: return nil
            }
        }()
        //Special case to support legacy host name
        if magicLinkHost == Constants.legacyMagicLinkHost {
            server = .main
        }
        guard let createdServer = server else { return nil }
        self = createdServer
    }

    init?(withMagicLink url: URL) {
        guard let host = url.host, let server = RPCServer(withMagicLinkHost: host) else { return nil }
        self = server
    }

    //We'll have to manually new cases here
    static var allCases: [RPCServer] {
        return [
            .main,
            .kovan,
            .ropsten,
            .rinkeby,
            .poa,
            .sokol,
            .classic,
            .xDai,
            .goerli,
            .artis_sigma1,
            .artis_tau1,
            .binance_smart_chain_testnet,
            .binance_smart_chain,
            .heco,
            .heco_testnet,
            .fantom,
            .fantom_testnet,
            .avalanche,
            .avalanche_testnet,
            .polygon,
            .callisto,
            .mumbai_testnet,
            .optimistic,
            .optimisticKovan,
        ]
    }
}
// swiftlint:enable type_body_length

extension RPCServer: Codable {
    private enum Keys: String, CodingKey {
        case chainId
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Keys.self)
        let chainId = try container.decode(Int.self, forKey: .chainId)
        self = .init(chainID: chainId)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Keys.self)
        try container.encode(chainID, forKey: .chainId)
    }
}

fileprivate extension URL {
    //Much better to use URLComponents, but this is much simpler for our use. This probably doesn't percent-escape probably, but we shouldn't need it for the URLs we access here
	func appendingQueryString(_ queryString: String) -> URL? {
        let urlString = absoluteString
        if urlString.contains("?") {
            return URL(string: "\(urlString)&\(queryString)")
        } else {
            return URL(string: "\(urlString)?\(queryString)")
        }
	}
}