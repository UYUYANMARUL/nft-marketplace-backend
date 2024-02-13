contract Trade {
    enum OfferState {
        PENDING,
        ACCEPTED,
        CANCELLED
    }

    struct Offer {
        uint256[] tokenIDsCreator;
        uint256[] tokenIDsAcceptor;
        address creatorAdress;
        address acceptorAdress;
        uint256 amountCreator;
        uint256 amountAcceptor;
        OfferState state;
        uint256 deadline;
    }

    Offer[] public offers;

    // mapping(address => uint256) public balances;
    // balances SenderBalance;
    // balances BuyerBalance;

    event OfferCreated(uint256 offerIndex);

    event OfferAccepted(uint256 offerIndex);

    function createOffer(
        uint256[] memory _tokenIDsCreator,
        uint256[] memory _tokenIDsAcceptor,
        address _creatorId,
        address _acceptorId,
        uint256 _amountCreator,
        uint256 _amountAcceptor,
        OfferState _state,
        uint256 _closeTime
    )
        public
        payable
        CreatorTokenCheck(_tokenIDsCreator, _creatorId)
        AcceptorTokenCheck(_tokenIDsAcceptor, _acceptorId)
        returns (bool)
    {
        require(balance >= _amountSender, "not enough balance");
        require(_closeTime >= 60, ".....");
        uint256 deadline = block.timestamp + _closeTime;
        offers.push(
            Offer(
                _tokenIDsCreator,
                _tokenIDsAcceptor,
                _creatorId,
                _acceptorId,
                _amountCreator,
                _amountAcceptor,
                OfferState.PENDING,
                deadline
            )
        );

        emit OfferCreated(offers.length - 1);
        return true;
    }

    function acceptOffer(
        uint256 _offerIndex,
        address _creatorAddress,
        address _acceptorAddress,
        uint256[] _tokenIDsCreator,
        uint256[] _tokenIDsAcceptor
    ) public AcceptorTokenCheck(_tokenIDsAcceptor, _acceptorAddress) timeCheck returns (string) {
        offers[_offerIndex].state = OfferState.ACCEPTED;
        for (uint256 i; i < _tokenIDsCreator.length; i++) {
            NFT.transferFrom(_tokenIDsCreator, _acceptorAddress, _tokenIDsCreator[i]);
        }
        for (uint256 i; i < _tokenIDsAcceptor.length; i++) {
            NFT.transferFrom(_acceptorAddress, _tokenIDsCreator, _tokenIDsAcceptor[i]);
        }
        emit OfferAccepted(_offerIndex);
        return "Offer accepted";
    }

    function cancelOffer(uint256 _offerIndex) public returns (string) {
        offers[_offerIndex].state = OfferState.canceled;
        return "Offer canceled";
    }

    function isItOwnerTheTokens(uint256[] tokenIds, address addr) public returns (bool) {
        for (uint256 i = 0; i < arr.length; ++i) {
            if (ownerOf(tokenIds[i]) != addr) {
                return false;
            }
        }
        return true;
    }

    modifier AcceptorTokenCheck(uint256[] tokenIds, address addr) {
        require(isItOwnerTheTokens(), "Acceptor does not have these tokens");
        _;
    }

    modifier CreatorTokenCheck(uint256[] tokenIds, address addr) {
        require(isItOwnerTheTokens(), "Creator does not have these tokens");
        _;
    }

    modifier timeCheck() {
        require(block.timestamp < time + offers[_offeerIndex].deadline, "Too late");
        _;
    }
}
