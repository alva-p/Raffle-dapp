import { useState, useCallback, useMemo } from 'react';
import { type Address } from 'viem';
import type { FilterState } from '../components/LotterySidebar';

export interface LotteryStateInfo {
  address: Address;
  state: number; // 0=Open, 1=Drawing, 2=Completed, 3=Cancelled
}

const LOTTERIES_PER_PAGE = 10;

export function useFilteredLotteries(lotteries: Address[], activeFilter: FilterState) {
  const [lotteryStates, setLotteryStates] = useState<Record<string, number>>({});
  const [currentPages, setCurrentPages] = useState<Record<FilterState, number>>({
    all: 1,
    open: 1,
    drawing: 1,
    completed: 1,
    cancelled: 1
  });

  // Callback para que las LotteryCard reporten su estado
  const updateLotteryState = useCallback((address: Address, state: number) => {
    setLotteryStates(prev => ({
      ...prev,
      [address.toLowerCase()]: state
    }));
  }, []);

  // Funciones para manejar paginación
  const goToPage = useCallback((page: number) => {
    setCurrentPages(prev => ({
      ...prev,
      [activeFilter]: page
    }));
  }, [activeFilter]);

  const nextPage = useCallback(() => {
    setCurrentPages(prev => ({
      ...prev,
      [activeFilter]: prev[activeFilter] + 1
    }));
  }, [activeFilter]);

  const prevPage = useCallback(() => {
    setCurrentPages(prev => ({
      ...prev,
      [activeFilter]: Math.max(1, prev[activeFilter] - 1)
    }));
  }, [activeFilter]);

  const paginationData = useMemo(() => {
    // Contar estados
    const counts: Record<FilterState, number> = {
      all: lotteries.length,
      open: 0,
      drawing: 0,
      completed: 0,
      cancelled: 0
    };

    // Contar por estados conocidos
    Object.values(lotteryStates).forEach(state => {
      switch (state) {
        case 0: counts.open++; break;
        case 1: counts.drawing++; break;
        case 2: counts.completed++; break;
        case 3: counts.cancelled++; break;
      }
    });

    // Filtrar loterías
    let filtered = lotteries;
    
    if (activeFilter !== 'all') {
      const targetState = activeFilter === 'open' ? 0 :
                         activeFilter === 'drawing' ? 1 :
                         activeFilter === 'completed' ? 2 :
                         activeFilter === 'cancelled' ? 3 : -1;
      
      filtered = lotteries.filter(address => 
        lotteryStates[address.toLowerCase()] === targetState
      );
    }

    // Ordenar por más reciente primero (asumiendo que las direcciones más recientes están al final del array)
    const sortedFiltered = [...filtered].reverse();

    // Calcular paginación
    const currentPage = currentPages[activeFilter];
    const totalItems = sortedFiltered.length;
    const totalPages = Math.ceil(totalItems / LOTTERIES_PER_PAGE);
    const startIndex = (currentPage - 1) * LOTTERIES_PER_PAGE;
    const endIndex = startIndex + LOTTERIES_PER_PAGE;
    const paginatedLotteries = sortedFiltered.slice(startIndex, endIndex);

    return {
      filteredLotteries: paginatedLotteries,
      lotteryCounts: counts,
      pagination: {
        currentPage,
        totalPages,
        totalItems,
        hasNextPage: currentPage < totalPages,
        hasPrevPage: currentPage > 1,
        startItem: startIndex + 1,
        endItem: Math.min(endIndex, totalItems)
      }
    };
  }, [lotteries, activeFilter, lotteryStates, currentPages]);

  return {
    filteredLotteries: paginationData.filteredLotteries,
    lotteryCounts: paginationData.lotteryCounts,
    pagination: paginationData.pagination,
    updateLotteryState,
    // Funciones de paginación
    goToPage,
    nextPage,
    prevPage
  };
}