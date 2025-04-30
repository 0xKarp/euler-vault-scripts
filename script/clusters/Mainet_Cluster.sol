// SPDX-License-Identifier: GPL-2.0-or-later

pragma solidity ^0.8.0;

import {ManageClusterBase} from "evk-periphery-scripts/production/ManageClusterBase.s.sol";
import {OracleVerifier} from "evk-periphery-scripts/utils/SanityCheckOracle.s.sol";
import "./Addresses.s.sol";

contract Cluster is ManageClusterBase, AddressesEthereum {
    function defineCluster() internal override {
        // define the path to the cluster addresses file here
        cluster.clusterAddressesPath = "/script/clusters/Cluster.json";

        // after the cluster is deployed, do not change the order of the assets in the .assets array. if done, it must be 
        // reflected in other the other arrays the ltvs matrix. IMPORTANT: do not define more than one vault for the same asset
        cluster.assets = [
            WETH, 
            ezETH,
            PZETH,
            inwstETHs,
            wstETH,
            cbETH,
            RETH,
            WOETH, 
            ETH+,
            WEETH, 
            rsETH,
            amphrETH,
            STEAKLRT
        ];
    }

    function configureCluster() internal override {
        // define the governors here
        cluster.oracleRoutersGovernor = getDeployer();
        cluster.vaultsGovernor = getDeployer();

        // define unit of account here
        cluster.unitOfAccount = USD;

        // define fee receiver here and interest fee here. 
        // if needed to be defined per asset, populate the feeReceiverOverride and interestFeeOverride mappings
        cluster.feeReceiver = address(0);
        cluster.interestFee = 0.1e4;

        // define max liquidation discount here. 
        // if needed to be defined per asset, populate the maxLiquidationDiscountOverride mapping
        cluster.maxLiquidationDiscount = 0.15e4;

        // define liquidation cool off time here. 
        // if needed to be defined per asset, populate the liquidationCoolOffTimeOverride mapping
        cluster.liquidationCoolOffTime = 1;

        // define hook target and hooked ops here. 
        // if needed to be defined per asset, populate the hookTargetOverride and hookedOpsOverride mappings
        cluster.hookTarget = address(0);
        cluster.hookedOps = 0;

        // define config flags here. if needed to be defined per asset, populate the configFlagsOverride mapping
        cluster.configFlags = 0;

        // define oracle providers here. 
        // in case the asset is an ERC4626 vault itself (i.e. sUSDS) and the convertToAssets function is meant to be used 
        // for pricing, the string should be preceeded by "ExternalVault|" prefix. this is in order to correctly resolve 
        // the asset (vault) in the oracle router. 
        // refer to https://oracles.euler.finance/ for the list of available oracle adapters
        cluster.oracleProviders[WETH ] = "0x10674C8C1aE2072d4a75FE83f1E159425fd84E1D";
        cluster.oracleProviders[ezETH ] = "0x0F239a09D9B4f048d2EfE36a4204692F8DF5B564";
        cluster.oracleProviders[PZETH ] = "0x0E45B0bc6D05872E355cca26f14ec5519E302db6";
        cluster.oracleProviders[inwstETHs ] = "";
        cluster.oracleProviders[wstETH ] = "0x02dd5B7ab536629d2235276aBCDf8eb3Af9528D7";
        cluster.oracleProviders[cbETH ] = "0x8710019824E557F907Fb0B8BD23d610d74dD7444";
        cluster.oracleProviders[RETH ] = "0xeb3Ed6A68C69659BfF24A4b996644aaCba68c4ec";
        cluster.oracleProviders[WOETH ] = ETH -> "0xC499881FCc94d6755532e2C80b474858a564D637";
        cluster.oracleProviders[ETH+ ] = "0x9c32824d98DBdBDC1c0C47f849E232DF3c5c66ec";
        cluster.oracleProviders[WEETH ] = "0x175b1A1347F207AA0529430012385A14C46D9638";
        cluster.oracleProviders[rsETH ] = "0xd9274249FD71413342F75168c476CC357B17A3A1";
        cluster.oracleProviders[amphrETH ] = ETH -> "0x517Cb608a08875FF60407F0209a87e093955A6C6";
        cluster.oracleProviders[STEAKLRT ] = ETH -> "0xc09B45b31b7DD7B7bEcb348f1Df192C6948986B9";


        // define supply caps here. 0 means no supply can occur, type(uint256).max means no cap defined hence max amount
        cluster.supplyCaps[WETH ] = 10_000;

        // define borrow caps here. 0 means no borrow can occur, type(uint256).max means no cap defined hence max amount
        cluster.borrowCaps[WETH ] = 9_000;
        // define IRM classes here and assign them to the assets. if asset is not meant to be borrowable, no IRM is needed.
        // to generate the IRM parameters, use the following command:
        // node lib/evk-periphery/script/utils/calculate-irm-linear-kink.js borrow <baseIr> <kinkIr> <maxIr> <kink>
        {
            // Base=0% APY  Kink(90%)=2.40% APY  Max=80.00% APY
            uint256[4] memory irmETH = [uint256(0), uint256(194425692),  uint256(41617711740), uint256(3865470566)];

            // Base=0% APY,  Kink(90%)=5.00% APY  Max=80.00% APY
            uint256[4] memory irmUSD = [uint256(0), uint256(399976852),  uint256(39767751304), uint256(3865470566)];

            cluster.kinkIRMParams[WETH ] = irmETH;
            cluster.kinkIRMParams[rsETH ] = irmUSD;
            cluster.kinkIRMParams[USDT ] = irmUSD;
        }

        // define the ramp duration to be used, in case the liquidation LTVs have to be ramped down
        cluster.rampDuration = 1 days;

        // define the spread between borrow and liquidation LTV
        cluster.spreadLTV = 0.02e4;
    
        // define liquidation LTV values here. columns are liability vaults, rows are collateral vaults
        cluster.ltvs = [
        //                0               1       2       3
        //                WETH            USDC    USDT    sUSDS
        /* 0  WETH    */ [uint16(0.00e4), 0.85e4, 0.85e4, 0.00e4],
        /* 1  USDC    */ [uint16(0.87e4), 0.00e4, 0.95e4, 0.00e4],
        /* 2  USDT    */ [uint16(0.87e4), 0.95e4, 0.00e4, 0.00e4],
        /* 3  sUSDS   */ [uint16(0.87e4), 0.95e4, 0.95e4, 0.00e4]
        ];
    }

    function postOperations() internal view override {
        // verify the oracle config for each vault
        for (uint256 i = 0; i < cluster.vaults.length; ++i) {
            OracleVerifier.verifyOracleConfig(lensAddresses.oracleLens, cluster.vaults[i], false);
        }
    }
}
