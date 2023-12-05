//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract VANET {
    address private trustedAuthorityAddress;

    struct RSU {
        string rsuID;
        string vtCode;
        bool isRegistered;
    }

    struct Vehicle {
        string vtCode;
        string vehicleDetails;
        string vehicleHash;
        bytes32 secretKey;
        address publicKey;
        bool isRegistered;
    }

    mapping(address => RSU) rsuMapping;
    mapping(address => Vehicle) vehicleMapping;

    constructor() {
        trustedAuthorityAddress = msg.sender;
    }

    modifier onlyTrustedAuthority() {
        require(
            msg.sender == trustedAuthorityAddress,
            "This function can only be performed by Trusted Authority"
        );
        _;
    }

    function registerRSU(
        address _rsuAddress,
        string memory _rsuID,
        string memory _vtCode
    ) public onlyTrustedAuthority {
        require(msg.sender != address(0));
        require(
            rsuMapping[_rsuAddress].isRegistered == false,
            "This RSU has already been registered"
        );
        require(bytes(_rsuID).length > 0);
        require(bytes(_vtCode).length > 0);

        rsuMapping[_rsuAddress] = RSU({
            rsuID: _rsuID,
            vtCode: _vtCode,
            isRegistered: true
        });
    }

    function isRsuRegistered(address _rsuAddress) public view returns (bool) {
        return rsuMapping[_rsuAddress].isRegistered;
    }

    function registerVehicle(
        address _vehicleAddress,
        string memory _vtCode,
        string memory _vehicleDetails,
        string memory _vehicleHash
    ) public onlyTrustedAuthority {
        require(bytes(_vtCode).length > 0);
        require(bytes(_vehicleDetails).length > 0);
        require(bytes(_vehicleHash).length > 0);
        require(_vehicleAddress != address(0));
        require(
            vehicleMapping[_vehicleAddress].isRegistered == false,
            "This vehicle is already registered"
        );

        bytes32 secret = keccak256(
            abi.encodePacked(_vehicleAddress, _vehicleDetails)
        );
        address publicKey = address(
            uint160(uint256(keccak256(abi.encodePacked(secret))))
        );
        vehicleMapping[_vehicleAddress] = Vehicle({
            vtCode: _vtCode,
            vehicleDetails: _vehicleDetails,
            vehicleHash: _vehicleHash,
            secretKey: secret,
            publicKey: publicKey,
            isRegistered: true
        });
    }

    function getVehiclePublicKey(
        address _vehicleAddress
    ) public view returns (address) {
        require(
            vehicleMapping[_vehicleAddress].isRegistered == true,
            "This address is not registered as a vehicle"
        );
        return vehicleMapping[_vehicleAddress].publicKey;
    }
}
