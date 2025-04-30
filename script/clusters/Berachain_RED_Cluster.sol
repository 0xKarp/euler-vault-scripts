// SPDX-License-Identifier: GPL-2.0-or-later

pragma solidity ^0.8.0;

import {ManageClusterBase} from "evk-periphery-scripts/production/ManageClusterBase.s.sol";
import {OracleVerifier} from "evk-periphery-scripts/utils/SanityCheckOracle.s.sol";
import "./Addresses.s.sol";

contract Cluster is ManageClusterBase, AddressesBerachain {
    function defineCluster() internal override {
        // define the path to the cluster addresses file here
        cluster.clusterAddressesPath = "/script/clusters/Berachain_RED_Cluster.json";

        // after the cluster is deployed, do not change the order of the assets in the .assets array. if done, it must be 
        // reflected in other the other arrays the ltvs matrix. IMPORTANT: do not define more than one vault for the same asset
        cluster.assets = [
         WBERA, 
         HONEY, 
         iBGT
        ];
    }

    function configureCluster() internal override {
        // define the governors here
        cluster.oracleRoutersGovernor = 0xB672Ea44A1EC692A9Baf851dC90a1Ee3DB25F1C4;
        cluster.vaultsGovernor = 0xB672Ea44A1EC692A9Baf851dC90a1Ee3DB25F1C4;

        // define unit of account here
        cluster.unitOfAccount = USD;

        // define fee receiver here and interest fee here. 
        // if needed to be defined per asset, populate the feeReceiverOverride and interestFeeOverride mappings
        cluster.feeReceiver = 0x50dE2Fb5cd259c1b99DBD3Bb4E7Aac76BE7288fC;
        cluster.interestFee = 0.15e4;

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
        cluster.oracleProviders[WBERA    ] = "0xe6D9C66C0416C1c88Ca5F777D81a7F424D4Fa87b";
        cluster.oracleProviders[HONEY    ] = "0x997d72fb46690f304C7DB92df9AA823323fb23B2";
        cluster.oracleProviders[iBGT    ] = "0x16cE03d4d67fdA6727498eDbDE2e4FD0bF5e32D3";



        // define supply caps here. 0 means no supply can occur, type(uint256).max means no cap defined hence max amount
        cluster.supplyCaps[WBERA    ] = 1_000_000;
        cluster.supplyCaps[HONEY    ] = 5_000_000;
        cluster.supplyCaps[iBGT    ] = 500_000;

        // define borrow caps here. 0 means no borrow can occur, type(uint256).max means no cap defined hence max amount
        cluster.borrowCaps[WBERA    ] = 900_000;
        cluster.borrowCaps[HONEY    ] = 4_500_000;
        cluster.borrowCaps[iBGT    ] = type(uint256).max;

        // define IRM classes here and assign them to the assets. if asset is not meant to be borrowable, no IRM is needed.
        // to generate the IRM parameters, use the following command:
        // node lib/evk-periphery/script/utils/calculate-irm-linear-kink.js borrow <baseIr> <kinkIr> <maxIr> <kink>
        {
           // Base=0% APY  Kink(75%)=175.00% APY  Max=375.00% APY
            uint256[4] memory irmBERA  = [uint256(0), uint256(9951593935), uint256(16129845658), uint256(3221225472)];

            // Base=0% APY,  Kink(90%)=10.0% APY  Max=49.5% APY
            uint256[4] memory irmMinor = [uint256(0), uint256(781343251), uint256(22637222055), uint256(3865470566)];


            cluster.kinkIRMParams[WBERA    ] = irmBERA;
            cluster.kinkIRMParams[HONEY    ] = irmMinor;
        }

        // define the ramp duration to be used, in case the liquidation LTVs have to be ramped down
        cluster.rampDuration = 7 days;

        // define the spread between borrow and liquidation LTV
        cluster.spreadLTV = 0.02e4;
    
        // define liquidation LTV values here. columns are liability vaults, rows are collateral vaults
        cluster.ltvs = [
            //                  0                1        2      
            //                  WBERA            HONEY    iBGT 
            /* 0  WBERA     */ [uint16(0.000e4), 0.000e4, 0.000e4],
            /* 1  HONEY     */ [uint16(0.000e4), 0.000e4, 0.000e4],
            /* 1  iBGT      */ [uint16(0.800e4), 0.700e4, 0.000e4]
        ];
    }

    function postOperations() internal view override {
        // verify the oracle config for each vault
        for (uint256 i = 0; i < cluster.vaults.length; ++i) {
            OracleVerifier.verifyOracleConfig(lensAddresses.oracleLens, cluster.vaults[i], false);
        }
    }
}
