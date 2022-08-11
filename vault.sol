// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract vault{
   //a contract where the owner create a grant for abeneficiary.
   //allows beneficiary to withdraw.
   //alllows owner to withdraw before time elapse
   //get information of a beneficiary
   //amount of ethers in the smart contract
   //the beneficiary must deposite above a certain before he can be able to ask for a grant
   
    address owner ; 
    uint time;
   
    constructor(){   
        owner == msg.sender;
    }

    struct details{
        string name;
        uint value;
        checkStatus status; 
    }

    enum checkStatus{
        deposited,
        requestGrant,
        withdrawAll,
        withdrawHalf,
        finished
    }

    address[] public keys;
    details[] Details;

    mapping(address => details) public LenderDetails;

    modifier onlyOwner(){
        require(msg.sender == owner, "not owner");
        _;
    }

    modifier seTime(){
        require((block.timestamp + 60) > block.timestamp, "not yet time");
        _;
    }

//the contract now is set to first get the deposite of people before they ask for a grant


//ask for a grant 
    function getGrant( address addr, string memory _name) payable external seTime {
        require(msg.value > 0, "zero is allowed");
        require(addr != address(0), "not this address");
        details storage LD = LenderDetails[addr];
        LD.name = _name;
        LD.value = msg.value;
        LD.status = checkStatus.deposited;
        keys.push(addr);
        Details.push(LD);
    }

    // 0x0A098Eda01Ce92ff4A4CCb7A4fFFb5A43EBC70DC

    function withdrawGrant(address addr) external seTime{
        details storage LD = LenderDetails[addr];
        require(addr != address(0), "not this address");    //is this how to implement Zero address
        require(addr == msg.sender, "not possible oo");  
        uint _value = LD.value;
        require(LD.value > 0, "insufficient funds");
        LD.value = 0;
        LD.status = checkStatus.withdrawAll;
        payable(addr).transfer(_value);
    }

    function customWithdraw(address addr, uint Cvalue) external seTime{
        details storage LD = LenderDetails[addr];
        require(addr != address(0), "not this address");  //is this how to implement Zero address
        require(addr == msg.sender, "you are who registered for this grant");
        uint _value = LD.value;
        require(_value > Cvalue, "insufficient funds");
        uint genBal = getGenBal();
        require(genBal > Cvalue, ""); 
        LD.value = LD.value - Cvalue;
        LD.status = checkStatus.withdrawHalf;
        payable(addr).transfer(Cvalue);
    }

    function revertGrant(address addr) external  onlyOwner() {
        require(addr != address(0), "not this address"); //is this how to implement Zero address
        details storage LD = LenderDetails[addr];
        uint _value = LD.value;
        LD.value = 0;
        payable(owner).transfer(_value);
    }


    function getBenBal(address addr) external view returns(uint){
        details memory LD = LenderDetails[addr];
        return LD.value;
    }

    function getGenBal() public view returns(uint){
        return address(this).balance;
    }

    function getAllDetails() external view returns(details[] memory DS){
        address[] memory Ckeys = keys;
        DS = new details[](Ckeys.length);

        for(uint i = 0 ; i < Ckeys.length; i++){
            DS[i] = LenderDetails[Ckeys[i]];
        }
    }
}

