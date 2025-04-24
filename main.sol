// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract FormulaOne {
    uint256 public raceDistance = 1000;
    uint8 public maxPlayers = 6;
    address public owner;
    bool public raceStarted;
    bool public raceFinished;

    struct Car {
        address driver;
        uint256 distance;
    }

    Car[] public cars;
    mapping(address => bool) public isRegistered;
    address public winner;

    event Registered(address driver);
    event RaceStarted();
    event RaceProgress(address driver, uint256 distance);
    event RaceFinished(address winner);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    modifier onlyBeforeRace() {
        require(!raceStarted, "Race already started");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function register() external onlyBeforeRace {
        require(!isRegistered[msg.sender], "Already registered");
        require(cars.length < maxPlayers, "Max players reached");

        cars.push(Car(msg.sender, 0));
        isRegistered[msg.sender] = true;

        emit Registered(msg.sender);
    }

    function startRace() external onlyOwner onlyBeforeRace {
        require(cars.length > 1, "Not enough players");

        raceStarted = true;
        emit RaceStarted();
    }

    function progressRace() external {
        require(raceStarted, "Race not started");
        require(!raceFinished, "Race already finished");

        for (uint8 i = 0; i < cars.length; i++) {
            if (cars[i].distance < raceDistance) {
                uint256 randomBoost = uint256(
                    keccak256(abi.encodePacked(block.timestamp, block.difficulty, i))
                ) % 100;
                cars[i].distance += randomBoost;

                emit RaceProgress(cars[i].driver, cars[i].distance);

                if (cars[i].distance >= raceDistance && winner == address(0)) {
                    winner = cars[i].driver;
                    raceFinished = true;
                    emit RaceFinished(winner);
                    break;
                }
            }
        }
    }

    function getCars() external view returns (Car[] memory) {
        return cars;
    }
}
