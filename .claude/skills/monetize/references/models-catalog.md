# Monetization Models Catalog

## How to Use This Reference
Read this file during the evaluate workflow. For each model, check the "Applicability Signals"
against the discovery context to determine if the model is viable before full scoring.

## Model 1: Open Source + Services
**Definition:** Release the core product as open source (MIT/Apache/GPL). Revenue comes from
paid consulting, implementation support, managed hosting, or training.

**Evaluation Criteria:**
- Market Fit: Does the target market value community/transparency? Are there enterprises who'd pay for support?
- Revenue: Typically $50K-$500K/yr for small teams via services. Scales with headcount, not product.
- Complexity: Low (just open the repo). Services infrastructure (booking, billing) is medium.
- Feasibility: Needs someone technical who can consult. 1-2 person team can start.
- Alignment: Strong if building developer tools or infra. Weak if product is consumer-facing.

**Applicability Signals:** Developer tools, infrastructure, libraries, CLI tools, self-hostable products.
**Red Flags:** Consumer apps, products requiring heavy UX, products with no technical buyer.

## Model 2: Open Core / Freemium
**Definition:** Free tier with limited features or usage. Paid tiers unlock premium features,
higher limits, or team functionality.

**Evaluation Criteria:**
- Market Fit: Works when free tier creates habit/dependency. Needs clear value boundary.
- Revenue: 2-5% conversion typical. $10-$100/mo/user. Can reach $1M+ ARR at scale.
- Complexity: Medium — need feature flagging, billing (Stripe), user management.
- Feasibility: 1-2 devs can build. Needs product sense to draw the free/paid line.
- Alignment: Strong for SaaS products with distinct user tiers.

**Applicability Signals:** Products with natural free/paid boundaries, collaboration tools, analytics.
**Red Flags:** Products where core value can't be meaningfully limited without crippling UX.

## Model 3: SaaS (Subscription Tiers)
**Definition:** Hosted product sold as monthly/annual subscriptions. Multiple tiers
targeting different customer segments (individual, team, enterprise).

**Evaluation Criteria:**
- Market Fit: Standard for B2B. Buyers expect it. Predictable revenue.
- Revenue: $10-$500/mo/seat depending on segment. Enterprise contracts $10K-$100K+/yr.
- Complexity: High — need hosting, auth, billing, onboarding, support infrastructure.
- Feasibility: 2-3 devs minimum for a proper SaaS. Solo possible but stretched.
- Alignment: Strong for any hosted product with recurring value.

**Applicability Signals:** Web apps, hosted tools, products requiring ongoing data/access.
**Red Flags:** One-time-use tools, products that work fine offline.

## Model 4: Marketplace / Platform
**Definition:** Create a platform where third parties transact. Take a percentage cut
(typically 5-30%) of each transaction.

**Evaluation Criteria:**
- Market Fit: Requires two-sided demand. Chicken-and-egg problem to solve.
- Revenue: High ceiling but slow start. 10-30% take rate on GMV.
- Complexity: Very high — need marketplace infrastructure, trust/safety, payments.
- Feasibility: Requires significant investment. Not a solo project.
- Alignment: Strong if product naturally connects buyers and sellers.

**Applicability Signals:** Products connecting service providers and consumers, template/plugin ecosystems.
**Red Flags:** No natural two-sided market, small niche with few participants.

## Model 5: Licensing (Per-Seat, Enterprise)
**Definition:** Sell licenses to use the software — per user, per instance, or as enterprise
site licenses. Can be perpetual or subscription.

**Evaluation Criteria:**
- Market Fit: Enterprise buyers are familiar with this. Works for on-prem/self-hosted.
- Revenue: $100-$10K+/seat/yr for enterprise. Volume depends on market size.
- Complexity: Medium — need license key management, compliance checking.
- Feasibility: Small team can manage. Sales cycle is longer (enterprise sales).
- Alignment: Strong for products enterprises deploy internally.

**Applicability Signals:** Self-hosted products, enterprise tools, compliance-sensitive industries.
**Red Flags:** Consumer products, products with no enterprise buyer.

## Model 6: Sponsorship / Donations / Tips Jar
**Definition:** Revenue from community support — GitHub Sponsors, Buy Me a Coffee,
Open Collective, Patreon. Voluntary contributions.

**Evaluation Criteria:**
- Market Fit: Works for beloved tools with strong community. Not predictable revenue.
- Revenue: Typically $500-$10K/mo for popular projects. Rare to exceed $50K/yr.
- Complexity: Very low — just set up profiles and add badges.
- Feasibility: Anyone can do this. Zero engineering effort.
- Alignment: Supplementary only. Not a primary business model.

**Applicability Signals:** Open source projects with >1K stars, developer tools, community projects.
**Red Flags:** B2B products (companies don't donate), products with no community.

## Model 7: API-as-a-Service
**Definition:** Expose core functionality as a paid API. Charge per call, per unit of
processing, or via tiered plans.

**Evaluation Criteria:**
- Market Fit: Strong if your product has unique data/processing others want to embed.
- Revenue: $0.001-$1/call depending on value. Can be very high margin.
- Complexity: Medium — need API infrastructure, rate limiting, billing, docs.
- Feasibility: 1-2 devs if core logic exists. Mostly wrapping existing functionality.
- Alignment: Strong if product has valuable computation/data. Enables ecosystem.

**Applicability Signals:** AI/ML products, data processing, unique algorithms, products others want to embed.
**Red Flags:** Products where value is in the UI, not the logic. No programmatic use case.

## Model 8: White-Label / Reseller
**Definition:** Allow others to rebrand and resell your product to their customers.
You provide the platform, they provide the brand and customer relationship.

**Evaluation Criteria:**
- Market Fit: Works when channel partners have distribution you don't.
- Revenue: 30-70% of end-user price. Volume through partners.
- Complexity: High — need multi-tenancy, branding customization, partner portal.
- Feasibility: Requires mature product. Not for early stage.
- Alignment: Strong if product is horizontal (applies across industries).

**Applicability Signals:** Horizontal SaaS, industry-agnostic tools, products agencies would resell.
**Red Flags:** Niche products, products tightly coupled to specific workflows.

## Model 9: CaaS (Consulting-as-a-Service)
**Definition:** Productized consulting — standardized packages for implementation,
customization, training, or strategy around your product or domain.

**Evaluation Criteria:**
- Market Fit: Strong when product requires expertise to implement or customize.
- Revenue: $150-$500/hr or $5K-$50K/engagement. Scales with team, not product.
- Complexity: Low tech, high operational. Need scheduling, SOW templates, delivery.
- Feasibility: Solo consultants can start immediately. Revenue from day one.
- Alignment: Strong alongside any product model. Great bootstrap revenue.

**Applicability Signals:** Complex products, enterprise deployments, products in specialized domains.
**Red Flags:** Self-service products that need no guidance, mass-market consumer apps.

## Model 10: PaaS (Platform-as-a-Service)
**Definition:** Provide a platform that others build applications on top of.
Charge for platform usage (compute, storage, API calls).

**Evaluation Criteria:**
- Market Fit: Requires developer ecosystem. Very high lock-in.
- Revenue: Usage-based, high ceiling. Grows with customer success.
- Complexity: Very high — need developer tools, SDKs, docs, sandboxing, metering.
- Feasibility: Large team needed. Not for early stage or small teams.
- Alignment: Only viable if product is inherently extensible/programmable.

**Applicability Signals:** Products with plugin systems, workflow builders, low-code platforms.
**Red Flags:** Simple applications, products with no extensibility.

## Model 11: IaaS (Infrastructure-as-a-Service)
**Definition:** Provide infrastructure (compute, storage, networking) that others
build on. Charge for resource consumption.

**Evaluation Criteria:**
- Market Fit: Commodity market dominated by hyperscalers. Niche plays exist.
- Revenue: Margin thin (10-30%) unless highly specialized. Volume play.
- Complexity: Extremely high — need data centers or cloud provisioning, SLAs, monitoring.
- Feasibility: Not viable for small teams unless wrapping existing infra.
- Alignment: Only if core product IS infrastructure.

**Applicability Signals:** Infrastructure products, specialized compute (GPU, edge), managed databases.
**Red Flags:** Application-layer products, anything not infrastructure.

## Model 12: Pay-as-you-go (Usage-Based)
**Definition:** Charge based on actual usage — API calls, documents processed,
storage consumed, minutes used. No fixed subscription.

**Evaluation Criteria:**
- Market Fit: Fair to users — pay for what you use. Lowers entry barrier.
- Revenue: Aligns revenue with customer value. Can be unpredictable month-to-month.
- Complexity: Medium — need metering, billing, usage dashboards, alerts.
- Feasibility: 1-2 devs can build metering on top of Stripe usage billing.
- Alignment: Strong for variable-usage products. Pairs well with API model.

**Applicability Signals:** AI/ML inference, document processing, data pipelines, communication APIs.
**Red Flags:** Products with flat usage patterns, products where metering adds friction.
