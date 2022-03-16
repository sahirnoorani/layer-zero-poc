// SPDX-License-Identifier: GPL-3.0-only

pragma solidity ^0.8.0;

import "./interfaces/IDeployment.sol";
import "./interfaces/ILayerZeroEndpoint.sol";

contract MultiChainCounter is IDeployment {
    event RecieveCountFromMaster(int256 _count);
    // required: the LayerZero endpoint which is passed in the constructor
    ILayerZeroEndpoint public endpoint;
    address public masterChainAddress;
    uint16 public masterChainId;

    // required: the LayerZero endpoint
    constructor(
        address _endpoint,
        address _masterChainAddress,
        uint16 _masterChainId
    ) {
        endpoint = ILayerZeroEndpoint(_endpoint);
        masterChainAddress = _masterChainAddress;
        masterChainId = _masterChainId;
    }

    function updateCounter(int256 _updateAmount, Operation _operation)
        public
        override
    {
        bytes memory _payload = abi.encodePacked(
            _updateAmount,
            _operation,
            Function.UPDATE_COUNTER
        );
        sendMessage(_payload);
    }

    function sendMessage(bytes memory _payload) public payable {
        endpoint.send{value: msg.value}(
            masterChainId,
            abi.encode(masterChainAddress),
            _payload,
            payable(msg.sender),
            address(0x0),
            bytes("")
        );
    }

    function viewCount(uint16 _chainToViewCountOf) public override {
        bytes memory _payload = abi.encodePacked(
            Function.VIEW_COUNT,
            _chainToViewCountOf
        );
        sendMessage(_payload);
    }

    function lzReceive(
        uint16,
        bytes memory,
        uint64,
        bytes memory _payload
    ) external override {
        int256 _count = abi.decode(_payload, (int256));
        emit RecieveCountFromMaster(_count);
    }
}
