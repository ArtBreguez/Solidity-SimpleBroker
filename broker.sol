// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

/// @notice Interface for ERC20 example token

interface IERC20Token {
    function accountBalance(address _address) external view returns(uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function tokenDecimals() external view returns(uint8);
}

/// @title A contract that sells one type of token
/// @author Arthur Gonçalves Breguez
/// @notice Sell one type of ERC-20 token to accounts and colect ether at the end of sale

contract TokenSale {

    IERC20Token public tokenContract;
    uint256 private price;          
    address private owner;
    uint256 private tokensSold;

/// @notice Emit a log when a sale is made
    event sold(address indexed buyer, uint256 amount);
/// @notice Emit a log when the token sale is ended
    event saleEnded(string message);

    constructor (IERC20Token _tokenContract, uint256 _price) {
        owner = msg.sender;
        tokenContract = _tokenContract;
        price = _price;
    }

/// @notice Show the price of one token (in wei)
/// @return token_price The token price in wei
    function getPrice() external view returns(uint256 token_price) {
        return price;
    }

/// @notice Show the amount of tokens that has been sold
/// @return tokens_sold The amount of sold tokens
    function getAmountOfTokensSold() external view returns(uint256 tokens_sold) {
        return tokensSold;
    }

/// @notice Show the amount of tokens the contract has
/// @return The amount of tokens remaining in the contract
    function showContractTokenBalance() external view returns(uint256) {
        return tokenContract.accountBalance(address(this));
    }

/// @notice Buy a certain amount of tokens (using wei)
/// @param numberOfTokens The amount of tokens the msg.sender wants to buy
/// @return success Return true if the transcation is successfully
    function buyTokens(uint256 numberOfTokens) public payable returns(bool success) {
        require((msg.value == safeMultiply(numberOfTokens, price)),"Amount of ether sent is not compatible with the amount of tokens");
        uint256 scaledAmount = safeMultiply(numberOfTokens, uint256(10) ** tokenContract.tokenDecimals());
        require(tokenContract.accountBalance(address(this)) >= scaledAmount, "Not enough tokens to sale");
        emit sold(msg.sender, numberOfTokens);
        tokensSold += numberOfTokens;
        require(tokenContract.transfer(msg.sender, scaledAmount), "Transaction Failed!");
        return true;
    }

/// @notice End the token sale of the contract (send the remaining tokens to the owner as the colected ether)
    function endSale() public {
        require(msg.sender == owner, "Not the owner!");
        require(tokenContract.transfer(owner, tokenContract.accountBalance(address(this))),"Failed to send the remain tokens"); 
        payable(msg.sender).transfer(address(this).balance);
        emit saleEnded("The sale has been finished!");
    }

/// @notice Validates if an arithmetic operation would result in an integer overflow/underflow
/// @param a First value of the computation
/// @param b Second value of the computation
/// @return The product of a and b
    function safeMultiply(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        } else {
            uint256 c = a * b;
            assert(c / a == b);
            return c;
        }
    }
}
