const BasicSale = artifacts.require("BasicSale");
const CloneFactory = artifacts.require("CloneFactory");
const DaicoFactory = artifacts.require("DaicoFactory");
const DaicoUtils = artifacts.require("DaicoUtils");
const RadicoSystem = artifacts.require("RadicoSystem");
const RadicoSystemAuthority = artifacts.require("RadicoSystemAuthority");

const ERC20 = artifacts.require("ERC20PresetMinterPauser");

const all = [
    BasicSale,
    CloneFactory,
    DaicoFactory,
    DaicoUtils,
    RadicoSystem,
    RadicoSystemAuthority
]

module.exports = async function (deployer, network, accounts) {

    if (network == "development") {
        await deployer.deploy(ERC20, "My Token", "TKN")
    }

    await deployer.deploy(DaicoUtils)
    await deployer.link(DaicoUtils, all)

    await deployer.deploy(CloneFactory)
    await deployer.link(CloneFactory, all)

    await deployer.deploy(RadicoSystem)
    await deployer.link(RadicoSystem, all)

    await deployer.deploy(BasicSale)
    await deployer.link(BasicSale, all)
};
