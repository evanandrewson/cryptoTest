// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract EvanCoin is ERC20, Pausable, Ownable, ReentrancyGuard {
    // Tokenomics
    uint256 public constant TOTAL_SUPPLY = 1_000_000_000 * 10**18; // 1 billion tokens
    uint256 public constant MAX_WALLET_SIZE = (TOTAL_SUPPLY * 2) / 100; // 2% max wallet size
    
    // Fee configuration
    uint256 public liquidityFee = 2; // 2% auto-liquidity
    uint256 public redistributionFee = 3; // 3% holder rewards
    uint256 public burnFee = 1; // 1% burn rate
    
    // PancakeSwap pair address
    address public pancakeSwapPair;
    
    // Exclusions from fees
    mapping(address => bool) public isExcludedFromFees;
    
    // Anti-bot mapping
    mapping(address => bool) public isBlacklisted;
    
    // Events
    event BlacklistUpdated(address indexed account, bool isBlacklisted);
    event FeeUpdated(string feeType, uint256 newValue);
    
    constructor() ERC20("EvanCoin", "EVAN") {
        // Mint initial supply
        _mint(msg.sender, TOTAL_SUPPLY);
        
        // Exclude owner and contract from fees
        isExcludedFromFees[owner()] = true;
        isExcludedFromFees[address(this)] = true;
    }
    
    // Override transfer function to implement fees and protections
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual override whenNotPaused nonReentrant {
        require(!isBlacklisted[sender] && !isBlacklisted[recipient], "Address is blacklisted");
        require(amount > 0, "Transfer amount must be greater than zero");
        
        // Check max wallet size
        if (recipient != pancakeSwapPair) {
            require(
                balanceOf(recipient) + amount <= MAX_WALLET_SIZE,
                "Exceeds maximum wallet size"
            );
        }
        
        // Calculate fees
        uint256 totalFees = 0;
        if (!isExcludedFromFees[sender] && !isExcludedFromFees[recipient]) {
            uint256 liquidityAmount = (amount * liquidityFee) / 100;
            uint256 redistributionAmount = (amount * redistributionFee) / 100;
            uint256 burnAmount = (amount * burnFee) / 100;
            
            totalFees = liquidityAmount + redistributionAmount + burnAmount;
            
            // Handle liquidity fee
            super._transfer(sender, address(this), liquidityAmount);
            
            // Handle redistribution
            super._transfer(sender, address(this), redistributionAmount);
            
            // Handle burn
            super._transfer(sender, address(0), burnAmount);
        }
        
        // Transfer remaining amount
        super._transfer(sender, recipient, amount - totalFees);
    }
    
    // Owner functions
    function setBlacklist(address account, bool blacklisted) external onlyOwner {
        isBlacklisted[account] = blacklisted;
        emit BlacklistUpdated(account, blacklisted);
    }
    
    function setPancakeSwapPair(address _pair) external onlyOwner {
        pancakeSwapPair = _pair;
    }
    
    function excludeFromFees(address account, bool excluded) external onlyOwner {
        isExcludedFromFees[account] = excluded;
    }
    
    function pause() external onlyOwner {
        _pause();
    }
    
    function unpause() external onlyOwner {
        _unpause();
    }
    
    // Emergency function to recover tokens
    function recoverToken(address tokenAddress, uint256 amount) external onlyOwner {
        IERC20(tokenAddress).transfer(owner(), amount);
    }
}

