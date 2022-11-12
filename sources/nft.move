module musetime::muse_time_controller {
    use std::signer;
    use std::string::{Self, String};
    use std::vector;

    use aptos_framework::account;
    use aptos_token::token;
    use aptos_framework::resource_account;
    #[test_only]
    use aptos_framework::account::create_account_for_test;

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

    /// Initialize this module: create a resource account, a collection, and a token data id
    fun init_module(resource_account: &signer) {
        let collection_name = string::utf8(b"Okx Test NFT");
        let description = string::utf8(b"A collection issued by Okx NFT team for testing purpose.");
        let uri = string::utf8(b"https://aptos.dev/img/nyan.jpeg");

        // create the resource account that we'll use to create tokens
        let resource_signer_cap = resource_account::retrieve_resource_account_cap(resource_account, @deployer);
        let resource_signer = account::create_signer_with_capability(&resource_signer_cap);

        // create the nft collection
        token::create_collection(&resource_signer, collection_name, description, uri, 100000000, vector<bool>[ true, true, true ]);
        
        move_to(resource_account, CollectionTokenMinter {
            signer_cap: resource_signer_cap,
            collection_name,
            description,
            uri,
            token_id_counter: 1,
            token_name_prefix: string::utf8(b"Okx-test-nft #"),
        });
    }

    /// Mint an NFT to the receiver.
    /// `to` address must enable direct transfer and `TokenStore` should be initialized.
    public entry fun mint_nft(to: address) acquires CollectionTokenMinter {
        let collection_token_minter = borrow_global_mut<CollectionTokenMinter>(@okx_test_nft);
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
    }

    /// Batch mint nft to one address.
    /// `to` address must enable direct transfer and `TokenStore` should be initialized.
    public entry fun batch_mint_nft(to: address, amount: u64) acquires CollectionTokenMinter {
        while (amount > 0) {
            mint_nft(to);
            amount = amount - 1;
        }
    }

    /// Burn nft by its owner.
    public entry fun burn_nft(nft_owner: &signer, token_name: String, property_version: u64, amount: u64) acquires CollectionTokenMinter {
        let collection_token_minter = borrow_global_mut<CollectionTokenMinter>(@okx_test_nft);
        let resource_signer = account::create_signer_with_capability(&collection_token_minter.signer_cap);

        token::burn(nft_owner, signer::address_of(&resource_signer), collection_token_minter.collection_name, token_name, property_version, amount);
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


    #[test_only]
    public fun set_up_test(origin_account: signer, collection_token_minter: &signer, nft_receiver: &signer, nft_receiver2: &signer) {
        create_account_for_test(signer::address_of(&origin_account));

        // create a resource account from the origin account, mocking the module publishing process
        resource_account::create_resource_account(&origin_account, vector::empty<u8>(), vector::empty<u8>());

        init_module(collection_token_minter);

        create_account_for_test(signer::address_of(nft_receiver));
        create_account_for_test(signer::address_of(nft_receiver2));

        token::initialize_token_store(nft_receiver);
        token::initialize_token_store(nft_receiver2);

        token::opt_in_direct_transfer(nft_receiver, true);
        token::opt_in_direct_transfer(nft_receiver2, true);

    }

    #[test (origin_account = @deployer, collection_token_minter = @0xc3bb8488ab1a5815a9d543d7e41b0e0df46a7396f89b22821f07a4362f75ddc5, nft_receiver = @0x123, nft_receiver2 = @0x234, aptos_framework = @aptos_framework)]
    public entry fun test_mint_and_burn_nft(
        origin_account: signer,
        collection_token_minter: signer,
        nft_receiver: signer,
        nft_receiver2: signer,
    ) {
        set_up_test(origin_account, &collection_token_minter, &nft_receiver, &nft_receiver2);

        // mint
        // mint_nft(signer::address_of(&nft_receiver));
        // mint_nft(signer::address_of(&nft_receiver2));

        // let collection_token_minter = borrow_global_mut<CollectionTokenMinter>(@okx_test_nft);
        // let resource_signer = account::create_signer_with_capability(&collection_token_minter.signer_cap);

        // let token_id = token::create_token_id_raw(
        //     signer::address_of(&resource_signer),
        //     collection_token_minter.collection_name,
        //     string::utf8(b"Okx-test-nft #1"),
        //     0
        // );
        // let balance = token::balance_of(signer::address_of(&nft_receiver), token_id);
        // assert!(balance == 1, 1);

        // let token_id = token::create_token_id_raw(
        //     signer::address_of(&resource_signer),
        //     collection_token_minter.collection_name,
        //     string::utf8(b"Okx-test-nft #2"),
        //     0
        // );
        // let balance = token::balance_of(signer::address_of(&nft_receiver2), token_id);
        // assert!(balance == 1, 2);

        // // burn
        // burn_nft(&nft_receiver, string::utf8(b"Okx-test-nft #1"), 0, 1);
        // let balance = token::balance_of(signer::address_of(&nft_receiver), token_id);
        // assert!(balance == 0, 3);
        
        // burn_nft(&nft_receiver2, string::utf8(b"Okx-test-nft #2"), 0, 1);
        // let balance = token::balance_of(signer::address_of(&nft_receiver2), token_id);
        // assert!(balance == 0, 4);
    }

    #[test]
    public fun test_num2String() {
        let s = num2String(1010135);
        assert!(s == string::utf8(b"1010135"), 1);
    }
}