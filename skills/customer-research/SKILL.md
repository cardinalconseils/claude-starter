---
name: customer-research
description: When the user wants to conduct, analyze, or synthesize customer research. Use when the user mentions 'customer research,' 'ICP research,' 'talk to customers,' 'analyze transcripts,' 'user interviews,' or 'win/loss analysis.'
allowed-tools: Read, Write, WebSearch, WebFetch, AskUserQuestion
model: sonnet
---

# Customer Research

Expert knowledge for planning, conducting, and synthesizing customer research that informs positioning, messaging, and product direction.

## Why Customer Research is Marketing's Most Underused Lever

The best marketing copy is written in the customer's own words. Customer research reveals:
- The exact language customers use to describe their problem (use it verbatim in headlines)
- The trigger event that made them look for a solution (use it in email subjects)
- The fears they had before buying (address them in the sales process)
- Why they chose you over alternatives (your real differentiator, not the one you invented)

## Research Methods by Goal

| Goal | Best Method |
|---|---|
| Understand why customers buy | Jobs-to-be-Done interviews |
| Improve onboarding and activation | User interviews + session recordings |
| Find product-market fit signals | Survey (NPS + open-ended) |
| Understand why deals are lost | Win/loss interviews |
| Define ICP characteristics | Customer data analysis + interviews |
| Validate messaging | 5-second test, preference tests |

## Jobs-to-be-Done (JTBD) Framework

JTBD is the most powerful framework for understanding what customers are actually buying.

**Core principle:** Customers don't buy products — they hire them to do a job. The job is the progress they're trying to make in their life or work.

**Three layers of the job:**
1. **Functional job:** The practical task ("I need to generate monthly reports faster")
2. **Social job:** How they want to be perceived ("I need to look organized to my manager")
3. **Emotional job:** How they want to feel ("I need to feel in control of our data")

Marketing that only addresses the functional job leaves 2/3 of the motivation untouched.

### JTBD Interview Script

**Session setup:** 45-60 minutes, recorded (with permission), one interviewer.

**Opening:**
"I want to understand the process you went through when you decided to look for a solution like [product]. I'm not going to pitch anything — I want to understand your experience."

**The timeline interview (work backwards from the purchase):**
1. "Take me back to when you first realized you needed something different. What was happening?"
2. "What triggered that realization? Was there a specific event?"
3. "What did you do first when you decided to look for solutions?"
4. "What other options did you consider? Why did you look at those?"
5. "What made you choose [product] over those alternatives?"
6. "What were you worried about before you bought?"
7. "What would have made you not buy?"
8. "How has your life/work changed since using [product]?"

**The magic question (ask this in every interview):**
"If [product] disappeared tomorrow and you couldn't use it, what would you do?"

The answer reveals your true competitive set and what the customer values most.

## User Interview Best Practices

**Recruiting:**
- Aim for 5-8 interviews per segment (more interviews don't add proportional value after 5)
- Interview recent buyers (within 90 days) — memory is fresh
- Interview churned customers separately — they reveal unmet expectations
- Screen for variety: different company sizes, use cases, industries

**Interview principles:**
- Ask about the past, not the future ("What did you do?" not "What would you do?")
- Follow curiosity, not the script — if something interesting surfaces, dig in
- Silence is a tool — pause after answers and let them fill it
- Never ask leading questions ("Don't you think X would help?")
- Never ask hypothetical questions ("If we built X, would you use it?")

**Forbidden interview mistakes:**
- Pitching your product during the interview
- Asking yes/no questions ("Do you like the dashboard?")
- Combining multiple questions into one
- Interpreting their answer before they finish

## Transcript Synthesis

Raw transcripts are not insights. Synthesis turns observations into patterns.

**Synthesis process:**

**Step 1: Highlight quotes**
Read each transcript and highlight every quote that:
- Describes a pain or frustration in the customer's own words
- Describes the trigger event that started their search
- Reveals a fear or objection
- Describes the benefit they wanted
- Describes how they measure success

**Step 2: Extract to sticky notes (one idea per note)**
Each highlighted quote becomes one observation card:
- Quote (verbatim)
- Customer name/type
- Category (pain / trigger / fear / benefit / success metric)

**Step 3: Group into themes**
Cluster cards with similar themes. Name each cluster.

**Step 4: Count frequency**
Which themes appear in 3+ of 5 interviews? Those are insights.
Which appear in only 1? Those are data points, not patterns.

**Step 5: Write insight statements**
"[N] of [total] customers said [theme] in their own words. Example quotes: [quote 1], [quote 2]."

## Research → Opportunity Handoff

After transcript synthesis, convert research findings into a prioritized opportunity space using the Opportunity Solution Tree (OST).

OST opportunity scoring: **Importance × (1 − Satisfaction)**. The data for both dimensions comes directly from this research:
- **Importance**: how frequently did the problem appear across interviews? (Frequency × emotional intensity)
- **Satisfaction**: are customers currently satisfied with existing solutions? (From magic question: "What would you do if [product] disappeared?")

Higher score = better opportunity to target. Read `skills/strategic-frameworks/workflows/opportunity-solution-tree.md` to run the full OST after synthesis completes.

This handoff is indeterministic — apply OST when 3+ interviews surfaced the same unmet need, or when the research goal was opportunity discovery rather than validation.

## Win/Loss Analysis

Win/loss analysis answers: "Why do we win deals? Why do we lose them?"

**Who to interview:**
- Recent wins (within 30 days): understand what closed them
- Recent losses (within 30 days, especially competitive losses): understand what you're missing
- No-decisions: understand why they didn't buy from anyone

**Win/loss interview questions:**
1. "Can you walk me through how you evaluated your options?"
2. "What were the top 3 things you considered?"
3. "What almost made you choose a different vendor?"
4. "What were you worried about with us?"
5. "What did [competitor] offer that you considered?"
6. [For losses] "What would have changed your decision?"

**Win/loss reporting:**
Track across 20+ interviews:
- Win rate by source (where do you win most often?)
- Win rate by competitor (who do you beat? who beats you?)
- Top win reasons (by frequency)
- Top loss reasons (by frequency)
- Feature gaps mentioned in losses

## ICP Definition from Research

Use customer research to ground ICP definition in evidence, not assumptions.

**ICP dimensions to capture:**
- **Firmographic:** Company size, industry, geography, funding stage
- **Technographic:** Tech stack, tools they currently use
- **Psychographic:** Attitudes, priorities, decision-making style
- **Behavioral:** How they evaluate software, buying process, team involved
- **Situational:** Trigger events that make them ready to buy right now

**ICP validation test:**
Plot your best customers (highest LTV, lowest churn, most referrals) on each firmographic dimension. Where do they cluster? That cluster is your confirmed ICP.

## Survey Design

Surveys scale research but sacrifice depth. Use surveys for:
- Quantifying patterns discovered in interviews
- Segmenting by NPS or CSAT
- Gathering feature prioritization data

**Survey design rules:**
- Maximum 7 questions for good completion rates
- One concept per question
- Avoid double-barreled questions ("Was the setup easy and the UI intuitive?")
- Always include open-text for "anything else?" at the end
- Test the survey on 3 people before sending

**The one question that predicts everything:**
"On a scale of 0-10, how disappointed would you be if you could no longer use [product]?"
- If >40% say "very disappointed" → product-market fit signal
- If <40% → more work needed

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "We already know our customers — we built the product" | Founders' mental model of customers diverges from reality within months of launch. Research is a reset. |
| "5 interviews isn't enough data" | 5-8 interviews reveal 80% of the patterns. 50 interviews don't add proportional insight after the first 8. |
| "Customers won't tell us the real reasons they leave" | With proper interview technique, customers are remarkably candid about why they churned. |
| "We'll do research after we fix the obvious product issues" | Research tells you what the real issues are. "Obvious" issues are often symptoms of deeper causes. |
| "Surveys are faster and cheaper than interviews" | Surveys quantify; they don't explain. You need interviews to know what to survey. |

## Verification

- [ ] Research goal defined before recruiting begins
- [ ] Interview guide written and reviewed
- [ ] 5-8 interviews completed per segment
- [ ] Interviews recorded and transcribed
- [ ] Synthesis completed using the 5-step process (highlight → extract → group → count → write)
- [ ] Insights expressed as patterns (N of M), not as individual anecdotes
- [ ] Win/loss data tracked across at least 20 deals before drawing conclusions
- [ ] ICP definition updated with research findings (firmographic + trigger events)
