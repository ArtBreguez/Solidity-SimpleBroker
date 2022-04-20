// SPDX-License-Identifier: GPL-3.0
        
pragma solidity >=0.6.2 <0.9.0;

// This import is automatically injected by Remix
import "remix_tests.sol"; 

// This import is required to use custom transaction context
// Although it may fail compilation in 'Solidity Compiler' plugin
// But it will work fine in 'Solidity Unit Testing' plugin
import "remix_accounts.sol";
import "/broker.sol";
import "/ERC20Token.sol";

// File name has to end with '_test.sol', this file can contain more than one testSuite contracts
contract testSuite {

    ERC20Token token;
    TokenSale broker;
    address acc0;
    address acc1;

    /// 'beforeAll' runs before all other tests
    function beforeAll() public {
        token = new ERC20Token("unit_test", "tst");
        broker = new TokenSale(IERC20Token(address(token)), 1);
        token.mint(address(broker), 100000000000000000000);
        acc0 = TestsAccounts.getAccount(0);   
        acc1 = TestsAccounts.getAccount(1);
        Assert.equal(broker.getPrice(), 1, "Price not equal 1 wei");
        Assert.equal(token.accountBalance(address(broker)), 100000000000000000000, "Invalid balance");
        
    }

    /// #sender: acc0
    /// #value: 100
    function checkSuccess() public payable{
        Assert.equal(msg.sender, acc0, "Not the sender");
        Assert.equal(msg.value, 100, "Value should be 100");
        broker.buyTokens{gas: 800000, value:100}(100);
        Assert.equal(token.accountBalance(address(broker)), 0, "Invalid balance");
        Assert.equal(token.accountBalance(address(acc0)), 100000000000000000000, "Not the same amount!");
    }

    //function checkSuccess2() public pure returns (bool) {
    //    // Use the return value (true or false) to test the contract
    //    return true;
    //}
    
    //function checkFailure() public {
    //    Assert.notEqual(uint(1), uint(1), "1 should not be equal to 1");
    //}

    /// Custom Transaction Context: https://remix-ide.readthedocs.io/en/latest/unittesting.html#customization
    /// #sender: account-1
    /// #value: 100
    //function checkSenderAndValue() public payable {
    //    // account index varies 0-9, value is in wei
    //    Assert.equal(msg.sender, TestsAccounts.getAccount(1), "Invalid sender");
    //    Assert.equal(msg.value, 100, "Invalid value");
    //}
}
