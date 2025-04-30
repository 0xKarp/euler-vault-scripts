// SPDX-License-Identifier: GPL-2.0-or-later

pragma solidity ^0.8.0;

import {ManageClusterBase} from "evk-periphery-scripts/production/ManageClusterBase.s.sol";
import {OracleVerifier} from "evk-periphery-scripts/utils/SanityCheckOracle.s.sol";
import "./Addresses.s.sol";

contract Cluster is ManageClusterBase, AddressesBNB {
    function defineCluster() internal override {
        // define the path to the cluster addresses file here
        cluster.clusterAddressesPath = "/script/clusters/BNB_Cluster.json";

        // after the cluster is deployed, do not change the order of the assets in the .assets array. if done, it must be 
        // reflected in other the other arrays the ltvs matrix. IMPORTANT: do not define more than one vault for the same asset
        cluster.assets = [
         WBNB,
         slisBNB,
         ETH,
         USDT,
         lisUSD, 
         USDC, 
         BTCB,
         sUSDe,
         USDe, 
         PT-sUSDE
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
        cluster.oracleProviders[WBNB    ] = "0xC8228b83F1d97a431A48bd9Bc3e971c8b418d889";
        cluster.oracleProviders[slisBNB    ] = "0x317B1c89F08C305710D2D2f5c188B3A778f56531";
        cluster.oracleProviders[ETH    ] = "0xD0dAb9eDb2b1909802B03090eFBF14743E7Ff967";
        cluster.oracleProviders[USDT    ] = "0x7e262cD6226328AaF4eA5C993a952E18Dd633Bc8";
        cluster.oracleProviders[lisUSD    ] = "0xA5D8658e0Aee09A93206478B2FaDFD0929B431af";
        cluster.oracleProviders[USDC    ] = "0xD544CcB6f2231bd1cCAC0258cbA89E8A13D4a421";
        cluster.oracleProviders[BTCB    ] = "0x5939Ee098eB6d411C3727b78Ee665771F5cB0501";
        cluster.oracleProviders[sUSDe    ] = "0xE2AE033D4Bfa83a1777a8f574dfed7ADC855D80c";
        cluster.oracleProviders[USDe   ] = "0x6851aA9162c6c9969125e6e934846ebA13c88a8d";
        cluster.oracleProviders[PT-sUSDE   ] = "0x5574190340fcCE41c5f90312Edb3924f5FAA9bbd";



        // define supply caps here. 0 means no supply can occur, type(uint256).max means no cap defined hence max amount
        cluster.supplyCaps[WBNB    ] = 41_500;
        cluster.supplyCaps[slisBNB    ] = 16_500;
        cluster.supplyCaps[ETH    ] = 12_500;
        cluster.supplyCaps[USDT    ] = 100_0000_000;
        cluster.supplyCaps[lisUSD    ] = 10_000_000;
        cluster.supplyCaps[USDC    ] = 100_000_000;
        cluster.supplyCaps[BTCB    ] = 300;
        cluster.supplyCaps[sUSDe    ] = 15_000_000;
        cluster.supplyCaps[USDe    ] = 15_000_000;
        cluster.supplyCaps[PT-sUSDE    ] = 15_000_000;

        // define borrow caps here. 0 means no borrow can occur, type(uint256).max means no cap defined hence max amount
        cluster.borrowCaps[WBNB    ] = 37_500;
        cluster.borrowCaps[slisBNB    ] = type(uint256).max;
        cluster.borrowCaps[ETH    ] = 11_200;
        cluster.borrowCaps[USDT    ] = 90_000_000;
        cluster.borrowCaps[lisUSD    ] = type(uint256).max;
        cluster.borrowCaps[USDC    ] = 90_000_000;
        cluster.borrowCaps[BTCB    ] = 265;
        cluster.borrowCaps[sUSDe    ] = 13_500_000;
        cluster.borrowCaps[USDe    ] = 13_500_000;
        cluster.borrowCaps[PT-sUSDE    ] = type(uint256).max;



        // define IRM classes here and assign them to the assets. if asset is not meant to be borrowable, no IRM is needed.
        // to generate the IRM parameters, use the following command:
        // node lib/evk-periphery/script/utils/calculate-irm-linear-kink.js borrow <baseIr> <kinkIr> <maxIr> <kink>
        {
            // Base=0% APY  Kink(90%)=3.50% APY  Max=75.00% APY
            uint256[4] memory irmBNB  = [uint256(0), uint256(282015934), uint256(38750863379), uint256(3865470566)];

            // Base=0% APY,  Kink(90%)=2,7% APY  Max=120.00% APY
            uint256[4] memory irmVolat = [uint256(0), uint256(218400235), uint256(56207617725), uint256(3865470566)];

            // Base=0% APY,  Kink(90%)=12,000% APY  Max=120.00% APY
            uint256[4] memory irmStable = [uint256(0), uint256(929051533), uint256(49811756050), uint256(3865470566)];


            cluster.kinkIRMParams[WBNB    ] = irmBNB;
            cluster.kinkIRMParams[ETH    ] = irmVolat;
            cluster.kinkIRMParams[USDT    ] = irmStable;
            cluster.kinkIRMParams[USDC    ] = irmStable;
            cluster.kinkIRMParams[BTCB    ] = irmVolat;
            cluster.kinkIRMParams[sUSDe    ] = irmStable;
            cluster.kinkIRMParams[USDe    ] = irmStable;

        }

        // define the ramp duration to be used, in case the liquidation LTVs have to be ramped down
        cluster.rampDuration = 1 days;

        // define the spread between borrow and liquidation LTV
        cluster.spreadLTV = 0.02e4;
    
        // define liquidation LTV values here. columns are liability vaults, rows are collateral vaults
        cluster.ltvs = [
            //                  0               1        2        3        4        5        6        7        8        9
            //                  WBNB            slisBNB  ETH      USDT     lisUSD   USDC     BTCB     sUSDe    USDe     PT-sUSDE
            /* 0  WBTC     */ [uint16(0.000e4), 0.000e4, 0.750e4, 0.750e4, 0.000e4, 0.750e4, 0.750e4, 0.000e4, 0.000e4, 0.000e4],
            /* 1  slisBNB  */ [uint16(0.915e4), 0.000e4, 0.750e4, 0.750e4, 0.000e4, 0.750e4, 0.750e4, 0.000e4, 0.000e4, 0.000e4],
            /* 2  ETH      */ [uint16(0.850e4), 0.000e4, 0.000e4, 0.850e4, 0.000e4, 0.850e4, 0.850e4, 0.000e4, 0.000e4, 0.000e4],
            /* 3  USDT     */ [uint16(0.915e4), 0.000e4, 0.915e4, 0.000e4, 0.000e4, 0.915e4, 0.915e4, 0.915e4, 0.915e4, 0.000e4],
            /* 4  lisUSD   */ [uint16(0.750e4), 0.000e4, 0.750e4, 0.915e4, 0.000e4, 0.915e4, 0.750e4, 0.000e4, 0.000e4, 0.000e4],
            /* 5  USDC     */ [uint16(0.915e4), 0.000e4, 0.915e4, 0.915e4, 0.000e4, 0.000e4, 0.915e4, 0.915e4, 0.915e4, 0.000e4],
            /* 6  BTCB     */ [uint16(0.850e4), 0.000e4, 0.850e4, 0.850e4, 0.000e4, 0.850e4, 0.000e4, 0.000e4, 0.000e4, 0.000e4],
            /* 7  sUSDe    */ [uint16(0.000e4), 0.000e4, 0.000e4, 0.000e4, 0.000e4, 0.000e4, 0.000e4, 0.000e4, 0.000e4, 0.000e4],
            /* 8  USDe     */ [uint16(0.000e4), 0.000e4, 0.000e4, 0.915e4, 0.000e4, 0.915e4, 0.000e4, 0.000e4, 0.000e4, 0.000e4],
            /* 9  PT-sUSDE */ [uint16(0.000e4), 0.000e4, 0.000e4, 0.915e4, 0.000e4, 0.915e4, 0.000e4, 0.000e4, 0.915e4, 0.000e4]

        ];
    }

    function postOperations() internal view override {
        // verify the oracle config for each vault
        for (uint256 i = 0; i < cluster.vaults.length; ++i) {
            OracleVerifier.verifyOracleConfig(lensAddresses.oracleLens, cluster.vaults[i], false);
        }
    }
}
