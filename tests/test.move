#[test_only]
module musetime::muse_time_test {

    use std::signer;
    // use aptos_framework::aptos_account;
    use aptos_framework::resource_account::{Self};

    use std::vector;
    use musetime::muse_time_controller;
    use aptos_token::token;

    // use std::debug;

    // use aptos_token::token;
    // use aptos_framework::account::create_account_for_test;
    #[test_only]
    use aptos_framework::account::create_account_for_test;

    const E_INVALID_BALANCE:u64 = 1;
    #[test(
        admin = @0x1,
        deployer = @deployer,
        user = @0x123
    )]
    fun test_one_step_econia(
        admin: &signer,
        deployer: &signer,
        user: &signer
    ) {
        create_account_for_test(signer::address_of(admin));
        create_account_for_test(signer::address_of(deployer));
        create_account_for_test(signer::address_of(user));
        token::opt_in_direct_transfer(user, true);

        let seed = vector::empty<u8>();
        resource_account::create_resource_account(deployer, seed , vector::empty<u8>());

        let resource_address = aptos_framework::account::create_resource_address(&signer::address_of(deployer), seed);
        let resource_signer_cap = aptos_framework::account::create_test_signer_cap(resource_address);
        let resource_signer = aptos_framework::account::create_signer_with_capability(&resource_signer_cap);

        muse_time_controller::init(deployer,&resource_signer);


        // createTimeTroves
        let _arOwnerAddress: vector<u8> = x"790ac11183ddE23163b307E3F7440F2460526957";
        let _topicOwner: vector<u8> = x"790ac11183ddE23163b307E3F7440F2460526957";
        muse_time_controller::createTimeTroves(deployer, _arOwnerAddress, _topicOwner);

        // mintTimeToken
        // user: &signer, 
        let topicOwner: address = signer::address_of(deployer);
        let expired: u64 = 10000000;
        let profileArId: vector<u8> = x"790ac11183ddE23163b307E3F7440F2460526957";
        let topicsArId: vector<u8> = x"790ac11183ddE23163b307E3F7440F2460526957";
        let topicId: vector<u8> = x"790ac11183ddE23163b307E3F7440F2460526957";
        let amountIn: u64 = 0;

        let token_id = muse_time_controller::testMintTimeToken(user, topicOwner, expired, profileArId, topicsArId, topicId, amountIn);

        let balance = token::balance_of(signer::address_of(user), token_id);
        assert!(balance == 1, E_INVALID_BALANCE);

    }
}