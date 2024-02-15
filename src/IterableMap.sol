// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "./Structs.sol";

library IterableMapping {
    struct MapBytes32ToListedToken {
        mapping(bytes32 => TokenStructs.ListedToken) values;
        bytes32[] keys;
        mapping(bytes32 => bool) exists;
    }

    function set(MapBytes32ToListedToken storage map, bytes32 key, TokenStructs.ListedToken memory value) internal {
        if (!map.exists[key]) {
            map.keys.push(key);
            map.exists[key] = true;
        }
        map.values[key] = value;
    }

    function get(MapBytes32ToListedToken storage map, bytes32 key)
        internal
        view
        returns (TokenStructs.ListedToken memory)
    {
        require(map.exists[key], "Key does not exist.");
        return map.values[key];
    }

    function remove(MapBytes32ToListedToken storage map, bytes32 key) internal {
        require(map.exists[key], "Key does not exist.");
        delete map.values[key];
        map.exists[key] = false;
    }

    function getKeyAtIndex(MapBytes32ToListedToken storage map, uint256 index) internal view returns (bytes32) {
        require(index < map.keys.length, "Index out of bounds.");
        return map.keys[index];
    }

    function size(MapBytes32ToListedToken storage map) internal view returns (uint256) {
        return map.keys.length;
    }

    function mapToArray(MapBytes32ToListedToken storage map)
        internal
        view
        returns (TokenStructs.ListedToken[] memory)
    {
        TokenStructs.ListedToken[] memory listedTokens = new TokenStructs.ListedToken[](map.keys.length);
        for (uint256 i = 0; i < map.keys.length; i++) {
            // Example of retrieving each key-value pair
            bytes32 key = map.keys[i];
            TokenStructs.ListedToken memory value = map.values[key];
            listedTokens[i] = value;
        }
        return listedTokens;
    }
}
