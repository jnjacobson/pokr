export type Player = {
  id: string;
  name: string;
  card: string | null;
};

export type Game = {
  id: string;
};

export type JoinPayload = {
  player_id: string;
  token: string;
  deck: string[];
  are_cards_revealed: boolean;
};

export type SessionReplacedPayload = {
  player_id: string;
  new_join_at: number;
};

export enum ChannelEvent {
  Join = 'join',
  PlayerUpdated = 'player_updated',
  CardsRevealed = 'cards_revealed',
  CardsReset = 'cards_reset',
  SessionReplaced = 'session_replaced',
}
