// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Escrow {
    address public owner;
    event OrderCreated(
        string indexed projectId,
        address indexed client,
        address indexed worker
    );
    event OrderApproved(string indexed projectId);
    event OrderCompleted(string indexed projectId);
    event OrderDisputed(string indexed projectId, string indexed reason);
    event OrderResolved(string indexed projectId, address indexed receiver);

    enum Status {
        Created,
        Accepted,
        Pending,
        Complited,
        Disputed
    }
    // Order structure
    struct Order {
        address client;
        address worker;
        uint amount;
        bool isPaid;
        Status status;
        string projectURI;
    }
    mapping(bytes32 => Order) public projectId;
    uint public orderCount;

    constructor() {
        owner = msg.sender;
    }

    function Create(
        string memory _projectId,
        address client,
        address worker,
        uint amount
    ) public {
        Order memory order = Order(
            client,
            worker,
            amount,
            false,
            Status.Created,
            ""
        );
        bytes32 idHash = keccak256(abi.encodePacked(_projectId));
        orderCount++;
        projectId[idHash] = order;
        emit OrderCreated(_projectId, client, worker);
    }

    function Accept(string memory _projectId) public payable {
        bytes32 idHash = keccak256(abi.encodePacked(_projectId));
        Order storage order = projectId[idHash];
        require(order.client == msg.sender, "Only client can fund");
        require(msg.value == order.amount, "Invalid amount");
        order.isPaid = true;
        (bool success, ) = order.worker.call{value: order.amount}("");
        if (success) {
            order.status = Status.Accepted;
            emit OrderApproved(_projectId);
        }
    }

    function Complete(string memory _projectId) public {
        bytes32 idHash = keccak256(abi.encodePacked(_projectId));
        Order storage order = projectId[idHash];
        require(order.worker == msg.sender, "Only worker can complete");
        order.status = Status.Complited;
        emit OrderCompleted(_projectId);
    }

    function Release(string memory _projectId) public {
        bytes32 idHash = keccak256(abi.encodePacked(_projectId));
        Order storage order = projectId[idHash];
        require(order.worker == msg.sender, "Only worker can release");
        order.status = Status.Complited;
        emit OrderCompleted(_projectId);
    }

    function Dispute(string memory _projectId, string memory _reason) public {
        bytes32 idHash = keccak256(abi.encodePacked(_projectId));
        Order storage order = projectId[idHash];
        require(
            order.client == msg.sender || order.worker == msg.sender,
            "Only client or worker can dispute"
        );
        order.status = Status.Disputed;
        emit OrderDisputed(_projectId, _reason);
    }

    function Resolve(
        string memory _projectId,
        address receiver
    ) public returns (bool is_success) {
        require(msg.sender == owner, "Only owner can resolve");
        bytes32 idHash = keccak256(abi.encodePacked(_projectId));
        Order storage order = projectId[idHash];

        if (order.client == receiver) {
            (bool success, ) = order.client.call{value: order.amount}("");
            return success;
        } else if (order.worker == receiver) {
            (bool success, ) = order.worker.call{value: order.amount}("");
            return success;
        }
        emit OrderResolved(_projectId, receiver);
    }
}
