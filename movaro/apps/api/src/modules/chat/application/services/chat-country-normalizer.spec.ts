import {
  normalizeChatCorridor,
  normalizeChatCountry,
} from './chat-country-normalizer';

describe('chat-country-normalizer', () => {
  it('normalizes common aliases to canonical country ids', () => {
    expect(normalizeChatCountry('Brazil')).toBe('brasil');
    expect(normalizeChatCountry('BR')).toBe('brasil');
    expect(normalizeChatCountry('Uruguay')).toBe('uruguai');
    expect(normalizeChatCountry('UY')).toBe('uruguai');
    expect(normalizeChatCountry('Paraguay')).toBe('paraguai');
    expect(normalizeChatCountry('CL')).toBe('chile');
  });

  it('builds corridor keys from normalized country ids', () => {
    expect(normalizeChatCorridor('AR', 'Brazil')).toBe('argentina->brasil');
    expect(normalizeChatCorridor('uy', 'cl')).toBe('uruguai->chile');
  });
});
