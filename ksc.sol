// SPDX-License-Identifier: MIT

/* 
Beomjoong Kim, Hyoung Joong Kim, and Junghee Lee,
“First Smart Contract Allowing Cryptoasset Recovery,” 
KSII Transactions on Internet and Information Systems, vol. 16, no. 3, Mar. 2022,
 doi: https://doi.org/10.3837/tiis.2022.03.006.
*/

pragma solidity ^0.8.0;

contract Kim{
    
    event safeTX_made(bytes32 Receipt);
    
    mapping (bytes32 => receipt) txInfo;
    
    struct receipt{
        address receiver;
        address backup;
        uint deadline;
        uint asset;
        bool claimed;
    }
    
    function Store(address receiver_, address backup_, uint deadline_) payable public returns(bytes32 returnReceipt) {
        require (msg.value > 0);
        uint current = block.timestamp;
        
        bytes32 receipt_ = keccak256(abi.encodePacked(msg.sender, receiver_, backup_, current, deadline_, msg.value));
        
        txInfo[receipt_].receiver = receiver_;
        txInfo[receipt_].backup = backup_;
        txInfo[receipt_].deadline = block.timestamp + deadline_;
        txInfo[receipt_].asset = txInfo[receipt_].asset + msg.value;
    
        emit safeTX_made(receipt_);
        return receipt_;
    }
    
    function Receive(bytes32 receipt_) public {
        require (msg.sender == txInfo[receipt_].receiver);
        require (txInfo[receipt_].claimed == false);
        txInfo[receipt_].claimed = true;
        payable(msg.sender).transfer(txInfo[receipt_].asset);
    }
    
    function Move (bytes32 receipt_) public {
        require (block.timestamp >= txInfo[receipt_].deadline);
        require (txInfo[receipt_].claimed == false);
        txInfo[receipt_].claimed = true;
        payable(txInfo[receipt_].backup).transfer(txInfo[receipt_].asset);
    }
}
       
