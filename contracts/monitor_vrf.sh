#!/bin/bash

# Script para monitorear el VRF
LOTTERY_ADDRESS="0x5cbB3E747aE5769A5397d0653AC14866b5A6305b"
RPC_URL="https://eth-sepolia.g.alchemy.com/v2/JFD5LtlpNb9DcEhBq_YUD"

echo "=== MONITOREANDO VRF ==="
echo "Lotería: $LOTTERY_ADDRESS"
echo ""

for i in {1..10}; do
    echo "--- Verificación $i ---"
    
    # Verificar estado
    STATE=$(cast call $LOTTERY_ADDRESS "lotteryState()" --rpc-url $RPC_URL)
    STATE_NUM=$(cast to-dec $STATE)
    echo "Estado: $STATE_NUM"
    
    case $STATE_NUM in
        1) echo "  -> Open (esperando participantes)" ;;
        3) echo "  -> Drawing (esperando VRF)" ;;
        4) echo "  -> Completed (VRF completado!)" ;;
        *) echo "  -> Estado desconocido" ;;
    esac
    
    # Si está completado, mostrar ganadores
    if [ $STATE_NUM -eq 4 ]; then
        echo ""
        echo "🎉 ¡VRF COMPLETADO!"
        WINNERS=$(cast call $LOTTERY_ADDRESS "getWinners()" --rpc-url $RPC_URL)
        echo "Ganadores: $WINNERS"
        break
    fi
    
    echo "Esperando 30 segundos..."
    echo ""
    sleep 30
done

echo "Monitoreo finalizado."