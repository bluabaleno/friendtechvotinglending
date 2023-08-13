pragma solidity >=0.8.2 <0.9.0;

import "./FriendtechSharesV1.sol";

contract ShareholderVoting {
    FriendtechSharesV1 public sharesContract;

    struct Proposal {
        string description;
        uint256 forVotes;
        uint256 againstVotes;
        bool executed;
        mapping(address => bool) hasVoted;
    }

    mapping(address => Proposal[]) public proposalsBySubject;

    constructor(address _sharesContract) {
        sharesContract = FriendtechSharesV1(_sharesContract);
    }

    function createProposal(address subject, string memory description) public {
        // Push a blank proposal to the array
        proposalsBySubject[subject].push();

        // Get a reference to the new proposal
        Proposal storage newProposal = proposalsBySubject[subject][proposalsBySubject[subject].length - 1];

        // Set the fields of the new proposal
        newProposal.description = description;
        newProposal.forVotes = 0;
        newProposal.againstVotes = 0;
    }

    function vote(address subject, uint256 proposalIndex, bool voteFor) public {
        Proposal storage proposal = proposalsBySubject[subject][proposalIndex];
        require(!proposal.hasVoted[msg.sender], "Already voted");

        uint256 balance = sharesContract.sharesBalance(subject, msg.sender);
        require(balance > 0, "Not a shareholder");

        if (voteFor) {
            proposal.forVotes += balance;
        } else {
            proposal.againstVotes += balance;
        }
        proposal.hasVoted[msg.sender] = true;
    }

    function executeProposal(address subject, uint256 proposalIndex) public {
        Proposal storage proposal = proposalsBySubject[subject][proposalIndex];
        require(!proposal.executed, "Already executed");

        uint256 totalShares = sharesContract.sharesSupply(subject);
        require(proposal.forVotes > totalShares / 2, "Not enough votes for");

        // The proposal has passed, execute the decision...
        proposal.executed = true;
    }
}