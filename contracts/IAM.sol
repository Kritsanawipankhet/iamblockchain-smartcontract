// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

// We need to import the helper functions from the contract that we copy/pasted.
import {Base64} from "./libraries/Base64.sol";

//import "./libraries/String.sol";

contract IAM {
    //using Strings for string;

    modifier clientOwner(string memory _client_id) {
        require(
            clients[_client_id].client_owner == msg.sender,
            "You are not authorized to access this client."
        );
        _;
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

    event AddedClient(
        string _client_id,
        address _client_owner,
        uint256 _create_date
    );

    mapping(string => Clients) public clients;

    function createClient(
        string memory _client_id,
        string memory _client_secret,
        string memory _client_name,
        string memory _client_logo,
        string memory _client_description,
        string memory _client_homepage,
        string memory _client_uri
    ) public {
        require(!isClient(_client_id), "Client already exists!");
        clients[_client_id] = Clients({
            client_id: _client_id,
            client_name: _client_name,
            client_secret: _client_secret,
            client_logo: _client_logo,
            client_description: _client_description,
            client_homepage: _client_homepage,
            client_uri: _client_uri,
            client_owner: msg.sender,
            create_date: block.timestamp
        });
        emit AddedClient(_client_id, msg.sender, block.timestamp);
    }

    function deleteClient(string memory _client_id)
        public
        clientOwner(_client_id)
    {
        require(bytes(_client_id).length != 0, "Client id is empty !");
        require(isClient(_client_id), "Invalid client id !");

        delete clients[_client_id];
    }

    function isClient(string memory _client_id) private view returns (bool) {
        require(bytes(_client_id).length != 0, "Client id is empty !");
        return
            keccak256(abi.encodePacked(clients[_client_id].client_id)) ==
                keccak256(abi.encodePacked(_client_id))
                ? true
                : false;
    }

    function getClient(string memory _client_id)
        public
        view
        returns (
            string memory,
            string memory,
            string memory,
            string memory,
            string memory,
            string memory
        )
    {
        require(bytes(_client_id).length != 0, "Client id is empty !");
        require(isClient(_client_id), "Invalid client id !");
        Clients memory client = clients[_client_id];
        return (
            client.client_name,
            client.client_secret,
            client.client_logo,
            client.client_description,
            client.client_homepage,
            client.client_uri
        );
    }

    function getClientJsonBase64(string memory _client_id)
        public
        view
        returns (string memory)
    {
        require(bytes(_client_id).length != 0, "Client id is empty !");
        require(isClient(_client_id), "Invalid client id !");
        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"client_id": "',
                        clients[_client_id].client_id,
                        '",',
                        '"client_name": "',
                        clients[_client_id].client_name,
                        '",',
                        '"client_logo": "',
                        clients[_client_id].client_logo,
                        '"}'
                    )
                )
            )
        );
        return string(abi.encodePacked("data:application/json;base64,", json));
    }
}
