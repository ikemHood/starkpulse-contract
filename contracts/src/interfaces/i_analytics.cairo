%lang starknet

@contract_interface
namespace IAnalytics {
    /// Log that `user` performed `action_id`
    func track_interaction(user: ContractAddress, action_id: felt) -> ();
}
