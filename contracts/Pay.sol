//SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

contract Pay {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    struct request {
        address requestor;
        uint256 amount;
        string message;
        string name;
    }

    struct sendRecieve {
        string action;
        uint256 amount;
        string message;
        address otherPartyAddress;
        string otherPartyName;
    }

    struct userName {
        string name;
        bool isNameSet;
    }

    mapping(address => userName) names;
    mapping(address => request[]) requests;
    mapping(address => sendRecieve[]) history;

    function addName(string memory _name) public {
        userName storage newUserName = names[msg.sender];
        newUserName.name = _name;
        newUserName.isNameSet = true;
    }

    function createRequest(
        address user,
        uint256 _amount,
        string memory _message
    ) public {
        request memory newRequest;
        newRequest.requestor = msg.sender;
        newRequest.amount = _amount;
        newRequest.message = _message;
        if (names[msg.sender].isNameSet) {
            newRequest.name = names[msg.sender].name;
        }
        requests[user].push(newRequest);
    }

    function payRequest(uint256 _request) public payable {
        require(_request < requests[msg.sender].length, "No such request");
        request[] storage myRequests = requests[msg.sender];
        request storage payableRequest = myRequests[_request];
        uint256 toPay = payableRequest.amount * 1e18;
        require(msg.value == toPay, "Pay Correct Amount");
        payable(payableRequest.requestor).transfer(msg.value);
        addHistory(
            payableRequest.requestor,
            msg.sender,
            payableRequest.amount,
            payableRequest.message
        );
        myRequests[_request] = myRequests[myRequests.length - 1];
        myRequests.pop();
    }

    function addHistory(
        address sender,
        address receiver,
        uint256 _amount,
        string memory _message
    ) private {
        sendRecieve memory newSend;
        newSend.action = "-";
        newSend.amount = _amount;
        newSend.message = _message;
        newSend.otherPartyAddress = receiver;
        if (names[receiver].isNameSet) {
            newSend.otherPartyName = names[receiver].name;
        }
        history[sender].push(newSend);

        sendRecieve memory newReceive;
        newReceive.action = "+";
        newReceive.amount = _amount;
        newReceive.message = _message;
        newReceive.otherPartyAddress = sender;
        if (names[sender].isNameSet) {
            newReceive.otherPartyName = names[sender].name;
        }
        history[receiver].push(newReceive);
    }

    function getMyRequests(
        address _user
    )
        public
        view
        returns (
            address[] memory,
            uint256[] memory,
            string[] memory,
            string[] memory
        )
    {
        address[] memory addrs = new address[](requests[_user].length);
        uint256[] memory amnt = new uint256[](requests[_user].length);
        string[] memory msge = new string[](requests[_user].length);
        string[] memory nme = new string[](requests[_user].length);

        for (uint i = 0; i < requests[_user].length; i++) {
            request storage myRequests = requests[_user][i];
            addrs[i] = myRequests.requestor;
            amnt[i] = myRequests.amount;
            msge[i] = myRequests.message;
            nme[i] = myRequests.name;
        }

        return (addrs, amnt, msge, nme);
    }

    function getMyHistory(
        address _user
    ) public view returns (sendRecieve[] memory) {
        return history[_user];
    }

    function getMyName(address _user) public view returns (userName memory) {
        return names[_user];
    }
}
