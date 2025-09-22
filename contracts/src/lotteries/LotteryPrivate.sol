// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./LotteryBase.sol";

/**
 * @title LotteryPrivate
 * @notice Lotería donde el creador puede importar participantes y elegir ganador
 * @dev Extiende LotteryBase pero no permite entries públicas
 */
contract LotteryPrivate is LotteryBase {
    
    enum Currency { NATIVE, ERC20 }
    
    // Mapping para rastrear participantes importados
    mapping(address => bool) public isParticipant;
    address[] public participantsList;
    
    // Events
    event ParticipantsImported(address[] participants, uint256 count);
    event ManualWinnerSelected(address winner, uint256 prize);
    
    // Storage variables
    Currency public currency;
    address public token;
    uint256 public ticketPrice;
    
    /**
     * @notice Constructor
     * @param _currency Tipo de moneda (NATIVE=0, ERC20=1)  
     * @param _token Dirección del token (si currency=ERC20)
     * @param _ticketPrice Precio por ticket (0 para loterías gratuitas)
     * @param _creator Dirección del creador
     * @param _factory Dirección del factory
     * @param _vrfCoordinator Coordinador VRF de Chainlink
     * @param _subscriptionId ID de suscripción VRF
     */
    constructor(
        Currency _currency,
        address _token,
        uint256 _ticketPrice,
        address _creator,
        address _factory,
        address _vrfCoordinator,
        uint256 _subscriptionId
    ) LotteryBase(_creator, _factory, _vrfCoordinator, uint64(_subscriptionId), 0x787d74caea10b2b357790d5b5247c2f63d1d91572a9846f780606e4d953677ae, 100000, 3) {
        currency = _currency;
        token = _token;
        ticketPrice = _ticketPrice;
    }

    /**
     * @notice Importar lista de participantes (solo creador)
     * @param _participants Array de direcciones de participantes
     */
    function importParticipants(address[] calldata _participants) external onlyCreator {
        require(lotteryState == State.Open, "Lottery not open");
        require(_participants.length > 0, "No participants provided");
        require(_participants.length <= 1000, "Too many participants (max 1000)");
        
        // Limpiar participantes anteriores si los hay
        if (participantsList.length > 0) {
            for (uint256 i = 0; i < participantsList.length; i++) {
                isParticipant[participantsList[i]] = false;
            }
            delete participantsList;
        }
        
        // Agregar nuevos participantes
        for (uint256 i = 0; i < _participants.length; i++) {
            address participant = _participants[i];
            require(participant != address(0), "Invalid participant address");
            require(!isParticipant[participant], "Duplicate participant");
            
            isParticipant[participant] = true;
            participantsList.push(participant);
            participants.push(participant);
        }
        
        emit ParticipantsImported(_participants, _participants.length);
    }
    
    /**
     * @notice Elegir ganador manualmente (solo creador)
     * @param winnerIndex Índice del ganador en la lista de participantes
     */
    function selectManualWinner(uint256 winnerIndex) external onlyCreator {
        require(lotteryState == State.Locked, "Lottery must be closed first");
        require(participants.length > 0, "No participants");
        require(winnerIndex < participants.length, "Invalid winner index");
        
        address winner = participants[winnerIndex];
        uint256 prize = address(this).balance; // Prize is contract balance
        
        // Cambiar estado y transferir premio
        lotteryState = State.Completed;
        winners.push(winner);
        
        if (prize > 0) {
            if (currency == Currency.NATIVE) {
                payable(winner).transfer(prize);
            } else {
                // TODO: Implement ERC20 transfer
            }
        }
        
        emit ManualWinnerSelected(winner, prize);
    }
    
    /**
     * @notice Obtener lista completa de participantes importados
     * @return Array de direcciones de participantes importados
     */
    function getImportedParticipants() external view returns (address[] memory) {
        return participantsList;
    }
    
    /**
     * @notice Verificar si una dirección es participante
     * @param _address Dirección a verificar
     * @return true si es participante
     */
    function checkParticipant(address _address) external view returns (bool) {
        return isParticipant[_address];
    }
    
    // Override: No permitir entries públicas en loterías privadas
    function enter() external payable {
        revert("Public entries not allowed in private lottery");
    }
    
    /**
     * @notice Agregar participante individual (solo creador)
     * @param participant Dirección del participante a agregar
     */
    function addParticipant(address participant) external onlyCreator {
        require(lotteryState == State.Open, "Lottery not open");
        require(participant != address(0), "Invalid participant address");
        require(!isParticipant[participant], "Already a participant");
        require(participants.length < 1000, "Max participants reached");
        
        isParticipant[participant] = true;
        participantsList.push(participant);
        participants.push(participant);
        
        address[] memory singleParticipant = new address[](1);
        singleParticipant[0] = participant;
        emit ParticipantsImported(singleParticipant, 1);
    }
    
    /**
     * @notice Remover participante (solo creador, antes de cerrar)
     * @param participant Dirección del participante a remover
     */
    function removeParticipant(address participant) external onlyCreator {
        require(lotteryState == State.Open, "Lottery not open");
        require(isParticipant[participant], "Not a participant");
        
        isParticipant[participant] = false;
        
        // Remover de participantsList
        for (uint256 i = 0; i < participantsList.length; i++) {
            if (participantsList[i] == participant) {
                participantsList[i] = participantsList[participantsList.length - 1];
                participantsList.pop();
                break;
            }
        }
        
        // Remover de participants (heredado)
        for (uint256 i = 0; i < participants.length; i++) {
            if (participants[i] == participant) {
                participants[i] = participants[participants.length - 1];
                participants.pop();
                break;
            }
        }
    }

    // Implementar funciones virtuales requeridas por LotteryBase
    function _addParticipant(address user) internal override {
        // En loterías privadas, no se usan entries públicas
        revert("Use importParticipants or addParticipant instead");
    }

    function _drawWinners(uint256 numWinners, uint256 randomWord) internal override {
        // Para loterías privadas, usar selectManualWinner o VRF
        if (participants.length == 0) revert("No participants");
        
        uint256 winnerIndex = randomWord % participants.length;
        address winner = participants[winnerIndex];
        uint256 prize = address(this).balance;
        
        lotteryState = State.Completed;
        winners.push(winner);
        
        if (prize > 0 && currency == Currency.NATIVE) {
            payable(winner).transfer(prize);
        }
        
        emit ManualWinnerSelected(winner, prize);
    }

    function _refundParticipants() internal override {
        // Refund logic for private lotteries
        uint256 refundAmount = address(this).balance / participants.length;
        if (refundAmount > 0 && currency == Currency.NATIVE) {
            for (uint256 i = 0; i < participants.length; i++) {
                payable(participants[i]).transfer(refundAmount);
            }
        }
        lotteryState = State.Cancelled;
    }
}