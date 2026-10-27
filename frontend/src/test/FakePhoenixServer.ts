import { vi } from 'vitest';

/** Phoenix serializer v2 frame: [join_ref, ref, topic, event, payload] */
type Frame = [string | null, string | null, string, string, unknown];

export type ReceivedMessage = {
  topic: string,
  event: string,
  payload: unknown,
};

export type GameSetup = {
  playerId: string,
  token: string,
  joinedAt: number,
  deck: string[],
  areCardsRevealed: boolean,
  /** Other players already present when we join. */
  otherPlayerIds: string[],
};

const CONNECTING = 0;
const OPEN = 1;
const CLOSED = 3;

// GameChannel broadcasts these to everyone on the topic, the sender included.
const ECHOED_EVENTS = ['player_updated', 'cards_revealed', 'cards_reset'];

const OK_REPLY = { status: 'ok', response: {} };

class FakeConnection {
  readyState = CONNECTING;

  binaryType = 'blob';

  onopen: ((event: unknown) => void) | null = null;

  onmessage: ((event: { data: string }) => void) | null = null;

  onclose: ((event: { code: number, reason: string, wasClean: boolean }) => void) | null = null;

  onerror: ((event: unknown) => void) | null = null;

  private readonly server: FakePhoenixServer;

  constructor(server: FakePhoenixServer) {
    this.server = server;

    queueMicrotask(() => {
      if (this.readyState !== CONNECTING) {
        return;
      }

      this.readyState = OPEN;
      this.onopen?.({});
    });
  }

  send(data: string) {
    this.server.handle(this, JSON.parse(data) as Frame);
  }

  close(code = 1000, reason = '') {
    if (this.readyState === CLOSED) {
      return;
    }

    this.readyState = CLOSED;
    queueMicrotask(() => this.onclose?.({ code, reason, wasClean: true }));
  }

  deliver(frame: Frame) {
    queueMicrotask(() => {
      if (this.readyState === OPEN) {
        this.onmessage?.({ data: JSON.stringify(frame) });
      }
    });
  }

  /** Closes silently, so the client doesn't try to reconnect after the test is over. */
  detach() {
    this.readyState = CLOSED;
    this.onopen = null;
    this.onmessage = null;
    this.onclose = null;
    this.onerror = null;
  }
}

/**
 * Stands in for the Phoenix backend at the WebSocket level, so the real `phoenix` client
 * (Socket, Channel, Presence) runs unmodified in tests. Speaks the v2 wire protocol and
 * follows what `PokrWeb.GameChannel` does on join and when events come in.
 */
export class FakePhoenixServer {
  readonly received: ReceivedMessage[] = [];

  readonly game: GameSetup;

  private connection: FakeConnection | undefined;

  private topic = '';

  constructor(game: Partial<GameSetup> = {}) {
    this.game = {
      playerId: 'player-me',
      token: 'token-me',
      joinedAt: 1_000,
      deck: ['1', '2', '3'],
      areCardsRevealed: false,
      otherPlayerIds: [],
      ...game,
    };
  }

  /** Replaces the global WebSocket, so call this before the code under test creates its Socket. */
  install() {
    const connect = () => {
      this.connection = new FakeConnection(this);

      return this.connection;
    };

    // phoenix calls `new WebSocket(url)`; returning an object from a constructor makes `new` yield it.
    vi.stubGlobal('WebSocket', function FakeWebSocket() {
      return connect();
    });
  }

  dispose() {
    this.connection?.detach();
    vi.unstubAllGlobals();
  }

  /** Pushes an event to the client, as if broadcast to the topic it joined. */
  push(event: string, payload: unknown) {
    this.connection?.deliver([null, null, this.topic, event, payload]);
  }

  playerLeaves(playerId: string) {
    this.presenceDiff({}, { [playerId]: this.presenceEntry(playerId) });
  }

  playerJoins(playerId: string) {
    this.presenceDiff({ [playerId]: this.presenceEntry(playerId) }, {});
  }

  /** @internal Called by the fake connection for every frame the client sends. */
  handle(connection: FakeConnection, [joinRef, ref, topic, event, payload]: Frame) {
    switch (event) {
      case 'phx_join':
        this.topic = topic;
        connection.deliver([joinRef, ref, topic, 'phx_reply', OK_REPLY]);
        this.pushGameState(connection, topic);
        break;
      case 'phx_leave':
        connection.deliver([joinRef, ref, topic, 'phx_reply', OK_REPLY]);
        break;
      case 'heartbeat':
        connection.deliver([null, ref, 'phoenix', 'phx_reply', OK_REPLY]);
        break;
      default:
        this.received.push({ topic, event, payload });

        if (ECHOED_EVENTS.includes(event)) {
          connection.deliver([null, null, topic, event, payload]);
        }
    }
  }

  private pushGameState(connection: FakeConnection, topic: string) {
    const playerIds = [...this.game.otherPlayerIds, this.game.playerId];

    connection.deliver([null, null, topic, 'presence_state', Object.fromEntries(
      playerIds.map((id) => [id, this.presenceEntry(id)]),
    )]);

    connection.deliver([null, null, topic, 'join', {
      player_id: this.game.playerId,
      token: this.game.token,
      joined_at: this.game.joinedAt,
      are_cards_revealed: this.game.areCardsRevealed,
      deck: this.game.deck,
    }]);
  }

  private presenceDiff(joins: object, leaves: object) {
    this.push('presence_diff', { joins, leaves });
  }

  private presenceEntry(playerId: string) {
    return { metas: [{ phx_ref: `ref-${playerId}`, online_at: this.game.joinedAt }] };
  }
}
