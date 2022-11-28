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
    address _baseController = 0x283Af0B28c62C092C9727F1Ee09c02CA627EB7F5;

    constructor(address baseController) {
        _baseController = baseController;
    }

    function updateBaseController(address baseController) onlyOwner external {
        _baseController = baseController;
    }

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

    function available(string memory name) public view returns(bool) {
        return IETHRegistrarController(_baseController).available(name);
    }

    function rentPrice(string memory name, uint duration) public view returns(uint) {
        return IETHRegistrarController(_baseController).rentPrice(name, duration);
    }
    
    function makeCommitment(string memory name, address owner, bytes32 secret) public view returns(bytes32) {
        return makeCommitmentWithConfig(name, owner, secret, address(0), address(0));
    }

    function makeCommitmentWithConfig(string memory name, address owner, bytes32 secret, address resolver, address addr) public view returns(bytes32) {
        return IETHRegistrarController(_baseController).makeCommitmentWithConfig(name, owner, secret, resolver, addr);
    }

    function commit(bytes32 commitment) public {
        IETHRegistrarController(_baseController).commit(commitment);
    }
  
    function register(string calldata name, address owner, uint duration, bytes32 secret) external payable {
        registerWithConfig(name, owner, duration, secret, address(0), address(0));
    }

    function registerWithConfig(string memory name, address owner, uint duration, bytes32 secret, address resolver, address addr) public payable {
        uint cost = rentPrice(name, duration);
        require( msg.value >= cost, "BulkEthRegistrarController: Not enough ether sent");
        require(available(name), "BulkEthRegistrarController: Name has already been registered");
        // TODO: commission
        // TODO: cost'u slippage vererek gonder.

        IETHRegistrarController(_baseController).registerWithConfig{ value: cost }(name, owner, duration, secret, resolver, addr);

        emit NameRegistered(name, owner, cost, duration);
    } 

    function renew(string calldata name, uint duration) external payable {
        uint cost = rentPrice(name, duration);
        require( msg.value >= cost, "BulkEthRegistrarController: Not enough ether sent");

        // TODO: commission
        // TODO: cost'u slippage vererek gonder.

        IETHRegistrarController(_baseController).renew{ value: cost }(name, duration);
    }

    function getBytes(string calldata secret) public pure returns (bytes32) {
        return bytes32(keccak256(abi.encodePacked(secret)));
    }

    function bulkAvailable(string[] memory names) public view returns (bool[] memory) {
        bool[] memory _availables = new bool[](names.length);
        for (uint i = 0; i < names.length; i++) {
            _availables[i] = available(names[i]);
        }
        return _availables;
    }

    function bulkRentPrice(BulkQuery[] memory query) public view returns(BulkResult[] memory result, uint totalPrice) {
        result = new BulkResult[](query.length);
        for (uint i = 0; i < query.length; i++) {
            BulkQuery memory q = query[i];
            bool _available = available(q.name);
            uint _price = rentPrice(q.name, q.duration);
            totalPrice += _price;
            result[i] = BulkResult(q.name, _available, q.duration, _price);
        }
    } 

    function bulkCommit(address owner, BulkQuery[] calldata query, string calldata secret) external { 
       bulkCommitWithConfig(owner, query, secret, address(0), address(0));
    }

    function bulkCommitWithConfig(address owner, BulkQuery[] calldata query, string calldata secret, address resolver, address addr) public { 
        for(uint i = 0; i < query.length; i++) { 
            BulkQuery memory c = query[i]; 
            bytes32 _secret = getBytes(secret);
            bytes32 commitment = makeCommitmentWithConfig(c.name, owner, _secret, resolver, addr);
            commit(commitment);
        } 
    }

    function bulkRegister( address owner, BulkQuery[] calldata query, string calldata secret) external payable {
        bulkRegisterWithConfig(owner, query, secret, address(0), address(0));
    }

    function bulkRegisterWithConfig(address owner, BulkQuery[] calldata query, string calldata secret, address resolver, address addr) public payable {
        uint256 totalCost;  
        (, totalCost) = bulkRentPrice(query);
         
        // TODO: commmision
        // TODO: cost'u slippage vererek gonder.
        require(msg.value >= totalCost, "BulkEthRegistrarController: Not enough ether sent");
       
        for( uint i = 0; i < query.length; ++i ) {
            BulkQuery memory q = query[i];

            require(available(q.name), string.concat("The item has already been registered: ", q.name));

            bytes32 _secret = getBytes(secret);
            uint cost = rentPrice(q.name, q.duration);
            IETHRegistrarController(_baseController).registerWithConfig{ value: cost }(q.name, owner, q.duration, _secret, resolver, addr);

            emit NameRegistered(q.name, owner, cost, q.duration);
        } 
    } 

    function bulkRenew(BulkQuery[] calldata query) external payable {
        uint256 totalCost; 
        (, totalCost) = bulkRentPrice(query);
  
        // TODO: commmision 
        // TODO: cost'u slippage vererek gonder.
        require( msg.value >= totalCost, "BulkEthRegistrarController: Not enough ether sent");

        for( uint i = 0; i < query.length; ++i ) {
            BulkQuery memory q = query[i];

            uint cost = rentPrice(q.name, q.duration);
            IETHRegistrarController(_baseController).renew{ value: cost }(q.name, q.duration);

            emit NameRenewed(q.name, msg.sender, cost, q.duration);
        } 

        
    }
}