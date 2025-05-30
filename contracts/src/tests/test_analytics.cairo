%lang starknet

from starkware.starknet.testing.starknet import Starknet
from interfaces.i_analytics import IAnalytics

@external
func test_analytics_store{syscall_ptr: felt*, range_check_ptr}() -> ():
    // 1) Deploy analytics_store
    let starknet = Starknet.empty();
    let analytics = await starknet.deploy("src/analytics/analytics_store.cairo");

    // 2) Call track_interaction via interface
    let analytics_if = IAnalytics::at(analytics.address);
    await analytics_if.track_interaction(caller=0x1, action_id=42).invoke();

    // 3) Read back the count
    let (cnt) = await analytics.get_user_action_count(0x1, 42).call();
    assert cnt == 1;

    return ();
end
