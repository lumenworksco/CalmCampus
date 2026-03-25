import React, { createContext, useContext, useState } from 'react';

interface AppState {
  hasOnboarded: boolean;
  setHasOnboarded: (v: boolean) => void;
  notificationsEnabled: boolean;
  setNotificationsEnabled: (v: boolean) => void;
}

const AppContext = createContext<AppState>({
  hasOnboarded: false,
  setHasOnboarded: () => {},
  notificationsEnabled: true,
  setNotificationsEnabled: () => {},
});

export function AppProvider({ children }: { children: React.ReactNode }) {
  const [hasOnboarded, setHasOnboarded] = useState(false);
  const [notificationsEnabled, setNotificationsEnabled] = useState(true);

  return (
    <AppContext.Provider value={{ hasOnboarded, setHasOnboarded, notificationsEnabled, setNotificationsEnabled }}>
      {children}
    </AppContext.Provider>
  );
}

export const useAppContext = () => useContext(AppContext);
