export const gameRulesSections = [
  {
    title: "Overview",
    content: "In this pharmaceutical market simulation, you'll compete as either Company A or Company D to gain market share through strategic decisions and resource management."
  },
  {
    title: "Game Structure",
    content: [
      "12 rounds of play",
      "Each round represents one month",
      "Players make simultaneous decisions",
      "Starting budget: $100,000",
    ]
  },
  {
    title: "Weekly Restrictions",
    content: [
      "Company A can interact with up to 4 doctors per week",
      "Company D can interact with up to 3 doctors per week",
      "Market research counts as one interaction",
      "Only one marketing action per doctor per week per company",
      "Each doctor can only be a speaker once per week (city conference or third-party meeting)",
    ]
  },
  {
    title: "Speaker Selection Rules",
    content: "When both Company A and Company D invite the same doctor as a speaker in the same week, selection will be based on learning needs match. If both match equally, the company with higher market share in that hospital will be chosen."
  },
  {
    title: "Marketing Activities",
    content: "Professional academic visits, city conferences, and third-party meeting sponsorships will increase doctors' understanding of products at different levels. Activities matching doctors' learning needs will be more effective. Activities based on deep insights will significantly increase product understanding."
  }
] as const;