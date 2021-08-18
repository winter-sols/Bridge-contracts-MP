// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IPolkally is IERC20 {
    function setSigner(
        address _newSigner
    )
        external;

    function getSigner()
        external
        returns (address);

    function mint(
        address _account,
        uint256 _amount,
        bytes memory _signature
    )
        external;

    function burn(
        uint256 _amount
    )
        external;
}
