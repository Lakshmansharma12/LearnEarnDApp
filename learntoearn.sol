learn to earn 
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract EducationToken is ERC20, Ownable {
    constructor() ERC20("EducationToken", "EDU") {
        _mint(msg.sender, 1000000 * 10 ** decimals());
    }

    function rewardTokens(address recipient, uint256 amount) external onlyOwner {
        _mint(recipient, amount);
    }
}

contract EducationNFT is ERC721URIStorage, Ownable {
    uint256 private _tokenIdCounter;

    constructor() ERC721("EducationBadge", "EDUB") {}

    function mintNFT(address recipient, string memory tokenURI) external onlyOwner {
        _tokenIdCounter++;
        uint256 newTokenId = _tokenIdCounter;
        _mint(recipient, newTokenId);
        _setTokenURI(newTokenId, tokenURI);
    }
}

contract LearnToEarnPlatform is Ownable {
    EducationToken private eduToken;
    EducationNFT private eduNFT;

    struct Course {
        string title;
        string content;
        uint256 price;
        address educator;
    }

    struct Task {
        string description;
        uint256 reward;
        bool isMilestone;
    }

    mapping(uint256 => Course) public courses;
    mapping(uint256 => Task[]) public courseTasks;
    mapping(address => uint256[]) public studentEnrollments;
    mapping(address => mapping(uint256 => bool)) public taskCompletion;

    uint256 private _courseIdCounter;

    event CourseCreated(uint256 courseId, string title, address educator);
    event TaskCompleted(address student, uint256 courseId, uint256 taskId, uint256 reward);

    constructor(EducationToken _eduToken, EducationNFT _eduNFT) {
        eduToken = _eduToken;
        eduNFT = _eduNFT;
    }

    function createCourse(string memory title, string memory content, uint256 price) external {
        _courseIdCounter++;
        uint256 courseId = _courseIdCounter;

        courses[courseId] = Course(title, content, price, msg.sender);
        emit CourseCreated(courseId, title, msg.sender);
    }

    function addTask(uint256 courseId, string memory description, uint256 reward, bool isMilestone) external {
        require(courses[courseId].educator == msg.sender, "Only educator can add tasks");
        courseTasks[courseId].push(Task(description, reward, isMilestone));
    }

    function enrollInCourse(uint256 courseId) external {
        require(eduToken.balanceOf(msg.sender) >= courses[courseId].price, "Insufficient tokens");
        eduToken.transferFrom(msg.sender, courses[courseId].educator, courses[courseId].price);
        studentEnrollments[msg.sender].push(courseId);
    }

    function completeTask(uint256 courseId, uint256 taskId) external {
        require(!taskCompletion[msg.sender][taskId], "Task already completed");
        Task memory task = courseTasks[courseId][taskId];

        taskCompletion[msg.sender][taskId] = true;
        eduToken.rewardTokens(msg.sender, task.reward);

        if (task.isMilestone) {
            eduNFT.mintNFT(msg.sender, "https://example.com/nft-metadata.json");
        }

        emit TaskCompleted(msg.sender, courseId, taskId, task.reward);
    }
}
