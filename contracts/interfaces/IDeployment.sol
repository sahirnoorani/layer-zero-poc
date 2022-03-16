// SPDX-License-Identifier: BUSL-1.1

pragma solidity >=0.8.0;

import "./ILayerZeroReceiver.sol";
import "./ILayerZeroEndpoint.sol";

interface IDeployment is ILayerZeroReceiver {
    enum Operation {
        ADD,
        SUBTRACT,
        MULTIPLY
    }

    enum Function {
        UPDATE_COUNTER,
        VIEW_COUNT
    }

    function updateCounter(int256 _updateAmount, Operation _operation) external;

    function viewCount(uint16 _chainToViewCountOf) external;
}
