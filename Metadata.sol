pragma solidity 0.8.7;

import "./Base64.sol";
import "./SSTORE2.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract Metadata is Ownable {
    using Strings for uint256;

    mapping(uint256 => bool) public isNounPepeOnChain;
    mapping(uint256 => address) onChainNounPepe;
    mapping(uint256 => bool) public isGif;

    modifier onlyFren {
        //frens can map.
        require(frens[msg.sender] || msg.sender == owner(), "not a fren");
        _;
    }

    mapping(address => bool) frens;

    function tokenURI(uint256 tokenId) public view returns (string memory) {
        return buildMetadata(tokenId);
    }

    function buildMetadata(uint256 tokenId) public view returns(string memory) {
        if (onChainNounPepe[tokenId] == address(0)) {
            return string(abi.encodePacked(
                'data:application/json;base64,', Base64.encode(bytes(abi.encodePacked(
                            '{"name": "Noun Pepe ', tokenId.toString(), 
                            '", "description":"', 
                            "This Noun Pepe is off the chain.",
                            '", "image": "', 
                            'https://storage.googleapis.com/nounpepes123/', 
                            tokenId.toString(), (isGif[tokenId] ? '.gif' : '.png'),
                            '"}')))));
        } else {
            return string(abi.encodePacked(
                'data:application/json;base64,', Base64.encode(bytes(abi.encodePacked(
                            '{"name": "Noun Pepe ', tokenId.toString(), 
                            '", "description":"', 
                            "This Noun Pepe is fully on-chain at a unique address.", 
                            '", "image":', 
                            isGif[tokenId] ? '"data:image/gif;base64,' : '"data:image/png;base64,',
                            SSTORE2.read(onChainNounPepe[tokenId]),
                            '"}')))));
        }
    }

    function onChainArt(uint256 tokenId) external view returns (string memory) {
        return string(SSTORE2.read(onChainNounPepe[tokenId]));
    }

    function onChainArtAddress(uint256 tokenId) external view returns (address) {
        return onChainNounPepe[tokenId];
    }

    receive() external payable { }

    function putNounPepeOnChain(uint256 tokenId, string calldata svg) external onlyFren {
        onChainNounPepe[tokenId] = SSTORE2.write(bytes(svg));
    }
    function takeNounPepeOffChain(uint256 tokenId) external onlyFren {
        onChainNounPepe[tokenId] = address(0);
    }

    function toggleIsGif(uint256 tokenId) external onlyFren {
        isGif[tokenId] = !isGif[tokenId];
    }

    function isFren(address _user) external view returns (bool) {
        return frens[_user];
    }

    function toggleFren(address _user) external onlyOwner {
        frens[_user] = !frens[_user];
    }

}
