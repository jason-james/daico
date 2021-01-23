// SPDX-License-Identifier: MIT
pragma solidity 0.7.4;

import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "./DaicoUtils.sol";

contract BasicSale is Ownable {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;
    using DaicoUtils for DaicoUtils.Data;

    DaicoUtils.Data self;

    event FundsWithdrawn(address indexed account, uint256 amount);
    event FundsDeposited(address indexed investor, uint256 amount);
    event TokensWithdrawn(address indexed investor, uint256 amount);
    event TokensWithdrawnAfterFailedSale();
    event FundsTapped(address recipient, uint256 amount);

    function init(
        address _fundRecipient,
        IERC20 _token,
        uint256 _totalForSale,
        uint256 _startDate,
        uint256 _endDate,
        uint256 _minimumFunding,
        uint256 _initialDevTapRate,
        // uint256 _initialInvestorTapRate,
        uint256 _fundingCap
    ) public onlyOwner {
        require(!self.initialised, "Contract already initialised");
        require(_endDate > _startDate, "End date cannot be before start date");
        require(
            _minimumFunding > 0,
            "The minimum funding amount must be greater than 0"
        );

        self.TOKEN = _token;
        self.TOTAL_TOKENS_FOR_SALE = _totalForSale;
        self.START = _startDate;
        self.END = _endDate;
        self.MINIMUM_FUNDING = _minimumFunding;
        self.FUNDING_CAP = _fundingCap;

        self.devTapRate = _initialDevTapRate;
        // self.investorTapRate = _initialInvestorTapRate;
        self.lastWithdrawn = _endDate;

        self.TOKEN.safeTransferFrom(
            _fundRecipient,
            address(this),
            _totalForSale
        );
        self.initialised = true;
    }

    receive() external payable {
        require(
            self.START <= block.timestamp,
            "The offering has not started yet"
        );
        require(block.timestamp <= self.END, "The offering has already ended");

        self.totalFunding += msg.value;
        self.provided[msg.sender] += msg.value;

        emit FundsDeposited(msg.sender, msg.value);
    }

    /// @notice Investors claim the tokens owed to them based on their contribution amount.
    function claim() external {
        self.claim();
    }

    /// @notice Daico owner withdraws all tokens if the minimum funding amount is not reached.
    function withdrawTokenAfterFailedSale() external onlyOwner {
        self.withdrawTokenAfterFailedSale();
    }

    /// @notice Daico owner taps current withdrawable amount.
    function tap() external onlyOwner {
        self.tap();
    }
}
