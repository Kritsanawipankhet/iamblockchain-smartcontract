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

    struct Authorizations {
        string authorization_id;
        string authorization_code;
        Clients client;
        string[] scopes;
        string redirect_uri;
        address client_user;
        bool is_active;
        uint256 expires_at;
        uint256 create_date;
    }

    struct Tokens {
        string token_id;
        Authorizations authorization;
        string access_token;
        uint256 access_token_expires_at;
        string[] scopes;
        // string refresh_token;
        // uint256 refresh_token_expires_at;
        Clients client;
        bool is_active;
        address client_user;
        uint256 create_date;
    }

    mapping(string => Clients) clients;
    mapping(string => Authorizations) authorizations;
    mapping(string => Tokens) tokens;

    event AddClient(
        address indexed _client_owner,
        string _client_id,
        uint256 _create_date
    );

    event DelClient(
        address indexed _client_owner,
        string _client_id,
        uint256 _del_date
    );

    event EditClient(
        address indexed _client_owner,
        string _client_id,
        uint256 _update_date
    );

    event RenewClientSecret(
        address indexed _client_owner,
        string _client_id,
        uint256 _event_at
    );

    event GrantAuthorize(
        address indexed _client_user,
        string _client_id,
        string _authorize_id,
        uint256 expires_at,
        uint256 _create_date
    );

    event ClientRevoke(
        address indexed _client_owner,
        string indexed _client_id,
        uint256 _event_at
    );

    event UserClientRevoke(
        address indexed _client_user,
        string _client_id,
        uint256 _event_at
    );

    event CreateAccessToken(
        address indexed _client_user,
        string _client_id,
        string _authorization_id,
        string _access_token_id,
        uint256 expires_at,
        uint256 _create_date
    );

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
        emit AddClient(msg.sender, _client_id, block.timestamp);
    }

    function deleteClient(string memory _client_id)
        public
        clientOwner(_client_id)
    {
        require(bytes(_client_id).length != 0, "Client id is empty !");
        require(isClient(_client_id), "Invalid client id !");

        delete clients[_client_id];
        emit DelClient(msg.sender, _client_id, block.timestamp);
    }

    function editClient(
        string memory _client_id,
        string memory _client_name,
        string memory _client_description,
        string memory _client_homepage,
        string memory _redirect_uri
    ) public clientOwner(_client_id) {
        require(bytes(_client_id).length != 0, "Client id is empty !");
        require(isClient(_client_id), "Invalid client id !");
        clients[_client_id].client_name = _client_name;
        clients[_client_id].client_description = _client_description;
        clients[_client_id].client_homepage = _client_homepage;
        clients[_client_id].redirect_uri = _redirect_uri;
        clients[_client_id].update_date = block.timestamp;
        emit EditClient(msg.sender, _client_id, block.timestamp);
    }

    function renewClientSecret(
        string memory _client_id,
        string memory _client_secret
    ) public clientOwner(_client_id) {
        require(bytes(_client_id).length != 0, "Client id is empty !");
        require(isClient(_client_id), "Invalid client id !");
        clients[_client_id].client_secret = _client_secret;
        clients[_client_id].update_date = block.timestamp;
        emit RenewClientSecret(msg.sender, _client_id, block.timestamp);
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

    function isExpire(uint256 _expires_at) public view returns (bool) {
        if (block.timestamp > _expires_at) {
            return true;
        }
        return false;
    }

    function isClient(string memory _client_id) private view returns (bool) {
        require(bytes(_client_id).length != 0, "Client id is empty !");
        return
            keccak256(abi.encodePacked(clients[_client_id].client_id)) ==
                keccak256(abi.encodePacked(_client_id))
                ? true
                : false;
    }

    function createAuthorize(
        string memory _client_id,
        string memory _authorization_id,
        string memory _authorization_code,
        string[] memory _scopes,
        string memory _redirect_uri,
        uint256 _expiration_period // unit seconds
    ) public {
        require(isClient(_client_id), "Invalid client id !");
        authorizations[_authorization_id] = Authorizations({
            authorization_id: _authorization_id,
            authorization_code: _authorization_code,
            client: clients[_client_id],
            scopes: _scopes,
            redirect_uri: _redirect_uri,
            client_user: msg.sender,
            is_active: true,
            expires_at: block.timestamp + _expiration_period, // create expire time
            create_date: block.timestamp
        });

        emit GrantAuthorize(
            msg.sender,
            _client_id,
            _authorization_id,
            block.timestamp + _expiration_period,
            block.timestamp
        );
    }

    function createAccessToken(
        string memory _client_id,
        string memory _authorization_id,
        string memory _access_token_id,
        string memory _access_token,
        string[] memory _scopes,
        uint256 _expiration_period
    ) public {
        require(isClient(_client_id), "Invalid client id !");
        require(isAuthorizationCode(_authorization_id));
        tokens[_access_token_id] = Tokens({
            token_id: _access_token_id,
            authorization: authorizations[_authorization_id],
            access_token: _access_token,
            access_token_expires_at: block.timestamp + _expiration_period, // create expire time
            client: clients[_client_id],
            scopes: _scopes,
            client_user: msg.sender,
            is_active: true,
            create_date: block.timestamp
        });

        emit CreateAccessToken(
            msg.sender,
            _client_id,
            _authorization_id,
            _access_token_id,
            block.timestamp + _expiration_period,
            block.timestamp
        );
    }

    function getGrantAuthorize(string memory _authorization_id)
        public
        view
        returns (Authorizations memory)
    {
        require(
            isAuthorizationCode(_authorization_id),
            "Invalid authorization code ! "
        );

        return authorizations[_authorization_id];
    }

    function isAuthorizationCode(string memory _authorization_id)
        private
        view
        returns (bool)
    {
        require(
            bytes(_authorization_id).length != 0,
            "Authorization code is empty !"
        );
        require(
            authorizations[_authorization_id].is_active == true,
            "Authorization code is active"
        );
        return
            keccak256(
                abi.encodePacked(
                    authorizations[_authorization_id].authorization_id
                )
            ) == keccak256(abi.encodePacked(_authorization_id))
                ? true
                : false;
    }
}
