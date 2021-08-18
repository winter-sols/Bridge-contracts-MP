// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "./interfaces/IPolkally.sol";

/**
 * KALLY token on BSC, Polygon and Avalanche.
 */

contract Polkally is ERC20Burnable, Ownable {
    using ECDSA for bytes32;
    // Signer address for signature verification.
    address private _signer;

    constructor(
        string memory _name,
        string memory _symbol,
        address signer_
    )
        ERC20(_name, _symbol)
    {
        _setSigner(signer_);
    }

    /**
     * @dev Set signature signer address.
     * Only contract owner can call.
     */
    function setSigner(
        address _newSigner
    )
        external
        onlyOwner
    {
        _setSigner(_newSigner);
    }

    /**
     * @dev Return signature signer address.
     */
    function getSigner()
        external
        view
        onlyOwner
        returns (address)
    {
        return _signer;
    }

    /**
     * @dev Create `_amount` tokens for `_account`.
     *
     * Requirements:
     *
     * - `_signer` must sign `_signature`.
     */
    function mint(
        address _account,
        uint256 _amount,
        bytes memory _signature
    )
        external
    {
        bytes32 msgHash = keccak256(abi.encodePacked(_account, _amount));
        require(_signer == msgHash.recover(_signature), "Polkally#mint: INVALID_SIGNATURE");
        _mint(_account, _amount);
    }

    /**
     * @dev Set signature signer address.
     *
     * `_newSigner` cannot be the zero address.
     */
    function _setSigner(
        address _newSigner
    )
        internal
    {
        require(_newSigner != address(0), "Polkally#_setSigner: INVALID_ADDRESS");
        _signer = _newSigner;
    }
}
