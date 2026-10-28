import { beforeEach, describe, expect, it } from 'vitest';

import { DECK_PRESETS, useLastDeck } from '@/decks';

const [FIBONACCI] = DECK_PRESETS;

beforeEach(() => {
  localStorage.clear();
});

describe('useLastDeck', () => {
  it('starts with the Fibonacci deck', () => {
    expect(useLastDeck().value).toEqual(FIBONACCI.cards);
  });

  it('returns the deck of the last game', () => {
    localStorage.setItem('lastDeck', '["XS","S","M"]');

    expect(useLastDeck().value).toEqual(['XS', 'S', 'M']);
  });

  it.each([
    ['broken JSON', '{nope'],
    ['no list', '"XS"'],
    ['an empty list', '[]'],
    ['cards that are no strings', '[1,2,3]'],
  ])('falls back to the Fibonacci deck for %s', (_, stored) => {
    localStorage.setItem('lastDeck', stored);

    expect(useLastDeck().value).toEqual(FIBONACCI.cards);
  });
});
