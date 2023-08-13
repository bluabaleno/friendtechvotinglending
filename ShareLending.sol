pragma solidity >=0.8.2 <0.9.0;

import "./FriendtechSharesV1.sol";

contract ShareLending {
    FriendtechSharesV1 public sharesContract;

    address public shareholderVotingContract;

    // Mapping from borrower to the collateral they have deposited
    mapping(address => uint256) public collateralDeposited;

    // Mapping from borrower to the share they have borrowed
    mapping(address => uint256) public sharesBorrowed;

    // Mapping to track which addresses are invited and whether the invitation has been used
    mapping(address => bool) public isInvited;
    mapping(address => bool) public invitationUsed;

    // Mapping to track the subject of each invitation
    mapping(address => address) public invitationSubject;

    // Mapping to track the expiration time of each invitation
    mapping(address => uint256) public invitationExpiration;

    // Mapping to track the expiration time of each loan
    mapping(address => uint256) public loanExpiration;

    // Mapping to track the approval of each borrower
    mapping(address => bool) public isApproved;

    uint256 constant DEFAULT_INVITATION_DURATION = 7 days;
    uint256 constant DEFAULT_LOAN_DURATION = 1 days;

    function setShareholderVotingContract(address _shareholderVotingContract) public {
    // Add authorization checks if needed
    shareholderVotingContract = _shareholderVotingContract;
    }

    function inviteGuest(address guest, uint256 duration) public {
        // Check if the sender is the subject of the invitation or the ShareholderVoting contract
        require(msg.sender == invitationSubject[guest] || msg.sender == shareholderVotingContract, "Not authorized");

        // Add the guest to the list of invited addresses and mark the invitation as not used
        isInvited[guest] = true;
        invitationUsed[guest] = false;

        // Set the expiration time of the invitation
        if (duration == 0) {
            duration = DEFAULT_INVITATION_DURATION;
        }
        invitationExpiration[guest] = block.timestamp + duration;
    }

    function depositCollateral(address guestSubject) public {
        require(isInvited[msg.sender] && !invitationUsed[msg.sender], "Not invited or invitation already used");
        require(block.timestamp <= invitationExpiration[msg.sender], "Invitation expired");
        require(isApproved[msg.sender], "Not approved");

        // Transfer the Guest's share from the Guest to this contract
        sharesContract.transferFrom(guestSubject, msg.sender, address(this), 1);

        // Record the collateral deposited by the Guest
        collateralDeposited[msg.sender] += 1;

        // Mark the invitation as used
        invitationUsed[msg.sender] = true;
    }

    function borrowShare(address hostSubject, uint256 duration) public {
        require(collateralDeposited[msg.sender] > 0, "No collateral deposited");

        // Set the expiration time of the loan
        if (duration == 0) {
            duration = DEFAULT_LOAN_DURATION;
        }
        loanExpiration[msg.sender] = block.timestamp + duration;

        // Transfer the Host's share from this contract to the Guest
        sharesContract.transferFrom(hostSubject, address(this), msg.sender, 1);

        // Record the share borrowed by the Guest
        sharesBorrowed[msg.sender] += 1;
    }

    function returnShare(address hostSubject) public {
        require(sharesBorrowed[msg.sender] > 0, "No share borrowed");
        require(block.timestamp <= loanExpiration[msg.sender], "Loan expired");

        // Transfer the Host's share from the Guest to this contract
        sharesContract.transferFrom(hostSubject, msg.sender, address(this), 1);

        // Update the record of the share borrowed by the Guest
        sharesBorrowed[msg.sender] -= 1;
    }

    function withdrawCollateral(address guestSubject) public {
        require(sharesBorrowed[msg.sender] == 0, "Share not returned");

        // Transfer the Guest's share from this contract to the Guest
        sharesContract.transferFrom(guestSubject, address(this), msg.sender, 1);

        // Update the record of the collateral deposited by the Guest
        collateralDeposited[msg.sender] -= 1;
    }

    // Add a new function to approve this contract to transfer the borrower's shares
    function approveTransfer(bool approved) public {
        isApproved[msg.sender] = approved;
    }
}