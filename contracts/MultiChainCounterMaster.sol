// SPDX-License-Identifier: GPL-3.0-only

pragma solidity ^0.8.0;

import "./interfaces/IDeployment.sol";
import "./interfaces/ILayerZeroEndpoint.sol";

contract MultiChainCounterMaster is IDeployment {
    mapping(uint16 => int256) public chainToCount;

    // required: the LayerZero endpoint which is passed in the constructor
    ILayerZeroEndpoint public endpoint;

    // required: the LayerZero endpoint
    constructor(address _endpoint) {
        endpoint = ILayerZeroEndpoint(_endpoint);
    }

    // overrides lzReceive function in ILayerZeroReceiver.
    // automatically invoked on the receiving chain after
    // the source chain calls endpoint.send(...)
    function lzReceive(
        uint16 _srcChainId,
        bytes memory _fromAddress,
        uint64,
        bytes memory _payload
    ) external override {
        require(msg.sender == address(endpoint));
        (
            int256 _updateAmount,
            Operation _operation,
            Function _function,
            uint16 _chainToViewCountOf
        ) = abi.decode(_payload, (int256, Operation, Function, uint16));
        if (_function == Function.UPDATE_COUNTER) {
            updateCounterHelper(_updateAmount, _operation, _srcChainId);
        } else if (_function == Function.VIEW_COUNT) {
            bytes memory _view_payload = abi.encode(
                viewCount(_chainToViewCountOf)
            );
            sendMessage(_srcChainId, _fromAddress, _view_payload);
        }
    }

    function viewCount(uint16 _chainToViewCountOf)
        public
        view
        override
        returns (int256)
    {
        return int256(chainToCount[_chainToViewCountOf]);
    }

    function updateCounter(int256 _updateAmount, Operation _operation)
        public
        override
    {
        updateCounterHelper(_updateAmount, _operation, getThisChainID());
    }

    function updateCounterHelper(
        int256 _updateAmount,
        Operation _operation,
        uint16 _chainIdToUpdate
    ) private {
        if (_operation == Operation.ADD) {
            chainToCount[_chainIdToUpdate] += _updateAmount;
        } else if (_operation == Operation.SUBTRACT) {
            chainToCount[_chainIdToUpdate] -= _updateAmount;
        } else if (_operation == Operation.MULTIPLY) {
            chainToCount[_chainIdToUpdate] *= _updateAmount;
        }
    }

    function sendMessage(
        uint16 _chainIDToSendTo,
        bytes memory _addressToSendTo,
        bytes memory _payload
    ) public payable {
        endpoint.send{value: msg.value}(
            _chainIDToSendTo,
            _addressToSendTo,
            _payload,
            payable(msg.sender),
            address(0x0),
            bytes("")
        );
    }

    function getThisChainID() private view returns (uint16) {
        uint16 id;
        assembly {
            id := chainid()
        }
        return id;
    }
}
