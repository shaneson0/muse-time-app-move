#[test_only]
module musetime::muse_time_controller {

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