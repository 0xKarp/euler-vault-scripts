// SPDX-License-Identifier: GPL-2.0-or-later

pragma solidity ^0.8.0;

import {ManageClusterBase} from "evk-periphery-scripts/production/ManageClusterBase.s.sol";
import {OracleVerifier} from "evk-periphery-scripts/utils/SanityCheckOracle.s.sol";
import "./Addresses.s.sol";

contract Cluster is ManageClusterBase, AddressesBOB {
    function defineCluster() internal override {
        // define the path to the cluster addresses file here
        cluster.clusterAddressesPath = "/script/clusters/BOB_Cluster.json";

        // after the cluster is deployed, do not change the order of the assets in the .assets array. if done, it must be 
        // reflected in other the other arrays the ltvs matrix. IMPORTANT: do not define more than one vault for the same asset
        cluster.assets = [
         LBTC,
         WBTC,
         new_WBTC, 
         HybridBTC_pendle,
         satUSD,
         newsatUSD
        ];
    }

    function configureCluster() internal override {
        // define the governors here
        cluster.oracleRoutersGovernor = 0xF9686A9Eef4a771Ea7D209766A4165d59dAA6C20;
        cluster.vaultsGovernor = 0xF9686A9Eef4a771Ea7D209766A4165d59dAA6C20;

        // define unit of account here
        cluster.unitOfAccount = USD;

        // define fee receiver here and interest fee here. 
        // if needed to be defined per asset, populate the feeReceiverOverride and interestFeeOverride mappings
        cluster.feeReceiver = 0x50dE2Fb5cd259c1b99DBD3Bb4E7Aac76BE7288fC;
        cluster.interestFee = 0.20e4;

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
        cluster.oracleProviders[LBTC    ] = "0xEd29690A4d7f1b63807957fb71149A8dcfD820a4";
        cluster.oracleProviders[WBTC   ] = "0xF2b8616744502851343c52DA76e9adFb97f08b91";
        cluster.oracleProviders[new_WBTC   ] = "0x421B5623A02dE8B2E7A5F83279F12EB1fC81D19d";
        cluster.oracleProviders[HybridBTC_pendle    ] = "0x997d72fb46690f304C7DB92df9AA823323fb23B2";
        cluster.oracleProviders[satUSD    ] = "0x70F58c13047845e3febC0e96dd5e4724F8EA65BA";
        cluster.oracleProviders[newsatUSD    ] = "0x36398c15cCbE5Fa2874ffB07F12555f1e584b6FB";

      

        // define supply caps here. 0 means no supply can occur, type(uint256).max means no cap defined hence max amount
        cluster.supplyCaps[LBTC    ] = 1000;
        cluster.supplyCaps[WBTC    ] = 0;
        cluster.supplyCaps[new_WBTC    ] = 1000;
        cluster.supplyCaps[HybridBTC_pendle    ] = 1000;
        cluster.supplyCaps[satUSD    ] = 0;
        cluster.supplyCaps[newsatUSD    ] = 5_000_000;



        // define borrow caps here. 0 means no borrow can occur, type(uint256).max means no cap defined hence max amount
        cluster.borrowCaps[LBTC    ] = 900;
        cluster.borrowCaps[WBTC   ] = 0;
        cluster.borrowCaps[new_WBTC   ] = 900;
        cluster.borrowCaps[HybridBTC_pendle    ] = type(uint256).max;
        cluster.borrowCaps[satUSD    ] = type(uint256).max;
        cluster.borrowCaps[newsatUSD    ] = 4_000_000;


        // define IRM classes here and assign them to the assets. if asset is not meant to be borrowable, no IRM is needed.
        // to generate the IRM parameters, use the following command:
        // node lib/evk-periphery/script/utils/calculate-irm-linear-kink.js borrow <baseIr> <kinkIr> <maxIr> <kink>
        {
           // Base=0% APY  Kink(90%)=% APY  Max=700.00% APY
            uint256[4] memory irmStable  = [uint256(0), uint256(3865470566), uint256(554653471), uint256(36297125544)];

            // Base=0% APY,  Kink(90%)=3.5% APY  Max=75% APY
            uint256[4] memory irmBTC = [uint256(0), uint256(3865470566), uint256(282015934), uint256(38750863379)];


            cluster.kinkIRMParams[LBTC    ] = irmBTC;
            cluster.kinkIRMParams[WBTC    ] = irmBTC;
            cluster.kinkIRMParams[new_WBTC    ] = irmBTC;
            cluster.kinkIRMParams[newsatUSD    ] = irmStable;
        }

        // define the ramp duration to be used, in case the liquidation LTVs have to be ramped down
        cluster.rampDuration = 2 days;

        // define the spread between borrow and liquidation LTV
        cluster.spreadLTV = 0.02e4;
    
        // define liquidation LTV values here. columns are liability vaults, rows are collateral vaults
        cluster.ltvs = [
            //                  0                1        2        3        4        5          
            //                  LBTC             WBTC     newWBTC  Hybrid   satUSD  newsatUSD
            /* 0  LBTC     */ [uint16(0.000e4), 0.965e4, 0.965e4, 0.000e4, 0.000e4, 0.860e4],
            /* 1  WBTC     */ [uint16(0.000e4), 0.000e4, 0.000e4, 0.000e4, 0.000e4, 0.000e4],
            /* 2  newWBTC  */ [uint16(0.965e4), 0.000e4, 0.000e4, 0.000e4, 0.000e4, 0.860e4],
            /* 3  Hybrid   */ [uint16(0.915e4), 0.915e4, 0.915e4, 0.000e4, 0.000e4, 0.860e4],
            /* 4  satUSD   */ [uint16(0.000e4), 0.000e4, 0.000e4, 0.000e4, 0.000e4, 0.000e4],
            /* 5  newsatUSD*/ [uint16(0.000e4), 0.000e4, 0.000e4, 0.000e4, 0.000e4, 0.000e4]
        ];
    }

    function postOperations() internal view override {
        // verify the oracle config for each vault
        for (uint256 i = 0; i < cluster.vaults.length; ++i) {
            OracleVerifier.verifyOracleConfig(lensAddresses.oracleLens, cluster.vaults[i], false);
        }
    }
}
