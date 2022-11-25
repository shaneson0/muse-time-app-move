module musetime::muse_time_controller {

    use std::signer;
    use aptos_token::token::{TokenId};
    use aptos_framework::aptos_coin::AptosCoin;
    use aptos_framework::coin;
    use musetime::muse_time_nft;

    const E_NOT_ADMIN: u64 = 1;

    struct TimeTrove has key {
        token_id: TokenId,
        ar_owner_address: vector<u8>,
        balance: coin::Coin<AptosCoin>
    }

    public entry fun init(admin: &signer, resouce_signer: &signer) {
        assert!(signer::address_of(admin) == @musetime, E_NOT_ADMIN);
        muse_time_nft::create_collection(admin, resouce_signer);
    }

    public entry fun mint_nft(user: &signer, ar_address: vector<u8> ) {
        let _token_id: TokenId = muse_time_nft::mint_nft(user);
        move_to(user, TimeTrove {
            token_id: _token_id,
            ar_owner_address: ar_address,
            balance: coin::zero<AptosCoin>()
        } )
    }

    public fun get_token_id(user: &signer): TokenId acquires TimeTrove  {
        let timeTrove = borrow_global<TimeTrove>(signer::address_of(user));
        return timeTrove.token_id
    }
}