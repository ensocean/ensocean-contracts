# EnsOcean Smart Contracts
    

    
 
     

    
 
    

 function rentPrice(address controller, string memory name, uint duration) public view returns(uint) {
        return IETHRegistrarController(controller).rentPrice(name, duration);
    }
    
    function makeCommitment(address controller, string memory name, address owner, bytes32 secret) public pure returns(bytes32) {
        return makeCommitmentWithConfig(controller, name, owner, secret, address(0), address(0));
    }

    function makeCommitmentWithConfig(address controller, string memory name, address owner, bytes32 secret, address resolver, address addr) public pure returns(bytes32) {
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
        uint fee = cost.div(100).mul(_feeRatio);
        uint costWithFee = cost.add(fee); 

        require( msg.value >= costWithFee, "BulkEthRegistrarController: Not enough ether sent.");
        require(available(controller, name), "BulkEthRegistrarController: Name has already been registered");
        // TODO: commission
        // TODO: cost'u slippage vererek gonder.

        IETHRegistrarController(controller).registerWithConfig{ value: cost }(name, owner, duration, secret, resolver, addr);

        emit NameRegistered(name, owner, cost, duration);
    } 

    function renew(address controller, string calldata name, uint duration) external payable {
        uint cost = rentPrice(controller, name, duration);
        uint fee = cost.div(100).mul(_feeRatio);
        uint costWithFee = cost.add(fee); 

        // TODO: cost'u slippage vererek gonder.
        require( msg.value >= costWithFee, "BulkEthRegistrarController: Not enough ether sent. Expected: ");
  
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

    function bulkRentPrice(address controller, BulkQuery[] memory query) public view returns(BulkResult[] memory result, uint totalPrice, uint totalPriceWithFee) {
        result = new BulkResult[](query.length);
        for (uint i = 0; i < query.length; i++) {
            BulkQuery memory q = query[i];
            bool _available = available(controller, q.name);
            uint _price = rentPrice(controller, q.name, q.duration);
            totalPrice += _price;
            totalPriceWithFee += _price.div(100).mul(_feeRatio).add(_price);
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

    function bulkRegister(address controller, BulkQuery[] calldata query, string calldata secret) external payable {
        bulkRegisterWithConfig(controller, query, secret);
    }

    function bulkRegisterWithConfig(address controller, BulkQuery[] calldata query, string calldata secret) public payable {
        uint256 totalCost;
        uint256 totalCostWithFee;
        (, totalCost, totalCostWithFee) = bulkRentPrice(controller, query);
 
        // TODO: cost'u slippage vererek gonder.
        require(msg.value >= totalCostWithFee, "BulkEthRegistrarController: Not enough ether sent. Expected: ");
       
        bytes32 _secret = getBytes(secret);

        for( uint i = 0; i < query.length; ++i ) {
            BulkQuery memory q = query[i];
 
            uint cost = rentPrice(controller, q.name, q.duration);
            IETHRegistrarController(controller).registerWithConfig{ value: cost }(q.name, q.owner, q.duration, _secret, q.resolver, q.addr);

            emit NameRegistered(q.name, q.owner, cost, q.duration);
        } 
    } 

    function bulkRenew(address controller, BulkQuery[] calldata query) external payable {
        uint256 totalCost;
        uint256 totalCostWithFee;
        (, totalCost, totalCostWithFee) = bulkRentPrice(controller, query); 
 
        // TODO: cost'u slippage vererek gonder.
        require( msg.value >= totalCostWithFee, "BulkEthRegistrarController: Not enough ether sent. Expected: ");

        for( uint i = 0; i < query.length; ++i ) {
            BulkQuery memory q = query[i];

            uint cost = rentPrice(controller, q.name, q.duration);
            IETHRegistrarController(controller).renew{ value: cost }(q.name, q.duration);

            emit NameRenewed(q.name, msg.sender, cost, q.duration);
        } 

        
    }


    const tx = await hre.ethers.provider.getTransaction("0x6fe8171d0be1e0a3cf2744be7a8cec5d33cfe0b3d88b7b3f534f3b1543ebd5de");
 
   console.log(tx)
   const cancelTransaction = await deployer.sendTransaction({
    from: '0xa3f6d09b9e7f443244e4e598459d86d2a4159519', 
  
    nonce: 35,
    gasPrice: tx.gasPrice.mul(2),
    data: "0x",
    value: 0
  });

  console.log(cancelTransaction.hash);

  process.exit(0);