// SPDX-License-Identifier: MIT

pragma solidity ^0.8.2;

import {IERC20} from "./IERC20.sol";

abstract contract WorldToken is IERC20 { 
    string public           name = "World Token";
    string public           symbol = "WRD";
    uint8  public constant  decimals = 18;
    
    uint256 private         _totalSupply;

    address public          owner;

    mapping (address => uint256)                     private _balances;
    mapping (address => mapping(address => uint256)) private _allowances;

    modifier IsOwner() {
        require(msg.sender == owner, "Only Owner");
        _;
    }
    
    function totalSupply() external view override  returns (uint256) { 
        return _totalSupply;
    }

    function balanceOf(address acc) external view override  returns (uint256) {
        return _balances[acc];
    }

    function transfer(address to, uint256 amount) external override returns(bool){
        _transfer(msg.sender, to, amount);
        return true;
    }

    function allowance(address owner, address spender) external view returns(uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) external override returns(bool) { 
        _approve(msg.sender, spender, amount);
        return true;
    }

    
    function transferFrom(address from, address to, uint256 amount) external override  returns(bool) {
            uint256 currAllowance = _allowances[from][msg.sender];
            
            require (currAllowance >= amount, "Error: Insufficient balance");
            
            _approve(from, msg.sender, currAllowance);
            _transfer(from, to, amount);

            return true;
    }

    function _transfer(address from, address to, uint256 amount) internal {
            require (from != address(0), "Error: From 0");
            require (to != address(0), "Error: To 0");
            require (_balances[from] >= amount, "Insufficient balance on transaction");

            _balances[from] -= amount;
            _balances[to] += amount;

            emit Transfer(from, to, amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal { 
            require (owner != address(0), "Error: Owner 0");
            require (spender != address(0), "Error: Spender 0");
            require (_balances[owner] >= amount, "Error: Insufficient balance on approval");
            
            _allowances[owner][spender] = amount;
            emit Approval(owner, spender, amount);

    }

    function mint (address to, uint256 amount) external IsOwner { 
        require(to != address(0), "Error: Owner 0");
        
        _totalSupply += amount;
        _balances[to] += amount;

        emit Transfer(address(0), to, amount);
    }

    function burn (address from, uint256 amount) external IsOwner { 
        require(from != address(0));
        require(_totalSupply >= amount, "");

        _totalSupply -= amount;
        _balances[from] -= amount;

        emit Burn(from, amount);
    }


}
 