// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title BMC1Token - BeMyCrypto1 ERC-20 Utility Token
/// @author Ben Macedo, CEO of BMC1 BeMyCrypto1 LLC
/// @notice BMC1 is a utility token supporting the Be My Coverage1 ecosystem
/// @dev 18 decimals, fixed supply of 6.5 trillion, 0.02% fee to company treasury
/// @custom:contact bmc1.ceo.macedo@bemycrypto1.online
/// @custom:company BMC1 BeMyCrypto1 LLC
/// @custom:purpose Company sustainability & ecosystem support

import "@openzeppelin/contracts/access/Ownable.sol";

contract BMC1Token is Ownable {

    string private _name = "BMC1";
    string private _symbol = "BMC1";
    uint8 private _decimals = 18;
    uint256 private _totalSupply = 6_500_000_000_000 * 10 ** 18; // 6.5 trillion
    uint256 public constant FEE_BASIS_POINTS = 2; // 0.02% fee

    address public treasury = 0x0A0A4D16a496A45FEd4f4a8d107e10368a8209cc;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    // ---------------- Constructor ---------------- //
    constructor() Ownable(0xF96a6aecBE8bb49eEdA828F0818d79f6c0536AA2) {
        // Mint entire supply to the owner
        _balances[0xF96a6aecBE8bb49eEdA828F0818d79f6c0536AA2] = _totalSupply;
        emit Transfer(address(0), 0xF96a6aecBE8bb49eEdA828F0818d79f6c0536AA2, _totalSupply);
    }

    // ---------------- ERC20 Standard Functions ---------------- //
    function name() public view returns (string memory) { return _name; }
    function symbol() public view returns (string memory) { return _symbol; }
    function decimals() public view returns (uint8) { return _decimals; }
    function totalSupply() public view returns (uint256) { return _totalSupply; }
    function balanceOf(address account) public view returns (uint256) { return _balances[account]; }
    function allowance(address owner, address spender) public view returns (uint256) { return _allowances[owner][spender]; }

    function approve(address spender, uint256 amount) public returns (bool) {
        require(spender != address(0), "ERC20: approve to zero address");
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        require(spender != address(0), "ERC20: approve to zero address");
        _allowances[msg.sender][spender] += addedValue;
        emit Approval(msg.sender, spender, _allowances[msg.sender][spender]);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        require(spender != address(0), "ERC20: approve to zero address");
        require(_allowances[msg.sender][spender] >= subtractedValue, "ERC20: decreased allowance below zero");
        _allowances[msg.sender][spender] -= subtractedValue;
        emit Approval(msg.sender, spender, _allowances[msg.sender][spender]);
        return true;
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        require(_allowances[sender][msg.sender] >= amount, "ERC20: transfer amount exceeds allowance");
        _allowances[sender][msg.sender] -= amount;
        _transfer(sender, recipient, amount);
        emit Approval(sender, msg.sender, _allowances[sender][msg.sender]);
        return true;
    }

    // ---------------- Internal Transfer Logic ---------------- //
    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from zero address");
        require(recipient != address(0), "ERC20: transfer to zero address");
        require(_balances[sender] >= amount, "ERC20: transfer amount exceeds balance");

        uint256 feeAmount = (amount * FEE_BASIS_POINTS) / 10_000;
        uint256 netAmount = amount - feeAmount;

        _balances[sender] -= amount;
        _balances[recipient] += netAmount;
        _balances[treasury] += feeAmount;

        emit Transfer(sender, recipient, netAmount);
        if(feeAmount > 0){
            emit Transfer(sender, treasury, feeAmount);
        }
    }

    // ---------------- Treasury Management ---------------- //
    /// @notice Allows owner to update treasury address if needed
    function setTreasury(address newTreasury) external onlyOwner {
        require(newTreasury != address(0), "ERC20: treasury cannot be zero address");
        treasury = newTreasury;
    }

}
