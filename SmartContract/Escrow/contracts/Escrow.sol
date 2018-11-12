pragma solidity ^0.4.23;

contract Escrow {
    enum TxStatus { Completed, Pending, Canceled, Refunded }
    struct PurchaseTransaction {
        uint itemPrice;
        uint Deposit;
        bool isBuyerDepositValid;
        bool isSellerDepositValid;
        address buyer;
        address seller;
        address arbiter;
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

    modifier enoughDeposit(uint _transactionID) {
        require(msg.value >= transactions[_transactionID].Deposit);
        _;
    }

    modifier depositsAreValid(uint _transactionID) {
        require(transactions[_transactionID].isBuyerDepositValid && transactions[_transactionID].isSellerDepositValid);
        _;
    }

    function createNewTransaction(address _buyer, address _seller, uint _itemPrice, address _arbiter, uint _refundAfterDays) public returns (uint) {
        PurchaseTransaction memory transaction = PurchaseTransaction({
            itemPrice: _itemPrice,
            Deposit: _itemPrice * 2,
            isBuyerDepositValid: false,
            isSellerDepositValid: false,
            buyer: _buyer,
            seller: _seller,
            arbiter: _arbiter,
            createdOn: now,
            refundPossibleAfterDays: _refundAfterDays * 1 days,
            status: TxStatus.Pending
            });
        uint transactionID = transactions.push(transaction) - 1;
        emit transactionCreation(transactionID, _itemPrice, _buyer, _seller);
        return transactionID;
    }

    function depositAsBuyer(uint _transactionID) public
    onlyBuyer(_transactionID) 
    transactionExists(_transactionID)
    enoughDeposit(_transactionID) 
    {
        transactions[_transactionID].isBuyerDepositValid = true;
        emit buyerDeposit(_transactionID);
    }

    function depositAsSeller(uint _transactionID) public
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
    {
        emit itemSent(_transactionID, msg.sender);
    }

    function declareItemAsDeliveried(uint _transactionID) public 
    onlyBuyer(_transactionID)
    depositsAreValid(_transactionID)
    {
        transactions[_transactionID].status = TxStatus.Completed;
        transactions[_transactionID].seller.transfer(transactions[_transactionID].Deposit + transactions[_transactionID].Deposit / 2);
        transactions[_transactionID].buyer.transfer(transactions[_transactionID].Deposit / 2);
        emit transactionComplete(_transactionID);
    }

    // TODO
    function askRefund() public {}

    // TODO
    function engageArbiter() public {}


}