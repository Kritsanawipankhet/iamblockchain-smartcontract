// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

// We need to import the helper functions from the contract that we copy/pasted.
import {Base64} from "./libraries/Base64.sol";
import "./libraries/String.sol";

contract IAM {
    using Strings for string;

    modifier clientOwner(string memory _client_id) {
        require(
            clients[_client_id].client_owner == msg.sender,
            "You are not authorized to access this client."
        );
        _;
    }
    struct UserAcessIAM {
        address userAddress;
        uint256 create_date;
    }

    struct Clients {
        string client_id; //clientid lowercase clientname
        string client_secret;
        string client_name; // unique
        string client_logo; // svg , png , jpeg encode Base64 to string
        string client_description;
        string client_homepage;
        string client_uri;
        address client_owner;
        uint256 create_date;
    }

    struct ClientsOfUser {
        string[] clients_id; // 1 user to manny clients
    }
    mapping(address => UserAcessIAM) user_access_iam;
    mapping(string => Clients) public clients;
    mapping(address => ClientsOfUser) clients_of_user;

    function createClient(
        string memory _client_id,
        string memory _client_secret,
        string memory _client_name,
        string memory _client_logo,
        string memory _client_description,
        string memory _client_homepage,
        string memory _client_uri
    ) public {
        clients[_client_id].client_id = _client_id;
        clients[_client_id].client_name = _client_name;
        clients[_client_id].client_secret = _client_secret;
        clients[_client_id].client_logo = _client_logo;
        clients[_client_id].client_description = _client_description;
        clients[_client_id].client_homepage = _client_homepage;
        clients[_client_id].client_uri = _client_uri;

        clients[_client_id].client_owner = msg.sender;
        clients[_client_id].create_date = block.timestamp;

        clients_of_user[msg.sender].clients_id.push(_client_id); //Add List Clients of User
    }

    function isClient(string memory _client_id) private view returns (bool) {
        return
            keccak256(abi.encodePacked(clients[_client_id].client_id)) ==
                keccak256(abi.encodePacked(_client_id))
                ? true
                : false;
    }

    function getClient(string memory _client_id)
        public
        view
        returns (Clients memory)
    {
        return clients[_client_id];
    }

    // function jsonResponse() public pure returns (string memory) {
    //     string memory json = Base64.encode(
    //         bytes(
    //             string(
    //                 abi.encodePacked(
    //                     '{"name": "sample",',
    //                     '"image_data": "5555"}'
    //                 )
    //             )
    //         )
    //     );
    //     return string(abi.encodePacked("data:application/json;base64,", json));
    // }
}
