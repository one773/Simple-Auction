// SIMPLE AUCTION 

// 1. Starting an Auction
// 2. Bidding
// 3. Ending an Auction
// 4. Withdrawals
// 5. Claiming item.

// SPDX-License-Identifier:MIT

pragma solidity ^0.8.19;

contract SimpleAuction {
    address public owner;
    string public item;
    uint256 public startTime;
    uint256 public endTime;
    uint256 public minBid;
    address public highestBidder;
    uint256 public highestBid;
    bool public itemClaimed;
    mapping(address => uint256) public bids;

    event AuctionStarted(string item, uint256 startTime, uint256 endTime, uint256 minBid);
    event BidPlaced(address bidder, uint256 amount);
    event AuctionEnded(address winner, uint256 amount);
    event ItemClaimed(address claimer, string item);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    modifier auctionOngoing() {
        require(block.timestamp >= startTime && block.timestamp <= endTime, "Auction is not ongoing.");
        _;
    }

    modifier auctionEnded() {
        require(block.timestamp > endTime, "Auction is still ongoing.");
        _;
    }

    constructor () {
        owner = msg.sender;
    }

    function startAuction(string memory _item, uint256 _startTime, uint256 _endTime, uint256 _minBid) public onlyOwner {
        require(_startTime < _endTime, "Start time has to be greater than end of auction.");
        require(_startTime >= block.timestamp, "Start time must be in the future.");

        item = _item;
        startTime = _startTime;
        endTime = _endTime;
        minBid = _minBid;
        highestBidder = address(0);
        highestBid = 0;
        itemClaimed = false;

        emit AuctionStarted(_item, _startTime, _endTime, _minBid);
    }

    function placeBid() public payable auctionOngoing {
        require(msg.value >= minBid, "Bid must be at least the minimum bid.");
        require(msg.value > highestBid, "Bid must be higher than the current highest bid.");

        if(highestBidder != address(0)) {
            bids[highestBidder] += highestBid;
        }

        highestBidder = msg.sender;
        highestBid = msg.value;

        emit BidPlaced(msg.sender, msg.value);
    }

    function withdraw() public {
        uint256 amount = bids[msg.sender];
        require(amount > 0, "No funds to retrieve");

        bids[msg.sender] = 0;

        payable(msg.sender).transfer(amount);
    }

    function endAuction() public onlyOwner auctionEnded {
        require(highestBidder != address(0), "No bids placed.");

        emit AuctionEnded(highestBidder, highestBid);
        payable(owner).transfer(highestBid);
    }

    function claimItem() public auctionEnded {
        require(msg.sender == highestBidder, "Only the winner of the auction can claim this item.");
        require(!itemClaimed,"Item has already been claimed");

        itemClaimed = true;

        emit ItemClaimed(msg.sender, item);
    }

    function isAuctionOngoing() public view returns (bool) {
        return block.timestamp >= startTime && block.timestamp <= endTime;
    }

    function isAuctionEnded() public view returns (bool) {
        return block.timestamp > endTime;
    }

    function getHighestBid() public view returns (uint256) {
        return highestBid;
    }

    function getHighestBidder() public view returns (address) {
        return highestBidder;
    }


}
