use core::option::OptionTrait;
use starknet::{ContractAddress, contract_address_try_from_felt252};

use snforge_std::{declare, ContractClassTrait, start_prank, CheatTarget};

use debug::PrintTrait;

use starknet_sign_typed_data::IMessageContractSafeDispatcher;
use starknet_sign_typed_data::IMessageContractSafeDispatcherTrait;
use starknet_sign_typed_data::IMessageContractDispatcher;
use starknet_sign_typed_data::IMessageContractDispatcherTrait;

const MESSAGE_HASH: felt252 = 0x11357f6641ca52050112c85804ea8f59a98be12c5296af634ad4fef0d9af0f1;
const SIG_R: felt252 = 3449381213729240051757458528449199117023858759534859749174941652635553920615;
const SIG_S: felt252 = 310477324566662876124928593715437615590639348637296057953766603012095711532;

fn deploy_contract(name: felt252) -> ContractAddress {
    let contract = declare(name);
    contract.deploy(@ArrayTrait::new()).unwrap()
}

#[test]
fn test_message_hash() {
    let contract_address = deploy_contract('MessageContract');

    let dispatcher = IMessageContractDispatcher { contract_address };

    let message_hash = dispatcher.message_hash(
        contract_address_try_from_felt252(0x05c6accc31f3689571cdf595828163bcfa0e5da7513cbd81d2d65e21e0dbbacb).unwrap(),
        contract_address_try_from_felt252(0x7cffe72748da43594c5924129b4f18bffe643270a96b8760a6f2e2db49d9732).unwrap(),
        'Hello, Vitalik!'
    );
    println!("message_hash: {}", message_hash);
    assert(message_hash == MESSAGE_HASH, message_hash);
}

#[test]
fn test_get_keccak() {
    let contract_address = deploy_contract('MessageContract');

    let dispatcher = IMessageContractDispatcher { contract_address };

    let keccak = dispatcher.get_keccak();
    assert(keccak == 0x3f7bee502f3e9d15bbb7c9e0a8c272b671fa51cd46c8da5cbb9a2b88f4f245f, 'Invalid keccak hash');

}

#[test]
fn test_hash_domain () {
    let contract_address = deploy_contract('MessageContract');

    let dispatcher = IMessageContractDispatcher { contract_address };

    let domain_hash = dispatcher.hash_domain();
    let domain_hash_2 = dispatcher.calc_domain_hash();
    assert(domain_hash == domain_hash_2, 'Invalid domain hash');

}

// #[test]
// fn test_verify_signature() {
//     let contract_address = deploy_contract('MessageContract');

//     let dispatcher = IMessageContractDispatcher { contract_address };

//     // let is_valid_signature = dispatcher.verify_signature();
//     // assert(is_valid_signature == true, 'Invalid signature');
//     // #[feature("safe_dispatcher")]
//     // let balance_before = safe_dispatcher.get_balance().unwrap();
//     // assert(balance_before == 0, 'Invalid balance');

//     // #[feature("safe_dispatcher")]
//     // match safe_dispatcher.increase_balance(0) {
//     //     Result::Ok(_) => panic_with_felt252('Should have panicked'),
//     //     Result::Err(panic_data) => {
//     //         assert(*panic_data.at(0) == 'Amount cannot be 0', *panic_data.at(0));
//     //     }
//     // };
// }

fn validate_lock_and_delegate_hash(
    chain_id: felt252, expected_domain_hash: felt252, expected_lock_hash: felt252,
) {
    let contract_address = deploy_contract('MessageContract');

    let dispatcher = IMessageContractDispatcher { contract_address };
    let account = starknet::contract_address_const::<20>();
    let delegatee = starknet::contract_address_const::<21>();
    let amount = 200;
    let nonce = 17;
    let expiry = 1234;

    // starknet::testing::set_chain_id(:chain_id);
    assert(
        dispatcher.lock_and_delegate_message_hash(
            domain: expected_domain_hash, :account, :delegatee, :amount, :nonce, :expiry
        ) == expected_lock_hash,
        'LOCK_AND_DELEGATE_HASH_MISMATCH'
    );
}

#[test]
#[available_gas(30000000)]
fn test_lock_and_delegate_message_hash() {

    validate_lock_and_delegate_hash(
        chain_id: 'SN_GOERLI',
        expected_domain_hash: 0x7fbbf1a57a6370927e09cad58ccbfbd6b26b1cc6ee639edf8e0e36f020284bb,
        expected_lock_hash: 0x700e4547ec169faac705c3f0bfdca19b12d1477ed0ce9d2f6824d541ce3c43c,
    );
}