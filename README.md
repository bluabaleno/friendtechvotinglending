FriendtechSharesV1 Contract Modification
Goal of the Changes

The goal of the modifications is to enable users to temporarily swap shares and thus chat rooms. This is achieved by introducing a new mapping sharesAllowance and two new functions approve and transferFrom to the FriendtechSharesV1 contract.
Changes Made

1. Added a new mapping sharesAllowance:

'''
// SharesSubject => (Owner => (Spender => Allowance))
mapping(address => mapping(address => mapping(address => uint256))) public sharesAllowance;
'''

2. Added a new function approve:

'''
function approve(address sharesSubject, address spender, uint256 amount) public {
    require(sharesBalance[sharesSubject][msg.sender] >= amount, "Insufficient shares");
    sharesAllowance[sharesSubject][msg.sender][spender] = amount;
}
'''

3. Added a new function transferFrom:

'''
function transferFrom(address sharesSubject, address from, address to, uint256 amount) public payable {
    require(sharesBalance[sharesSubject][from] >= amount, "Insufficient shares");
    require(sharesAllowance[sharesSubject][from][msg.sender] >= amount, "Not approved");
    sharesBalance[sharesSubject][from] -= amount;
    sharesBalance[sharesSubject][to] += amount;
    sharesAllowance[sharesSubject][from][msg.sender] -= amount;
}
'''

Issues Encountered

1. The sharesAllowance mapping cannot be updated via the ShareholderVoting contract. This is because the approve function, which updates the sharesAllowance mapping, needs to be called by the account that owns the shares.

2. The transferFrom function requires that there are mappings added to the sharesAllowance first before it is able to be called. This is typically done by calling the approve function.

3. The depositCollateral function in the ShareLending contract fails even when all conditions are met. The issue might be with the transferFrom function in the FriendtechSharesV1 contract.

If you know a way to achieve the goal without modifying the original contract, please share your solution.