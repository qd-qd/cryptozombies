pragma solidity >=0.4.19;

import "./zombiefactory.sol";

/* Interface of CryptoKitty contract */
contract KittyInterface {
    function getKitty(uint256 _id) external view returns (
        bool isGestating,
        bool isReady,
        uint256 cooldownIndex,
        uint256 nextActionAt,
        uint256 siringWithId,
        uint256 birthTime,
        uint256 matronId,
        uint256 sireId,
        uint256 generation,
        uint256 genes
    );
}

contract ZombieFeeding is ZombieFactory {

    KittyInterface kittyContract;

    modifier onlyOwnerOf(uint256 _zombieId) {
        require(msg.sender == zombieToOwner[_zombieId]);
        _;
    }

    function setKittyContractAddress (address _address) external onlyOwner {
        kittyContract = KittyInterface(_address);
    }

    function _triggerCooldown(Zombie storage _zombie) internal {
        _zombie.readyTime = uint32(now + cooldownTime);
    }

    function _isReady(Zombie storage _zombie) internal view returns (bool) {
        return (_zombie.readyTime <= now);
    }

    function feedAndMultiply(uint256 _zombieId, uint256 _targetDna, string memory _species) internal onlyOwnerOf(_zombieId) {
        Zombie storage myZombie = zombies[_zombieId];
        require(_isReady(myZombie));
        uint256 targetDna = _targetDna % dnaModulus;
        uint256 newDna = (myZombie.dna + targetDna) / 2;
        if (keccak256(bytes(_species)) == keccak256("kitty")) {
            newDna = newDna - newDna % 100 + 99;
        }
        _createZombie("NoName", newDna);
        _triggerCooldown(myZombie);
    }

    function feedOnKitty(uint256 _zombieId, uint256 _kittyId) public {
        uint256 kittyDna;
        /* Is the way to only get the last value returned by getKitty method */
        (,,,,,,,,,kittyDna) = kittyContract.getKitty(_kittyId);
        feedAndMultiply(_zombieId, kittyDna, "kitty");
    }

}