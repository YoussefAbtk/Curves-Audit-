// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import "@crytic/properties/contracts/util/PropertiesHelper.sol";
import "@crytic/properties/contracts/util/PropertiesConstants.sol";

import "@crytic/properties/contracts/util/Hevm.sol";
import {Curves} from "./Curves.sol"; 
import {CurvesERC20} from "./CurvesERC20.sol";
import {CurvesERC20Factory} from "./CurvesERC20Factory.sol";
import {FeeSplitter} from "./FeeSplitter.sol";

contract EchidnaCurves is PropertiesAsserts, PropertiesConstants{
    Curves curves; 
    FeeSplitter feeSplitter; 
    mapping(address=> bool) hasAReference; 
    mapping(address => bool) isExternal;
    mapping(address=> mapping(address=> uint256)) amountDeposited;
    address owner= hevm.addr(666);
    uint256 amountExternal; 
    constructor() payable {
        CurvesERC20Factory factory = new CurvesERC20Factory(); 
        feeSplitter = new FeeSplitter();
        curves = new Curves(address(factory), address(feeSplitter));
        feeSplitter.setCurves(curves); 
        feeSplitter.setManager(address(curves), true);
        curves.setManager(address(this), false);
        curves.transferOwnership(owner); 
        hevm.prank(owner);
        curves.setManager(owner, true);
        hevm.prank(owner); 
        curves.setMaxFeePercent(0.4e18);
        hevm.prank(owner); 
        curves.setProtocolFeePercent(0.1e18, owner);
        hevm.prank(owner); 
        curves.setExternalFeePercent(0.2e18,0,0.1e18);


    }

    function test_buyCurvesTokensForTheFirstTime(uint256 _amount) public payable  {
        _amount=clampBetween(_amount, 1, 100_000);
         
          uint256 supply = curves.curvesTokenSupply(msg.sender);
          uint256 priceBefore = curves.getPrice(supply, 1);
          uint256 price = curves.getPrice(supply, _amount);
          (uint256 protocolFee, uint256 subjectFee, uint256 referralFee, uint256 holdersFee, uint256 totalFee) = curves.getFees(price); 
          if(msg.value > msg.sender.balance)return; 
          if(msg.value < price +totalFee) return; 
      
          
        hevm.prank(msg.sender); 
        try curves.buyCurvesToken{value: msg.value }(msg.sender, _amount){
            uint256 supplyAfter = curves.curvesTokenSupply(msg.sender);
            uint256 priceAfter = curves.getPrice(supplyAfter, 1);
            assertEq(supplyAfter, supply+_amount, "Supply didn't increase");
            assertGte(priceAfter, priceBefore, "price should increase"); 
            hasAReference[msg.sender]= true; 
         //   amountDeposited[msg.sender][msg.sender]+=_amount; 
        } catch {
          assert(false);
       // assertWithMsg(false, "buyCurvesToken should not revert.");
        }

        }
        function test_buyCurvesTokensForUser(uint256 _amount, uint256 _whichUser) external payable  {
         _whichUser = clampBetween(_whichUser, 1,3); 
         address user = _chooseUser(_whichUser); 
         if(!hasAReference[user])return; 
         _amount=clampBetween(_amount, 1, 100_000);
        uint256 userClaimable = feeSplitter.getClaimableFees(user, user); 
          uint256 supply = curves.curvesTokenSupply(user);
            uint256 priceBefore = curves.getPrice(supply, 1);

          uint256 price = curves.getPrice(supply, _amount);
          (, , , , uint256 totalFee) = curves.getFees(price);
          if(msg.value > msg.sender.balance)return; 
          if(msg.value < price +totalFee) return; 
           hevm.prank(msg.sender); 
        try curves.buyCurvesToken{value: msg.value }(user, _amount){
         uint256 supplyAfter = curves.curvesTokenSupply(user);
            uint256 priceAfter = curves.getPrice(supplyAfter, 1);
            
            assertEq(supplyAfter, supply+_amount, "Supply didn't increase");
            if(supplyAfter>supply){
            assertGt(priceAfter, priceBefore, "price should increase");
            } else {
            assertEq(priceAfter, priceBefore, "price should be egal");
            }
            assertEq(curves.curvesTokenBalance(user, USER1)+curves.curvesTokenBalance(user, USER2)+curves.curvesTokenBalance(user, USER3)+curves.curvesTokenBalance(user, address(curves)), supplyAfter, "The amount should be right");
          //  amountDeposited[user][msg.sender]+=_amount; 
          if(user != msg.sender && feeSplitter.balanceOf(user,user) !=0) {
            assertGt(feeSplitter.getClaimableFees(user, user), userClaimable, "the user cannot have fees"); 
          }

        } catch {
          assert(false);
       // assertWithMsg(false, "buyCurvesToken should not revert.");
        }

        }
 
 function test_sellCurvesTokens(uint256 _whichUser, uint256 _amount ) external {
    _whichUser = clampBetween(_whichUser, 1,3); 
         address user = _chooseUser(_whichUser); 
         if(!hasAReference[user])return; 
         uint256 balancBefore = curves.curvesTokenBalance(user, msg.sender);
         uint256 supply = curves.curvesTokenSupply(user);
                     uint256 priceBefore = curves.getPrice(supply, 1);
    _amount = clampBetween(_amount,0,balancBefore);
    _amount = clampBetween(_amount,0,supply-1);
    uint256 _userBalanceBefore = msg.sender.balance;
    if(balancBefore ==0) return;
    if(feeSplitter.totalSupply(user)/1e18==_amount)return; 
    emit LogUint256("the balance of the sender before", balancBefore); 
    hevm.prank(msg.sender);
    try curves.sellCurvesToken(user,_amount){
        uint256 _userBalanceAfter = msg.sender.balance;
         uint256 supplyAfter = curves.curvesTokenSupply(user);
         uint256 priceAfter = curves.getPrice(supplyAfter, 1);
          assertEq(supplyAfter, supply-_amount, "Supply didn't decrease");
          if(supplyAfter<supply){
            assertLt(priceAfter, priceBefore, "price should decrease");
            } else {
            assertEq(priceAfter, priceBefore, "price should be egal");
            }
            assertEq(curves.curvesTokenBalance(user, USER1)+curves.curvesTokenBalance(user, USER2)+curves.curvesTokenBalance(user, USER3)+curves.curvesTokenBalance(user, address(curves)), supplyAfter, "The amount should be right");
              emit LogUint256("This is the balance of sender",_userBalanceAfter);
            emit LogUint256("This is the balance of sender before",_userBalanceBefore);
          //  assertGte(_userBalanceAfter,_userBalanceBefore, "the user didn't get ETH");
      //      amountDeposited[user][msg.sender]-=_amount; 
    

    }catch {
        assertWithMsg(false, "sellCurvesToken should not revert.");

    }

 }
 function test_mint() external {
if( !hasAReference[msg.sender])return; 
if(isExternal[msg.sender]) return;
hevm.prank(msg.sender); 
try curves.mint(msg.sender) {
    isExternal[msg.sender] = true; 
} catch {
assertWithMsg(false, "Should not revert.");

}
 }
function test_withdraw(uint256 _amount, uint256 _whichUser) external {
_whichUser = clampBetween(_whichUser, 1,3); 
address user = _chooseUser(_whichUser); 
uint256 ERC20BalanceBefore;
bool wasExternal = isExternal[user];
 (,,address tokenAddressBefore) = curves.externalCurvesTokens(user);
if(wasExternal) {
    ERC20BalanceBefore =CurvesERC20(tokenAddressBefore).balanceOf(msg.sender);
}
 if(!hasAReference[user])return; 
         uint256 balancBefore = curves.curvesTokenBalance(user, msg.sender);
         uint256 supply = curves.curvesTokenSupply(user);
 _amount = clampBetween(_amount,0,balancBefore);
hevm.prank(msg.sender);
 try curves.withdraw(user, _amount) {
        isExternal[user] = true; 
        (,,address tokenAddress) = curves.externalCurvesTokens(user);
        assertWithMsg(tokenAddress!= address(0), "Token wasn't deployed");
        if(wasExternal) {
        assertEq(CurvesERC20(tokenAddress).balanceOf(msg.sender),ERC20BalanceBefore + _amount*1 ether, "The user didn't receive the tokens."); 
        }
        amountExternal+= _amount; 
        assertEq(amountExternal, curves.curvesTokenBalance(USER2, address(curves))+ curves.curvesTokenBalance(USER3, address(curves))+curves.curvesTokenBalance(USER1, address(curves)), "Some amount was gained");
        amountDeposited[user][msg.sender]+=_amount;
 } catch {
    assertWithMsg(false, "Should not revert.");

 }


}
        function test_deposit(uint256 _whichUser, uint256 _amount) external {
            _whichUser = clampBetween(_whichUser, 1,3); 
            address user = _chooseUser(_whichUser); 
            uint256 ERC20BalanceBefore;
            bool wasExternal = isExternal[user];
            (,,address tokenAddressBefore) = curves.externalCurvesTokens(user);
            if(wasExternal) {
             ERC20BalanceBefore =CurvesERC20(tokenAddressBefore).balanceOf(msg.sender);
            }
        if(!hasAReference[user])return; 
        if(!wasExternal)return;
        _amount= clampBetween(_amount,0,amountDeposited[user][msg.sender]);
        hevm.prank(msg.sender); 
        try curves.deposit(user, _amount*1 ether) {
        (,,address tokenAddress) = curves.externalCurvesTokens(user);
        amountExternal-= _amount; 

        assertEq(CurvesERC20(tokenAddress).balanceOf(msg.sender),ERC20BalanceBefore - _amount*1 ether, "The user didn't receive the tokens."); 
        amountDeposited[user][msg.sender]-=_amount;
        } catch {    
            assertWithMsg(false, "Should not revert.");
}
        }


        function test_claimFees(uint256 _whichUser) external {
            _whichUser = clampBetween(_whichUser, 1,3); 
            address user = _chooseUser(_whichUser); 
           uint256 feesClaimable = feeSplitter.getClaimableFees(user, msg.sender); 
           if(feesClaimable ==0)return; 
                   (,,address tokenAddress) = curves.externalCurvesTokens(user);

           emit LogUint256( "This is the fees of the user",feeSplitter.getClaimableFees(user, msg.sender)); 
           emit LogUint256( "this is the balance before", feeSplitter.balanceOf(user, msg.sender)/1e18);
           emit LogUint256("This is the feeSplitter balance", address(feeSplitter).balance); 
           emit LogUint256("This is the external balance of the user", CurvesERC20(tokenAddress).balanceOf(msg.sender)/1e18 );
            hevm.prank(msg.sender); 
            try feeSplitter.claimFees(user) {

            } catch {
            assertWithMsg(false, "Should not revert.");

            }
        }
        function test_transfer(uint256 _whichUser, uint256 _toWhichUser, uint256 _amount) external {
             _whichUser = clampBetween(_whichUser, 1,3); 
            address user = _chooseUser(_whichUser); 
          //  if(!hasAReference[user])return;
            _toWhichUser = clampBetween(_toWhichUser, 1,3); 
            address toUser = _chooseUser(_toWhichUser);
         uint256 balancBefore = curves.curvesTokenBalance(user, msg.sender);
         _amount = clampBetween(_amount, 0, balancBefore);

            hevm.prank(msg.sender); 
            try curves.transferCurvesToken(user,toUser,_amount) {} catch {
                assertWithMsg(false, "Should not revert"); 
            }


        }
        function test_transferAll(uint256 _whichUser, uint256 _toWhichUser) external {
             _whichUser = clampBetween(_whichUser, 1,3); 
            address user = _chooseUser(_whichUser); 
          //  if(!hasAReference[user])return;
            _toWhichUser = clampBetween(_toWhichUser, 1,3); 
            address toUser = _chooseUser(_toWhichUser);

            hevm.prank(msg.sender); 
            try curves.transferAllCurvesTokens(toUser) {} catch {
                assertWithMsg(false, "Should not revert"); 
            }


        }
        function test_ClaimBatching() external  {
            address[] memory tokens = feeSplitter.getUserTokens(msg.sender);

   hevm.prank(msg.sender); 
   try feeSplitter.batchClaiming(tokens) {} catch {
    assertWithMsg(false, "Should not revert"); 
   }
        }
        function _chooseUser(uint256 _whichUser) internal pure returns(address user){
         if(_whichUser==1) user= USER1;
         if(_whichUser==2)user= USER2;
         if(_whichUser==3)user= USER3;
        }
        receive() payable external {}
}