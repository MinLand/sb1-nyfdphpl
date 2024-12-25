import { Briefcase, Users, Presentation, LineChart } from 'lucide-react';

export const operations = [
  {
    id: 'academic-visits',
    name: 'Professional Academic Visits',
    icon: Briefcase,
    cost: 300,
    maxPerWeek: {
      A: 4,
      D: 3
    }
  },
  {
    id: 'city-conference',
    name: 'City Conference',
    icon: Users,
    cost: 5000,
    maxPerWeek: {
      A: 1,
      D: 1
    }
  },
  {
    id: 'external-events',
    name: 'External Events Sponsorship',
    icon: Presentation,
    cost: 10000,
    maxPerWeek: {
      A: 1,
      D: 1
    }
  },
  {
    id: 'market-research',
    name: 'Market Research',
    icon: LineChart,
    cost: 1000,
    maxPerWeek: {
      A: 1,
      D: 1
    }
  },
] as const;