import { CityInsightTheme } from './city-insight.entity';

export interface CityInsightExplorePlaceEntity {
  id: string;
  cityId: string;
  cityName: string;
  theme: CityInsightTheme;
  name: string;
  category: string;
  neighborhood?: string;
  region?: string;
  shortText: string;
  imageUrl?: string;
  mapUrl: string;
  latitude?: number;
  longitude?: number;
  source: 'openstreetmap' | 'template' | 'curated';
}
