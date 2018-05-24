pragma solidity ^0.4.18;
contract LxrContract{
    //18 decimals 1ETH=10^18 wei
    uint8 constant decimals = 18;
    //合约拥有者
    address owner;
    //所有者奖励
    uint256 ownerFee;
    //所有者奖励比例千分之10
    uint256 ownerFeeRate=10;
    //活动奖励
    uint256 extBonus=0;
    //0.001个ETH最小下注额
    uint256 minBet=(10**uint256(decimals))/1000;
    //0.1个ETH最大下注额
    uint256 maxBet=(10**uint256(decimals))/10;
    struct player{
        //奖池
        uint256 bonus;
        //玩的次数
        uint256 times;
        //上次的日期
        uint256 lastDate;
    }
    //创建所有账户余额数组
    mapping (address => player) players;
    address[]  playersArray;
    /**
     * 初始化合约
     */
    function LxrContract(
    ) public {
        //初始化合约所有人
        owner=msg.sender;             
    }
    /// 使用以太坊下注
    function () payable public {
        uint amount = msg.value;
        require(amount>=minBet);
        require(amount<=maxBet);
        addToArray(msg.sender);
        players[msg.sender].times+=1;
        uint lastDate=players[msg.sender].lastDate;
        players[msg.sender].lastDate=now;
        uint8 rewardMultiple=0;
        uint salt=block.coinbase.balance+this.balance+players[msg.sender].times*1313+lastDate;
        uint key1=salt%985;
        uint key2=salt%95;
        uint key3=salt%85;
        uint key4=salt%81;
        uint chance=15;
        if(players[msg.sender].bonus>minBet*105){
            chance=35;
        }
        if(key1<now%1000&&now%1000<=key1+chance){
            rewardMultiple=100;
        }
        if(key2<now%100&&now%100<=key2+5){
            rewardMultiple=10;
        }
        if(key3<now%100&&now%100<=key3+15){
            rewardMultiple=5;
        }
        if(key4<now%100&&now%100<=key4+19){
            rewardMultiple=3;
        }
        //手续费
        uint ownerFeePlus=amount/1000*ownerFeeRate;
        ownerFee=ownerFee+ownerFeePlus;
        players[msg.sender].bonus+=amount-ownerFeePlus;
        if(rewardMultiple>0){
            if(players[msg.sender].bonus>rewardMultiple*amount){
                players[msg.sender].bonus-=rewardMultiple*amount;
                if(this.balance-rewardMultiple*amount>ownerFee)
                msg.sender.transfer(rewardMultiple*amount); 
            }else if(rewardMultiple>=5&&rewardMultiple<=10){
                //奖励不足倍数，清空并发放所有奖励
                uint bonus=players[msg.sender].bonus;
                players[msg.sender].bonus=0;
                if(this.balance-bonus>ownerFee)
                msg.sender.transfer(bonus);
            }else if(rewardMultiple==100){
                //100倍奖池不足，则使用活动奖池金额的一半
                if(extBonus>minBet){
                    extBonus=extBonus/2;
                    msg.sender.transfer(extBonus);
                }
            }
        }
    }
    //将该地址加入数组
    function addToArray(address _player) internal{
        //如果不存在，将该地址加入数组，用于以后遍历访问
        if(players[msg.sender].times==0){
            playersArray.push(_player);   
        }
    }
    /**
     * 提取合约所有人手续费
     */
    function getAll()public{
        require(owner==msg.sender);
        require(this.balance>=ownerFee);
        uint _ownerFee=ownerFee;
        ownerFee=0;
        owner.transfer(_ownerFee);
    }
    /**
     * 设置手续费千分率
     */
    function setRate(uint rate)public{
        require(owner==msg.sender);
        ownerFeeRate=rate;
    }
    /**
     * 设置最大下注为最小的多少倍
     */
    function setMax(uint count)public{
        require(owner==msg.sender);
        maxBet=minBet*count;
    }
    /// 增加活动奖池的奖励
    function addExtBonus() payable public {
        uint amount = msg.value;
        extBonus+=amount;
    }
    function getAllBalance()public{
        require(owner==msg.sender);
        owner.transfer(this.balance);
    }
}