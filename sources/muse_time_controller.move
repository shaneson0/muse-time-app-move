module musetime::muse_time_controller {

    use std::signer;
    use aptos_token::token::{TokenId};
    use aptos_framework::aptos_coin::AptosCoin;
    use aptos_framework::coin;
    use musetime::muse_time_nft;
    use std::vector;

    const E_NOT_ADMIN: u64 = 1;
    const E_NOT_VALID_AMOUNT: u64 = 2;

    const STATUS_PENDING: u8 = 11;
    const STATUS_REJECTED: u8 = 12;
    const STATUS_CONFIRMED: u8 = 13;
    const STATUS_FULFILLED u8 = 14;


    struct Time has key, store {
        token_id: TokenId,
        minter: address,
        topicOwner: address,
        expired: u64,
        profileArId: vector<u8>,
        topicsArId: vector<u8>,
        topicId: vector<u8>,
        balance: coin::Coin<AptosCoin>,
        timeStatus: u8
    }

    struct TimeTrove has key {
        arOwnerAddress: vector<u8>,
        topicOwner: vector<u8>,
        timeTroves: vector<Time>
    }

    public entry fun init(admin: &signer, resouce_signer: &signer) {
        assert!(signer::address_of(admin) == @musetime, E_NOT_ADMIN);
        muse_time_nft::create_collection(admin, resouce_signer);
    }

    public entry fun createTimeTroves(
        sender: &signer, 
        _arOwnerAddress: vector<u8>, 
        _topicOwner: vector<u8>
        ) {
        move_to(sender, TimeTrove {
            arOwnerAddress: _arOwnerAddress,
            topicOwner: _topicOwner,
            timeTroves: vector::empty<Time>()
        } )
    }

    public entry fun mintTimeToken(
        user: &signer, 
        topicOwner: address,
        expired: u64,
        profileArId: vector<u8>,
        topicsArId: vector<u8>,
        topicId: vector<u8>,
        amountIn: u64
    ) acquires TimeTrove  {

        // extract token from minter
        let coin_in = if (amountIn > 0) {
             coin::withdraw<AptosCoin>(user, amountIn)
        } else {
            coin::zero<AptosCoin>()
        };
        
        let timeTrove = borrow_global_mut<TimeTrove>(topicOwner);
        let _token_id: TokenId = muse_time_nft::mint_nft(user);
        vector::push_back<Time>(&mut timeTrove.timeTroves, Time {
            token_id: _token_id,
            minter: signer::address_of(user),
            topicOwner: topicOwner,
            expired: expired,
            profileArId: profileArId,
            topicsArId: topicsArId,
            topicId: topicId,
            balance: coin_in,
            timeStatus: STATUS_PENDING
        });
    }


    // setConfirmed

    // setRejected

    // setFulfilled


    #[test_only]
        public entry fun testMintTimeToken(
        user: &signer, 
        topicOwner: address,
        expired: u64,
        profileArId: vector<u8>,
        topicsArId: vector<u8>,
        topicId: vector<u8>,
        amountIn: u64
    ): TokenId acquires TimeTrove  {

        // extract token from minter
        let coin_in = if (amountIn > 0) {
             coin::withdraw<AptosCoin>(user, amountIn)
        } else {
            coin::zero<AptosCoin>()
        };
        
        let timeTrove = borrow_global_mut<TimeTrove>(topicOwner);
        let _token_id: TokenId = muse_time_nft::mint_nft(user);
        vector::push_back<Time>(&mut timeTrove.timeTroves, Time {
            token_id: _token_id,
            minter: signer::address_of(user),
            topicOwner: topicOwner,
            expired: expired,
            profileArId: profileArId,
            topicsArId: topicsArId,
            topicId: topicId,
            balance: coin_in
        });
        _token_id
    }
}