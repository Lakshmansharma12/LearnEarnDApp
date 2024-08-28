// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract EducationToken is ERC20, Ownable {
    constructor() ERC20("EducationToken", "EDU") {
        _mint(msg.sender, 1000000 * 10 ** decimals());
    }

    function rewardTokens(address recipient, uint256 amount) external onlyOwner {
        _mint(recipient, amount);
    }
}

contract EducationNFT is ERC721, Ownable {
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


// Install required packages:
// npm install express web3 dotenv

const express = require('express');
const Web3 = require('web3');
const dotenv = require('dotenv');

dotenv.config();

const app = express();
const port = 3000;

// Connect to the Ethereum blockchain
const web3 = new Web3(new Web3.providers.HttpProvider(process.env.INFURA_URL));

const eduTokenABI = [/* EducationToken ABI */];
const eduNFTABI = [/* EducationNFT ABI */];
const learnToEarnABI = [/* LearnToEarnPlatform ABI */];

const eduTokenAddress = process.env.EDU_TOKEN_ADDRESS;
const eduNFTAddress = process.env.EDU_NFT_ADDRESS;
const learnToEarnAddress = process.env.LEARN_TO_EARN_ADDRESS;

const eduToken = new web3.eth.Contract(eduTokenABI, eduTokenAddress);
const eduNFT = new web3.eth.Contract(eduNFTABI, eduNFTAddress);
const learnToEarn = new web3.eth.Contract(learnToEarnABI, learnToEarnAddress);

// Middleware to parse JSON bodies
app.use(express.json());

app.post('/create-course', async (req, res) => {
    const { title, content, price, educatorAddress } = req.body;

    const createCourse = learnToEarn.methods.createCourse(title, content, price);
    const gas = await createCourse.estimateGas({ from: educatorAddress });

    createCourse.send({ from: educatorAddress, gas })
        .then(receipt => res.json({ status: 'success', receipt }))
        .catch(error => res.status(500).json({ status: 'error', error }));
});

app.post('/enroll-course', async (req, res) => {
    const { courseId, studentAddress } = req.body;

    const enrollInCourse = learnToEarn.methods.enrollInCourse(courseId);
    const gas = await enrollInCourse.estimateGas({ from: studentAddress });

    enrollInCourse.send({ from: studentAddress, gas })
        .then(receipt => res.json({ status: 'success', receipt }))
        .catch(error => res.status(500).json({ status: 'error', error }));
});

app.post('/complete-task', async (req, res) => {
    const { courseId, taskId, studentAddress } = req.body;

    const completeTask = learnToEarn.methods.completeTask(courseId, taskId);
    const gas = await completeTask.estimateGas({ from: studentAddress });

    completeTask.send({ from: studentAddress, gas })
        .then(receipt => res.json({ status: 'success', receipt }))
        .catch(error => res.status(500).json({ status: 'error', error }));
});

app.listen(port, () => {
    console.log(`Learn-to-Earn backend listening at http://localhost:${port}`);
});
// Install required packages:
// npx create-react-app learn-to-earn-frontend
// cd learn-to-earn-frontend
// npm install axios web3

import React, { useState } from 'react';
import axios from 'axios';
import Web3 from 'web3';

const App = () => {
    const [courseId, setCourseId] = useState('');
    const [taskId, setTaskId] = useState('');
    const [studentAddress, setStudentAddress] = useState('');

    const enrollInCourse = async () => {
        try {
            const response = await axios.post('http://localhost:3000/enroll-course', {
                courseId,
                studentAddress
            });
            console.log(response.data);
        } catch (error) {
            console.error('Error enrolling in course:', error);
        }
    };

    const completeTask = async () => {
        try {
            const response = await axios.post('http://localhost:3000/complete-task', {
                courseId,
                taskId,
                studentAddress
            });
            console.log(response.data);
        } catch (error) {
            console.error('Error completing task:', error);
        }
    };

    return (
        <div>
            <h1>Learn-to-Earn Platform</h1>
            <input type="text" placeholder="Course ID" value={courseId} onChange={(e) => setCourseId(e.target.value)} />
            <input type="text" placeholder="Task ID" value={taskId} onChange={(e) => setTaskId(e.target.value)} />
            <input type="text" placeholder="Student Address" value={studentAddress} onChange={(e) => setStudentAddress(e.target.value)} />
            <button onClick={enrollInCourse}>Enroll in Course</button>
            <button onClick={completeTask}>Complete Task</button>
        </div>
    );
};

export default App;
