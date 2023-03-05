//SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "@chainlink/contracts/src/v0.8/KeeperCompatible.sol";
import "@openzeppelin/contracts@4.6.0/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts@4.6.0/utils/Counters.sol";

contract Flower is ERC721, ERC721URIStorage, KeeperCompatibleInterface {
    using Counters for Counters.Counter;

    Counters.Counter public tokenIdCounter;

    string[] IpfsUri = [
        "https://ipfs.io/ipfs/QmXRbmeTXux5vdiYNK1WeRDbNgv6DRyxYTkaauZ2hZ58QV",
        "https://ipfs.io/ipfs/QmNN2E8PRBQgVwPK1D5CAEYuD6sZGBHW2PtUWUKN6Kx6PS",
        "https://ipfs.io/ipfs/QmZkZ9YvLqXJKNWFoNcrCi1n2EsGn9VaNPvF3WiVyJ4ejG"
    ]; 

    uint256 lastTimeStamp;
    uint256 interval;

    constructor(uint _interval) ERC721("Caretta", "TUR") {
        interval = _interval;
        lastTimeStamp = block.timestamp;
    }

    function checkUpkeep(bytes calldata) external view override returns (bool upkeepNeeded, bytes memory /* performData */) {
        uint256 tokenId = tokenIdCounter.current() - 1;
        bool done;
        if (flowerStage(tokenId) >= 2) {
            done = true;
        }

        upkeepNeeded = !done && ((block.timestamp - lastTimeStamp) > interval);        
    }

    function performUpkeep(bytes calldata) external override {
        if ((block.timestamp - lastTimeStamp) > interval ) {
            lastTimeStamp = block.timestamp;            
            uint256 tokenId = tokenIdCounter.current() - 1;
            growFlower(tokenId);
        }
    }

    function safeMint(address to) public {
        uint256 tokenId = tokenIdCounter.current();
        tokenIdCounter.increment();
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, IpfsUri[0]);
    }

    function growFlower(uint256 _tokenId) public {
        if(flowerStage(_tokenId) >= 2){return;}
        uint256 newVal = flowerStage(_tokenId) + 1;
        string memory newUri = IpfsUri[newVal];
        _setTokenURI(_tokenId, newUri);
    }

    function flowerStage(uint256 _tokenId) public view returns (uint256) {
        string memory _uri = tokenURI(_tokenId);
        if (compareStrings(_uri, IpfsUri[0])) {
            return 0;
        }
        if (
            compareStrings(_uri, IpfsUri[1]) 
        ) {
            return 1;
        }
        return 2;
    }

    function compareStrings(string memory a, string memory b)
        public
        pure
        returns (bool)
    {
        return (keccak256(abi.encodePacked((a))) ==
            keccak256(abi.encodePacked((b))));
    }

    function _burn(uint256 tokenId)
        internal
        override(ERC721, ERC721URIStorage)
    {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }
}
