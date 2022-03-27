// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

// We need to import the helper functions from the contract that we copy/pasted.
import {Base64} from "./libraries/Base64.sol";
import {Strings} from "./libraries/Strings.sol";

contract IAM {
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
        string redirect_uri;
        address client_owner;
        uint256 update_date;
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
        string memory _redirect_uri
    ) public {
        require(!isClient(_client_id), "Client already exists!");
        clients[_client_id] = Clients({
            client_id: _client_id,
            client_name: _client_name,
            client_secret: _client_secret,
            client_logo: _client_logo,
            client_description: _client_description,
            client_homepage: _client_homepage,
            redirect_uri: _redirect_uri,
            client_owner: msg.sender,
            update_date: block.timestamp,
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

    function getClientByOwner(string memory _client_id)
        public
        view
        clientOwner(_client_id)
        returns (Clients memory)
    {
        require(bytes(_client_id).length != 0, "Client id is empty !");
        require(isClient(_client_id), "Invalid client id !");
        return clients[_client_id];
    }

    function getClientPublicJson(string memory _client_id)
        public
        view
        returns (string memory)
    {
        require(bytes(_client_id).length != 0, "Client id is empty !");
        require(isClient(_client_id), "Invalid client id !");
        string memory client = Base64.encode(
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
                        '",',
                        '"client_description": "',
                        clients[_client_id].client_description,
                        '",',
                        '"client_homepage": "',
                        clients[_client_id].client_homepage,
                        '",',
                        '"redirect_uri": "',
                        clients[_client_id].redirect_uri,
                        '",',
                        '"client_owner": "',
                        Strings.toString(
                            abi.encodePacked(clients[_client_id].client_owner)
                        ),
                        '",',
                        '"update_date": ',
                        Strings.uint256ToString(
                            clients[_client_id].update_date
                        ),
                        ",",
                        '"create_date": ',
                        Strings.uint256ToString(
                            clients[_client_id].create_date
                        ),
                        "}"
                    )
                )
            )
        );
        return string(abi.encodePacked(client));
    }
}
