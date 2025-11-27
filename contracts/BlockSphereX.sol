// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @title BlockSphereX
 * @dev Registry for projects and their tagged blocks across different domains
 * @notice Creators can register projects and attach multiple blocks of metadata/content
 */
contract BlockSphereX {
    address public owner;

    struct Project {
        uint256 id;
        address creator;
        string  name;
        string  description;
        string  domain;        // e.g. "defi", "nft", "infra"
        uint256 createdAt;
        bool    isActive;
    }

    struct ProjectBlock {
        uint256 id;
        uint256 projectId;
        address creator;
        string  label;
        string  contentURI;    // IPFS / HTTPS / etc.
        string  tag;           // e.g. "architecture", "spec", "audit"
        uint256 createdAt;
        bool    isActive;
    }

    uint256 public totalProjects;
    uint256 public totalBlocks;

    // projectId => Project
    mapping(uint256 => Project) public projects;

    // blockId => ProjectBlock
    mapping(uint256 => ProjectBlock) public blocksById;

    // creator => projectIds
    mapping(address => uint256[]) public projectsOf;

    // creator => blockIds
    mapping(address => uint256[]) public blocksOf;

    // projectId => blockIds
    mapping(uint256 => uint256[]) public blocksOfProject;

    event ProjectRegistered(
        uint256 indexed projectId,
        address indexed creator,
        string name,
        string domain,
        uint256 createdAt
    );

    event ProjectStatusUpdated(
        uint256 indexed projectId,
        bool isActive,
        uint256 timestamp
    );

    event BlockAdded(
        uint256 indexed blockId,
        uint256 indexed projectId,
        address indexed creator,
        string label,
        string tag,
        uint256 createdAt
    );

    event BlockStatusUpdated(
        uint256 indexed blockId,
        bool isActive,
        uint256 timestamp
    );

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner");
        _;
    }

    modifier projectExists(uint256 projectId) {
        require(projects[projectId].creator != address(0), "Project not found");
        _;
    }

    modifier blockExists(uint256 blockId) {
        require(blocksById[blockId].creator != address(0), "Block not found");
        _;
    }

    modifier onlyProjectCreator(uint256 projectId) {
        require(projects[projectId].creator == msg.sender, "Not project creator");
        _;
    }

    modifier onlyBlockCreator(uint256 blockId) {
        require(blocksById[blockId].creator == msg.sender, "Not block creator");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    /**
     * @dev Register a new project in the BlockSphereX registry
     * @param name Project name
     * @param description Short description
     * @param domain Domain/category label
     */
    function registerProject(
        string calldata name,
        string calldata description,
        string calldata domain
    ) external returns (uint256 projectId) {
        projectId = totalProjects;
        totalProjects += 1;

        projects[projectId] = Project({
            id: projectId,
            creator: msg.sender,
            name: name,
            description: description,
            domain: domain,
            createdAt: block.timestamp,
            isActive: true
        });

        projectsOf[msg.sender].push(projectId);

        emit ProjectRegistered(projectId, msg.sender, name, domain, block.timestamp);
    }

    /**
     * @dev Set a project's active flag
     */
    function setProjectActive(uint256 projectId, bool active)
        external
        projectExists(projectId)
        onlyProjectCreator(projectId)
    {
        projects[projectId].isActive = active;
        emit ProjectStatusUpdated(projectId, active, block.timestamp);
    }

    /**
     * @dev Attach a new block to an existing project
     * @param projectId Parent project identifier
     * @param label Label for the block
     * @param contentURI Off-chain content reference
     * @param tag Tag for quick filtering
     */
    function addBlock(
        uint256 projectId,
        string calldata label,
        string calldata contentURI,
        string calldata tag
    )
        external
        projectExists(projectId)
        returns (uint256 blockId)
    {
        require(projects[projectId].isActive, "Project inactive");

        blockId = totalBlocks;
        totalBlocks += 1;

        blocksById[blockId] = ProjectBlock({
            id: blockId,
            projectId: projectId,
            creator: msg.sender,
            label: label,
            contentURI: contentURI,
            tag: tag,
            createdAt: block.timestamp,
            isActive: true
        });

        blocksOfProject[projectId].push(blockId);
        blocksOf[msg.sender].push(blockId);

        emit BlockAdded(blockId, projectId, msg.sender, label, tag, block.timestamp);
    }

    /**
     * @dev Toggle a block's active status
     */
    function setBlockActive(uint256 blockId, bool active)
        external
        blockExists(blockId)
        onlyBlockCreator(blockId)
    {
        blocksById[blockId].isActive = active;
        emit BlockStatusUpdated(blockId, active, block.timestamp);
    }

    /**
     * @dev Get all project IDs created by a user
     */
    function getProjectsOf(address user) external view returns (uint256[] memory) {
        return projectsOf[user];
    }

    /**
     * @dev Get all block IDs created by a user
     */
    function getBlocksOf(address user) external view returns (uint256[] memory) {
        return blocksOf[user];
    }

    /**
     * @dev Get all block IDs attached to a project
     */
    function getBlocksOfProject(uint256 projectId)
        external
        view
        projectExists(projectId)
        returns (uint256[] memory)
    {
        return blocksOfProject[projectId];
    }

    /**
     * @dev Transfer registry ownership
     */
    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "Zero address");
        address prev = owner;
        owner = newOwner;
        emit OwnershipTransferred(prev, newOwner);
    }
}
