pragma experimental ABIEncoderV2;
pragma solidity ^0.6.12;
// import "./PRESALE.sol";
import "https://raw.githubusercontent.com/smartcontractkit/chainlink/master/contracts/src/v0.6/VRFConsumerBase.sol";
// import "@chainlink/contracts/src/v0.6/VRFConsumerBase.sol";
// SPDX-License-Identifier: Unlicensed
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
    
}

interface IERC20 {

    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);
    function increaseAllowance(address spender, uint256 addedValue) external returns(bool);
    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
    uint256 private _lockTime;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

     /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    function geUnlockTime() public view returns (uint256) {
        return _lockTime;
    }

    //Locks the contract for owner for the amount of time provided
    function lock(uint256 time) public virtual onlyOwner {
        _previousOwner = _owner;
        _owner = address(0);
        _lockTime = now + time;
    }
    
    //Unlocks the contract for owner when _lockTime is exceeds
    function unlock() public virtual {
        require(_previousOwner == msg.sender, "You don't have permission to unlock");
        require(now > _lockTime , "Contract is locked until 7 days");
        _owner = _previousOwner;
    }
}
// pragma solidity >=0.5.0;
interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}
// pragma solidity >=0.5.0;
interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    // function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}
// pragma solidity >=0.6.2;
interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}
// pragma solidity >=0.6.2;
interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}


contract HODLERO is Context, Ownable, VRFConsumerBase, IERC20 {
    using SafeMathChainlink for uint256;
    // using Address for address;

    
    // -----------------------------------------------------------------------------------------------------------------------------------///////
    // -----------------------------------------------------------------------------------------------------------------------------------///////
    //  __       _____   ______  ______  ____    ____    __    __      ____    ____    _____   ______  _____   ____     _____   __        ///////
    // /\ \     /\  __`\/\__  _\/\__  _\/\  _`\ /\  _`\ /\ \  /\ \    /\  _`\ /\  _`\ /\  __`\/\__  _\/\  __`\/\  _`\  /\  __`\/\ \       ///////
    // \ \ \    \ \ \/\ \/_/\ \/\/_/\ \/\ \ \L\_\ \ \L\ \ `\`\\/'/    \ \ \L\ \ \ \L\ \ \ \/\ \/_/\ \/\ \ \/\ \ \ \/\_\\ \ \/\ \ \ \      ///////
    //  \ \ \  __\ \ \ \ \ \ \ \   \ \ \ \ \  _\L\ \ ,  /`\ `\ /'      \ \ ,__/\ \ ,  /\ \ \ \ \ \ \ \ \ \ \ \ \ \ \/_/_\ \ \ \ \ \ \  __ ///////
    //   \ \ \L\ \\ \ \_\ \ \ \ \   \ \ \ \ \ \L\ \ \ \\ \ `\ \ \       \ \ \/  \ \ \\ \\ \ \_\ \ \ \ \ \ \ \_\ \ \ \L\ \\ \ \_\ \ \ \L\ \///////
    //    \ \____/ \ \_____\ \ \_\   \ \_\ \ \____/\ \_\ \_\ \ \_\       \ \_\   \ \_\ \_\ \_____\ \ \_\ \ \_____\ \____/ \ \_____\ \____////////
    //     \/___/   \/_____/  \/_/    \/_/  \/___/  \/_/\/ /  \/_/        \/_/    \/_/\/ /\/_____/  \/_/  \/_____/\/___/   \/_____/\/___/ ///////
    // -----------------------------------------------------------------------------------------------------------------------------------///////
    // -----------------------------------------------------------------------------------------------------------------------------------///////

    // Link vars
    bytes32 keyHash;

    // uint256 fee = 100000000000000000; // 0.1 LINK(testnet); (chainlink has 18 decimals, so we need 1.0e+17 number here)
    
    uint256 fee = 200000000000000000; // 0.1 LINK(mainnet); (chainlink has 18 decimals, so we need 1.0e+17 number here)
    
    event PickWinnerCalled(address from, uint256 blockNumber);
    event LotteryDraw(
       address winnerAddress,
       uint participantID,
       uint256 winnerBalanceTimeOfRoll,
       uint256 drawID,
       uint256 amountWon,
       uint256 totalPoolSize,
       address feePaidTo,
       uint256 feeAmountPaid,
       uint256 nextBlockCallableAt
    );
    event LotteryDrawP2(
       uint256 validatedAt,
       uint256 blockNumber,
       bool userWinEligible,
       bool wasThisGamePaidOut,
       string message
    );
    // event LotteryPayout(address indexed wallet, )
    struct ParticipantWallet {
        bool valid;
        uint ParticipantID;
    }
    struct Participant { 
       address _address;
       uint256 _balance;
       uint256 validatedAt;
       bool isValidLotteryPlayer;
    }
    struct Draw { 
       address winnerAddress;
       uint participantID;
       uint256 winnerBalanceTimeOfRoll;
       uint256 drawID;
       uint256 amountWon;
       uint256 totalPoolSize;
       address feePaidTo;
       uint256 feeAmountPaid;
       bool userWinEligible;
       uint256 validatedAt;
       bool wasThisGamePaidOut;
       uint256 blockNumber;
       string message;
    }
    
    
    

    
    // Lotto vars/mappings
    uint256 participantsAmount = 0; //increment on each new transaction
    uint256 validParticipants = 0;
    
    uint256 requiredMinimalBalance = 2000000000000; //0.002% Go down dynamically based on how much circulating supply there is. (initial 2k tokens)
    // uint256 minimumHodlingTime = 3 * 86400; //3 days block (1 block per 3 seconds)
    
    // uint256 minimumHodlingTime = 300; //5 minutes of block (1 block per 3 seconds) (test)
    uint256 minimumHodlingTime = 100000; //3-4 minutes of block (1 block seconds)(300000 seconds) (livenet)
    
    uint256 public lastRollResult;
    uint256 public lastGameDrawedAt;
    uint256 public drawBlockSize = 400000; //400000 block between each time pickWinner function can be called.
    // uint256 public drawBlockSize = 1000; //1000 block between each time pickWinner function can be called. (testnet)
    uint256 public nextDrawBlockSize; //400000 blocks  = ~2 weeks on binance chain (~3 second per block)
    uint256 public gameDrawCallableAt;
    uint256 public drawid = 1;
    bool isLinkTransferLocked = false;
    address linkAdr = 0x404460C6A5EdE2D891e8297795264fDe62ADBB75; //livbenet contract address on the bsc network
    // address linkAdr = 0x84b9B910527Ad5C03A9Ca831909E21e236EA7b06; //testnet contract address on the bsc network
    uint256 amountPercentageCalcMinimalRequirements = 50000000000000; //
    uint256 minimalDrawBlockSize = 20;
    uint256 LinkWalletBalance = 0;
    bool receivedTokenTransfer = false;
    IERC20 link = IERC20(linkAdr);

    bool isLinkApproved = false; //If link tokens has been approved for transfa.
    
    mapping (uint256 => Participant) participants;
    mapping (address => ParticipantWallet) participantWallets;
    mapping (uint256 => Draw) draws;
    

    
    function insertParticipant(address _address) private {
        uint256 playerBalance = balanceOf(_address);
       
        if(playerBalance >= requiredMinimalBalance) {
            uint newParticipantAmount = participantsAmount + 1;
            
            //if participant exists
            
            
            ParticipantWallet storage participantwallet = participantWallets[_address];
            Participant storage participant = participants[newParticipantAmount];
            
            participant.isValidLotteryPlayer = true;
            participantwallet.valid = true;
            participantwallet.ParticipantID = newParticipantAmount;
            
            participant._address = _address;
            participant.validatedAt = block.number;
            participantsAmount++;
            
            participant._balance = playerBalance;
            validParticipants++;
        }
    }
    function updateParticipantStats(address _address) private {
        ParticipantWallet memory participantwallet = participantWallets[_address];
        uint ParticipantID = participantwallet.ParticipantID;
        Participant storage participant = participants[ParticipantID];
        uint256 playerBalance = balanceOf(_address);
        participant._balance = playerBalance;
        bool oldValidity = participant.isValidLotteryPlayer;
        
        if(playerBalance >= requiredMinimalBalance) {
            
            if(oldValidity == true) {
                //do nothing because player was already in the participant list
            } else {
                //add a new valid pariticipant;
                participant.isValidLotteryPlayer = true;
                participant.validatedAt = block.number;
                validParticipants++;
            }
        } else {
            if(oldValidity == true) {
                validParticipants--;
            }
            participant.validatedAt = 0;
            participant.isValidLotteryPlayer = false;
        }
    }
    // function getParicipantWinnerChance() view public returns(uint256) {
    //     return validParticipants * 10000 / participantsAmount; 
    // }
    function getParticipant(uint _id) view public returns (address pariticpantAddress, uint256 participantBalance , bool validParticipant, uint256 validatedAt) {
        return (participants[_id]._address, participants[_id]._balance, participants[_id].isValidLotteryPlayer, participants[_id].validatedAt);
    }
    function getParticipantByAddress(address _address) view public returns (uint256 pariticpantId, address participantAddress, uint256 participantBalance, bool validParticipant, bool isValidWallet, uint256 validatedAt) {
        ParticipantWallet memory wallet = participantWallets[_address];
        bool isValid = wallet.valid;
        uint participantid = wallet.ParticipantID;
        Participant memory participant = participants[participantid];
        return (participantid, participant._address, participant._balance, participant.isValidLotteryPlayer, isValid, participant.validatedAt);
    }
    function decideParticipation(address _address) private returns(bool) {
         (,,,,bool valid,) = getParticipantByAddress(_address);
         if(valid == true) {
             //update address balance here
             updateParticipantStats(_address);
             return true;
         } else {
             //insert address here
             insertParticipant(_address);
             return false;
         }
    }
    function updateParticipation(address sender) public returns(bool) {
        (bool rt)=decideParticipation(sender);
        return rt;
    }
    // Pariticipants lotto end
    // Lottery Pool functions
    // function getPoolSize() public view returns(uint256) {
    //     return balanceOf(lotteryPoolWallet);
    // }
    
    
    // Lotto draw functions
    address currentLinkFunder;
    function pickWinner() private returns(bytes32 requestId) {
        require(block.number >= gameDrawCallableAt, "Draw not yet callable.");
        require(LINK.balanceOf(address(this)) >= fee, "Not enough LINK - fill contract with faucet");
        return requestRandomness(keyHash, fee);
    }

    // link function (This is automatically called by chainlink)
    function fulfillRandomness(bytes32 requestId, uint256 randomness) internal override {
        //get a random number between 1 - participantsAmount;
        lastRollResult = randomness.mod(participantsAmount).add(1);
        
        // get participant details
        (address wallet, uint256 balance, bool valid, uint256 validatedAt) = getParticipant(lastRollResult);
        // event LogRandomResult(address indexed wallet, uint indexed drawid , uint256 walletBalance, uint256 ParticipantID, bool isPaid);
        uint256 poolSize = balanceOf(lotteryPoolWallet);
        uint256 payerFeeSize = poolSize.mul(5).div(100); //5% WILL GO to payer.
        uint256 winnerSize = poolSize.mul(95).div(100); //95% goes to winner.
        bool paidOut = false;
        uint calculatedNextBlockSize = nextDrawBlockSize / 2; //200000
        uint256 validHodling = validatedAt + minimumHodlingTime;
        string memory message = '{"error": true, "msg": ""}';
        if(balance < requiredMinimalBalance) {
            // if player balance is invalid, dont pay out player, and split nextDrawBlockSize by half(Nearest lowest).

            message = '{"error": true, "msg": "Winner has insufficent balance!"}';
            //If the calculated next round is less then or equal to the allowed minimal
            if(calculatedNextBlockSize <= minimalDrawBlockSize) {
                //add only minimalDrawBlockSize (20 in this case),to the next draw callable round.
                gameDrawCallableAt = block.number + minimalDrawBlockSize;
                nextDrawBlockSize = minimalDrawBlockSize;
            } else {
                gameDrawCallableAt = block.number + calculatedNextBlockSize; //+blockNumber + 200000
                nextDrawBlockSize = calculatedNextBlockSize;    
            }
        } else {
            //If the calculated next round is less then or equal to the allowed minimal
            if(block.number >= validHodling) {
                // if player is valid, pay out the player,and payer and reset lotto.
                _transferStandard(lotteryPoolWallet, wallet, winnerSize);
                _transferStandard(lotteryPoolWallet, currentLinkFunder, payerFeeSize);
                
                nextDrawBlockSize = drawBlockSize;
                gameDrawCallableAt = block.number + nextDrawBlockSize;
                paidOut = true;
                message = '{"success": true, "msg": "Paid out!"}';
            } else {
                message = '{"error": true, "msg": "Winner has enough balance, but has not held it enough time"}';
                if(calculatedNextBlockSize <= minimalDrawBlockSize) {
                    //add only minimalDrawBlockSize (20 in this case),to the next draw callable round.
                    gameDrawCallableAt = block.number + minimalDrawBlockSize;
                    nextDrawBlockSize = minimalDrawBlockSize;
                } else {
                    gameDrawCallableAt = block.number + calculatedNextBlockSize; //+blockNumber + 200000
                    nextDrawBlockSize = calculatedNextBlockSize;    
                }
            }
        }
        
        // insert the draw
        Draw storage draw = draws[drawid];
        draw.winnerAddress = wallet;
        draw.winnerBalanceTimeOfRoll = balance;
        draw.participantID = lastRollResult;
        draw.drawID = drawid;
        draw.amountWon = winnerSize;
        draw.totalPoolSize = poolSize;
        draw.feePaidTo = currentLinkFunder; //for now same as winner
        draw.feeAmountPaid = payerFeeSize;
        draw.userWinEligible = valid;
        draw.wasThisGamePaidOut = paidOut;
        draw.blockNumber = block.number;
        draw.validatedAt = validatedAt;
        draw.message = message;
        lastGameDrawedAt = block.number;
        
        // Both cases, insert the draw
        
         emit LotteryDraw(wallet,lastRollResult,balance, drawid , winnerSize, poolSize, currentLinkFunder, payerFeeSize , gameDrawCallableAt);
         emit LotteryDrawP2(validatedAt, block.number, valid, paidOut, message);

         drawid++;
         isLinkTransferLocked = false;
    }
    //you need to call P2 to get the remaining result. Why it does this? Idk..
    function getLastDrawP1() public view returns ( 
       address winnerAddress, uint participantID, uint256 winnerBalanceTimeOfRoll,
       uint256 drawID,
       uint256 amountWon,
       uint256 totalPoolSize,
      address feePaidTo) {
        
       (address drawResultwinnerAddress,
       uint drawResultparticipantID,
       uint256 drawResultWinnerBalanceTimeOfRoll,
       uint256 drawResultdrawID,
       uint256 drawResultamountWon,
       uint256 drawResulttotalPoolSize, 
       address drawResultfeePaidTo) = getDrawByID(drawid.sub(1));
       return (drawResultwinnerAddress, drawResultparticipantID, drawResultWinnerBalanceTimeOfRoll, drawResultdrawID, drawResultamountWon, drawResulttotalPoolSize, drawResultfeePaidTo);
    }
    
    function getLastDrawP2() public view returns( uint256 feeAmountPaid,bool userWinEligible, bool wasThisGamePaidOut,  uint256 blockNumber, string memory message, uint256 validatedAt) { 
        (uint256 drawResultfeeAmountPaid, bool drawResultuserWinEligible, bool drawResultwasThisGamePaidOut, uint256 drawResultBlock, string memory message, uint256 validatedAt) = getDrawByIDP2(drawid.sub(1));
        
        return  (drawResultfeeAmountPaid, drawResultuserWinEligible, drawResultwasThisGamePaidOut, drawResultBlock, message, validatedAt);
    }
    function getDrawByID(uint256 drawIdToGet) public view returns ( 
       address winnerAddress,
       uint participantID,
       uint256 winnerBalanceTimeOfRoll,
       uint256 drawID,
       uint256 amountWon,
       uint256 totalPoolSize,
       address feePaidTo) {
          Draw memory draw = draws[drawIdToGet];
          return (draw.winnerAddress, draw.participantID, draw.winnerBalanceTimeOfRoll, draw.drawID, draw.amountWon, draw.totalPoolSize, draw.feePaidTo);
    }
    function getDrawByIDP2(uint256 drawIdToGet) public view returns ( 
       uint256 feeAmountPaid,
       bool userWinEligible,
       bool wasThisGamePaidOut,
       uint256 blockNumber,
       string memory message,
       uint256 validatedAt) {
          Draw memory draw = draws[drawIdToGet];
          return (draw.feeAmountPaid, draw.userWinEligible, draw.wasThisGamePaidOut, draw.blockNumber, draw.message, draw.validatedAt);
    }
    
    address lastMsgSender;   

    function onTokenTransfer(address from, uint256 amount, bytes memory data)  public {
        // lastMsgSender = msg.sender;
        require(msg.sender == linkAdr, "Invalid Sender"); //Only allow chainlink to send us balance
        require(LINK.balanceOf(address(this)) >= amount, "Invalid token received");
        if(block.number >= gameDrawCallableAt) {
            if(isLinkTransferLocked == true) {
                //refund the user.
                LINK.transferFrom(address(this), from, amount);
            } else {
                if(amount > fee) {
                    isLinkTransferLocked = true;
                    currentLinkFunder = from;
                    receivedTokenTransfer = true;
                    pickWinner();
                    uint256 toRefund = amount.sub(fee);
                    LINK.transferFrom(address(this), from, toRefund);
                    PickWinnerCalled(from, block.number);
                } else if (amount == fee) {
                    // pick the winner
                     isLinkTransferLocked = true;
                    currentLinkFunder = from;
                    receivedTokenTransfer = true;
                    pickWinner();
                    PickWinnerCalled(from, block.number);
                } else if(amount < fee) {
                    //refund the user
                    LINK.transferFrom(address(this), from, amount);
                }
            }      
        } else {
            //refund
            LINK.transferFrom(address(this), from, amount);
        }
    }
    function toUint256(bytes memory _bytes) internal pure returns (uint256 value) {
        assembly {
          value := mload(add(_bytes, 0x20))
        }
    }
    
    mapping (address => uint256) _rOwned;
    mapping (address => uint256) _tOwned;
    mapping (address => mapping (address => uint256)) internal _allowances;

    mapping (address => bool) _isExcludedFromFee;

    mapping (address => bool) _isExcluded;
    address[] _excluded;
   
    uint256 constant MAX = ~ uint256(0);
    // 5,000,000,000.000,000,000 (5 Billion Tokens)
    uint256 _tTotal = 100 * 10**6 * 10**9; //100.000.000,000000000
    uint256 _rTotal = (MAX - (MAX % _tTotal));
    uint256 _tFeeTotal;

    string public _name = "HODLERO";
    string public _symbol = "HDLR";
    uint8  public _decimals = 9;
    
    uint256 _taxFee = 0;
    uint256 _previousTaxFee = _taxFee;
    
    uint256 _liquidityFee = 0;
    uint256  _previousLiquidityFee = _liquidityFee;

    uint256 _burnFee = 0;
    uint256  _previousBurnFee = _burnFee;

    uint256 _marketingFee = 0;
    address marketingWallet = 0x4C5090ae27632fB08C9ac852881135bfe32f9C17;
    uint256  _previousmarketingFee = _marketingFee;
    
    uint256 _lotteryFee = 0;
    address lotteryPoolWallet = 0xD1d0fbFd614a0d437D251919BEbb8Be2d5A70617; 
    IUniswapV2Router02 public immutable uniswapV2Router;
    address public immutable uniswapV2Pair;
    
    bool inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = false;

    uint256 _maxTxAmount = 100 * 10**6 * 10**9; 
    uint256 numTokensSellToAddToLiquidity = 25 * 10**3 * 10**9; //token reaches 25000 tokens, liquify it
    
    event MinTokensBeforeSwapUpdated(uint256 minTokensBeforeSwap);
    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );
    
    modifier lockTheSwap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }
    
    // (VRF CORDINATOR, LINK TOKEN ADDRESS)
    // KEYHASH = LINK TOKENS BINANCE CHAIN testnet
    // https://docs.chain.link/docs/vrf-contracts/
 
    
    // PRESALE public presale;
    // address public presaleAddress;
    
    //livenet
    constructor () VRFConsumerBase(0x747973a5A2a4Ae1D3a8fDF5479f1514F65Db9C31, 0x404460C6A5EdE2D891e8297795264fDe62ADBB75) public {
        keyHash = 0xc251acd21ec4fb7f31bb8868288bfdbaeb4fbfec2df3735ddbd4f7dc8d60103c;
    // constructor () VRFConsumerBase(0xa555fC018435bef5A13C6c6870a9d4C11DEC329C, 0x84b9B910527Ad5C03A9Ca831909E21e236EA7b06) public {
        //  keyHash = 0xcaf3c3727e033261d383b315559476f48034c13b18f8cafed4d871abe5049186;
        _rOwned[_msgSender()] = _rTotal;
        // address payable ownerPancakeAdress = 0x4C5090ae27632fB08C9ac852881135bfe32f9C17; //where the owner will receive the 30% marketing fundsing from raised liquidity

        
        //livenet 
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);

            
        // testnet https://pancake.kiemtienonline360.com/#/swap
        // IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);
         // Create a uniswap pair for this new token
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());
        // set the rest of the contract variables
        uniswapV2Router = _uniswapV2Router;
        gameDrawCallableAt = block.number + drawBlockSize;
        nextDrawBlockSize = drawBlockSize;
        //exclude owner, lotteryPoolWallet, marketingWallet from free, and this contract from fee
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[lotteryPoolWallet] = true;
        _isExcludedFromFee[marketingWallet] = true;
        _isExcludedFromFee[0x42D28B4f10b85d8F88Ce93aDD0D598a673c5A8C7] = true; //owner bnb address
        
        emit Transfer(address(0), _msgSender(), _tTotal);
    }
    
    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        if (_isExcluded[account]) return _tOwned[account];
        return tokenFromReflection(_rOwned[account]);
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        // _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public override virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue));
        return true;
    }

    function isExcludedFromReward(address account) public view returns (bool) {
        return _isExcluded[account];
    }

    function totalFees() public view returns (uint256) {
        return _tFeeTotal;
    }

    function reflectionFromToken(uint256 tAmount, bool deductTransferFee) public view returns(uint256) {
        require(tAmount <= _tTotal, "Amount must be less than supply");
        if (!deductTransferFee) {
            (uint256 rAmount,,,,,) = _getValues(tAmount);
            return rAmount;
        } else {
            (,uint256 rTransferAmount,,,,) = _getValues(tAmount);
            return rTransferAmount;
        }
    }

    function tokenFromReflection(uint256 rAmount) public view returns(uint256) {
        require(rAmount <= _rTotal, "Amount must be less than total reflections");
        uint256 currentRate =  _getRate();
        return rAmount.div(currentRate);
    }
    function approveLink() public onlyOwner() {
        uint256 approveAmt = 1000000000 * 10**18;
        LINK.approve(address(this), approveAmt);
        isLinkApproved = true;
    }
    function excludeFromReward(address account) public onlyOwner() {
        require(account != 0x05fF2B0DB69458A0750badebc4f9e13aDd608C7F, 'We can not exclude Pancake router.');
        require(!_isExcluded[account], "Account is already excluded");
        if(_rOwned[account] > 0) {
            _tOwned[account] = tokenFromReflection(_rOwned[account]);
        }
        _isExcluded[account] = true;
        _excluded.push(account);
    }

    function includeInReward(address account) external onlyOwner() {
        require(_isExcluded[account], "Account is already excluded");
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_excluded[i] == account) {
                _excluded[i] = _excluded[_excluded.length - 1];
                _tOwned[account] = 0;
                _isExcluded[account] = false;
                _excluded.pop();
                break;
            }
        }
    }

    function _transferBothExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity) = _getValues(tAmount);
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);        
        _takeLiquidity(tLiquidity);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }
    

    
     //to recieve ETH from uniswapV2Router when swaping
    receive() external payable {}

    function _reflectFee(uint256 rFee, uint256 tFee) private {
        _rTotal = _rTotal.sub(rFee);
        _tFeeTotal = _tFeeTotal.add(tFee);
    }

    function _getValues(uint256 tAmount) private view returns (uint256, uint256, uint256, uint256, uint256, uint256) {
        (uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity) = _getTValues(tAmount);
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) = _getRValues(tAmount, tFee, tLiquidity, _getRate());
        return (rAmount, rTransferAmount, rFee, tTransferAmount, tFee, tLiquidity);
    }

    function _getTValues(uint256 tAmount) private view returns (uint256, uint256, uint256) {
        uint256 tFee = calculateTaxFee(tAmount);
        uint256 tLiquidity = calculateLiquidityFee(tAmount);
        uint256 tTransferAmount = tAmount.sub(tFee).sub(tLiquidity);
        return (tTransferAmount, tFee, tLiquidity);
    }

    function _getRValues(uint256 tAmount, uint256 tFee, uint256 tLiquidity, uint256 currentRate) private pure returns (uint256, uint256, uint256) {
        uint256 rAmount = tAmount.mul(currentRate);
        uint256 rFee = tFee.mul(currentRate);
        uint256 rLiquidity = tLiquidity.mul(currentRate);
        uint256 rTransferAmount = rAmount.sub(rFee).sub(rLiquidity);
        return (rAmount, rTransferAmount, rFee);
    }

    function _getRate() private view returns(uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply.div(tSupply);
    }

    function _getCurrentSupply() private view returns(uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;      
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_rOwned[_excluded[i]] > rSupply || _tOwned[_excluded[i]] > tSupply) return (_rTotal, _tTotal);
            rSupply = rSupply.sub(_rOwned[_excluded[i]]);
            tSupply = tSupply.sub(_tOwned[_excluded[i]]);
        }
        if (rSupply < _rTotal.div(_tTotal)) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }
    
    function _takeLiquidity(uint256 tLiquidity) private {
        uint256 currentRate =  _getRate();
        uint256 rLiquidity = tLiquidity.mul(currentRate);
        _rOwned[address(this)] = _rOwned[address(this)].add(rLiquidity);
        if(_isExcluded[address(this)])
            _tOwned[address(this)] = _tOwned[address(this)].add(tLiquidity);
    }
    
    function calculateTaxFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_taxFee).div(
            10**2
        );
    }

    function calculateLiquidityFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_liquidityFee).div(
            10**2
        );
    }
    
    function removeAllFee() private {
        _taxFee = 0;
        _liquidityFee = 0;
        _burnFee = 0;
        _marketingFee = 0;
        _lotteryFee = 0;
    }
    
    function restoreAllFee() private {
        _taxFee = 1;
        _liquidityFee = 2;
        _burnFee = 1;
        _marketingFee = 1;
        _lotteryFee = 1;
    }
    
    function isExcludedFromFee(address account) public view returns(bool) {
        return _isExcludedFromFee[account];
    }

    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        // is the token balance of this contract address over the min number of
        // tokens that we need to initiate a swap + liquidity lock?
        // also, don't get caught in a circular liquidity event.
        // also, don't swap & liquify if sender is uniswap pair.
        uint256 contractTokenBalance = balanceOf(address(this));        
        bool overMinTokenBalance = contractTokenBalance >= numTokensSellToAddToLiquidity;
        if (
            overMinTokenBalance &&
            !inSwapAndLiquify &&
            from != uniswapV2Pair &&
            swapAndLiquifyEnabled
        ) {
            contractTokenBalance = numTokensSellToAddToLiquidity;
            //add liquidity
            swapAndLiquify(contractTokenBalance);
        }
        
        //transfer amount, it will take tax, burn, liquidity fee
        _tokenTransfer(from,to,amount);
    }

    function swapAndLiquify(uint256 contractTokenBalance) private lockTheSwap {
        // split the contract balance into halves
        uint256 half = contractTokenBalance.div(2);
        uint256 otherHalf = contractTokenBalance.sub(half);

        // capture the contract's current ETH balance.
        // this is so that we can capture exactly the amount of ETH that the
        // swap creates, and not make the liquidity event include any ETH that
        // has been manually sent to the contract
        uint256 initialBalance = address(this).balance;

        // swap tokens for ETH
        swapTokensForEth(half); // <- this breaks the ETH -> HATE swap when swap+liquify is triggered

        // how much ETH did we just swap into?
        uint256 newBalance = address(this).balance.sub(initialBalance);

        // add liquidity to uniswap
        addLiquidity(otherHalf, newBalance);
        
        emit SwapAndLiquify(half, newBalance, otherHalf);
    }

    function swapTokensForEth(uint256 tokenAmount) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // make the swap
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
    }
    
    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // add the liquidity
        uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            owner(),
            block.timestamp
        );
    }

    //this method is responsible for taking all fee, if takeFee is true
    function _tokenTransfer(address sender, address recipient, uint256 amount) private {
        if(_isExcludedFromFee[sender] || _isExcludedFromFee[recipient]){
            removeAllFee();
        }
        else{
            require(amount <= _maxTxAmount, "Transfer amount exceeds the maxTxAmount.");
        }
        
        //Calculate burn amount and marketing amount
        // x * burnfee / 100
        uint256 burnAmt = amount.mul(_burnFee).div(100);
        //No burn amount found ?
        uint256 marketingAmt = amount.mul(_marketingFee).div(100);
        uint256 lotteryAmt = amount.mul(_lotteryFee).div(100);
        // console.log("Marketing Amount: " + marketingAmt);
        // console.log("Burn Amount: " +  burnAmt);
        if (_isExcluded[sender] && !_isExcluded[recipient]) {
            _transferFromExcluded(sender, recipient, (amount.sub(burnAmt).sub(marketingAmt).sub(lotteryAmt)));
        } else if (!_isExcluded[sender] && _isExcluded[recipient]) {
            _transferToExcluded(sender, recipient, (amount.sub(burnAmt).sub(marketingAmt).sub(lotteryAmt)));
        } else if (!_isExcluded[sender] && !_isExcluded[recipient]) {
            _transferStandard(sender, recipient, (amount.sub(burnAmt).sub(marketingAmt).sub(lotteryAmt)));
        } else if (_isExcluded[sender] && _isExcluded[recipient]) {
            _transferBothExcluded(sender, recipient, (amount.sub(burnAmt).sub(marketingAmt).sub(lotteryAmt)));
        } else {
            // console.log("Sending Standard");
            _transferStandard(sender, recipient, (amount.sub(burnAmt).sub(marketingAmt).sub(lotteryAmt)));
        }
        
        //Temporarily remove fees to transfer to burn address and marketing wallet
        _taxFee = 0;
        _liquidityFee = 0;

        //Send transfers to burn and marketing wallet, and pool
        _transferStandard(sender, address(0), burnAmt);
        _transferStandard(sender, marketingWallet, marketingAmt);
        _transferStandard(sender, lotteryPoolWallet, lotteryAmt);
        //((100000000000000000|(100m) - 50000000000000000(50m)) / 50000000000000) = 1000 tokens * 1000000000 (1000000000000)
        requiredMinimalBalance = ((_tTotal.sub(balanceOf(address(0)))) / amountPercentageCalcMinimalRequirements).mul(1000000000);
        //Restore tax and liquidity fees
        _taxFee = _previousTaxFee;
        _liquidityFee = _previousLiquidityFee;
        if(sender != address(this) && sender != marketingWallet && sender != lotteryPoolWallet && sender != address(0) && sender != owner()) {
            decideParticipation(sender);    
        }
         if(recipient != address(this) && recipient != marketingWallet && recipient != lotteryPoolWallet && recipient != address(0) && recipient != owner()) {
            decideParticipation(recipient);   
         }
        
        if(_isExcludedFromFee[sender] || _isExcludedFromFee[recipient])
            restoreAllFee();
    }

    function _transferStandard(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _takeLiquidity(tLiquidity);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferToExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);           
        _takeLiquidity(tLiquidity);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferFromExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity) = _getValues(tAmount);
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);   
        _takeLiquidity(tLiquidity);
        _reflectFee(rFee, tFee);
        
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function excludeFromFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = true;
    }
    
    function includeInFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = false;
    }
    
    //Call this function after finalizing the presale
    function enableAllFees() external onlyOwner() {
        _taxFee = 2;
        _previousTaxFee = _taxFee;
        _liquidityFee = 3;
        _previousLiquidityFee = _liquidityFee;
        // Sets the burn rate and marketingFee to 0.5%
        _burnFee = 1;
        _previousBurnFee = _burnFee;
        _marketingFee = 1;
        _lotteryFee = 1;
        _previousmarketingFee = _marketingFee;
        inSwapAndLiquify = true;
        emit SwapAndLiquifyEnabledUpdated(true);
    }

    function disableAllFees() external onlyOwner() {
        _taxFee = 0;
        _previousTaxFee = _taxFee;
        _liquidityFee = 0;
        _previousLiquidityFee = _liquidityFee;
        _burnFee = 0;
        _previousBurnFee = _taxFee;
        _marketingFee = 0;
        _previousmarketingFee = _marketingFee;
        inSwapAndLiquify = false;
        emit SwapAndLiquifyEnabledUpdated(false);
    }
    
    function setmarketingWallet(address newWallet) external onlyOwner() {
        marketingWallet = newWallet;
    }
   
    function setMaxTxPercent(uint256 maxTxPercent) external onlyOwner() {
        require(maxTxPercent > 10, "Cannot set transaction amount less than 10 percent!");
        _maxTxAmount = _tTotal.mul(maxTxPercent).div(
            10**2
        );
    }

    function setSwapAndLiquifyEnabled(bool _enabled) public onlyOwner {
        swapAndLiquifyEnabled = _enabled;
        emit SwapAndLiquifyEnabledUpdated(_enabled);
    }
    
}