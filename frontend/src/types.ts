export type Player = {
    id: string;
    name: string;
    card: string | null;
}

export type Game = {
    id: string | null;
    deck: string[];
    areCardsRevealed: boolean;
    isConnected: boolean;
}
