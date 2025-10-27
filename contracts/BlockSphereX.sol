// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title BlockSphereX
 * @dev A simple decentralized registry that allows users to register, update, and retrieve profile data.
 */
contract BlockSphereX {
    struct UserProfile {
        string name;
        string email;
        uint256 registrationTime;
    }

    mapping(address => UserProfile) private userProfiles;

    event UserRegistered(address indexed user, string name, string email, uint256 time);
    event UserUpdated(address indexed user, string newName, string newEmail, uint256 time);

    /**
     * @dev Register a new user profile. Can only be done once per address.
     * @param _name The user's name.
     * @param _email The user's email address.
     */
    function registerUser(string memory _name, string memory _email) external {
        require(bytes(userProfiles[msg.sender].name).length == 0, "User already registered");
        userProfiles[msg.sender] = UserProfile(_name, _email, block.timestamp);
        emit UserRegistered(msg.sender, _name, _email, block.timestamp);
    }

    /**
     * @dev Update an existing user profile.
     * @param _newName The new name to update.
     * @param _newEmail The new email to update.
     */
    function updateUser(string memory _newName, string memory _newEmail) external {
        require(bytes(userProfiles[msg.sender].name).length != 0, "User not registered");
        userProfiles[msg.sender].name = _newName;
        userProfiles[msg.sender].email = _newEmail;
        emit UserUpdated(msg.sender, _newName, _newEmail, block.timestamp);
    }

    /**
     * @dev Retrieve user details.
     * @param _user The wallet address of the user.
     */
    function getUser(address _user) external view returns (string memory, string memory, uint256) {
        UserProfile memory profile = userProfiles[_user];
        require(bytes(profile.name).length != 0, "User not found");
        return (profile.name, profile.email, profile.registrationTime);
    }
}
