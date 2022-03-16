pragma solidity ^0.8.0;

import "./interfaces/ILayerZeroReceiver.sol";
import "./interfaces/ILayerZeroEndpoint.sol";
import "./interfaces/ILayerZeroUserApplicationConfig.sol";

abstract contract Counter is
    ILayerZeroReceiver,
    ILayerZeroUserApplicationConfig
{
    uint256 public messageCounter;
    ILayerZeroEndpoint public endpoint;

    constructor(address _endpoint) {
        endpoint = ILayerZeroEndpoint(_endpoint);
    }

    function getCounter() public view returns (uint256) {
        return messageCounter;
    }

    function lzReceive(
        uint16,
        bytes memory,
        uint64,
        bytes memory
    ) external override {
        require(msg.sender == address(endpoint));
        messageCounter += 1;
    }

    function incrementCounter(
        uint16 _dstChainId,
        bytes calldata _dstCounterMockAddress
    ) public payable {
        endpoint.send{value: msg.value}(
            _dstChainId,
            _dstCounterMockAddress,
            bytes(""),
            payable(msg.sender),
            address(0x0),
            bytes("")
        );
    }
}
