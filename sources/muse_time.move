module musetime::muse_time_nft {
    use std::signer;
    use std::string::{Self, String};
    use std::vector;

    use aptos_token::token::{TokenId};
    use aptos_framework::account;
    use aptos_token::token;
    use aptos_framework::resource_account;

    friend musetime::muse_time_controller;
    friend musetime::muse_time_test;

    // This struct stores an NFT collection's relevant information
    struct CollectionTokenMinter has key {
        signer_cap: account::SignerCapability,
        token_name_prefix: String,
        collection_name: String,
        description: String,
        // base token uri
        uri: String,
        // incremented token id counter
        token_id_counter: u64,
    }

    public(friend) fun create_collection(deployer: &signer, resource_signer: &signer) {
        let collection_name = string::utf8(b"Test");
        let description = string::utf8(b"A collection issued by NFT team for testing purpose.");
        let uri = string::utf8(b"https://aptos.dev/img/nyan.jpeg");

        // // create the nft collection
        let resource_signer_cap = resource_account::retrieve_resource_account_cap(resource_signer, signer::address_of(deployer));
        token::create_collection(resource_signer, collection_name, description, uri, 100000000, vector<bool>[ true, true, true ]);
        
        move_to(deployer, CollectionTokenMinter {
            signer_cap: resource_signer_cap,
            collection_name,
            description,
            uri,
            token_id_counter: 1,
            token_name_prefix: string::utf8(b"test-nft #"),
        });
    }

    /// Mint an NFT to the receiver.
    /// `to` address must enable direct transfer and `TokenStore` should be initialized.
    // URL: https://static.looksnice.org/0xDE4175CA8B80A903d795A19F629192938B18FCb8/0xd3749a59d60f9c0317bcab7ca1c59e9a21e5b1323dc5dcb451d03c6626952611
    // 
    public(friend) fun mint_nft(user: &signer): TokenId acquires CollectionTokenMinter {
        let to:address = signer::address_of(user);
        let collection_token_minter = borrow_global_mut<CollectionTokenMinter>(@deployer);
        let resource_signer = account::create_signer_with_capability(&collection_token_minter.signer_cap);

        let token_name = string::utf8(b"");
        string::append(&mut token_name, collection_token_minter.token_name_prefix);
        string::append(&mut token_name, num2String(collection_token_minter.token_id_counter));

        collection_token_minter.token_id_counter = collection_token_minter.token_id_counter + 1;

        let token_data_id = token::create_tokendata(
            &resource_signer,
            collection_token_minter.collection_name,
            token_name,
            collection_token_minter.description,
            0,
            collection_token_minter.uri,
            @royalty,
            100,
            5,
            token::create_token_mutability_config(&vector<bool>[true, true, true, true, true]),
            vector<String>[ string::utf8(b"TOKEN_BURNABLE_BY_OWNER")],
            vector<vector<u8>>[ vector<u8>[ 1 ] ],
            vector<String>[ string::utf8(b"bool") ],
        );

        token::mint_token_to(&resource_signer, to, token_data_id, 1);
        let token_id = token::create_token_id(token_data_id, 0);
        return token_id
    }

    fun num2String(n: u64): String {
        let res = vector::empty();

        while (n > 0) {
            let m = n % 10 + 48;
            vector::push_back(&mut res, (m as u8));
            n = n / 10;
        };
        vector::reverse(&mut res);

        string::utf8(res)
    }

}