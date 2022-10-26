// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract Collab {
    // keep track of groups index
    uint256 internal index;

    struct Talk {
        address from;
        string message;
        uint256 timestamp;
    }

    struct Group {
        uint256 identifier;
        address author;
        string name;
        string thumbnail;
        address[] participants;
    }

    mapping(uint256 => Group) internal groups;
    mapping(uint256 => Talk[]) internal talks;

    //events
    event GroupCreated(uint256 indexed groupId);
    event TalkCreated(address indexed sender, string message, uint256 time);
    event TalkDeleted(uint256 indexed groupId, uint256 talkId);
    event JoinedGroup(uint256 indexed groupId, address indexed participant);
    event LeaveGroup(uint256 indexed groupId, address indexed participant);

    modifier validIdentifier(uint256 _identifier) {
        require(_identifier < index, "Invalid identifier entered");
        _;
    }

    /*
     *   Create a new group and save on blockchain
     */
    function createGroup(string memory _name, string memory _thumbnail) public {
        address[] memory participants;
        groups[index] = Group(
            index,
            msg.sender,
            _name,
            _thumbnail,
            participants
        );
        uint256 id = index;
        index++;
        joinGroup(id);
        emit GroupCreated(id);
    }

    /*
     *  Send and add talk to a group
     */
    function sendTalk(string memory _message, uint256 _identifier)
        public
        validIdentifier(_identifier)
    {
        Talk memory talk = Talk(msg.sender, _message, block.timestamp);
        talks[_identifier].push(talk);
        emit TalkCreated(talk.from, talk.message, talk.timestamp);
    }

    /*
     * Delete talk from a group conversation
     */
    function deleteTalk(uint256 _identifier, uint256 _talkIndex)
        public
        validIdentifier(_identifier)
    {
        Talk[] storage talk = talks[_identifier];
        if (talk[_talkIndex].from == msg.sender) {
            talk[_talkIndex] = talk[talk.length - 1];
            talk.pop();
            emit TalkDeleted(_identifier, _talkIndex);
        }
    }

    /*
     *   Show details of all groups available
     */
    function allGroups() public view returns (Group[] memory) {
        Group[] memory all = new Group[](index);
        for (uint256 i = 0; i < index; i++) {
            all[i] = groups[i];
        }
        return all;
    }

    /*
     *   Join a group using the group identifier
     */
    function joinGroup(uint256 _identifier)
        public
        validIdentifier(_identifier)
    {
        // check if user is already in group
        Group storage grp = groups[_identifier];
        bool alreadyIn = false;
        for (uint256 i = 0; i < grp.participants.length; i++) {
            if (grp.participants[i] == msg.sender) {
                alreadyIn = true;
            }
        }

        // add msg.sender if not already joined
        if (alreadyIn == false) {
            grp.participants.push(msg.sender);
            emit JoinedGroup(_identifier, msg.sender);
        }
    }

    /*
     *   Exit a group conversation
     */
    function leaveGroup(uint256 _identifier)
        public
        validIdentifier(_identifier)
    {
        Group storage grp = groups[_identifier];
        for (uint256 i = 0; i < grp.participants.length; i++) {
            if (grp.participants[i] == msg.sender) {
                grp.participants[i] = grp.participants[
                    grp.participants.length - 1
                ];
                grp.participants.pop();
                emit LeaveGroup(_identifier, msg.sender);
                break;
            }
        }
    }

    /*
     *   Check detailed info about a group
     */
    function groupInfo(uint256 _identifier)
        public
        view
        validIdentifier(_identifier)
        returns (
            uint256,
            address,
            string memory,
            string memory,
            address[] memory
        )
    {
        Group memory grp = groups[_identifier];
        uint256 identifier = grp.identifier;
        address author = grp.author;
        string memory name = grp.name;
        string memory thumbnail = grp.thumbnail;
        address[] memory participants = grp.participants;

        return (identifier, author, name, thumbnail, participants);
    }

    /*
     *   Read group conversations
     */
    function groupConvo(uint256 _identifier)
        public
        view
        validIdentifier(_identifier)
        returns (Talk[] memory)
    {
        return talks[_identifier];
    }
}
