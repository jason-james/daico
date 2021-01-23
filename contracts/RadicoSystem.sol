// SPDX-License-Identifier: MIT
pragma solidity 0.7.4;

import "@openzeppelin/contracts/access/Ownable.sol";

import "./DaicoFactory.sol";
import "./BasicSale.sol";

/* In here we can have global governance functions if desired, 
  for example pausing all sales if a bug is found in the contracts.

  This contract is also responsible for initialising the system. When deployed, 
  it creates the base auction contracts, passing them into the DaicoFactory constructor.

  It also has the ability to update DaicoFactory dependencies, for example, 
  to change the contract addresses it uses to clone.

  Any functions in here which update state should probably be onlyOwner.
*/

contract RadicoSystem is Ownable {
    BasicSale public basicSale;
    DaicoFactory public daicoFactory;
    address public factoryContractAddress;

    event DaicoFactoryCreated(address contractAddress);

    constructor() {
        basicSale = new BasicSale();
        daicoFactory = new DaicoFactory(address(this));
        daicoFactory.setBaseBasicSaleAddress(address(basicSale));

        factoryContractAddress = address(daicoFactory);
        emit DaicoFactoryCreated(address(daicoFactory));
    }
}
