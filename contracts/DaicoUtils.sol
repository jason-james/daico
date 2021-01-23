// SPDX-License-Identifier: MIT
pragma solidity 0.7.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";

/* 
    Library containing functions that are handled the same way among all types of sales.
*/

library DaicoUtils {
    // Data in below struct should be applicable for all types of sales
    struct Data {
        bool initialised;
        IERC20 TOKEN;
        uint256 START;
        uint256 END;
        uint256 TOTAL_TOKENS_FOR_SALE;
        uint256 MINIMUM_FUNDING;
        uint256 FUNDING_CAP;
        uint256 devTapRate;
        // uint256 investorTapRate;
        mapping(address => uint256) provided;
        uint256 totalFunding;
        uint256 lastWithdrawn;
    }

    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    event FundsWithdrawn(address indexed account, uint256 amount);
    event FundsDeposited(address indexed investor, uint256 amount);
    event TokensWithdrawn(address indexed investor, uint256 amount);
    event TokensWithdrawnAfterFailedSale();
    event FundsTapped(address recipient, uint256 amount);

    function claim(Data storage self) public {
        require(
            block.timestamp > self.END,
            "The offering has not finished yet"
        );
        require(
            self.provided[msg.sender] > 0,
            "You did not contribute to this offering"
        );

        uint256 userProvided = self.provided[msg.sender];
        self.provided[msg.sender] = 0;

        if (self.totalFunding >= self.MINIMUM_FUNDING) {
            uint256 tokenAmount =
                self.TOTAL_TOKENS_FOR_SALE.mul(userProvided).div(
                    self.totalFunding
                );
            self.TOKEN.safeTransfer(msg.sender, tokenAmount);
            emit TokensWithdrawn(msg.sender, tokenAmount);
        } else {
            msg.sender.transfer(userProvided);
            emit FundsWithdrawn(msg.sender, userProvided);
        }
    }

    function withdrawTokenAfterFailedSale(Data storage self) public {
        require(self.END < block.timestamp, "The offering must be completed");
        require(
            self.totalFunding < self.MINIMUM_FUNDING,
            "The required amount has been provided!"
        );
        self.TOKEN.safeTransfer(
            msg.sender,
            self.TOKEN.balanceOf(address(this))
        );
        emit TokensWithdrawnAfterFailedSale();
    }

    function getWithdrawableFunds(Data storage self)
        public
        view
        returns (uint256)
    {
        uint256 withdrawable =
            self.devTapRate.mul(block.timestamp.sub(self.lastWithdrawn));

        if (address(this).balance < withdrawable) {
            withdrawable = address(this).balance;
        }
        return withdrawable;
    }

    function tap(Data storage self) public {
        uint256 withdrawable = getWithdrawableFunds(self);
        require(withdrawable > 0, "There are no more funds to withdraw");

        self.lastWithdrawn = block.timestamp;
        msg.sender.transfer(withdrawable);
        emit FundsTapped(msg.sender, withdrawable);
    }

    // function increase_tap(Data storage self, uint256 new_tap) {
    //     self.withdraw()
    //     self.tap = new_tap
    // }
}
