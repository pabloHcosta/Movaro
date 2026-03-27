export enum CityInsightType {
  Lifestyle = 'lifestyle',
  CostOfLiving = 'cost_of_living',
  Housing = 'housing',
  Work = 'work',
  PracticalTip = 'practical_tip',
  Motivation = 'motivation',
}

export enum CityInsightTheme {
  Neighborhoods = 'neighborhoods',
  Beaches = 'beaches',
  Parks = 'parks',
  Nightlife = 'nightlife',
  FoodAndCafes = 'food_and_cafes',
  CultureAndEvents = 'culture_and_events',
  Viewpoints = 'viewpoints',
  LocalRoutine = 'local_routine',
}

export type CityInsightSource = 'curated' | 'generated' | 'template';

export interface CityInsightEntity {
  id: string;
  cityId: string;
  cityName: string;
  type: CityInsightType;
  theme?: CityInsightTheme;
  title: string;
  shortText: string;
  content: string;
  placeHighlights?: string[];
  imageUrl?: string;
  ctaLabel?: string;
  source: CityInsightSource;
  generatedAt: string;
  expiresAt?: string;
}
