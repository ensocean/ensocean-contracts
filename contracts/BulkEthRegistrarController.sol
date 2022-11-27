// SPDX-License-Identifier: MIT

pragma solidity ^0.8.12; 
 
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "./IETHRegistrarController.sol";
import "./BulkQuery.sol";
import "./BulkResult.sol";

contract BulkEthRegistrarController is Ownable {

    event NameRegistered(string name,  address indexed owner, uint256 cost,  uint256 duration);
    event NameRenewed(string name,  address indexed owner, uint256 cost,  uint256 duration);
         
    // TODO: Islemler gec yapılırsa fiyat degısımleri olabilir. Bir miktar fazla göndermesini isteyebiliriz.
 
    function withdraw(address payee) external onlyOwner payable {
        payable(payee).transfer(address(this).balance);
    }
 
    function withdrawOf(address payee, address token) external onlyOwner payable {
        IERC20(token).transfer(payable(payee), IERC20(token).balanceOf(address(this)));
    } 

    function balance() external view returns(uint256) {
        return address(this).balance;
    }
 
    function balanceOf(address token) external view returns(uint256) {
        return IERC20(token).balanceOf(address(this));
    }

    function available(address controller, string memory name) public view returns(bool) {
        return IETHRegistrarController(controller).available(name);
    }

    function rentPrice(address controller, string memory name, uint duration) public view returns(uint) {
        return IETHRegistrarController(controller).rentPrice(name, duration);
    }
    
    function makeCommitment(address controller,string memory name, address owner, bytes32 secret) pure public returns(bytes32) {
        return makeCommitmentWithConfig(controller, name, owner, secret, address(0), address(0));
    }

    function makeCommitmentWithConfig(address controller, string memory name, address owner, bytes32 secret, address resolver, address addr) pure public returns(bytes32) {
        return IETHRegistrarController(controller).makeCommitmentWithConfig(name, owner, secret, resolver, addr);
    }

    function commit(address controller, bytes32 commitment) public {
        IETHRegistrarController(controller).commit(commitment);
    }
  
    function register(address controller, string calldata name, address owner, uint duration, bytes32 secret) external payable {
        registerWithConfig(controller, name, owner, duration, secret, address(0), address(0));
    }

    function registerWithConfig(address controller, string memory name, address owner, uint duration, bytes32 secret, address resolver, address addr) public payable {
        uint cost = rentPrice(controller, name, duration);
        require( msg.value >= cost, "BulkEthRegistrarController: Not enough ether sent");
        
        // TODO: commission

        IETHRegistrarController(controller).registerWithConfig{ value: cost }(name, owner, duration, secret, resolver, addr);

        emit NameRegistered(name, owner, cost, duration);
    } 

    function renew(address controller, string calldata name, uint duration) external payable {
        uint cost = rentPrice(controller, name, duration);
        require( msg.value >= cost, "BulkEthRegistrarController: Not enough ether sent");

        IETHRegistrarController(controller).renew{ value: cost }(name, duration);
    }

    function getBytes(string calldata secret) public pure returns (bytes32) {
        return bytes32(keccak256(abi.encodePacked(secret)));
    }

    function bulkAvailable(address controller, string[] memory names) public view returns (bool[] memory) {
        bool[] memory _availables = new bool[](names.length);
        for (uint i = 0; i < names.length; i++) {
            _availables[i] = available(controller, names[i]);
        }
        return _availables;
    }

    function bulkRentPrice(address controller, BulkQuery[] memory query) public view returns(BulkResult[] memory result, uint totalPrice) {
        result = new BulkResult[](query.length);
        for (uint i = 0; i < query.length; i++) {
            BulkQuery memory q = query[i];
            bool _available = available(controller, q.name);
            uint _price = rentPrice(controller, q.name, q.duration);
            totalPrice += _price;
            result[i] = BulkResult(q.name, _available, q.duration, _price);
        }
    } 

    function bulkCommit(address controller, address owner, BulkQuery[] calldata query, string calldata secret) external { 
       bulkCommitWithConfig(controller, owner, query, secret, address(0), address(0));
    }

    function bulkCommitWithConfig(address controller, address owner, BulkQuery[] calldata query, string calldata secret, address resolver, address addr) public { 
        for(uint i = 0; i < query.length; i++) { 
            BulkQuery memory c = query[i]; 
            bytes32 _secret = getBytes(secret);
            bytes32 commitment = makeCommitmentWithConfig(controller, c.name, owner, _secret, resolver, addr);
            commit(controller, commitment);
        } 
    }

    function bulkRegister(address controller, address owner, BulkQuery[] calldata query, string calldata secret) external payable {
        bulkRegisterWithConfig(controller, owner, query, secret, address(0), address(0));
    }

    function bulkRegisterWithConfig(address controller, address owner, BulkQuery[] calldata query, string calldata secret, address resolver, address addr) public payable {
        uint256 totalCost; 
        (, totalCost) = bulkRentPrice(controller, query);
        
        // TODO: you are not the owner
        // TODO: commmision

        require( msg.value >= totalCost, "BulkEthRegistrarController: Not enough ether sent");
 
        for( uint i = 0; i < query.length; ++i ) {
            BulkQuery memory q = query[i];
            bytes32 _secret = getBytes(secret);

            uint cost = rentPrice(controller, q.name, q.duration);
            IETHRegistrarController(controller).registerWithConfig{ value: cost }(q.name, owner, q.duration, _secret, resolver, addr);

            emit NameRegistered(q.name, owner, cost, q.duration);
        } 
    } 

    function bulkRenew(address controller, BulkQuery[] calldata query) external payable {
        uint256 totalCost; 
        (, totalCost) = bulkRentPrice(controller, query);
 
        // TODO: you are not the owner
        // TODO: commmision

        require( msg.value >= totalCost, "BulkEthRegistrarController: Not enough ether sent");

        for( uint i = 0; i < query.length; ++i ) {
            BulkQuery memory q = query[i];

            uint cost = rentPrice(controller, q.name, q.duration);
            IETHRegistrarController(controller).renew{ value: cost }(q.name, q.duration);

            emit NameRenewed(q.name, msg.sender, cost, q.duration);
        } 

        
    }
}