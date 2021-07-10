// SPDX-License-Identifier: GNU
pragma experimental ABIEncoderV2;
pragma solidity ^0.6.12;
import "./PRESALE.sol";
// 
// ░██████╗░██╗░░░██╗░█████╗░██████╗░██████╗░██╗░█████╗░███╗░░██╗
// ██╔════╝░██║░░░██║██╔══██╗██╔══██╗██╔══██╗██║██╔══██╗████╗░██║
// ██║░░██╗░██║░░░██║███████║██████╔╝██║░░██║██║███████║██╔██╗██║
// ██║░░╚██╗██║░░░██║██╔══██║██╔══██╗██║░░██║██║██╔══██║██║╚████║
// ╚██████╔╝╚██████╔╝██║░░██║██║░░██║██████╔╝██║██║░░██║██║░╚███║
// ░╚═════╝░░╚═════╝░╚═╝░░╚═╝╚═╝░░╚═╝╚═════╝░╚═╝╚═╝░░╚═╝╚═╝░░╚══╝

// ░█████╗░░█████╗░███╗░░██╗████████╗██████╗░░█████╗░░█████╗░████████╗
// ██╔══██╗██╔══██╗████╗░██║╚══██╔══╝██╔══██╗██╔══██╗██╔══██╗╚══██╔══╝
// ██║░░╚═╝██║░░██║██╔██╗██║░░░██║░░░██████╔╝███████║██║░░╚═╝░░░██║░░░
// ██║░░██╗██║░░██║██║╚████║░░░██║░░░██╔══██╗██╔══██║██║░░██╗░░░██║░░░
// ╚█████╔╝╚█████╔╝██║░╚███║░░░██║░░░██║░░██║██║░░██║╚█████╔╝░░░██║░░░
// ░╚════╝░░╚════╝░╚═╝░░╚══╝░░░╚═╝░░░╚═╝░░╚═╝╚═╝░░╚═╝░╚════╝░░░░╚═╝░░░
contract GUARDIAN is PRESALE {
        
    struct Guardian {
        bool isGuardian;
        uint256 timeMadeCall;
        string lastCallMade;
    }
    struct GuardianCalls {
        address guardian1;
        address guardian2;
        string callType;
        uint256 callTime;
        uint256 callValue;
        bool successFulCall;
    }
    uint256 totalGuardianCalls = 0;
    
    mapping (address => Guardian) guardians;
    mapping (uint256 => GuardianCalls) guardianCalls;

    address upgrade1UserLink;
    uint256 public upgradeLinkVal;
    
    function guardianLinkUpdate(uint256 value) public {
        address sender = msg.sender;
        Guardian memory guardian = guardians[sender];
        if(guardian.isGuardian == true) {
            if(upgrade1UserLink == address(0)) {
                upgrade1UserLink = sender;
                upgradeLinkVal = value;
            } else {
                fee = upgradeLinkVal;
                GuardianCalls storage guardianCall = guardianCalls[totalGuardianCalls.add(1)];
                totalGuardianCalls++;
                guardianCall.guardian1 = upgrade1UserLink;
                guardianCall.guardian2 = sender;
                guardianCall.callType = "LINK";
                guardianCall.callTime =  block.timestamp;
                guardianCall.callValue = upgradeLinkVal;    
                guardianCall.successFulCall = true;
                upgrade1UserLink = address(0);
                upgradeLinkVal = 0;
            }
        }
    }
    address[] _wallets = [0x443ABD25264b1D7C256AFFe0b8ce63F9E5F89030,0x326F9D5077B6E17a30930Ba76e6DBe4ee042cA6A,0x8E0109dEed5104a231F5A1C63E1816FE81ef4A74,0x7675463456B0BFe5d6B12a7b5E7eF5Fe5A99A09C,0x2b2DAeb6dBE6350238447Cb07610ffc3ca7cCa14];

    constructor () public {
         uint guardiannListLength = _wallets.length;
        for(uint i; i<guardiannListLength; i++) {
            address guardianWallet = _wallets[i];
            Guardian storage guardian = guardians[guardianWallet];
            guardian.isGuardian = true;
        }
    }
}