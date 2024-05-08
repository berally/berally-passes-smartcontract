// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

contract BerallyPasses is OwnableUpgradeable {
    uint256 public protocolFeePercentage;
    uint256 public managerFeePercentage;
    address public treasury;

    event ProtocolFeePercentageChanged(uint256 feePercentage);
    event ManagerFeePercentageChanged(uint256 feePercentage);
    event Trade(
        address trader,
        address manager,
        bool isBuy,
        uint256 passAmount,
        uint256 beraAmount,
        uint256 protocolBeraAmount,
        uint256 managerBeraAmount,
        uint256 supply,
        uint256 factor
    );

    mapping(uint256 => bool) public defaultFactors;

    mapping(address => mapping(address => uint256)) public passesBalance;
    mapping(address => uint256) public passesSupply;
    mapping(address => uint256) public factors;

    function initialize() public initializer {
        __Ownable_init();
        treasury = owner();

        protocolFeePercentage = 4e16;
        managerFeePercentage = 6e16;

        defaultFactors[36000] = true;
        defaultFactors[24000] = true;
        defaultFactors[12000] = true;
    }

    function setTreasury(address _treasury) public onlyOwner {
        treasury = _treasury;
    }

    function setDefaultFactor(uint256 factor, bool status) public onlyOwner {
        defaultFactors[factor] = status;
    }

    function setProtocolFeePercentage(uint256 _feePercentage) public onlyOwner {
        protocolFeePercentage = _feePercentage;
        emit ProtocolFeePercentageChanged(protocolFeePercentage);
    }

    function setManagerFeePercentage(uint256 _feePercentage) public onlyOwner {
        managerFeePercentage = _feePercentage;
        emit ManagerFeePercentageChanged(managerFeePercentage);
    }

    function getPrice(uint256 supply, uint256 amount, uint256 factor) public pure returns (uint256) {
        uint256 sum1 = supply == 0 ? 0 : (supply - 1 )* (supply) * (2 * (supply - 1) + 1) / 6;
        uint256 sum2 = supply == 0 && amount == 1 ? 0 : (supply - 1 + amount) * (supply + amount) * (2 * (supply - 1 + amount) + 1) / 6;
        uint256 summation = sum2 - sum1;
        return summation * 1 ether / factor;
    }

    function getBuyPrice(address manager, uint256 amount) public view returns (uint256) {
        uint256 factor = factors[manager];
        if (factor == 0) return 0;
        return getPrice(passesSupply[manager], amount, factor);
    }

    function getSellPrice(address manager, uint256 amount) public view returns (uint256) {
        uint256 factor = factors[manager];
        if (factor == 0) return 0;
        return getPrice(passesSupply[manager] - amount, amount, factor);
    }

    function getBuyPriceAfterFee(address manager, uint256 amount) public view returns (uint256) {
        uint256 price = getBuyPrice(manager, amount);
        uint256 protocolFee = price * protocolFeePercentage / 1 ether;
        uint256 managerFee = price * managerFeePercentage / 1 ether;
        return price + protocolFee + managerFee;
    }

    function getSellPriceAfterFee(address manager, uint256 amount) public view returns (uint256) {
        uint256 price = getSellPrice(manager, amount);
        uint256 protocolFee = price * protocolFeePercentage / 1 ether;
        uint256 managerFee = price * managerFeePercentage / 1 ether;
        return price - protocolFee - managerFee;
    }

    function balanceOf(address holder, address manager) public view returns (uint256) {
        return passesBalance[manager][holder];
    }

    function buyPasses(address manager, uint256 amount, uint256 factor) public payable {
        uint256 supply = passesSupply[manager];
        require(supply > 0 || manager == msg.sender, "Manager must buy the first pass");

        if(supply == 0 && manager == msg.sender) {
            require(defaultFactors[factor], "Invalid factor value");
            factors[manager] = factor;
        }
        else {
            require(factors[manager] == factor, "Invalid factor value");
        }

        uint256 price = getPrice(supply, amount, factor);
        uint256 protocolFee = price * protocolFeePercentage / 1 ether;
        uint256 managerFee = price * managerFeePercentage / 1 ether;
        require(msg.value >= price + protocolFee + managerFee, "Insufficient payment");
        uint256 refundedAmount = msg.value - (price + protocolFee + managerFee);
        passesBalance[manager][msg.sender] = passesBalance[manager][msg.sender] + amount;
        passesSupply[manager] = supply + amount;
        emit Trade(msg.sender, manager, true, amount, price, protocolFee, managerFee, supply + amount, factor);
        (bool success1, ) = treasury.call{value: protocolFee}("");
        (bool success2, ) = manager.call{value: managerFee}("");
        bool success3 = true;
        if(refundedAmount > 0) {
            (success3, ) = msg.sender.call{value: refundedAmount}("");
        }
        require(success1 && success2 && success3, "Unable to send funds");
    }

    function sellPasses(address manager, uint256 amount, uint256 minPrice) public payable {
        uint256 supply = passesSupply[manager];
        require(supply > amount, "Cannot sell the last pass");
        require(msg.sender != manager || passesBalance[manager][msg.sender] > amount, "Cannot sell the first pass");
        uint factor = factors[manager];
        uint256 price = getPrice(supply - amount, amount, factor);
        require(price >= minPrice, "Lower than minimum price");
        uint256 protocolFee = price * protocolFeePercentage / 1 ether;
        uint256 managerFee = price * managerFeePercentage / 1 ether;
        require(passesBalance[manager][msg.sender] >= amount, "Insufficient passes");
        passesBalance[manager][msg.sender] = passesBalance[manager][msg.sender] - amount;
        passesSupply[manager] = supply - amount;
        emit Trade(msg.sender, manager, false, amount, price, protocolFee, managerFee, supply - amount, factor);
        (bool success1, ) = msg.sender.call{value: price - protocolFee - managerFee}("");
        (bool success2, ) = treasury.call{value: protocolFee}("");
        (bool success3, ) = manager.call{value: managerFee}("");
        require(success1 && success2 && success3, "Unable to send funds");
    }
}