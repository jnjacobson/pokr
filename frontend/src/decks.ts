import { useLocalStorage } from '@vueuse/core';

export type DeckPreset = {
  name: string,
  cards: string[],
};

export const DECK_PRESETS: DeckPreset[] = [
  { name: 'Fibonacci', cards: ['0', '½', '1', '2', '3', '5', '8', '13', '20', '40', '100', '?', '☕'] },
  { name: 'T-shirt sizes', cards: ['XS', 'S', 'M', 'L', 'XL', '?', '☕'] },
];

const [DEFAULT_PRESET] = DECK_PRESETS;

const isDeck = (value: unknown): value is string[] => (
  Array.isArray(value) && value.length > 0 && value.every((card) => typeof card === 'string')
);

/** The deck of the game I was in last, which the next game I create starts with. */
export function useLastDeck() {
  return useLocalStorage<string[]>('lastDeck', DEFAULT_PRESET.cards, {
    serializer: {
      read: (raw) => {
        try {
          const deck: unknown = JSON.parse(raw);

          return isDeck(deck) ? deck : DEFAULT_PRESET.cards;
        } catch {
          return DEFAULT_PRESET.cards;
        }
      },
      write: (deck) => JSON.stringify(deck),
    },
  });
}
