// Función para añadir a LotteryBase.sol

function closeLottery() external onlyCreator {
    require(lotteryState == State.Open, "Lottery not open");
    require(participants.length > 0, "No participants");
    lotteryState = State.Drawing;
    emit LotteryStateChanged(State.Drawing);
}

// También añade este evento al inicio del contrato
event LotteryStateChanged(State newState);