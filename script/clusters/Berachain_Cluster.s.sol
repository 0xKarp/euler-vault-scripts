// SPDX-License-Identifier: GPL-2.0-or-later

pragma solidity ^0.8.0;

import {ManageClusterBase} from "evk-periphery-scripts/production/ManageClusterBase.s.sol";
import {OracleVerifier} from "evk-periphery-scripts/utils/SanityCheckOracle.s.sol";
import "./Addresses.s.sol";

contract Cluster is ManageClusterBase, AddressesBerachain {
    function defineCluster() internal override {
        // define the path to the cluster addresses file here
        cluster.clusterAddressesPath = "/script/clusters/Berachain_Cluster.json";

        // after the cluster is deployed, do not change the order of the assets in the .assets array. if done, it must be 
        // reflected in other the other arrays the ltvs matrix. IMPORTANT: do not define more than one vault for the same asset
        cluster.assets = [
         WBERA,
         WETH,
         WBTC,
         HONEY, 
         USDC, 
         STONE, 
         BYUSD, 
         NECT, 
         beraETH, 
         USDe, 
         sUSDe, 
         rUSD, 
         srUSD, 
         PT_sUSDE, 
         iBERA
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
        cluster.oracleProviders[WETH     ] = "0xf7129a6280DCFfF6149792186b54C818ea4D80D6";
        cluster.oracleProviders[WBTC     ] = "0xF2b8616744502851343c52DA76e9adFb97f08b91";
        cluster.oracleProviders[HONEY    ] = "0x997d72fb46690f304C7DB92df9AA823323fb23B2";
        cluster.oracleProviders[USDC     ] = "0x5ad9C6117ceB1981CfCB89BEb6Bd29c9157aB5b3";
        cluster.oracleProviders[STONE    ] = "0x255Bee201D2526BBf2753DF6A6057f23431A3E1C";
        cluster.oracleProviders[BYUSD    ] = "0xe5908cbd7b3bc2648b32ce3dc8dfad4d83afd1b4";
        cluster.oracleProviders[NECT    ] = "0xA5D8658e0Aee09A93206478B2FaDFD0929B431af";
        cluster.oracleProviders[beraETH    ] = "0x8582eF5CE2D82Bfa0779ee0d49a849b8f4070CAf";
        cluster.oracleProviders[USDe    ] = "0x7e940d9618753f2Cb816C14b05e5Da969A617490";
        cluster.oracleProviders[sUSDe    ] = "0xFC8a6E73DBCBAb3456E024ddeab59e095792D2eD";
        cluster.oracleProviders[rUSD    ] = "0x617889fED99d725831305d13b86Ecc110D772822";
        cluster.oracleProviders[srUSD    ] = "0xe8a784f4BdCd4707BAF4068e72887888Ad58c033";
        cluster.oracleProviders[PT_sUSDE    ] = "0x4417B07Fad263751775e334458Cb8F16A5971893";
        cluster.oracleProviders[iBERA    ] = "0xD5fD501C97564f1003C436525A0CED2fB96867b1";

        // define supply caps here. 0 means no supply can occur, type(uint256).max means no cap defined hence max amount
        cluster.supplyCaps[WBERA    ] = 5_000_000;
        cluster.supplyCaps[WETH     ] = 10_000;
        cluster.supplyCaps[WBTC     ] = 300;
        cluster.supplyCaps[HONEY    ] = 100_000_000;
        cluster.supplyCaps[USDC     ] = 100_000_000;
        cluster.supplyCaps[STONE    ] = 10_000;
        cluster.supplyCaps[BYUSD    ] = 100_000_000;
        cluster.supplyCaps[NECT    ] = 2_000_000;
        cluster.supplyCaps[beraETH    ] = 10_000;
        cluster.supplyCaps[USDe    ] = 50_000_000;
        cluster.supplyCaps[sUSDe    ] = 50_000_000;
        cluster.supplyCaps[rUSD    ] = 25_000_000;
        cluster.supplyCaps[srUSD    ] = 25_000_000;
        cluster.supplyCaps[PT_sUSDE    ] = 25_000_000;
        cluster.supplyCaps[iBERA    ] = 500_000;

        // define borrow caps here. 0 means no borrow can occur, type(uint256).max means no cap defined hence max amount
        cluster.borrowCaps[WBERA    ] = 4_500_000;
        cluster.borrowCaps[WETH     ] = 9_200;
        cluster.borrowCaps[WBTC     ] = 276;
        cluster.borrowCaps[HONEY    ] = 92_000_000;
        cluster.borrowCaps[USDC     ] = 92_000_000;
        cluster.borrowCaps[STONE    ] = 9_200;
        cluster.borrowCaps[BYUSD    ] = 92_000_000;
        cluster.borrowCaps[NECT    ] = type(uint256).max;
        cluster.borrowCaps[beraETH    ] = type(uint256).max;
        cluster.borrowCaps[USDe    ] = 4_000_000;
        cluster.borrowCaps[sUSDe    ] = type(uint256).max;
        cluster.borrowCaps[rUSD    ] = 22_500_000;
        cluster.borrowCaps[srUSD    ] = type(uint256).max;
        cluster.borrowCaps[PT_sUSDE    ] = type(uint256).max;
        cluster.borrowCaps[iBERA    ] = type(uint256).max;

        // define IRM classes here and assign them to the assets. if asset is not meant to be borrowable, no IRM is needed.
        // to generate the IRM parameters, use the following command:
        // node lib/evk-periphery/script/utils/calculate-irm-linear-kink.js borrow <baseIr> <kinkIr> <maxIr> <kink>
        {
            // Base=0% APY  Kink(75%)=175.00% APY  Max=375.00% APY
            uint256[4] memory irmBERA  = [uint256(0), uint256(9951593935), uint256(16129845658), uint256(3221225472)];

            // Base=0% APY,  Kink(90%)=3.00% APY  Max=150.00% APY
            uint256[4] memory irmMajor = [uint256(0), uint256(242320082), uint256(65424051595), uint256(3865470566)];

            // Base=0% APY,  Kink(90%)=10.0% APY  Max=49.5% APY
            uint256[4] memory irmMinor = [uint256(0), uint256(929051533), uint256(21554187388), uint256(3865470566)];

            // Base=0% APY,  Kink(90%)=10.0% APY  Max=85% APY
            uint256[4] memory irmStable = [uint256(0), uint256(781341783), uint256(38356946119), uint256(3865470566)];


            cluster.kinkIRMParams[WBERA    ] = irmBERA;
            cluster.kinkIRMParams[WETH     ] = irmMajor;
            cluster.kinkIRMParams[WBTC     ] = irmMajor;
            cluster.kinkIRMParams[HONEY    ] = irmStable;
            cluster.kinkIRMParams[USDC     ] = irmStable;
            cluster.kinkIRMParams[STONE    ] = irmMajor;
            cluster.kinkIRMParams[BYUSD    ] = irmStable;
            cluster.kinkIRMParams[USDe    ] = irmStable;
            cluster.kinkIRMParams[rUSD    ] = irmStable;
        }

        // define the ramp duration to be used, in case the liquidation LTVs have to be ramped down
        cluster.rampDuration = 28 days;

        // define the spread between borrow and liquidation LTV
        cluster.spreadLTV = 0.02e4;
    
        // define liquidation LTV values here. columns are liability vaults, rows are collateral vaults
        cluster.ltvs = [
            //                  0                1        2        3        4        5        6        7        8        9        10       11       12       13       14
            //                  WBERA            WETH     WBTC     HONEY    USDC     STONE    BYUSD    NECT     beraETH  USDe     sUSDe    rUSD     srUSD    PT_sUSDE iBERA
            /* 0  WBERA     */ [uint16(0.000e4), 0.700e4, 0.700e4, 0.700e4, 0.700e4, 0.700e4, 0.700e4, 0.000e4, 0.700e4, 0.700e4, 0.000e4, 0.000e4, 0.000e4, 0.000e4, 0.000e4],
            /* 1  WETH      */ [uint16(0.800e4), 0.000e4, 0.850e4, 0.780e4, 0.780e4, 0.915e4, 0.780e4, 0.000e4, 0.915e4, 0.780e4, 0.000e4, 0.000e4, 0.000e4, 0.000e4, 0.000e4],
            /* 2  WBTC      */ [uint16(0.800e4), 0.850e4, 0.000e4, 0.780e4, 0.780e4, 0.800e4, 0.780e4, 0.000e4, 0.800e4, 0.780e4, 0.000e4, 0.000e4, 0.000e4, 0.000e4, 0.000e4],
            /* 3  HONEY     */ [uint16(0.915e4), 0.800e4, 0.800e4, 0.000e4, 0.965e4, 0.800e4, 0.965e4, 0.000e4, 0.800e4, 0.915e4, 0.000e4, 0.000e4, 0.000e4, 0.000e4, 0.000e4],
            /* 4  USDC      */ [uint16(0.915e4), 0.800e4, 0.800e4, 0.965e4, 0.000e4, 0.800e4, 0.965e4, 0.000e4, 0.800e4, 0.915e4, 0.000e4, 0.000e4, 0.000e4, 0.000e4, 0.000e4],
            /* 5  STONE     */ [uint16(0.800e4), 0.850e4, 0.850e4, 0.780e4, 0.780e4, 0.000e4, 0.780e4, 0.000e4, 0.000e4, 0.000e4, 0.000e4, 0.000e4, 0.000e4, 0.000e4, 0.000e4],
            /* 6  BYUSD     */ [uint16(0.915e4), 0.800e4, 0.800e4, 0.000e4, 0.000e4, 0.800e4, 0.000e4, 0.000e4, 0.800e4, 0.915e4, 0.000e4, 0.000e4, 0.000e4, 0.000e4, 0.000e4],
            /* 7  NECT      */ [uint16(0.915e4), 0.000e4, 0.000e4, 0.915e4, 0.915e4, 0.000e4, 0.915e4, 0.000e4, 0.000e4, 0.915e4, 0.000e4, 0.000e4, 0.000e4, 0.000e4, 0.000e4],
            /* 8  beraETH   */ [uint16(0.800e4), 0.000e4, 0.850e4, 0.780e4, 0.780e4, 0.915e4, 0.780e4, 0.000e4, 0.000e4, 0.780e4, 0.000e4, 0.000e4, 0.000e4, 0.000e4, 0.000e4],
            /* 9  USDe      */ [uint16(0.915e4), 0.800e4, 0.800e4, 0.915e4, 0.915e4, 0.800e4, 0.915e4, 0.000e4, 0.800e4, 0.000e4, 0.000e4, 0.000e4, 0.000e4, 0.000e4, 0.000e4],
            /* 10 sUSDe     */ [uint16(0.915e4), 0.800e4, 0.800e4, 0.915e4, 0.915e4, 0.000e4, 0.915e4, 0.000e4, 0.000e4, 0.915e4, 0.000e4, 0.000e4, 0.000e4, 0.000e4, 0.000e4],
            /* 11 rUSD      */ [uint16(0.915e4), 0.800e4, 0.800e4, 0.915e4, 0.915e4, 0.800e4, 0.915e4, 0.000e4, 0.800e4, 0.915e4, 0.000e4, 0.000e4, 0.000e4, 0.000e4, 0.000e4],
            /* 12 srUSD     */ [uint16(0.000e4), 0.000e4, 0.000e4, 0.915e4, 0.915e4, 0.000e4, 0.915e4, 0.000e4, 0.000e4, 0.915e4, 0.000e4, 0.950e4, 0.000e4, 0.000e4, 0.000e4],
            /* 13 PT_sUSDE  */ [uint16(0.915e4), 0.800e4, 0.800e4, 0.915e4, 0.915e4, 0.800e4, 0.915e4, 0.000e4, 0.800e4, 0.915e4, 0.000e4, 0.000e4, 0.000e4, 0.000e4, 0.000e4],
            /* 14 iBERA     */ [uint16(0.800e4), 0.675e4, 0.675e4, 0.700e4, 0.700e4, 0.675e4, 0.700e4, 0.000e4, 0.675e4, 0.700e4, 0.000e4, 0.000e4, 0.000e4, 0.000e4, 0.000e4]
        ];
    }

    function postOperations() internal view override {
        // verify the oracle config for each vault
        for (uint256 i = 0; i < cluster.vaults.length; ++i) {
            OracleVerifier.verifyOracleConfig(lensAddresses.oracleLens, cluster.vaults[i], false);
        }
    }
}
