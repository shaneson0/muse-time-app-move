#[test_only]
module musetime::encryption_testing {
    use aptos_std::ed25519::{Self};
    use std::debug;

    use std::hash;
    use aptos_std::secp256k1::{ecdsa_recover, ecdsa_signature_from_bytes, ecdsa_raw_public_key_to_bytes};
    
    #[test]
    fun signature_verify_strict_test() {

        let signature = x"c2b1a1f5674b8594b6a052b3b57be13c255abdcb41e80dfe73dc12b7a2339c2a50888f8c94acffa780de9443bd783c3ce177797c0638fe401211da144218c202";
        let pk = x"1456eeb5364532ac4372fe396ca59501fbbcf8f409e56e4b58dc907d30531655";
        let _message = x"b5e97db07fa0bd0e5598aa3643a9bc6f6693bddc1a9fec9e674a461eaa00b193651be6d6d9f796fe078911b27c0a7ecd9d80dbacea42b7cca6de9dc6bf53ce43660200000000000002d8ac932680e7bf09166766a17543a4ba0f01aeeab02112df8fc75577965f3fdf1070726f78795f61676772656761746f7213656e7472795f70726f78795f756e7873776170070700000000000000000000000000000000000000000000000000000000000000010a6170746f735f636f696e094170746f73436f696e0007881ac202b1f1e6ad4efcff7a1d0579411533f2502417a19211cfc49751ddb5f404636f696e044d4f4a4f000700000000000000000000000000000000000000000000000000000000000000010a6170746f735f636f696e094170746f73436f696e000700000000000000000000000000000000000000000000000000000000000000010a6170746f735f636f696e094170746f73436f696e0007190d44266241744264b964a37b8f09863167a12d3e70cda39376cfb4e3561e12066375727665730c556e636f7272656c617465640007190d44266241744264b964a37b8f09863167a12d3e70cda39376cfb4e3561e12066375727665730c556e636f7272656c617465640007190d44266241744264b964a37b8f09863167a12d3e70cda39376cfb4e3561e12066375727665730c556e636f7272656c61746564000508e8030000000000000800000000000000000302030711020000000000000000000000000000000003020000a861000000000000d2000000000000005d1e54b28401000001";

        let ed25519_signature = ed25519::new_signature_from_bytes(signature);
        let ed25519_public_key = ed25519::new_unvalidated_public_key_from_bytes(pk);

        debug::print(&ed25519_signature);
        debug::print(&ed25519_public_key);

        let res = ed25519::signature_verify_strict(&ed25519_signature, &ed25519_public_key, _message);
        debug::print(&res);
    }


    #[test]
    /// Test on a valid secp256k1 ECDSA signature created using sk = x"0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef"
    fun test_ecdsa_recover()  {
        // Flipped bits; Signature stays valid
        let pk = ecdsa_recover(
            hash::sha2_256(b"test aptos secp256k1"),
            0,
            // NOTE: A '7' was flipped to an 'f' here
            & ecdsa_signature_from_bytes(x"f7ad936da03f948c14c542020e3c5f4e02aaacd1f20427c11aa6e2fbf8776477646bba0e1a37f9e7c7f7c423a1d2849baafd7ff6a9930814a43c3f80d59db56f"),
        );
        assert!(std::option::is_some(&pk), 1);
        let pksBytes = ecdsa_raw_public_key_to_bytes(& std::option::extract(&mut pk));
        assert!(pksBytes!= x"4646ae5047316b4230d0086c8acec687f00b1cd9d1dc634f6cb358ac0a9a8ffffe77b4dd0a4bfb95851f3b7355c781dd60f8418fc8a65d14907aff47c903a559", 1);  
    }
}