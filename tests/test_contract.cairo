use core::option::OptionTrait;
use starknet::{ContractAddress, contract_address_try_from_felt252};

use snforge_std::{declare, ContractClassTrait, start_prank, CheatTarget};

use debug::PrintTrait;

use starknet_sign_typed_data::IMessageContractSafeDispatcher;
use starknet_sign_typed_data::IMessageContractSafeDispatcherTrait;
use starknet_sign_typed_data::IMessageContractDispatcher;
use starknet_sign_typed_data::IMessageContractDispatcherTrait;

const MESSAGE_HASH: felt252 = 0x11357f6641ca52050112c85804ea8f59a98be12c5296af634ad4fef0d9af0f1;
const SIG_R: felt252 = 876127409893055305263472568801265030870686557618925505070655540045852847437;
const SIG_S: felt252 = 3151883555888554397787478372336642758697253366189524680994584841657575588135;

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

#[test]
fn test_verify_signature() {
    let contract_address = deploy_contract('MessageContract');

    let dispatcher = IMessageContractDispatcher { contract_address };

    let is_valid_signature = dispatcher.verify_signature(
        contract_address_try_from_felt252(0x05c6accc31f3689571cdf595828163bcfa0e5da7513cbd81d2d65e21e0dbbacb).unwrap(),
        contract_address_try_from_felt252(0x7cffe72748da43594c5924129b4f18bffe643270a96b8760a6f2e2db49d9732).unwrap(),
        'Hello, Vitalik!',
        array![
            SIG_R,
            SIG_S
        ]
    );
    assert(is_valid_signature == true, 'Invalid signature');
}