pragma solidity ^0.4.23;

contract Escrow {
    enum TxStatus { Completed, Pending, Canceled, Refunded, InConflict }
    struct PurchaseTransaction {
        uint itemPrice;
        uint Deposit;
        bool isBuyerDepositValid;
        bool isSellerDepositValid;
        address buyer;
        address seller;
        address arbiter;
        bool isArbiterEngaged;
        uint createdOn;
        uint refundPossibleAfterDays;
        TxStatus status;
    }

    event transactionCreation(uint indexed transactionID, uint itemPrice, address buyer, address seller);
    event transactionRefund(uint indexed transactionID, uint itemPrice, address buyer, address seller, uint when);
    event transactionComplete(uint indexed transactionID);
    event transactionCanceled(uint indexed transactionID);
    event buyerDeposit(uint indexed transactionID);
    event sellerDeposit(uint indexed transactionID);
    event itemSent(uint indexed transactionID, address seller);
    event arbiterEngage(uint indexed transactionID, address indexed arbiter);
    event conflictSolved(uint indexed transactionID, address indexed arbiter, address winner);


    PurchaseTransaction[] transactions;

    modifier transactionExists(uint _transactionID) {
        require(transactions.length - 1 >= _transactionID);
        _;
    }

    modifier onlyBuyer(uint _transactionID) {
        require(transactions[_transactionID].buyer == msg.sender);
        _;
    }

    modifier onlySeller(uint _transactionID) {
        require(transactions[_transactionID].seller == msg.sender);
        _;
    }

    modifier onlySellerOrBuyer(uint _transactionID) {
        require(transactions[_transactionID].seller == msg.sender || transactions[_transactionID].buyer == msg.sender);
        _;
    }

    modifier onlyArbiter(uint _transactionID) {
        require(transactions[_transactionID].arbiter == msg.sender);
        _;
    }

    modifier arbiterEngaged(uint _transactionID) {
        require(transactions[_transactionID].isArbiterEngaged);
        _;
    }

    modifier enoughDeposit(uint _transactionID) {
        require(msg.value >= transactions[_transactionID].Deposit);
        _;
    }

    modifier depositsAreValid(uint _transactionID) {
        require(transactions[_transactionID].isBuyerDepositValid && transactions[_transactionID].isSellerDepositValid);
        _;
    }

    modifier conflictWinnerValid(uint _transactionID, address winner) {
        require(transactions[_transactionID].seller == winner || transactions[_transactionID].buyer == winner);
        _;
    }

    modifier arbiterNotEngaged(uint _transactionID) {
        require(!transactions[_transactionID].isArbiterEngaged);
        _;
    }

    function createNewTransaction(
        address _buyer, 
        address _seller, 
        uint _itemPrice, 
        address _arbiter, 
        uint _refundAfterDays) public returns (uint) 
    {
        PurchaseTransaction memory transaction = PurchaseTransaction({
            itemPrice: _itemPrice,
            Deposit: _itemPrice * 2,
            isBuyerDepositValid: false,
            isSellerDepositValid: false,
            buyer: _buyer,
            seller: _seller,
            arbiter: _arbiter,
            isArbiterEngaged: false,
            createdOn: now,
            refundPossibleAfterDays: _refundAfterDays * 1 days,
            status: TxStatus.Pending
            });
        uint transactionID = transactions.push(transaction) - 1;
        emit transactionCreation(transactionID, _itemPrice, _buyer, _seller);
        return transactionID;
    }

    function depositAsBuyer(uint _transactionID) public payable
    onlyBuyer(_transactionID) 
    transactionExists(_transactionID)
    enoughDeposit(_transactionID) 
    {
        transactions[_transactionID].isBuyerDepositValid = true;
        emit buyerDeposit(_transactionID);
    }

    function depositAsSeller(uint _transactionID) public payable
    onlySeller(_transactionID) 
    transactionExists(_transactionID)
    enoughDeposit(_transactionID) 
    {
        transactions[_transactionID].isBuyerDepositValid = true;
        emit sellerDeposit(_transactionID);
    }

    function cancelTransaction(uint _transactionID) public 
    onlySellerOrBuyer(_transactionID)
    transactionExists(_transactionID) 
    {
        transactions[_transactionID].status = TxStatus.Canceled;
        emit transactionCanceled(_transactionID);
    }

    function declareItemAsSent(uint _transactionID) public 
    onlySeller(_transactionID)
    depositsAreValid(_transactionID)
    transactionExists(_transactionID)
    {
        emit itemSent(_transactionID, msg.sender);
    }

    function declareItemAsDeliveried(uint _transactionID) public 
    onlyBuyer(_transactionID)
    depositsAreValid(_transactionID)
    transactionExists(_transactionID)
    {
        transactions[_transactionID].status = TxStatus.Completed;
        transactions[_transactionID].seller.transfer(transactions[_transactionID].Deposit + transactions[_transactionID].Deposit / 2);
        transactions[_transactionID].buyer.transfer(transactions[_transactionID].Deposit / 2);
        emit transactionComplete(_transactionID);
    }

    
    function askRefund(uint _transactionID) public
    onlySellerOrBuyer(_transactionID)
    transactionExists(_transactionID)
    depositsAreValid(_transactionID)
    {
        transactions[_transactionID].status = TxStatus.Refunded;
        transactions[_transactionID].seller.transfer(transactions[_transactionID].Deposit);
        transactions[_transactionID].buyer.transfer(transactions[_transactionID].Deposit);
        emit transactionRefund(
            _transactionID, 
            transactions[_transactionID].itemPrice,
            transactions[_transactionID].buyer,
            transactions[_transactionID].seller,
            now);
    }

    function engageArbiter(uint _transactionID) public 
    onlySellerOrBuyer(_transactionID)
    transactionExists(_transactionID)
    depositsAreValid(_transactionID)
    arbiterNotEngaged(_transactionID)
    {
        transactions[_transactionID].isArbiterEngaged = true;
        transactions[_transactionID].status = TxStatus.InConflict;
        emit arbiterEngage(_transactionID, transactions[_transactionID].arbiter);
    }

    function resolveConflict(uint _transactionID, address winner) public 
    onlyArbiter(_transactionID)
    arbiterEngaged(_transactionID)
    transactionExists(_transactionID)
    conflictWinnerValid(_transactionID, winner)
    {
        if(winner == transactions[_transactionID].seller) {
            transactions[_transactionID].seller.transfer(transactions[_transactionID].Deposit + transactions[_transactionID].Deposit / 2);
        } else if(winner == transactions[_transactionID].buyer) {
            transactions[_transactionID].buyer.transfer(transactions[_transactionID].Deposit);
        }
        transactions[_transactionID].status = TxStatus.Completed;
        emit conflictSolved(_transactionID, transactions[_transactionID].arbiter, winner);
    }

}