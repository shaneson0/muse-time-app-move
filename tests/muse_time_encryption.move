#[test_only]
module musetime::encryption_testing {
    use aptos_std::ed25519;
    
    #[test]
    fun signature_verify_strict_test() {
        ed25519:signature_verify_strict()
    }
}