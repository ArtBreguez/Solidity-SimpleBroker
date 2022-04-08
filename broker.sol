// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

interface IERC20Token {
    function balanceOf(address owner) external returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function decimals() external returns (uint256);
}

contract TokenSale {
    IERC20Token public tokenContract;  // the token being sold
    uint256 public price;              // the price, in wei, per token
    address owner;

    uint256 public tokensSold;

    event Sold(address indexed buyer, uint256 amount);

    modifier safeMath(uint256 numberOfTokens, uint256 price) {
        safeMultiply(numberOfTokens, price);
        _;
    }

    constructor (IERC20Token _tokenContract, uint256 _price) public {
        owner = msg.sender;
        tokenContract = _tokenContract;
        price = _price;
    }

    // Guards against integer overflows
    function safeMultiply(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        } else {
            uint256 c = a * b;
            assert(c / a == b);
            return c;
        }
    }

    function buyTokens(uint256 numberOfTokens) public payable safeMath(numberOfTokens, price) {
        //require(msg.value == safeMultiply(numberOfTokens, price), "O valor enviado não é compativel com a quantidade de tokens que se deseja comprar");
        IERC20Token tokenContractBalance = IERC20Token(tokenContract);
        //uint256 balance = tokenContractBalance.balanceOf(this);
        uint256 balance = tokenContractBalance.balanceOf(address(this));
        uint256 scaledAmount = safeMultiply(numberOfTokens, uint256(10) ** tokenContract.decimals());

        //require(tokenContractBalance.balanceOf(this) >= scaledAmount);

        emit Sold(msg.sender, numberOfTokens);
        tokensSold += numberOfTokens;

        require(tokenContract.transfer(msg.sender, scaledAmount));
    }

    function endSale() public {
        require(msg.sender == owner);

        // Send unsold tokens to the owner.
        require(tokenContract.transfer(owner, tokenContract.balanceOf(this)));

        msg.sender.transfer(address(this).balance);
    }

    function showContractTokenBalance() external returns(uint256) {
        return tokenContract.balanceOf(this);
    }
}
