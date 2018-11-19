pragma solidity 0.4.24;


contract ArraysExample {
    event newNumberPushed(uint _number, uint _numbersLength);
    uint[] numbers;

    function addUser() public returns (uint[]) {
        uint randomNumb = random();
        uint length = numbers.push(randomNumb);
        emit newNumberPushed(randomNumb, length);
        return numbers;
    }

    function random() private view returns (uint8) {
        return uint8(uint256(keccak256(block.timestamp, block.difficulty))%251);
    }
}