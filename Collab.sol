// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract Collab {
    // keep track of groups index
    uint256 internal index;

    struct Message {
        address from;
        string message;
        uint256 timestamp;
    }

    struct Group {
        address admin;
        uint256 identifier;
        address creator;
        string name;
        string thumbnail;
        address[] participants;
    }

    mapping(uint256 => Group) internal groups;
    mapping(uint256 => Message[]) internal messages;

    modifier validIdentifier(uint256 _identifier) {
        require(_identifier < index, "Invalid identifier entered");
        _;
    }

    modifier isValidInput(bytes memory input){
        require(input.length > 0, "invalid input");
        _;
    }

    modifier onlyAdmin(uint _identifier){
        require(msg.sender == groups[_identifier].admin, "only admin can access this function");
        _;
    }

    /*
     *   Create a new group and save on blockchain
     */
    function createGroup(string memory _name, string memory _thumbnail) public 
        isValidInput(bytes(_name)){
        address[] memory participants;
        groups[index] = Group(
            msg.sender,
            index,
            msg.sender,
            _name,
            _thumbnail,
            participants
        );
        uint256 id = index;
        index++;
        joinGroup(id);
    }

    /*
     *  Send and add talk to a group
     */
    function sendMessage(string memory _message, uint256 _identifier)
        public
        validIdentifier(_identifier)
        isValidInput(bytes(_message))
    {
        Message memory talk = Message(msg.sender, _message, block.timestamp);
        messages[_identifier].push(talk);
    }

    /*
     * Delete talk from a group conversation
     */
    function deleteMessage(uint256 _identifier, uint256 _messageIndex)
        public
        validIdentifier(_identifier)
    {
        Message[] storage talk = messages[_identifier];
        if (talk[_messageIndex].from == msg.sender || msg.sender == groups[_identifier].admin) {
            talk[_messageIndex] = talk[talk.length - 1];
            talk.pop();
        }
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
                break;
            }
        }
    }

    //Admin functions

    function removeParticipant(uint256 _identifier, address participant)
        public
        validIdentifier(_identifier)
        onlyAdmin(_identifier)
    {
        Group storage grp = groups[_identifier];
        for (uint256 i = 0; i < grp.participants.length; i++) {
            if (grp.participants[i] == participant) {
                grp.participants[i] = grp.participants[
                    grp.participants.length - 1
                ];
                grp.participants.pop();
                break;
            }
        }
    }

    function editGroupDetails(uint256 _identifier,string memory _name, string memory _thumbnail )
        external onlyAdmin(_identifier)
    {
        Group storage grp = groups[_identifier];
        grp.name = _name;
        grp.thumbnail = _thumbnail;
    }

    function changeAdmin(uint _identifier, address _admin ) external onlyAdmin(_identifier){
        groups[_identifier].admin = _admin;
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
        address creator = grp.creator;
        string memory name = grp.name;
        string memory thumbnail = grp.thumbnail;
        address[] memory participants = grp.participants;

        return (identifier, creator, name, thumbnail, participants);
    }

    /*
     *   Read group conversations
     */
    function groupConvo(uint256 _identifier)
        public
        view
        validIdentifier(_identifier)
        returns (Message[] memory)
    {
        return messages[_identifier];
    }
}
