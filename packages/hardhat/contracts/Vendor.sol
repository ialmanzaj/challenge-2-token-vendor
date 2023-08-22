pragma solidity 0.8.4; //Do not change the solidity version as it negativly impacts submission grading
// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/access/Ownable.sol";
import "./YourToken.sol";
import "hardhat/console.sol";

contract Vendor is Ownable {
  uint256 public constant tokensPerEth = 100;
  uint256 public constant tokenPrice = 0.01 ether;
  event BuyTokens(address buyer, uint256 amountOfETH, uint256 amountOfTokens);

  YourToken public yourToken;

  constructor(address tokenAddress) {
    yourToken = YourToken(tokenAddress);
  }

  function vendorTokens() public view returns(uint) {
    return yourToken.balanceOf(address(this));
  }

  function myTokens() public view returns(uint) {
    return yourToken.balanceOf(msg.sender);
  }

  // ToDo: create a payable buyTokens() function:
  function buyTokens() public payable returns (bool) {
    require(msg.value > 0, "not enough eth");
    uint256 _totalTokens = msg.value * 1e18 / tokenPrice;
    payable(address(this)).call{value:msg.value}("");
    bool success = yourToken.transfer(msg.sender, _totalTokens);
    require(success, "could not transfer");
    emit BuyTokens(msg.sender, msg.value, _totalTokens);
    return true;
  }

  receive() external payable {}
  fallback() external payable {}

  // ToDo: create a withdraw() function that lets the owner withdraw ETH
  function withdraw() public onlyOwner {
    uint256 balance = address(this).balance;
    require(balance > 0, "no eth in balance");
    (bool ok, )= payable(msg.sender).call{value:balance}("");
    require(ok, "Failed to withdraw");
  }

  // ToDo: create a sellTokens(uint256 _amount) function:
  function sellTokens(uint256 _amount) public {
    require(yourToken.balanceOf(msg.sender) >= _amount);
    uint amountEth = _amount / tokenPrice * 1e14;
    bool success = yourToken.transferFrom(msg.sender, address(this), _amount);
    require(success, "could not transfer");
    payable(msg.sender).call{value: amountEth}("");
  }
}
