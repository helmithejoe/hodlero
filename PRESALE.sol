///////////////////////////////////////////////////////////////////////       
//  /\  _`\ /\  _`\ /\  _`\ /\  _`\ /\  _  \/\ \     /\  _`\    ///////
// \ \ \L\ \ \ \L\ \ \ \L\_\ \,\L\_\ \ \L\ \ \ \    \ \ \L\_\   ///////
//  \ \ ,__/\ \ ,  /\ \  _\L\/_\__ \\ \  __ \ \ \  __\ \  _\L   ///////
//   \ \ \/  \ \ \\ \\ \ \L\ \/\ \L\ \ \ \/\ \ \ \L\ \\ \ \L\ \ ///////
//    \ \_\   \ \_\ \_\ \____/\ `\____\ \_\ \_\ \____/ \ \____/ ///////
//     \/_/    \/_/\/ /\/___/  \/_____/\/_/\/_/\/___/   \/___/  ///////
//////////////////////////D.A.N.I.E.L.M////////////////////////////////
pragma experimental ABIEncoderV2;
pragma solidity ^0.6.12;
// SPDX-License-Identifier: Unlicensed
import {Address} from "./Address.sol";
import {HODLERO} from "./HODLERO.sol";


contract PRESALE is HODLERO {
    using Address for address;
    
    address _owner;
    
    // structs
    struct PresaleWallet {
       uint256 amountTokensBought;
       uint256 amountBNBPaid;
       uint256 amountRefunded;
       uint256 amountClaimed;
       bool whitelisted;
       bool claimed; //can only claim once
       bool refunded; //can only refund once
    }
    struct Receipt {
        address wallet;
        uint256 paidBNB;
        uint256 tokensPurchased;
        uint256 blocknumber;
        uint256 timestamp;
    }
    
    mapping (address => PresaleWallet) presaleWallets;
    mapping (uint => Receipt) receipts;
    
    event presalePurchase(address wallet, uint256 tokensBought, uint256 bnbPaid);
    event presaleRefund(address wallet, uint256 bnbRefunded);
    event presaleCompleteMaxCap(uint256 bnbRaised, uint256 tokensSold);
    event presaleCompleteMinCap(uint256 bnbRaised, uint256 tokensSold);
    
    event presaleFinalized(uint256 bnbRaised, uint256 tokensSold, uint256 tokensBurned,uint256 tokensSentToPancakeSwap, uint256 amountBNB, uint256 amountSentToOwnerWallet, uint256 amountTokens);
    //////////PRESALE CONFIGURATIONS////////
    
    //////////PRESALE CONFIGURATIONS////////
    uint tokenPercentToSell = 94;
    uint allocatedPercentForPancakeSwap = 34; //how much of the tokenPercentToSell to allocate to pancakeswap after presale.
    uint allocatedPercentForPresale = tokenPercentToSell.sub(allocatedPercentForPancakeSwap); //
    //livenet
    uint256 mincap = 200;
    uint256 maxcap = 1000;
    //testnet
    // uint256 mincap = 1;
    // uint256 maxcap = 2;
    
    uint256 minbuy = 1000000000000000; //0.01 eth
    uint256 maxbuy = 10 * 10**18; //10.00 eth
    // //LIVENET //
    uint256 mincapFullBnb = 200 * 10**18;
    uint256 maxcapFullBnb = 1000 * 10**18;
    ////testnet
    // uint256 mincapFullBnb = 1 * 10**17; //0.1
    // uint256 maxcapFullBnb = 1 * 10**18; //1
    
    uint256 startDate = 1625932800; //
    uint256 whitelistedEndDate = 1625940000; //Must be equal to or bigger then startDate
    uint256 endDate = 1626544800; //Must be Bigger then whitelistedEndDate
    address payable ownerPancakeAdress = 0x42D28B4f10b85d8F88Ce93aDD0D598a673c5A8C7;
    uint allocatedForOwnerBNB = 30;

    uint256 allocatedTokensForPresale = (_tTotal.mul(10000).div(1000000)) * allocatedPercentForPresale; //60m
    uint256 allocatedTokensForPancakeSwapAfterPresale = _tTotal.div(100).mul(allocatedPercentForPancakeSwap); //34m
    uint256 tokensPerBNBPresale = allocatedTokensForPresale.div(maxcap); //there is 9 decimals at the end of this number.

    // CONFIG END

    bool maxCapReached;
    uint256 raisedBNB;
    uint256 tokensSOLD;
    uint256 totalPresalePurchases;
    
    enum PresaleState{WHITELISTED, LIVE, ENDED, FINALIZED, CANCELLED}
    PresaleState presaleState = PresaleState.WHITELISTED; //SET THE DEFAULT STATE OF CONTRACT
 
    //cheeseburger = amountPercentageTokensRemaining
    uint256 amountPercentageTokensRemaining;
    uint256 amountUnsoldTokensRemaining;
    uint256 amountToSendToPancakeSwap;
    
    uint256 amountTokenToBurnPancakeSwap;
    uint256 amountTokenBurnPresale;
    
    uint256 amountTokensRemainingPancakeSwap;
    
    uint256 amountOwnerBNBFee; 
    uint256 amountPancakeBNBFee;
    
    uint256 totalBurn;
    bool reachedMinimumBNB = false;
    
    uint256 withdrawedMarketingFunds = 0;
    
    function withdrawMarketingFundsAdmin(uint256 _amount) public onlyOwner {
        uint basisPoint = allocatedForOwnerBNB.mul(100); //3000
        uint256 totalAvailable = (raisedBNB.mul(basisPoint)).div(10000);   
        uint256 availableToWithdrawNow = totalAvailable.sub(withdrawedMarketingFunds);
        require(availableToWithdrawNow >= _amount, "You can't withdraw that much. check availableToWithdrawNow function");
        ownerPancakeAdress.transfer(_amount);
    }
    function getPresaleDetails() public view returns(uint256 _raisedBNB, uint256 _tokensSOLD, uint256 _minCap, uint256 _maxCap, uint256 _minBuy, uint256 _maxBuy, uint256 _startDate, uint256 _endDate, uint256 _whitelistedEndDate) {
            return (raisedBNB, tokensSOLD, mincapFullBnb, maxcapFullBnb, minbuy, maxbuy, startDate, endDate, whitelistedEndDate);
    }
    function getPresaleDetailsP2() public view returns(uint256 tokensAvailable, uint256 chainLinkFee) {
        uint256 totalRemaining = allocatedTokensForPresale.sub(tokensSOLD);
        return (totalRemaining, fee);
    }
    function finalizePresale() public onlyOwner() {
        // require(balanceOf(address(this)) >= allocatedTokensForPresale, "Contract needs tokens to send!"); //call contract function to check balance (CONTRACT)
        require(getPresaleState() == 1, "PRESALE HAS NOT ENDED, WAIT IT OUT TO FINALIZE!");
        
        amountUnsoldTokensRemaining = allocatedTokensForPresale.sub(tokensSOLD);    
        amountPercentageTokensRemaining = (amountUnsoldTokensRemaining.mul(1000000000).div(allocatedTokensForPresale)); //(Google gives 999900000), but variable gives
        amountTokensRemainingPancakeSwap = amountPercentageTokensRemaining.mul(allocatedTokensForPancakeSwapAfterPresale).div(1000000000); //33,996,600,000,000,000 (3400 tokens to pancaky)
        
        //bnb pancakeswap split 
        amountOwnerBNBFee = ((allocatedForOwnerBNB.mul(1 * 10**18)).mul(raisedBNB)).div(1 * 10**20);
        amountPancakeBNBFee = raisedBNB.sub(amountOwnerBNBFee);
        
        //tokens
        amountToSendToPancakeSwap = allocatedTokensForPancakeSwapAfterPresale.sub(amountTokensRemainingPancakeSwap);
        amountTokenBurnPresale = amountUnsoldTokensRemaining;
        amountTokenToBurnPancakeSwap = amountTokensRemainingPancakeSwap;
        totalBurn = amountTokenToBurnPancakeSwap.add(amountTokenBurnPresale);
        
        //transfer from parentContract to this contract.
        
        //send 70% BALANCE to parentContract.
        //send 30% balance to ownerAddress
        
        _allowances[address(this)][address(0)] = totalBurn;
        _allowances[address(this)][address(uniswapV2Router)] = amountToSendToPancakeSwap;
        _transfer(address(this), address(0) , totalBurn);
        uniswapV2Router.addLiquidityETH{value: amountPancakeBNBFee}(
            address(this),
            amountToSendToPancakeSwap,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            owner(),
            block.timestamp
        );
        // ownerPancakeAdress.transfer(amountOwnerBNBFee
        presaleState = PresaleState.FINALIZED;
        emit presaleFinalized(raisedBNB, tokensSOLD, totalBurn, amountToSendToPancakeSwap, amountPancakeBNBFee, amountOwnerBNBFee, amountToSendToPancakeSwap);
    }
    function cancelPresale() public onlyOwner() {
        require(getPresaleState() == 1 || getPresaleState() == 5 || getPresaleState() == 4, "PRESALE MUST BE WHITELISTED, LIVE, OR ENDED IN ORDER TO GET CANCELLED.");
        presaleState = PresaleState.CANCELLED;
    }
    function getPresaleWallet(address _wallet) public view returns(uint256 amountTokensBought, uint256 amountBNBPaid, uint256 amountRefunded, uint256 amountClaimed, bool whitelisted, bool claimed, bool refunded) {
            PresaleWallet memory presaleWallet = presaleWallets[_wallet];
            return (presaleWallet.amountTokensBought, presaleWallet.amountBNBPaid,presaleWallet.amountRefunded,presaleWallet.amountClaimed,presaleWallet.whitelisted,presaleWallet.claimed, presaleWallet.refunded);
    }
    function addToWhitelist(address[] memory _wallets) public onlyOwner() {
        uint whitelistwalletlength = _wallets.length;
        for(uint i; i<whitelistwalletlength; i++) {
            address _wallet = _wallets[i];
            PresaleWallet storage presaleWallet = presaleWallets[_wallet];
            presaleWallet.whitelisted = true;
        }
    }
    function buyTokensForBnb() public payable {
        require(msg.value > minbuy, "MINIMUM PURCHASE IS 0.01 BNB");
        require(msg.value <= maxbuy, "MAX BUY IS 10 BNB");
        require(getPresaleState() == 5 || getPresaleState() == 4, "PRESALE IS NOT RUNNING(COULD BE CANCELLED OR ENDED, OR FINALIZED)");
        
        if(block.timestamp > endDate || block.timestamp < startDate) {
              revert("You can't buy this token yet or Presale had already ended, tokens cannot be purchased any longer.");
        } else {
            if(getPresaleState() == 4) {
                //WHITELISTED PRESALE
                PresaleWallet storage presaleWallet = presaleWallets[msg.sender];
                if(presaleWallet.whitelisted == false) {
                    if(block.timestamp >= whitelistedEndDate) {
                        presaleState = PresaleState.LIVE;
                        generateReceiptAndUserPurchasedTokens(msg.sender, msg.value);
                    } else {
                      revert('REFUNDED, YOUR WALLET IS NOT WHITELISTED');   
                    }
                } else {
                    //make purchase, update tokens.
                    generateReceiptAndUserPurchasedTokens(msg.sender, msg.value);
                }
            } else if(getPresaleState() == 5) {
                generateReceiptAndUserPurchasedTokens(msg.sender, msg.value);
            } else {
                revert('REFUNDED, PRESALE IS NOT LIVE OR IN WHITELISTED MODE');
            }
        }
    }
    function calcTokenRewards(uint256 amountToConvertInBNB) private view returns(uint256) {
        //get total tokens paid out.
        uint256 math = (amountToConvertInBNB * 10**9).div(10**18); //1 bnb
        return (tokensPerBNBPresale * math).div(10**9);
    }
    function generateReceiptAndUserPurchasedTokens(address _sender, uint256 _amount) private {
            PresaleWallet storage presaleWallet = presaleWallets[_sender];
            uint256 totalNewBnB = presaleWallet.amountBNBPaid.add(_amount);
            if(totalNewBnB > maxbuy) {
                revert("REFUNDED, MAX BUY LIMIT WOULD GET REACHED");
            } else {
                //add to total paidBNB
                uint256 toPayout = calcTokenRewards(_amount);
                uint256 raisedBNBNew = raisedBNB.add(_amount);
                if(raisedBNBNew > maxcapFullBnb) {
                    revert("REFUNDED, TOTAL PRESALE WOULD GET REACHED");
                } else {
                    //all good.
                    //RECEIVE OLD BNB PURCHASE AMOUNT
                    uint256 oldPaidAmt = presaleWallet.amountBNBPaid;
                    if((oldPaidAmt+_amount) > maxbuy) {
                        revert("REFUNDED, YOU WOULD REACH 10BNB PER WALLET LIMIT, TRY SMALLER 😥");
                    } else { 
                        //update user wallet
                        presaleWallet.amountTokensBought += toPayout;
                        presaleWallet.amountBNBPaid += _amount;
                        Receipt storage receipt = receipts[totalPresalePurchases + 1];
                        
                        //generate receipt
                        receipt.wallet = _sender;
                        receipt.paidBNB = _amount;
                        receipt.tokensPurchased = toPayout;
                        totalPresalePurchases++;
                        tokensSOLD += toPayout;
                        raisedBNB += _amount;
                        
                        emit presalePurchase(_sender, toPayout, _amount);
                        
                        if(raisedBNB >= mincapFullBnb && reachedMinimumBNB == false) {
                            reachedMinimumBNB = true;
                            emit presaleCompleteMinCap(tokensSOLD, raisedBNB);
                        }
                        
                        uint256 eligibleCap = maxcapFullBnb.div(5000); //0.02% of hardcap
                        uint256 math = maxcapFullBnb - eligibleCap; //1000 BNB - 0.02% = 999,800,000,000,000,000,000 (0.2 BNB left from 1k hardcap)
                        
                        //if raisedBNB is higher then math (999,800,000,000,000,000,000)
                        //We don't need to check here if the hardcap is hit with this, because we're checking on top.
                        if(raisedBNB >= math) { //0.02% remaining finalize presale
                            presaleState = PresaleState.ENDED;
                            emit presaleCompleteMaxCap(tokensSOLD, raisedBNB);
                        }
                    }
                }
            }
    }
    function claimTokens() public {
        require(getPresaleState() == 3, "YOU CAN'T CLAIM YOUR TOKENS YET!");
        PresaleWallet storage presaleWallet = presaleWallets[msg.sender];
        if(presaleWallet.amountTokensBought > 0 && presaleWallet.refunded == false && presaleWallet.claimed == false) {
            presaleWallet.claimed = true;
            presaleWallet.amountClaimed = presaleWallet.amountTokensBought;
            _transfer(address(this),  msg.sender, presaleWallet.amountTokensBought); //CALL CONTRACT FUNCTION HERE
        }
    }
    function claimRefunds() public {
        require(getPresaleState() == 2, "YOU CAN'T CLAIM REFUNDS YET!");
        PresaleWallet storage presaleWallet = presaleWallets[msg.sender];
        if(presaleWallet.amountBNBPaid > 0) {
            if(presaleWallet.refunded == false && presaleWallet.claimed == false) { 
                // revert("YOU HAVE ALREADY RECEIVED A REFUND!");   
                presaleWallet.amountRefunded = presaleWallet.amountBNBPaid;
                presaleWallet.refunded = true;
                address payable _address = msg.sender;
                _address.transfer(presaleWallet.amountBNBPaid);
                // emit presaleRefund(msg.sender, presaleWallet.amountRefunded);
            }
        }
    }
    function getPresaleState() private view returns (uint)  {
        // 1 - ENDED (FINISHED SUCCESSFULLY, BUT NOT YET FINALIZED)
        // 2 - CANCELLED = USER CAN NOW CLAIM REFUNDS!
        // 3 - FINALIZED = USER CAN NOW CLAIM TOKENS!
        // 4 - WHITELISTED = ONLY WHITELISTED PEOPLE CAN BUY!
        // 5 - LIVE = EVERYONE CAN BUY!
        // 6 - NOT_YET_BUYABLE 
        
        //CHECK IF REACHED END DATE OR STARTED YET
        if(block.timestamp > endDate || block.timestamp < startDate) {
            if(block.timestamp > endDate) {
                //ENDED
                if(reachedMinimum() == false) {
                    return 2;
                } else if(reachedMinimum() == true) {
                    if(presaleState == PresaleState.FINALIZED) {
                        return 3;
                    } else if(presaleState == PresaleState.CANCELLED) {
                        return 2;
                    } else if(presaleState == PresaleState.ENDED && block.timestamp >= endDate.add(259200)) {
                        //if presale hasn't been finalized or cancelled in 3 days, we cancel it.
                      return 2;
                    } else {
                      return 1;
                    }
                }
            } else {
              return 6;   
            }
        } else {
            if(presaleState == PresaleState.LIVE) {
               return 5;
            } else if(presaleState == PresaleState.WHITELISTED) {
                if(block.timestamp >= whitelistedEndDate) {
                    return 5;    
                } else {
                    return 4;
                }
            } else if(presaleState == PresaleState.CANCELLED) {
                return 2;
            } else if(presaleState == PresaleState.ENDED) {
                return 1;
            } else if(presaleState == PresaleState.FINALIZED) {
                return 3;
            }
        }
    }
    function reachedMinimum() private view returns (bool) {
        if(raisedBNB >= mincapFullBnb) {
            return true;
        } else {
            return false;
        }
    }
    function getPresaleStateText() public view returns(string memory) {
        uint _PRESALESTATE = getPresaleState();
        string memory presaleText;
        if(_PRESALESTATE == 1) {
            presaleText = "ENDED";
        } else if(_PRESALESTATE == 2) {
            presaleText = "CANCELLED";
        } else if(_PRESALESTATE == 3) {
            presaleText = "FINALIZED";
        } else if(_PRESALESTATE == 4) {
            presaleText = "WHITELISTED";
        } else if(_PRESALESTATE == 5) {
            presaleText = "LIVE";
        } else if(_PRESALESTATE == 6) {
            presaleText = "NOT_YET_BUYABLE";
        }
         return presaleText;
    }
   
}