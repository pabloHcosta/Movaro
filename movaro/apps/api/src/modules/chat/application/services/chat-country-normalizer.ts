const COUNTRY_ALIASES: Record<string, string> = {
  argentina: 'argentina',
  ar: 'argentina',
  brasil: 'brasil',
  brazil: 'brasil',
  br: 'brasil',
  chile: 'chile',
  cl: 'chile',
  uruguay: 'uruguai',
  uruguai: 'uruguai',
  uy: 'uruguai',
  paraguay: 'paraguai',
  paraguai: 'paraguai',
  py: 'paraguai',
};

function normalizeToken(value: string): string {
  return value
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
    .toLowerCase()
    .trim();
}

export function normalizeChatCountry(value: string): string {
  const normalized = normalizeToken(value);
  return COUNTRY_ALIASES[normalized] ?? normalized;
}

export function normalizeChatCorridor(
  originCountry: string,
  destinationCountry: string,
): string {
  return `${normalizeChatCountry(originCountry)}->${normalizeChatCountry(destinationCountry)}`;
}
