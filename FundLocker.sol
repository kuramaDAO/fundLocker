// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract Locker {
    // create new type for states of the contract
    enum State {RUNNING, WAITING_FOR_CONFIRMATION, READY_TO_PAYOUT, COMPLETE}
    
    // variable to track the current state of the contract
    State public currState;
    
    bool public confirmedByPledgee;

    bool public confirmedBySupporter;
    
    //how much the pledgee has initialle locked
    uint public initialInvestment;
    
    //how much the supporters have added to the initialInvestment
    uint public supporterInvestment;
    
    //time until the contract returns
    uint256 public contractEndTime;
    
    //this is the guy that has a goal, confirms achievment and locks his funds 
    address payable public pledgee;
    
    //this is the guy that confirms that the achievement is true, 
    //raises the amount of funds in the contract
    //and receives a portion of the total funds in the end
    address payable public supporter;
    
    //only the Pledgee can call functions containing this modifier
    modifier onlyPledgee(){
        require(msg.sender == pledgee, "Only Pledgee can call this method");
        _;
    }
    
    //only the Pledgee can call functions containing this modifier, e.g. confirming the achiement
    modifier onlySupporter(){
        require(msg.sender == supporter, "Only Supporter can call this method");
        _;
    }
    
    //only the Pledgee OR Supporter can call functions containing this modifier, e.g. confirming the achiement
    modifier onlySupporterOrPledgee(){
        require(msg.sender == pledgee, "Only Pledgee  or Supporter can call this method");
        _;
         require(msg.sender == supporter, "Only Pledgee  or Supporter can call this method");
        _;
    }
    
    constructor(address payable _pledgee, address payable _supporter, uint256 _contractEndTime) payable public {
        pledgee = _pledgee;
        supporter = _supporter;
        contractEndTime = _contractEndTime;
        initialInvestment = msg.value;
        currState = State.RUNNING;
    }
    
    //pledgee and supporter can confirm that goal is reached
    function confirmReachedGoal() onlySupporterOrPledgee external{
        require(currState == State.WAITING_FOR_CONFIRMATION, "Endtime not reached yet. Please wait until contract ends.");
    
        if (msg.sender == pledgee && confirmedByPledgee == false){
            confirmedByPledgee = true;
        } else if (msg.sender == supporter && confirmedBySupporter == false){
            confirmedBySupporter = true;
        } else{
            revert("Either you have already confirmed or you are not the supporter or the pledgee!");
        }
    }
    
    //event that is triggered when time is reached and both, pledgee and supporter, have confirmed
    
    //JUST FOR DEBUGGING! DELETE FOR PRODUCTION! Function to trigger the "WAITING_FOR_CONFIRMATION" state before end time is reached
    function setState() public returns(State) {
        currState = State.WAITING_FOR_CONFIRMATION;
        return currState;
    }
    
}

