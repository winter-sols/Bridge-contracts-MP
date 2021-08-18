// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "./interfaces/IPolkally.sol";

/**
 * KALLY token cross-chain transfer contract.
 */

contract PolkallyTransfer is Ownable {
    using ECDSA for bytes32;
    // KALLY token address.
    address public kally;

    uint256 public totalTransferRecords;

    mapping(uint256 => TransferRecord) private _transferRecords;

    struct TransferRecord {
        uint256 fromChainId;
        address from;
        uint256 toChainId;
        address to;
        uint256 amount;
        uint256 depositedAt;
    }

    event CrossChainTransfer(uint256 fromChainId, address indexed from, uint256 toChainId, address indexed to, uint256 amount);

    constructor(
        address _kally
    )
    {
        _setKally(_kally);
    }

    /**
     * @dev Transfer method for cross-chain.
     * `_signer` must sign `_signature`.
     */
    function deposit(
        uint256 _toChainId,
        address _to,
        uint256 _amount
    )
        external
    {
        require(_toChainId != 0, "PolkallyTransfer#transferToChain: INVALID_CHAIN_ID");
        // Transfer tokens to this contract.
        ERC20Burnable(kally).transferFrom(_msgSender(), address(this), _amount);
        // Lock Permanently on Ethereum mainnet and burn on other networks.
        if (getChainId() != 1) {
            ERC20Burnable(kally).burn(_amount);
        }

        TransferRecord storage transferRecord = _transferRecords[_getNextTransferRecordId()];
        transferRecord.fromChainId = getChainId();
        transferRecord.from = _msgSender();
        transferRecord.toChainId = _toChainId;
        transferRecord.to = _to;
        transferRecord.amount = _amount;
        transferRecord.depositedAt = block.timestamp;
        emit CrossChainTransfer(getChainId(), _msgSender(), _toChainId, _to, _amount);
    }

    /**
     * @dev Set KALLY token address.
     * Only contract owner can call.
     */
    function setKally(
        address _kally
    )
        external
        onlyOwner
    {
        _setKally(_kally);
    }

    /**
     * @dev Return chain id .
     */
    function getChainId()
        public
        view
        returns (uint256)
    {
        uint256 id;
        assembly { id := chainid() }
        return id;
    }

    /**
     * @dev Return transfer record with `_id` .
     */
    function getTransferRecord(
        uint256 _id
    )
        external
        view
        returns (TransferRecord memory)
    {
        return _transferRecords[_id];
    }

    /**
     * @dev Set KALLY token address.
     */
    function _setKally(
        address _kally
    )
        internal
    {
        require(_kally != address(0), "PolkallyTransfer#_setKally: INVALID_ADDRESS");
        kally = _kally;
    }

    /**
     * @dev Get next transfer record id.
     * Starts from 1.
     */
    function _getNextTransferRecordId()
        internal
        returns (uint256)
    {
        return ++totalTransferRecords;
    }
}
