// SPDX-License-Identifier: MIT
pragma solidity 0.7.4;

/// @title  Radico System Authority.
/// @notice Contract to secure function calls to that only the System contract should be able to use.
/// @dev    The `RadicoSystem` contract address is passed as a constructor parameter.
contract RadicoSystemAuthority {
    address internal radicoSystemAddress;

    /// @notice Set the address of the System contract on contract initialization.
    constructor(address _radicoSystemAddress) {
        radicoSystemAddress = _radicoSystemAddress;
    }

    /// @notice Function modifier ensures modified function is only called by TBTCSystem.
    modifier onlyRadicoSystem() {
        require(
            msg.sender == radicoSystemAddress,
            "Caller must be RadicoSystem contract"
        );
        _;
    }
}
