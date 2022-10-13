// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.13;

import "@ensdomains/ens-contracts/contracts/ethregistrar/ETHRegistrarController.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract BulkEthRegistrarController is Ownable {
     
    struct EnsQuery {
        string  name; 
        address owner;
        uint256 duration;
        bytes32 secret; 
        address resolver; 
        bytes[] data;
        bool reverseRecord;
        uint32 fuses;
        uint64 wrapperExpiry;
        uint256 timestamp; 
        uint256 totalPrice;
    }

    struct EnsPrice {
        string name;
        address owner;
        uint256 duration;
        IPriceOracle.Price price;
    }
  
    mapping(address => EnsQuery[]) private userQueries;
     
     event NameRegistered(
        string name,
        bytes32 indexed label,
        address indexed owner,
        uint256 baseCost,
        uint256 premium,
        uint256 duration
    ); 

    address public baseControllerAddress = 0x283Af0B28c62C092C9727F1Ee09c02CA627EB7F5;
    ETHRegistrarController private controller = ETHRegistrarController(baseControllerAddress);

    function updateEthRegistrarController(address controller) external onlyOwner {
        baseControllerAddress = controller;
    } 

    function random(address userAddress) internal view returns (bytes32) {
        return bytes32(keccak256(abi.encodePacked(block.difficulty, block.timestamp, userAddress)));
    }
 
    function withdraw(address payee) external onlyOwner payable {
        payable(payee).transfer(address(this).balance);
    }
 
    function withdrawOf(address payee, address token) external onlyOwner payable {
        IERC20(token).transfer(payable(payee), address(this).balance);
    } 

    function getPrice(string calldata name, uint duration) public view returns(IPriceOracle.Price memory totalPrice) {
        return controller.rentPrice(name, duration); 
    }

    function getTotalPrice(string calldata name, uint duration) public view returns(uint totalPrice) {
        IPriceOracle.Price memory price = controller.rentPrice(name, duration);
        totalPrice = price.base + price.premium;
    }

    function getPrices(EnsQuery[] calldata query) public view returns(EnsPrice[] memory prices, uint256 totalPrice) {
        prices = new EnsPrice[](query.length);
        for (uint i = 0; i < query.length; i++) {
            EnsQuery memory q = query[i];
            IPriceOracle.Price memory price = controller.rentPrice(q.name, q.duration);
            totalPrice += price.base + price.premium;
            prices[i] = EnsPrice(q.name, msg.sender, q.duration, price);
        }
    }

    function valid(string memory name) public view returns (bool) {
        return controller.valid(name);
    }

    function available(string memory name) public view returns (bool) {
       return controller.available(name);
    } 
 
    function makeBulkCommitment(EnsQuery[] calldata query) external {
        delete userQueries[msg.sender];

        for(uint i = 0; i < query.length; i++) {
            bytes32 secret = random(msg.sender);
            EnsQuery memory q = query[i];
            q.owner = msg.sender;
            q.secret = secret;
            bytes32 commitment = controller.makeCommitment(q.name, q.owner, q.duration, secret, q.resolver, q.data, q.reverseRecord, q.fuses, q.wrapperExpiry);
            controller.commit(commitment);
            userQueries[msg.sender].push( q );
        } 
    } 
  
    function bulkRegistrar(EnsQuery[] calldata query) external payable {
        uint256 totalPrice;
        (, totalPrice) = getPrices(query);

        require( msg.value >= totalPrice, "BulkEthRegistrarController: not enough ether provided");

        EnsQuery[] memory queries = userQueries[msg.sender];

        require(queries.length > 0, "User has no commitment");

        for( uint i = 0; i < queries.length; ++i ) {
            EnsQuery memory q = queries[i];

            IPriceOracle.Price memory price = controller.rentPrice(q.name, q.duration);
            
            controller.register{ value: price.base + price.premium }(q.name, q.owner, q.duration, q.secret, q.resolver, q.data, q.reverseRecord, q.fuses, q.wrapperExpiry);
            
            emit NameRegistered(q.name, keccak256(bytes(q.name)), q.owner, price.base, price.premium, q.duration);
              
            delete userQueries[msg.sender];  
        }
    }
}