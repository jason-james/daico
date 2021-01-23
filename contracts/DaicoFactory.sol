// SPDX-License-Identifier: MIT
pragma solidity 0.7.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "./BasicSale.sol";
import "./CloneFactory.sol";
import "./RadicoSystemAuthority.sol";

contract DaicoFactory is CloneFactory, RadicoSystemAuthority {
    address public baseBasicSaleAddress;
    //   address public baseDutchAuctionAddress; future (example)
    //   address public nftTokenAddress; future (example)

    event BasicSaleCreated(address createdBasicSaleAddress);

    constructor(address radicoSystemAddress)
        RadicoSystemAuthority(radicoSystemAddress)
    {} // This calls the constructor of the RadicoSystemAuthority

    function setBaseBasicSaleAddress(address _baseBasicSaleAddress)
        public
        onlyRadicoSystem
    {
        baseBasicSaleAddress = _baseBasicSaleAddress;
    }

    function createBasicSale(
        address _fundRecipient,
        IERC20 _token,
        uint256 _totalForSale,
        uint256 _startDate,
        uint256 _endDate,
        uint256 _minimumFunding,
        uint256 _initialDevTapRate,
        // uint256 _initialInvestorTapRate,
        uint256 _fundingCap
    ) external returns (address) {
        address createdBasicSaleAddr = createClone(baseBasicSaleAddress);
        BasicSale clone = BasicSale(payable(createdBasicSaleAddr));
        clone.init(
            _fundRecipient,
            _token,
            _totalForSale,
            _startDate,
            _endDate,
            _minimumFunding,
            _initialDevTapRate,
            // _initialInvestorTapRate,
            _fundingCap
        );
        clone.transferOwnership(_fundRecipient);
        emit BasicSaleCreated(createdBasicSaleAddr);
        return createdBasicSaleAddr;
    }

    receive() external payable {
        revert();
    }

    // function createDutchAuction() public {
    // future (example)
    //}
}
