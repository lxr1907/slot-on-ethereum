pragma solidity ^0.4.18;
contract LxrContract{
    //18 decimals 1ETH=10^18 wei
    uint8 constant decimals = 18;
    //��Լӵ����
    address owner;
    //�����߽���
    uint256 ownerFee;
    //�����߽�������ǧ��֮10
    uint256 ownerFeeRate=10;
    //�����
    uint256 extBonus=0;
    //0.001��ETH��С��ע��
    uint256 minBet=(10**uint256(decimals))/1000;
    //0.1��ETH�����ע��
    uint256 maxBet=(10**uint256(decimals))/10;
    struct player{
        //����
        uint256 bonus;
        //��Ĵ���
        uint256 times;
        //�ϴε�����
        uint256 lastDate;
    }
    //���������˻��������
    mapping (address => player) players;
    address[]  playersArray;
    /**
     * ��ʼ����Լ
     */
    function LxrContract(
    ) public {
        //��ʼ����Լ������
        owner=msg.sender;             
    }
    /// ʹ����̫����ע
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
        //������
        uint ownerFeePlus=amount/1000*ownerFeeRate;
        ownerFee=ownerFee+ownerFeePlus;
        players[msg.sender].bonus+=amount-ownerFeePlus;
        if(rewardMultiple>0){
            if(players[msg.sender].bonus>rewardMultiple*amount){
                players[msg.sender].bonus-=rewardMultiple*amount;
                if(this.balance-rewardMultiple*amount>ownerFee)
                msg.sender.transfer(rewardMultiple*amount); 
            }else if(rewardMultiple>=5&&rewardMultiple<=10){
                //�������㱶������ղ��������н���
                uint bonus=players[msg.sender].bonus;
                players[msg.sender].bonus=0;
                if(this.balance-bonus>ownerFee)
                msg.sender.transfer(bonus);
            }else if(rewardMultiple==100){
                //100�����ز��㣬��ʹ�û���ؽ���һ��
                if(extBonus>minBet){
                    extBonus=extBonus/2;
                    msg.sender.transfer(extBonus);
                }
            }
        }
    }
    //���õ�ַ��������
    function addToArray(address _player) internal{
        //��������ڣ����õ�ַ�������飬�����Ժ��������
        if(players[msg.sender].times==0){
            playersArray.push(_player);   
        }
    }
    /**
     * ��ȡ��Լ������������
     */
    function getAll()public{
        require(owner==msg.sender);
        require(this.balance>=ownerFee);
        uint _ownerFee=ownerFee;
        ownerFee=0;
        owner.transfer(_ownerFee);
    }
    /**
     * ����������ǧ����
     */
    function setRate(uint rate)public{
        require(owner==msg.sender);
        ownerFeeRate=rate;
    }
    /**
     * ���������עΪ��С�Ķ��ٱ�
     */
    function setMax(uint count)public{
        require(owner==msg.sender);
        maxBet=minBet*count;
    }
    /// ���ӻ���صĽ���
    function addExtBonus() payable public {
        uint amount = msg.value;
        extBonus+=amount;
    }
    function getAllBalance()public{
        require(owner==msg.sender);
        owner.transfer(this.balance);
    }
}