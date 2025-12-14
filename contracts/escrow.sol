// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract Escrow is ReentrancyGuard{
    address public owner;
    event OrderCreated(
        string indexed projectId,
        address indexed client
    );
    event OrderApproved(string indexed _projectId,address indexed worker);
    event OrderCompleted(string indexed _projectId);
    event OrderReleased(string indexed _projectId);
    event OrderDisputed(string indexed _projectId, string indexed reason);
    event OrderResolved(string indexed _projectId, address indexed receiver);

    enum Status {
        Created,
        Accepted,
        Released,
        Completed,
        Disputed,
        Resolved
    }
    // Order structure
    struct Order {
        address client;
        address worker;
        uint amount;
        Status status;
        string projectURI;
    }
    mapping(bytes32 => Order) public projectId;
    uint public orderCount;

    constructor() {
        owner = msg.sender;
    }

    function Create(
        string memory _projectId
    ) public payable{
        Order memory order = Order(
            msg.sender,
            address(0),
            msg.value,
            Status.Created,
            ""
        );
        bytes32 idHash = keccak256(abi.encodePacked(_projectId));
        orderCount++;
        projectId[idHash] = order;
        emit OrderCreated(_projectId, msg.sender);
    }

    function Accept(string memory _projectId) public  {
        bytes32 idHash = keccak256(abi.encodePacked(_projectId));
        Order storage order = projectId[idHash];
        require(order.worker == address(0) && order.status == Status.Created, "Order already accepted");
        order.worker = msg.sender;
        order.status = Status.Accepted;
        emit OrderApproved(_projectId,msg.sender);
    }

    function Complete(string memory _projectId) public {
        bytes32 idHash = keccak256(abi.encodePacked(_projectId));
        Order storage order = projectId[idHash];
        require(order.worker == msg.sender, "Only worker can complete");
        order.status = Status.Completed;
        emit OrderCompleted(_projectId);
    }

    function Release(string memory _projectId) public nonReentrant {
        bytes32 idHash = keccak256(abi.encodePacked(_projectId));
        Order storage order = projectId[idHash];
        require(order.status != Status.Disputed , "Order is disputed");
        require(order.status == Status.Completed , "Order not completed");
        require(order.client == msg.sender, "Only Client can release funds");
        order.status = Status.Released; 
        uint SentAmount = order.amount;
        order.amount = 0;
        (bool success, ) = order.worker.call{value: SentAmount}("");
        require(success, "Transfer failed.");
        emit OrderReleased(_projectId);
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
    ) public nonReentrant returns (bool is_success) {
        require(msg.sender == owner, "Only owner can resolve");
        bytes32 idHash = keccak256(abi.encodePacked(_projectId));
        Order storage order = projectId[idHash];
        require(order.status == Status.Disputed, "Order is not disputed");
        order.status = Status.Resolved;
        uint SentAmount = order.amount;
        order.amount = 0;
        emit OrderResolved(_projectId, receiver);
        bool success;
        if (order.client == receiver) {
            (success, ) = order.client.call{value: SentAmount}("");
            
        } else if (order.worker == receiver) {
            (success, ) = order.worker.call{value: SentAmount}("");
        }else {
            revert("Invalid receiver");
        }
        require(success, "Transfer failed.");
        return success;
    }
}
